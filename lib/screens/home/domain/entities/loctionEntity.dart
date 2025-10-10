class LocationEntity {
  final double latitude;
  final double longitude;
  final bool isInRadius;

  LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.isInRadius,
  });
}
