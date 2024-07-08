import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/directions.dart' as directions;
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:async';
import 'package:get/get.dart';
import '../utilis/app_constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GoogleMapController? myMapController;
  Marker? _currentLocationMarker;
  Marker? _destinationMarker;
  Polyline? _routePolyline;
  String currentAddress = "Current Location";
  double? _estimatedTime;

  final directions.GoogleMapsDirections _directionsApi =
  directions.GoogleMapsDirections(apiKey: AppConstants.kGoogleApiKey);

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    startLocationUpdates();
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }

  void requestLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      print("Location permission granted.");
    } else {
      print("Location permission denied.");
    }
  }

  void startLocationUpdates() {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    ).listen((Position position) {
      updateCurrentLocationMarker(position);
    });
  }

  void stopLocationUpdates() {
    positionStream?.cancel();
  }

  Future<void> updateCurrentLocationMarker(Position position) async {
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocationMarker = Marker(
        markerId: MarkerId('current_location'),
        position: currentLatLng,
        infoWindow: InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    });

    await _drawRoute();
    _calculateEstimatedTime(position.speed);
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    myMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 14.4746,
        ),
      ),
    );

    List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude, position.longitude);
    geocoding.Placemark place = placemarks[0];

    setState(() {
      _currentLocationMarker = Marker(
        markerId: MarkerId('current_location'),
        position: currentLatLng,
        infoWindow: InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      currentAddress = "${place.street}, ${place.locality}, ${place.country}";
    });
  }

  Future<void> setDestination(String placeDescription) async {
    List<geocoding.Location> locations = await geocoding.locationFromAddress(placeDescription);
    if (locations.isNotEmpty) {
      geocoding.Location location = locations[0];
      LatLng destinationLatLng = LatLng(location.latitude, location.longitude);

      setState(() {
        _destinationMarker = Marker(
          markerId: MarkerId('destination'),
          position: destinationLatLng,
          infoWindow: InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      });

      _drawRoute();
    }
  }

  Future<void> _drawRoute() async {
    if (_currentLocationMarker == null || _destinationMarker == null) return;

    final currentLatLng = _currentLocationMarker!.position;
    final destinationLatLng = _destinationMarker!.position;

    directions.DirectionsResponse response = await _directionsApi.directionsWithLocation(
      directions.Location(lat: currentLatLng.latitude, lng: currentLatLng.longitude),
      directions.Location(lat: destinationLatLng.latitude, lng: destinationLatLng.longitude),
      travelMode: directions.TravelMode.driving,
    );

    if (response.isOkay) {
      List<LatLng> polylineCoordinates = [];
      for (var leg in response.routes.first.legs) {
        for (var step in leg.steps) {
          polylineCoordinates.add(
            LatLng(step.startLocation.lat, step.startLocation.lng),
          );
          polylineCoordinates.add(
            LatLng(step.endLocation.lat, step.endLocation.lng),
          );
        }
      }

      setState(() {
        _routePolyline = Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.pink,
          width: 5,
        );
      });


    }
  }

  void _zoomToFitMarkers() {
    if (_currentLocationMarker == null || _destinationMarker == null) return;

    LatLngBounds bounds;
    if (_currentLocationMarker!.position.latitude > _destinationMarker!.position.latitude) {
      bounds = LatLngBounds(
        southwest: _destinationMarker!.position,
        northeast: _currentLocationMarker!.position,
      );
    } else {
      bounds = LatLngBounds(
        southwest: _currentLocationMarker!.position,
        northeast: _destinationMarker!.position,
      );
    }

    myMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }


  void _calculateEstimatedTime(double speed) {
    if (speed <= 0 || _currentLocationMarker == null || _destinationMarker == null) {
      setState(() {
        _estimatedTime = null;
      });
      return;
    }

    final currentLatLng = _currentLocationMarker!.position;
    final destinationLatLng = _destinationMarker!.position;

    final distance = Geolocator.distanceBetween(
      currentLatLng.latitude,
      currentLatLng.longitude,
      destinationLatLng.latitude,
      destinationLatLng.longitude,
    );

    final timeInSeconds = distance / speed;
    final timeInMinutes = timeInSeconds / 60;

    setState(() {
      _estimatedTime = timeInMinutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              myMapController = controller;
            },
            markers: {
              if (_currentLocationMarker != null) _currentLocationMarker!,
              if (_destinationMarker != null) _destinationMarker!,
            },
            polylines: {
              if (_routePolyline != null) _routePolyline!,
            },
          ),
          buildProfileTile(),
          buildCurrentLocationBox(),
          buildTextField(context),
          buildCurrentLocationIcon(),
          if (_estimatedTime != null) buildEstimatedTimeBox(),
        ],
      ),
    );
  }

  Widget buildProfileTile() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.5,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(color: Colors.white70),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/person.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Hi there, ',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    TextSpan(
                      text: 'David', // call data from database
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                ),
                Text(
                  "Where are you going?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentLocationBox() {
    return Positioned(
      top: 150,
      left: 20,
      right: 20,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                currentAddress,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> showGoogleAutoComplete(BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "TZ",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: AppConstants.kGoogleApiKey,
      components: [Component(Component.country, "TZ")],
      types: [],
      hint: "Search City",
    );

    return p?.description;
  }

  TextEditingController destinationController = TextEditingController();
  bool showSourceField = false;

  Widget buildTextField(BuildContext context) {
    return Positioned(
      top: 220,
      left: 20,
      right: 20,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: destinationController,
          readOnly: true,
          onTap: () async {
            String? selectedPlace = await showGoogleAutoComplete(context);
            if (selectedPlace != null) {
              destinationController.text = selectedPlace;
              setDestination(selectedPlace);
            }
          },
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Search for a destination',
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                Icons.search,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget buildCurrentLocationIcon() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        child: GestureDetector(
          onTap: () async {
            await getCurrentLocation();
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green,
            child: Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEstimatedTimeBox() {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _estimatedTime != null
                ? "Estimated time: ${_estimatedTime!.toStringAsFixed(2)} minutes"
                : "Calculating time...",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
