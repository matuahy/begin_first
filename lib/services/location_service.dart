import 'dart:io';

import 'package:begin_first/domain/models/location_info.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class LocationService {
  Future<LocationInfo?> getCurrentLocation();
  Future<bool> hasLocationPermission();
  Future<bool> requestLocationPermission();
  Future<String?> getAddressFromCoordinates(double lat, double lng);
  Future<void> openInMaps(double lat, double lng, String? label);
}

class LocationServiceImpl implements LocationService {
  @override
  Future<LocationInfo?> getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    return _buildLocationInfo(position.latitude, position.longitude);
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isEmpty) {
      return null;
    }
    final place = placemarks.first;
    return _formatAddress(place);
  }

  @override
  Future<void> openInMaps(double lat, double lng, String? label) async {
    final encodedLabel = label == null ? '' : Uri.encodeComponent(label);
    final uri = Platform.isIOS
        ? Uri.parse('http://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel')
        : Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch maps');
    }
  }

  Future<LocationInfo> _buildLocationInfo(double lat, double lng) async {
    String? placeName;
    String? address;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        placeName = place.name;
        address = _formatAddress(place);
      }
    } catch (_) {
      address = null;
    }

    return LocationInfo(
      latitude: lat,
      longitude: lng,
      placeName: placeName,
      address: address,
    );
  }

  String _formatAddress(Placemark place) {
    final parts = <String?>[
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ];
    return parts
        .where((part) => part != null && part.trim().isNotEmpty)
        .join(', ');
  }
}
