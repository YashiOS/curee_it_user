import 'package:cureeit_user_app/current_address/api_services.dart';
import 'package:cureeit_user_app/current_address/location_permission_helper.dart';
import 'package:cureeit_user_app/current_address/models/get_places.dart';
import 'package:cureeit_user_app/current_address/models/place_from_coordinates.dart';
import 'package:cureeit_user_app/screens/add_address_screen.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _mapController;
  TextEditingController searchPlaceController = TextEditingController();
  GetPlaces getPlaces = GetPlaces();
  // double defaultLat = 27.6008427;
  // double defaultLng = 75.1431501;
  double defaultLat = 26.9124;
  double defaultLng = 75.7873;
  PlaceFromCoordinates placeFromCoordinates = PlaceFromCoordinates();
  bool isLoading = true;

  void _changeCameraPosition(double lat, double lng) {
    CameraPosition newPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 15.0, // Zoom level
    );

    // Animate the camera to the new position
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(newPosition));
  }

  getAddress() {
    ApiServices().placeFromCoordinates(defaultLat, defaultLng).then((value) {
      setState(() {
        defaultLat = value.results?[0].geometry?.location?.lat ?? 0.0;
        defaultLng = value.results?[0].geometry?.location?.lng ?? 0.0;
        placeFromCoordinates = value;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    determinePosition().then((value) {
      defaultLat = value.latitude;
      defaultLng = value.longitude;
    });
    getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Current Location",
          style: TextStyle(
              color: primaryColor,
              fontFamily: "JosefinSans",
              fontWeight: FontWeight.w400),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            )
          : Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(defaultLat, defaultLng),
                      zoom: 14.4746,
                    ),
                    onCameraIdle: () {
                      ApiServices()
                          .placeFromCoordinates(defaultLat, defaultLng)
                          .then((value) {
                        setState(() {
                          defaultLat =
                              value.results?[0].geometry?.location?.lat ?? 0.0;
                          defaultLng =
                              value.results?[0].geometry?.location?.lng ?? 0.0;
                          placeFromCoordinates = value;
                          isLoading = false;
                          print(defaultLat);
                        });
                      });
                    },
                    onCameraMove: (CameraPosition position) {
                      setState(() {
                        defaultLat = position.target.latitude;
                        defaultLng = position.target.longitude;
                      });
                    },
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.location_on,
                    size: 36,
                    color: primaryColor,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 18),
                              child: TextField(
                                controller: searchPlaceController,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Urbanist",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    helperStyle: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Urbanist",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    hintText: "Search ...",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "Urbanist",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    fillColor: Colors.white,
                                    iconColor: secondaryColor),
                                onChanged: (String value) {
                                  print(value.toString());
                                  ApiServices()
                                      .getPlaces(value.toString())
                                      .then((value) {
                                    setState(() {
                                      getPlaces = value;
                                    });
                                  });
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: searchPlaceController.text.isEmpty
                                ? false
                                : true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 18),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: ListView.builder(
                                          itemCount:
                                              getPlaces.predictions?.length ??
                                                  0,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () {
                                                ApiServices()
                                                    .getCoordinatesFromPlaceId(
                                                        getPlaces
                                                                .predictions?[
                                                                    index]
                                                                .placeId ??
                                                            "")
                                                    .then((value) {
                                                  setState(() {
                                                    defaultLat = value
                                                            .result
                                                            ?.geometry
                                                            ?.location
                                                            ?.lat ??
                                                        0.0;
                                                    defaultLng = value
                                                            .result
                                                            ?.geometry
                                                            ?.location
                                                            ?.lng ??
                                                        0.0;
                                                    searchPlaceController
                                                        .clear();
                                                    getAddress();
                                                    _changeCameraPosition(
                                                        defaultLat, defaultLng);
                                                  });
                                                }).onError((error, stackTrace) {
                                                  print(
                                                      "Error in get Coordinates");
                                                });
                                              },
                                              leading: Icon(
                                                Icons.location_on_outlined,
                                                color: secondaryColor,
                                              ),
                                              title: Text(getPlaces
                                                  .predictions![index]
                                                  .description
                                                  .toString()),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Visibility(
                        visible:
                            searchPlaceController.text.isEmpty ? true : false,
                        child: Column(
                          spacing: 8,
                          children: [
                            GestureDetector(
                              onTap: () {
                                determinePosition().then((value) {
                                  setState(() {
                                    defaultLat = value.latitude;
                                    defaultLng = value.longitude;
                                    print(defaultLat);
                                    getAddress();
                                    _changeCameraPosition(
                                        defaultLat, defaultLng);
                                  });
                                }).onError((error, stackTrace) {
                                  print("Location Error $error");
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 6,
                                  children: [
                                    Icon(
                                      Icons.my_location,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Current Location",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Urbanist",
                                          // fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Row(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                    child: Text(
                                      placeFromCoordinates
                                              .results?[0].formattedAddress ??
                                          "Loading...",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontFamily: "Urbanist",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      builder: (context) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.6,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context).viewInsets.bottom,
                                            ),
                                            child: AddAddressScreen(
                                              userId: "68fa72cbdc5f0a68",
                                              userLat: defaultLat,
                                              userLong: defaultLng,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: secondaryColor.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: primaryColor,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
