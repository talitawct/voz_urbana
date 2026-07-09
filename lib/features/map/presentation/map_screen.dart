import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng _currentLocation = _fallbackLocation;
  List<UrbanReport> _reports = [];
  String? _locationError;
  bool _isLoadingLocation = true;
  bool _isLoadingReports = true;
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

  void _setLocationFallback(String message) {
    if (!mounted) return;

    setState(() {
      _currentLocation = _fallbackLocation;
      _locationError = message;
    });

    _moveCamera(_fallbackLocation);
  }

  void _moveCamera(LatLng location) {
    if (!_isMapReady) return;

    _mapController.move(location, 15);
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
              decoration: InputDecoration(
                hintText: 'Pesquisar localidade...',
                prefixIcon: const Icon(Icons.search),
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
