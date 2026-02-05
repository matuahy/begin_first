class LocationInfo {
  const LocationInfo({
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? placeName;
  final String? address;

  LocationInfo copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
    String? address,
  }) {
    return LocationInfo(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
    );
  }
}
