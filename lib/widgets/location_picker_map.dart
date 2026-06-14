import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerMap extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const LocationPickerMap({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  // Default coordinate for Manisharjo (just a placeholder, adjust to actual default village coordinate if known)
  // E.g. somewhere in Boyolali / Karanganyar
  final LatLng _defaultLocation = const LatLng(-7.5, 111.0); 

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation ?? _defaultLocation,
                initialZoom: _selectedLocation != null ? 18.0 : 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                  widget.onLocationSelected(point);
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.manisharjo_smart_address',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            // Floating instructions / reset button
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Color(0xFF0F4C81)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tap pada peta untuk menentukan lokasi rumah',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F4C81)),
                      ),
                    ),
                    if (_selectedLocation != null)
                      IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xFF0F4C81)),
                        tooltip: 'Pusatkan ke pin',
                        onPressed: () {
                          _mapController.move(_selectedLocation!, 18.0);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
