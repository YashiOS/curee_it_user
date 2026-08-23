import 'dart:async';

import 'package:cureeit_user_app/current_address/location_permission_helper.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/address_provider.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/cart_provider.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/order_provider.dart';
import 'package:cureeit_user_app/screens/home/presentation/providers/service_providers.dart';
import 'package:cureeit_user_app/screens/home/domain/entities/addressEntity.dart';
import 'package:cureeit_user_app/screens/home/presentation/widget/onGoingOrders.dart';
import 'package:cureeit_user_app/screens/home/presentation/widget/product_grid.dart';
import 'package:cureeit_user_app/screens/location.dart';
import 'package:cureeit_user_app/screens/otp/domain/entities/userEntity.dart';
import 'package:cureeit_user_app/screens/otp/presentation/provider/otpProvider.dart';
import 'package:cureeit_user_app/screens/profile_screen.dart';
import 'package:cureeit_user_app/screens/search.dart';
import 'package:cureeit_user_app/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String latitude;
  final String longitude;

  const HomeScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  double _lastScrollOffset = 0.0;
  bool _isScrollingDown = false;
  Timer? _hintTimer;
  int _currentHintIndex = 0;
  final List<String> _hints = [
    "Search for \"diapers\"",
    "Search for \"dolo\"",
    "Search for \"paracetamol\"",
    "Search for \"ORS\"",
    "Search for \"vicks\"",
    "Search for \"thermometer\"",
    "Search for \"stayfree\"",
    "Search for \"anti-allergy\"",
    "Search for \"multivitamins\"",
    "Search for \"ipill\"",
    "Search for \"condom\"",
    "Search for \"nasal drops\"",
    "Search for \"injection\"",
  ];
  String? _currentHint;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(_scrollListener);
    _startHintRotation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startApp();
    });
  }

  void startApp() async {
    final user = await ref.read(OtpNotifierProvider.notifier).getUserData();
    await ref.read(addressNotifierProvider.notifier).getLocationPermission();
    final granted = ref.watch(addressNotifierProvider).permissionGranted;
    if (granted) {
      fetchAddresses(user);
      fetchOnGoingOrders(user);
      fetchCart(user);
    } else {
      _showLocationDeniedDialog();
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  AddressEntity? _nearestAddress(
    List<AddressEntity> addresses,
    Position position,
  ) {
    AddressEntity? nearest;
    double nearestDistance = double.infinity;

    for (final address in addresses) {
      final latitude = double.tryParse(address.userLat?.toString() ?? '');
      final longitude = double.tryParse(address.userLong?.toString() ?? '');
      if (latitude == null || longitude == null) continue;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        latitude,
        longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = address;
      }
    }

    return nearest;
  }

  void fetchAddresses(User? user) async {
    await ref
        .read(addressNotifierProvider.notifier)
        .fetchAddresses(user!.userId);
    final addresses = ref.read(addressNotifierProvider).addresses;

    if (addresses.isEmpty) {
      // No saved address yet — fall back to the device's current location
      // so the home screen can still check serviceability and show products.
      try {
        final position = await determinePosition();
        ref
            .read(orderNotifierProvider.notifier)
            .checkLocation(position.latitude, position.longitude);
      } catch (e) {
        ref
            .read(orderNotifierProvider.notifier)
            .checkLocation(double.parse(widget.latitude), double.parse(widget.longitude));
      }
    } else if (addresses.length == 1) {
      await ref
          .read(addressNotifierProvider.notifier)
          .setCurrentAddress(addresses[0], 0);
      ref.read(orderNotifierProvider.notifier).checkLocation(
          _toDouble(addresses[0].userLat), _toDouble(addresses[0].userLong));
    } else {
      try {
        final position = await determinePosition();
        final nearestAddress = _nearestAddress(addresses, position);

        if (nearestAddress != null) {
          final nearestIndex = addresses.indexOf(nearestAddress);
          await ref
              .read(addressNotifierProvider.notifier)
              .setCurrentAddress(nearestAddress, nearestIndex);
          ref.read(orderNotifierProvider.notifier).checkLocation(
              _toDouble(nearestAddress.userLat),
              _toDouble(nearestAddress.userLong));
          return;
        }
      } catch (_) {}

      final fallbackAddress = addresses[0];
      await ref
          .read(addressNotifierProvider.notifier)
          .setCurrentAddress(fallbackAddress, 0);
      ref.read(orderNotifierProvider.notifier).checkLocation(
          _toDouble(fallbackAddress.userLat),
          _toDouble(fallbackAddress.userLong));
    }
  }

  void _showLocationDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: lightWhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          "Location Required",
          style: GoogleFonts.mulish(color: blackColor),
        ),
        content: Text(
          "Please enable location to use this app.",
          style: GoogleFonts.mulish(color: blackColor),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFBE404F),
              foregroundColor: blackColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              startApp(); // Exit the app
            },
            child: Text("Re-Try", style: GoogleFonts.mulish(color: blackColor)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final currentScrollOffset = _scrollController.offset;

    if (currentScrollOffset > _lastScrollOffset && !_isScrollingDown) {
      _isScrollingDown = true;
      _animationController.reverse();
    } else if (currentScrollOffset < _lastScrollOffset && _isScrollingDown) {
      _isScrollingDown = false;
      _animationController.forward();
    }

    _lastScrollOffset = currentScrollOffset;
  }

  void _startHintRotation() {
    _currentHint = _hints[_currentHintIndex];

    _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _currentHint = "";
      });

      setState(() {
        _currentHintIndex = (_currentHintIndex + 1) % _hints.length;
      });

      setState(() {
        _currentHint = _hints[_currentHintIndex];
      });
    });
  }

  void fetchCart(User? user) {
    ref.read(cartNotifierProvider.notifier).fetchCart(user!.userId);
  }

  void fetchOnGoingOrders(User? user) {
    ref.read(orderNotifierProvider.notifier).fetchOrderHistory(user!.userId);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    final addressState = ref.watch(addressNotifierProvider);
    final cartItem = ref.watch(cartNotifierProvider).cartItems;

    final currentAddress = addressState.currentAddress;
    final lat = currentAddress != null
        ? currentAddress.userLat.toString()
        : widget.latitude;
    final lng = currentAddress != null
        ? currentAddress.userLong.toString()
        : widget.longitude;
    final servicesAsync = ref.watch(servicesProvider((lat, lng)));

    return Scaffold(
      backgroundColor:Colors.black,
      key: _scaffoldKey,
      body: Stack(
        children: [
          if (orderState.currentLocationAvailable == true)
            Positioned(
              bottom: 0,
              left: 55,
              right: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'lib/images/final_homebike1.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),

          // Main content
          Container(
            margin:
                const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header section
                SliverAppBar(
                  backgroundColor:  Colors.black,
                  expandedHeight: 90,
                  floating: false,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LocationScreen()),
                        );
                        await ref
                            .read(addressNotifierProvider.notifier)
                            .getCurrentAddress();
                        final selected =
                            ref.read(addressNotifierProvider).currentAddress;
                        if (selected != null) {
                          ref.read(orderNotifierProvider.notifier).checkLocation(
                              _toDouble(selected.userLat),
                              _toDouble(selected.userLong));
                        }
                      },
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color:  Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 30,
                                    child: Image.asset("lib/images/siccLog.png"),
                                  ),
                                  Text(
                                    orderState.estimatedTime != null
                                        ? "Delivering in ${orderState.estimatedTime} mins"
                                        : "Fetching delivery time...",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.mulish(
                                      color: WhiteColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 280,
                                    height: 24,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 50,
                                            maxWidth: 250,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 4),
                                                child: Text(
                                                  "${addressState.currentAddress?.type} :",
                                                  style: TextStyle(
                                                    color: WhiteColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  "${addressState.currentAddress?.address}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.mulish(
                                                    color: WhiteColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen()),
                                );
                              },
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Image.asset("lib/images/profileIcon.png"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Ongoing orders section
                if (orderState.currentLocationAvailable == true &&
                    orderState.ongoingOrders.isNotEmpty)
                  SliverAppBar(
                    backgroundColor:  Colors.transparent,
                    floating: true,
                    scrolledUnderElevation: 0,
                    elevation: 0,
                    expandedHeight: null,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: OngoingOrdersSection(
                          onGoingOrders: orderState.ongoingOrders),
                    ),
                  ),

                SliverAppBar(
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  expandedHeight: null,
                  backgroundColor:  Colors.black,
                  pinned: true,
                  flexibleSpace: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Search(Mic_on:false ),
                            ),
                          );    
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 14),
                            height: 43,
                            decoration: BoxDecoration(
                              color:  textFieldFillColor,
                              borderRadius: BorderRadius.circular(8),
                             
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, right: 5),
                                  child: Icon(Icons.search,
                                      color: blackColor, size: 18),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 26),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (child, animation) {
                                        final inAnimation = Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: Offset.zero,
                                        ).animate(animation);

                                        final outAnimation = Tween<Offset>(
                                          begin: const Offset(0, -1),
                                          end: Offset.zero,
                                        ).animate(animation);

                                        return SlideTransition(
                                          position: child.key ==
                                                  ValueKey(
                                                      _hints[_currentHintIndex])
                                              ? inAnimation
                                              : outAnimation,
                                          child: child,
                                        );
                                      },
                                      child: Align(
                                        key: ValueKey<String>(
                                            _hints[_currentHintIndex]),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _currentHint ?? "",
                                          style: GoogleFonts.mulish(
                                            color: greyColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to voice search
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.only(left: 0, right: 16),
                                    child: Icon(Icons.mic,
                                        color: greenColor, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          color:  Colors.black,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              orderState.currentLocationAvailable == true
                                  ? "Frequently Bought"
                                  : "Unknown",
                              style: GoogleFonts.mulish(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.038,
                                fontWeight: FontWeight.bold,
                                color: WhiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (orderState.currentLocationAvailable == false)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        "We’re not in your area yet—but we’re on our way!",
                        textAlign: TextAlign.center, // Center this text too
                        style: GoogleFonts.mulish(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          color: greyColor,
                        ),
                      ),
                    ),
                  ),
                // if (orderState.currentLocationAvailable != null &&
                //     orderState.currentLocationAvailable == true)
                  SliverPadding(
                    padding: EdgeInsets.only(
                        bottom:
                            cartItem.length > 0 ? 135 : 56), // adjust as needed
                    sliver: servicesAsync.when(
                      data: (services) => ProductGrid(services: services),
                      loading: () => const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: blackColor),
                        ),
                      ),
                      error: (err, _) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            "Error: $err",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          if (cartItem.length > 0)
            Positioned(
              right: 0,
              bottom: 75,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.10,
                decoration: BoxDecoration(
                  color:  Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: Offset(0, -2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: Offset(-2, 0),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: Offset(2, 0),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.045,
                    vertical: MediaQuery.of(context).size.height * 0.012,
                  ),
                  child: Column(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 12,
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  border: Border.all(
                                    width: 2,
                                    color: blackColor,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset("lib/images/siccLog.png", fit: BoxFit.contain),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${cartItem.length} Items ',
                                    style: GoogleFonts.mulish(
                                      color: greyColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    '|  ₹${ref.watch(cartNotifierProvider).finalTotal}',
                                    style: GoogleFonts.mulish(
                                      color: WhiteColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              DefaultTabController.of(context).animateTo(2);
                            },
                            child: Container(
                              width: 90,
                              height: 40,
                              decoration: BoxDecoration(
                                color: greenColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'View Cart',
                                  style: GoogleFonts.mulish(
                                    color:  scaffoldWhiteColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
