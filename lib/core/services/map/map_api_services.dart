import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nestle_waters_purelife/core/services/map/map_constants.dart';
import 'package:nestle_waters_purelife/core/services/map/models/get_coordinates_from_placeId.dart';
import 'package:nestle_waters_purelife/core/services/map/models/get_places.dart';
import 'models/place_from_coordinates.dart';

class ApiServices {


  Future<PlaceFromCoordinates> placeFromCoordinates (double lat, double lng) async{
    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${Constants.gcpKey}');
    var response = await http.get(url);

    if(response.statusCode == 200){
      return PlaceFromCoordinates.fromJson(jsonDecode(response.body));
    }else {
      throw Exception('API ERROR: placeFromCoordinates');
    }
  }


  Future<GetPlaces> getPlaces (String placeName) async{
    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${Constants.gcpKey}');
    var response = await http.get(url);

    if(response.statusCode == 200){
      return GetPlaces.fromJson(jsonDecode(response.body));
    }else {
      throw Exception('API ERROR: getPlaces');
    }
  }


  Future<GetCoordinatesFromPlaceId> getCoordinatesFromPlaceId (String placeId) async{
    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=${Constants.gcpKey}');
    var response = await http.get(url);

    if(response.statusCode == 200){
      return GetCoordinatesFromPlaceId.fromJson(jsonDecode(response.body));
    }else {
      throw Exception('API ERROR: getPlaces');
    }
  }

}