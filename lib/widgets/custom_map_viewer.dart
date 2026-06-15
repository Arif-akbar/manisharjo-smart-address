import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapViewer extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String markerLabel;
  final double height;

  const CustomMapViewer({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.markerLabel,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final location = LatLng(latitude, longitude);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: location,
            initialZoom: 16.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.manisharjo.smart_address',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 120,
                  height: 60,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Text(
                          markerLabel,
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFEF4444),
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
