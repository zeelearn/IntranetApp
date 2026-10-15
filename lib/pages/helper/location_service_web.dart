import 'dart:async';
import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'utils.dart';

class LocationServiceImpl {
  static Future<LocationData?> getLocation(BuildContext? context) async {
    final location = Location();

    // 1. Check current browser permission state upfront
    final initialState = await _getBrowserPermissionState();
    debugPrint("LocationServiceImpl [Web]: Initial permission state: $initialState");

    if (initialState == 'denied') {
      _showMessage(
        context,
        "Location permission is blocked. Please enable it from browser settings.",
      );
      return null;
    }

    try {
      debugPrint("LocationServiceImpl [Web]: Calling location.getLocation() with 5s timeout...");

      final locationData = await location.getLocation().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint("LocationServiceImpl [Web]: Browser geolocation timed out after 5s.");
          throw TimeoutException("Browser geolocation timed out.");
        },
      );

      if (locationData.latitude != null && locationData.longitude != null) {
        debugPrint("LocationServiceImpl [Web]: Got browser location: ${locationData.latitude}, ${locationData.longitude}");
        return locationData;
      }
    } on TimeoutException {
      // Check if user clicked 'Allow' or ignored/dismissed the prompt
      final stateAfterTimeout = await _getBrowserPermissionState();
      debugPrint("LocationServiceImpl [Web]: Permission state after timeout: $stateAfterTimeout");

      if (stateAfterTimeout == 'prompt') {
        _showMessage(
          context,
          "Please allow location permission in the browser prompt.",
        );
        return null;
      } else if (stateAfterTimeout == 'denied') {
        _showMessage(
          context,
          "Location permission was denied. Please allow location in browser settings.",
        );
        return null;
      }

      // Permission was granted, but GPS/Wi-Fi couldn't acquire coordinates -> Fallback to IP
      debugPrint("LocationServiceImpl [Web]: Permission GRANTED, falling back to IP...");
      return await _handleIpFallbackWithConfirmation(context);
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      debugPrint("LocationServiceImpl [Web]: Error during getLocation: $e");

      if (errStr.contains('denied') || errStr.contains('permission')) {
        _showMessage(
          context,
          "Location permission was denied. Please allow location in browser settings.",
        );
        return null;
      }

      final stateAfterError = await _getBrowserPermissionState();
      if (stateAfterError == 'granted' || stateAfterError == 'unknown') {
        debugPrint("LocationServiceImpl [Web]: Position unavailable ($e). Falling back to IP...");
        return await _handleIpFallbackWithConfirmation(context);
      } else {
        _showMessage(
          context,
          "Location permission is required. Please allow location in browser settings.",
        );
        return null;
      }
    }

    _showMessage(
      context,
      "Unable to determine location. Please check your network connection.",
    );
    return null;
  }

  /// Handles fetching IP location, resolving full reverse-geocoded address, and displaying confirmation dialog
  static Future<LocationData?> _handleIpFallbackWithConfirmation(
    BuildContext? context,
  ) async {
    final ipResult = await _getLocationFromIP();
    if (ipResult == null) {
      _showMessage(
        context,
        "Unable to determine location via GPS or network IP.",
      );
      return null;
    }

    // Resolve full reverse-geocoded address
    String fullAddress = '';
    try {
      final lat = ipResult.locationData.latitude;
      final lng = ipResult.locationData.longitude;
      if (lat != null && lng != null) {
        final address = await Utility.getAddress(lat, lng);
        if (address != null && address.trim().isNotEmpty) {
          fullAddress = address.trim();
        }
      }
    } catch (e) {
      debugPrint("Error fetching reverse geocoded address: $e");
    }

    if (fullAddress.isEmpty) {
      fullAddress = ipResult.displayName;
    }

    // If context is available, ask the user to confirm the IP-based location
    if (context != null && context.mounted) {
      return await _showIpConfirmationDialog(context, ipResult, fullAddress);
    }

    return ipResult.locationData;
  }

  /// Shows confirmation dialog with full address, Confirm, Retry, and Cancel buttons
  static Future<LocationData?> _showIpConfirmationDialog(
    BuildContext context,
    _IpLocationResult ipResult,
    String fullAddress,
  ) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Confirm Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your exact GPS location could not be determined. We detected your estimated location via your network/IP address:",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Full Address:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fullAddress.isNotEmpty ? fullAddress : "Address not available",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const Divider(height: 16),
                      Text(
                        "Coordinates: ${ipResult.locationData.latitude?.toStringAsFixed(4)}, ${ipResult.locationData.longitude?.toStringAsFixed(4)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Is this location correct?",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'retry'),
              child: const Text(
                "Retry",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (result == 'confirm') {
      return ipResult.locationData;
    } else if (result == 'retry') {
      return await getLocation(context);
    } else {
      return null;
    }
  }

  /// Checks the browser's native permission state: 'granted', 'prompt', or 'denied'
  static Future<String> _getBrowserPermissionState() async {
    try {
      final permissions = html.window.navigator.permissions;
      if (permissions != null) {
        final status = await permissions.query({'name': 'geolocation'});
        return status.state ?? 'unknown';
      }
    } catch (e) {
      debugPrint("LocationServiceImpl [Web]: Permission query not supported or failed: $e");
    }
    return 'unknown';
  }

  /// IP Geolocation Fallback using CORS-friendly HTTPS endpoints
  static Future<_IpLocationResult?> _getLocationFromIP() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );

    final urls = [
      'https://ipwho.is/',
      'https://ipapi.co/json/',
    ];

    for (final url in urls) {
      try {
        debugPrint("LocationServiceImpl [Web]: Trying IP geolocation endpoint: $url");
        final response = await dio.get(url);

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final lat = (data['latitude'] as num?)?.toDouble();
          final lng = (data['longitude'] as num?)?.toDouble();
          final city = data['city']?.toString() ?? '';
          final region = (data['region'] ?? data['region_name'])?.toString() ?? '';
          final postal = (data['postal'] ?? data['postal_code'] ?? data['zip'])?.toString() ?? '';
          final country = (data['country'] ?? data['country_name'])?.toString() ?? '';
          final ip = data['ip']?.toString() ?? '';

          if (lat != null && lng != null) {
            debugPrint("LocationServiceImpl [Web]: Successfully obtained IP location: $lat, $lng from $url");
            final locData = LocationData.fromMap({
              'latitude': lat,
              'longitude': lng,
              'accuracy': 1000.0, // approximate accuracy for IP
              'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
            });

            return _IpLocationResult(
              locationData: locData,
              city: city,
              region: region,
              postal: postal,
              country: country,
              ip: ip,
            );
          }
        }
      } catch (e) {
        debugPrint("LocationServiceImpl [Web]: Failed on $url: $e");
      }
    }
    return null;
  }

  static void _showMessage(BuildContext? context, String message) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }
}

class _IpLocationResult {
  final LocationData locationData;
  final String city;
  final String region;
  final String postal;
  final String country;
  final String ip;

  _IpLocationResult({
    required this.locationData,
    required this.city,
    required this.region,
    required this.postal,
    required this.country,
    required this.ip,
  });

  String get displayName {
    final regionAndPostal = [region, postal].where((s) => s.isNotEmpty).join(' - ');
    final parts = [city, regionAndPostal, country].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(", ") : "";
  }
}
