import 'dart:convert';

import 'package:cureeit_user_app/current_address/models/get_coordinates_from_placeId.dart';
import 'package:cureeit_user_app/current_address/models/get_places.dart';
import 'package:cureeit_user_app/current_address/models/place_from_coordinates.dart';
import 'package:cureeit_user_app/utils/constants.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  Future<PlaceFromCoordinates> placeFromCoordinates(
      double lat, double lng) async {
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Constants.gcpKey}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return PlaceFromCoordinates.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Map api error');
    }
  }

  Future<GetPlaces> getPlaces(String placeName) async {
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${Constants.gcpKey}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return GetPlaces.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Get Places api error');
    }
  }

  Future<GetCoordinatesFromPlaceId> getCoordinatesFromPlaceId(
      String placeId) async {
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=${Constants.gcpKey}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return GetCoordinatesFromPlaceId.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Get Places api error');
    }
  }
}
