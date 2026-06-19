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
    }).onError((error, stackTrace) {
      print("Get Address Error $error");
      setState(() {
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

print(value.latitude);
print(value.longitude);
        getAddress();
        _changeCameraPosition(defaultLat, defaultLng);
      });
    }).onError((error, stackTrace) {
      print("Location Error $error");
      getAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  scaffoldWhiteColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
            elevation: 0,
        backgroundColor:  scaffoldWhiteColor,
        centerTitle: true,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        title: Text(
          "Select Location",
          style: GoogleFonts.mulish(
              color: blackColor, fontSize: 22.69, fontWeight: FontWeight.w400),
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
                        ColorFilter.mode(blackColor, BlendMode.srcIn),
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
                color: blackColor,
              ),
            )
          : Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: GoogleMap(
                    style: LightMapStyle,
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
                // Add this widget just above the Center widget that contains your pin
                // Add this to your Stack children (replace your current Positioned widgets)
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.44 +
                      25, // 25 is half of pin height
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: lightWhiteColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Order will be delivered here",
                              style: GoogleFonts.mulish(
                                color: blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Place the pin to your exact location",
                              style: GoogleFonts.mulish(
                                color: blackColor,
                                fontSize: 12.6,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      CustomPaint(
                        painter: TrianglePainter(
                          color: lightWhiteColor,
                        ),
                        size: Size(20, 10),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: Container(
                      height: 35,
                      width: 35,
                      child: Image.asset(
                        "lib/images/location1.png",
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
                                  color: lightWhiteColor,
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 18),
                              child: TextField(
                                controller: searchPlaceController,
                                cursorColor: greenColor,
                                style: GoogleFonts.mulish(
                                    color: blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    helperStyle: GoogleFonts.mulish(
                                        color: blackColor,
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
                                    color: lightWhiteColor,
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
                                                color: blackColor,
                                              ),
                                              title: Text(
                                                getPlaces.predictions![index]
                                                    .description
                                                    .toString(),
                                                style: GoogleFonts.mulish(
                                                    color: blackColor),
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
                                  color: lightWhiteColor,
                                  border: currentLocationFething
                                      ? Border(
                                          top: BorderSide(
                                              color: greenColor, width: 2),
                                        )
                                      : Border.all(
                                          width: 0, color: Colors.transparent)),
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Row(
                                crossAxisAlignment:CrossAxisAlignment.center,
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
                                          color: blackColor,
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
                                    child:Container(
                                      height: 50,
                                      width: 50,
                                      child: Image.asset(
                                        'lib/images/tick.png',
                                        fit:BoxFit.fill,
                                      ),
                                    )
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

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(10, 10);
    path.lineTo(20, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  Size get size => Size(20, 10);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
