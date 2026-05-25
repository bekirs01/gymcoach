class MapBounds {
  const MapBounds({
    required this.southWestLat,
    required this.southWestLng,
    required this.northEastLat,
    required this.northEastLng,
  });

  final double southWestLat;
  final double southWestLng;
  final double northEastLat;
  final double northEastLng;

  Map<String, dynamic> toQueryParams() => {
        'p_min_lat': southWestLat,
        'p_min_lng': southWestLng,
        'p_max_lat': northEastLat,
        'p_max_lng': northEastLng,
      };

  Map<String, dynamic> toRpcParams() => toQueryParams();
}
