import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nestle_waters_purelife/core/services/map/map_api_services.dart';
import 'package:nestle_waters_purelife/core/services/map/models/place_from_coordinates.dart';


class GoogleMapsScreen extends StatefulWidget {
  final double lat, lng;
  const GoogleMapsScreen({super.key, required this.lat, required this.lng});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {

  double defaultLat = 0.0;
  double defaultLng = 0.0;
  PlaceFromCoordinates placeFromCoordinates = PlaceFromCoordinates();
  bool isLoading = true;


  getAddress () {
    ApiServices().placeFromCoordinates(widget.lat, widget.lng).then((value){
      setState(() {
        defaultLat = value.results?[0].geometry?.location?.lat??0.0;
        defaultLng = value.results?[0].geometry?.location?.lng??0.0;
        placeFromCoordinates = value;
        print('Current Address: ${value.results?[0].formattedAddress}');
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    print("latiti: ${widget.lat} |||||||||| lnggg: ${widget.lng}");
    super.initState();
    getAddress ();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text("Current Address"),
      ),

      body: isLoading? const Center(child: CircularProgressIndicator(),):
      Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            minMaxZoomPreference: const MinMaxZoomPreference(12, 20),
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.lat, widget.lng), zoom: 14.4746,
            ),
            onCameraIdle: (){
              ApiServices().placeFromCoordinates(defaultLat, defaultLng).then((value){
                setState(() {
                  defaultLat = value.results?[0].geometry?.location?.lat??0.0;
                  defaultLng = value.results?[0].geometry?.location?.lng??0.0;
                  placeFromCoordinates = value;
                  print('Current Address: ${value.results?[0].formattedAddress}');
                });
              });
            },
            onCameraMove: (CameraPosition position){
              print('lat: ${position.target.latitude} || lng: ${position.target.longitude}');
              setState(() {
                defaultLat = position.target.latitude;
                defaultLng = position.target.longitude;
              });
            },
          ),
          const Center(child: Icon(Icons.location_on, size: 50, color: Colors.redAccent,),)
        ],
      ),
      
      
      bottomSheet: Container(
        color: Colors.green[100],
        padding: const EdgeInsets.only(top: 10, bottom: 30, left: 20, right: 20),
        child:  Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(3.0),
              child: Icon(Icons.location_on),
            ),
            Expanded(child: Text(placeFromCoordinates.results?[0].formattedAddress??"Loading...", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),))
          ],
        ),
      ),
    );
  }
}
