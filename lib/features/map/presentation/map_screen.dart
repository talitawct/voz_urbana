import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  GoogleMapController? _mapController;
  LatLng _currentLocation = _fallbackLocation;
  List<UrbanReport> _reports = [];
  String? _locationError;
  bool _hasLocationPermission = false;
  bool _isLoadingLocation = true;
  bool _isLoadingReports = true;

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('usuario_atual'),
          position: _currentLocation,
          infoWindow: const InfoWindow(
            title: 'Sua localização',
            snippet: 'Ponto usado para registrar novas denúncias.',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
        ..._reports.map(_reportMarker),
      };

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadReports();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
      );

      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _hasLocationPermission = true;
      });

      await _moveCamera(location);
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
      markerId: MarkerId(
        'denuncia_${report.id ?? report.createdAt.microsecondsSinceEpoch}',
      ),
      position: LatLng(report.latitude, report.longitude),
      infoWindow: InfoWindow(
        title: report.category,
        snippet: 'Status: ${report.status}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _markerHue(report.status),
      ),
    );
  }

  double _markerHue(String status) {
    if (status.toLowerCase() == 'resolvido') {
      return BitmapDescriptor.hueGreen;
    }

    return BitmapDescriptor.hueRed;
  }

  void _setLocationFallback(String message) {
    if (!mounted) return;

    setState(() {
      _currentLocation = _fallbackLocation;
      _locationError = message;
      _hasLocationPermission = false;
    });

    _moveCamera(_fallbackLocation);
  }

  Future<void> _moveCamera(LatLng location) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 15,
        ),
      ),
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
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _moveCamera(_currentLocation);
            },
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
