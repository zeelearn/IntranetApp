import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// In-app map for a single CVF visit (planned + check-in/out pins).
class CvfLocationMapScreen extends StatefulWidget {
  const CvfLocationMapScreen({super.key, required this.cvf});

  final GetDetailedPJP cvf;

  @override
  State<CvfLocationMapScreen> createState() => _CvfLocationMapScreenState();
}

class _CvfLocationMapScreenState extends State<CvfLocationMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  void _buildMarkers() {
    final cvf = widget.cvf;
    final title = cvf.ActivityTitle.isNotEmpty && cvf.ActivityTitle != 'NA'
        ? cvf.ActivityTitle
        : cvf.franchiseeName;

    if (cvf.Latitude != 0 || cvf.Longitude != 0) {
      _markers.add(
        Marker(
          markerId: MarkerId('planned_${cvf.PJPCVF_Id}'),
          position: LatLng(cvf.Latitude, cvf.Longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: 'Planned: $title', snippet: cvf.Address),
        ),
      );
    }

    if (cvf.LatitudeIn != 0 || cvf.LongitudeIn != 0) {
      _markers.add(
        Marker(
          markerId: MarkerId('checkin_${cvf.PJPCVF_Id}'),
          position: LatLng(cvf.LatitudeIn, cvf.LongitudeIn),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Check In',
            snippet: cvf.CheckInAddress.isNotEmpty ? cvf.CheckInAddress : null,
          ),
        ),
      );
    }

    if (cvf.LatitudeOut != 0 || cvf.LongitudeOut != 0) {
      _markers.add(
        Marker(
          markerId: MarkerId('checkout_${cvf.PJPCVF_Id}'),
          position: LatLng(cvf.LatitudeOut, cvf.LongitudeOut),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Check Out',
            snippet: cvf.CheckOutAddress.isNotEmpty ? cvf.CheckOutAddress : null,
          ),
        ),
      );
    }
  }

  LatLng get _initialPosition {
    if (_markers.isNotEmpty) return _markers.first.position;
    final cvf = widget.cvf;
    if (cvf.Latitude != 0 || cvf.Longitude != 0) {
      return LatLng(cvf.Latitude, cvf.Longitude);
    }
    return const LatLng(20.5937, 78.9629);
  }

  void _fitBounds() {
    if (_mapController == null || _markers.isEmpty) return;
    if (_markers.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_markers.first.position, 14),
      );
      return;
    }
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final m in _markers) {
      minLat = minLat < m.position.latitude ? minLat : m.position.latitude;
      maxLat = maxLat > m.position.latitude ? maxLat : m.position.latitude;
      minLng = minLng < m.position.longitude ? minLng : m.position.longitude;
      maxLng = maxLng > m.position.longitude ? maxLng : m.position.longitude;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        64,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cvf = widget.cvf;
    final displayTitle = cvf.ActivityTitle.isNotEmpty && cvf.ActivityTitle != 'NA'
        ? cvf.ActivityTitle
        : cvf.franchiseeName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryLightColor,
        foregroundColor: Colors.white,
        title: Text(
          displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          if (cvf.CheckInAddress.isNotEmpty)
            Container(
              width: double.infinity,
              color: kPrimaryTEXTBGColor,
              padding: const EdgeInsets.all(12),
              child: Text(
                cvf.CheckInAddress,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14,
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
              },
            ),
          ),
          if (_markers.length > 1)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(BitmapDescriptor.hueAzure, 'Planned'),
                  const SizedBox(width: 16),
                  _legendDot(BitmapDescriptor.hueGreen, 'Check In'),
                  const SizedBox(width: 16),
                  _legendDot(BitmapDescriptor.hueOrange, 'Check Out'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendDot(double hue, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: _hueColor(hue), size: 18),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _hueColor(double hue) {
    if (hue == BitmapDescriptor.hueGreen) return Colors.green;
    if (hue == BitmapDescriptor.hueOrange) return Colors.orange;
    return kPrimaryLightColor;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

void openCvfLocationMap(BuildContext context, GetDetailedPJP cvf) {
  final hasLocation = (cvf.Latitude != 0 || cvf.Longitude != 0) ||
      (cvf.LatitudeIn != 0 || cvf.LongitudeIn != 0) ||
      (cvf.LatitudeOut != 0 || cvf.LongitudeOut != 0);
  if (!hasLocation) {
    Utility.showMessage(context, 'Location not available for this visit');
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CvfLocationMapScreen(cvf: cvf)),
  );
}
