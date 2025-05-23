import 'package:cureeit_user_app/current_address/api_services.dart';
import 'package:cureeit_user_app/current_address/location_permission_helper.dart';
import 'package:cureeit_user_app/current_address/map_style.dart';
import 'package:cureeit_user_app/current_address/models/get_places.dart';
import 'package:cureeit_user_app/current_address/models/place_from_coordinates.dart';
import 'package:cureeit_user_app/screens/add_address_screen.dart';
import 'package:cureeit_user_app/selected_Address/currentAddress.dart';
import 'package:cureeit_user_app/user/user.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  GoogleMapController? _mapController;
  bool currentLocationFething = false;
  TextEditingController searchPlaceController = TextEditingController();
  GetPlaces getPlaces = GetPlaces();
  // double defaultLat = 27.6008427;
  // double defaultLng = 75.1431501;
  double defaultLat = 26.9124;
  double defaultLng = 75.7873;
  PlaceFromCoordinates placeFromCoordinates = PlaceFromCoordinates();
  bool isLoading = true;
  late String mapDarkStyle;

  void _changeCameraPosition(double lat, double lng) {
    CameraPosition newPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 18, // Zoom level
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

        currentLocationFething = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    determinePosition().then((value) {
      setState(() {
        defaultLat = value.latitude;
        defaultLng = value.longitude;

        getAddress();
        _changeCameraPosition(defaultLat, defaultLng);
      });
    }).onError((error, stackTrace) {
      print("Location Error $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBlackColor,
      appBar: AppBar(
        backgroundColor: scaffoldBlackColor,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        title: Text(
          "Current Location",
          style: GoogleFonts.mulish(
              color: whiteColor, fontSize: 22.69, fontWeight: FontWeight.w400),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                spacing: 4,
                children: [
                  SvgPicture.asset(
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    "lib/images/back.svg",
                    width: 24, // optional
                    height: 24, // optional
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: whiteColor,
              ),
            )
          : Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: GoogleMap(
                    style: darkMapStyle,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(defaultLat, defaultLng),
                      zoom: 18,
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
                  child: Container(
                      height: 35,
                      width: 35,
                      child: Image.asset(
                        "lib/images/location.png",
                      )),
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
                                  color: ligtBlackColor,
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 18),
                              child: TextField(
                                controller: searchPlaceController,
                                cursorColor: greenColor,
                                style: GoogleFonts.mulish(
                                    color: whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    helperStyle: GoogleFonts.mulish(
                                        color: whiteColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    hintText: "Search ...",
                                    hintStyle: GoogleFonts.mulish(
                                        color: Colors.grey,
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
                                height: 300,
                                decoration: BoxDecoration(
                                    color: ligtBlackColor,
                                    borderRadius: BorderRadius.circular(8)),
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
                                                color: whiteColor,
                                              ),
                                              title: Text(
                                                getPlaces.predictions![index]
                                                    .description
                                                    .toString(),
                                                style: GoogleFonts.mulish(
                                                    color: whiteColor),
                                              ),
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
                                setState(() {
                                  currentLocationFething = true;
                                });

                                determinePosition().then((value) {
                                  setState(() {
                                    defaultLat = value.latitude;
                                    defaultLng = value.longitude;

                                    getAddress();
                                    _changeCameraPosition(
                                        defaultLat, defaultLng);
                                  });
                                }).onError((error, stackTrace) {
                                  print("Location Error $error");
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.02),
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                    color: greenColor,
                                    borderRadius: BorderRadius.circular(8)),
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
                                      style: GoogleFonts.mulish(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.016,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: ligtBlackColor,
                                  border: currentLocationFething
                                      ? Border(
                                          top: BorderSide(
                                              color: greenColor, width: 2),
                                        )
                                      : Border.all(
                                          width: 0, color: Colors.transparent)),
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
                                      style: GoogleFonts.mulish(
                                          color: whiteColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      print(defaultLat);
                                      print(defaultLng);
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (context) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child: AddAddressScreen(
                                              userId: User.userId!,
                                              userLat: defaultLat,
                                              userLong: defaultLng,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.check_circle,
                                      color: greenColor,
                                      size: 48,
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
