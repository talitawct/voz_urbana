import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/reports/report_repository.dart';
import '../../../core/reports/urban_report.dart';
import '../../settings/presentation/settings_screen.dart';

class MapScreen extends StatefulWidget {
  final Function(bool) onToggleTheme;

  const MapScreen({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _fallbackLocation = LatLng(-12.9777, -38.5016);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentLocation = _fallbackLocation;
  LatLng? _searchedLocation;
  String? _searchedLocationLabel;
  List<UrbanReport> _reports = [];
  String? _locationError;
  bool _isLoadingLocation = true;
  bool _isLoadingReports = true;
  bool _isSearching = false;
  bool _isMapReady = false;

  List<Marker> get _markers => [
        Marker(
          point: _currentLocation,
          width: 44,
          height: 44,
          child: const Tooltip(
            message:
                'Sua localização\nPonto usado para registrar novas denúncias.',
            child: Icon(
              Icons.my_location,
              color: Color(0xFF0033A0),
              size: 34,
            ),
          ),
        ),
        if (_searchedLocation != null)
          Marker(
            point: _searchedLocation!,
            width: 48,
            height: 48,
            child: Tooltip(
              message: _searchedLocationLabel ?? 'Local pesquisado',
              child: const Icon(
                Icons.place,
                color: Color(0xFFFFC107),
                size: 42,
              ),
            ),
          ),
        ..._reports.map(_reportMarker),
      ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadReports();
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              onThemeToggle: widget.onToggleTheme,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        );
        break;

      case 'logout':
        AuthService.signOut();
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationFallback(
          'GPS desativado. O mapa abriu em Salvador como localização padrão.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setLocationFallback(
          'Permissão de localização negada. O mapa abriu em Salvador como referência.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationFallback(
          'Permissão de localização bloqueada. Libere o acesso nas configurações do app.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() {
        _currentLocation = location;
      });

      _moveCamera(location);
    } catch (_) {
      _setLocationFallback(
        'Não foi possível obter sua localização. O mapa abriu em Salvador como referência.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoadingReports = true;
    });

    try {
      final reports = await ReportRepository.findAll();

      if (!mounted) return;

      setState(() {
        _reports = reports;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar as denúncias no mapa.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReports = false;
        });
      }
    }
  }

  Future<void> _searchPlace(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.length < 3) {
      _showSnackBar('Digite pelo menos 3 caracteres para pesquisar.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
    });

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'jsonv2',
        'q': query,
        'countrycodes': 'br',
        'limit': '1',
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Accept-Language': 'pt-BR,pt;q=0.9',
          'User-Agent':
              'VozUrbana/1.0 (academic project; contact: talitawct3@gmail.com)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _showSnackBar('Não foi possível pesquisar agora. Tente novamente.');
        return;
      }

      final results = jsonDecode(response.body);
      if (results is! List || results.isEmpty) {
        _showSnackBar('Nenhum local encontrado para "$query".');
        return;
      }

      final firstResult = results.first;
      if (firstResult is! Map<String, dynamic>) {
        _showSnackBar('Resultado de busca inválido.');
        return;
      }

      final latitude = double.tryParse(firstResult['lat']?.toString() ?? '');
      final longitude = double.tryParse(firstResult['lon']?.toString() ?? '');
      if (latitude == null || longitude == null) {
        _showSnackBar('Resultado de busca sem coordenadas.');
        return;
      }

      final location = LatLng(latitude, longitude);
      final label = firstResult['display_name']?.toString() ?? query;

      if (!mounted) return;

      setState(() {
        _searchedLocation = location;
        _searchedLocationLabel = label;
      });

      _moveCamera(location, zoom: 16);
      _showSnackBar('Local encontrado: ${_shortPlaceName(label)}');
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Erro ao pesquisar local. Verifique sua conexão.');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Marker _reportMarker(UrbanReport report) {
    return Marker(
      point: LatLng(report.latitude, report.longitude),
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => _showReportMarkerDetails(report),
        child: Tooltip(
          message:
              '${report.category}\n${report.status} - ${_formatDate(report.createdAt)} - ${_shortDescription(report)}',
          child: Icon(
            Icons.location_on,
            color: _markerColor(report.status),
            size: 42,
          ),
        ),
      ),
    );
  }

  Color _markerColor(String status) {
    if (status.toLowerCase() == 'resolvido') {
      return const Color(0xFF2E7D32);
    }

    return const Color(0xFFD32F2F);
  }

  void _showReportMarkerDetails(UrbanReport report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${report.category} - ${report.status} - ${_formatDate(report.createdAt)}',
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }

  String _shortDescription(UrbanReport report) {
    if (report.description.trim().isEmpty) {
      return 'Sem descrição';
    }

    final description = report.description.trim();
    if (description.length <= 36) return description;

    return '${description.substring(0, 33)}...';
  }

  String _shortPlaceName(String placeName) {
    final parts = placeName.split(',');
    if (parts.length <= 2) return placeName;

    return '${parts[0].trim()}, ${parts[1].trim()}';
  }

  void _setLocationFallback(String message) {
    if (!mounted) return;

    setState(() {
      _currentLocation = _fallbackLocation;
      _locationError = message;
    });

    _moveCamera(_fallbackLocation);
  }

  void _moveCamera(LatLng location, {double zoom = 15}) {
    if (!_isMapReady) return;

    _mapController.move(location, zoom);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mapa de Ocorrências'),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'settings',
                child: Text('Configurações'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Sair'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 14,
              minZoom: 4,
              maxZoom: 18,
              onMapReady: () {
                _isMapReady = true;
                _moveCamera(_currentLocation);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'voz_urbana',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  '(c) OpenStreetMap contributors',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: TextField(
              controller: _searchController,
              enabled: !_isSearching,
              textInputAction: TextInputAction.search,
              onSubmitted: _searchPlace,
              decoration: InputDecoration(
                hintText: 'Pesquisar localidade...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Pesquisar',
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _searchPlace(_searchController.text),
                      ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          if (_locationError != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 86,
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _locationError!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'atualizar_denuncias_mapa',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0033A0),
                  onPressed: _isLoadingReports ? null : _loadReports,
                  child: _isLoadingReports
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'centralizar_mapa',
                  backgroundColor: const Color(0xFF0033A0),
                  foregroundColor: Colors.white,
                  onPressed: _isLoadingLocation ? null : _loadCurrentLocation,
                  child: _isLoadingLocation
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          if (_reports.isEmpty && !_isLoadingReports)
            Positioned(
              left: 16,
              right: 96,
              bottom: 24,
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Nenhuma denúncia salva para exibir no mapa.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
