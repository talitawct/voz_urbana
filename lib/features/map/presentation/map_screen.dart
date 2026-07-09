import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/auth/auth_service.dart';
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
  String? _locationError;
  bool _hasLocationPermission = false;
  bool _isLoadingLocation = true;

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
        const Marker(
          markerId: MarkerId('buraco_av_principal'),
          position: LatLng(-12.9813, -38.5108),
          infoWindow: InfoWindow(
            title: 'Buraco na Av. Principal',
            snippet: 'Status: Urgente (Pendente)',
          ),
        ),
        Marker(
          markerId: const MarkerId('poste_rua_4'),
          position: const LatLng(-12.9737, -38.4972),
          infoWindow: const InfoWindow(
            title: 'Poste sem luz na Rua 4',
            snippet: 'Status: Resolvido',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      };

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
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
            child: FloatingActionButton(
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
          ),
        ],
      ),
    );
  }
}
