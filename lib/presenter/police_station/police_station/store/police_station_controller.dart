import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gina/components/dialogs/info_dialog.dart';
import 'package:gina/domain/entities/police_station_entity.dart';
import 'package:gina/domain/entities/user_entity.dart';
import 'package:gina/utils/assets/app_assets.dart';
import 'package:gina/utils/framework/environment.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class PolicyStationController extends ChangeNotifier {
  UserEntity? user;
  LatLng? currentPosition;
  Set<Marker> markers = {};
  List<PoliceStationEntity> stations = [];
  bool isLoading = true;
  int? selectedStation;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Environment.mapKey);

  setIsLoading([bool? newLoading]) {
    if (newLoading == null) {
      isLoading = !isLoading;
    } else {
      isLoading = newLoading;
    }
    notifyListeners();
  }

  setSelectedStation(int? newStation) {
    selectedStation = newStation;
    notifyListeners();
  }

  Future<bool> getUserLocation(BuildContext context) async {
    setIsLoading(true);
    final status = await Permission.location.request();

    if (!status.isGranted && !status.isProvisional) {
      return false;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();
    await _fetchPoliceStations(position.latitude, position.longitude, context);
    setIsLoading(false);
    return true;
  }

  Future<void> _fetchPoliceStations(
    double lat,
    double lng,
    BuildContext context,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=5000' // 5km
        '&language=pt-BR'
        '&type=police'
        '&key=${Environment.mapKey}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      stations =
          results.map((item) {
            double distanceInMeters = Geolocator.distanceBetween(
              lat,
              lng,
              item['geometry']['location']['lat'] as double,
              item['geometry']['location']['lng'] as double,
            );

            double distanceInKm = distanceInMeters / 1000;
            final handledItem = <String, dynamic>{
              ...item,
              'distance': distanceInKm,
            };
            return PoliceStationEntity.fromMap(handledItem);
          }).toList();

      stations.sort((a, b) => a.distance.compareTo(b.distance));
      final pin = await _loadCustomMarker();
      markers =
          results.map((place) {
            final photoReference = place['photos']?[0]['photo_reference'];
            final String photoUrl =
                'https://maps.googleapis.com/maps/api/place/photo'
                '?maxwidth=400'
                '&photo_reference=$photoReference'
                '&key=${Environment.mapKey}';
            return Marker(
              visible: place['business_status'] == 'OPERATIONAL',
              markerId: MarkerId(place['place_id']),
              position: LatLng(
                place['geometry']['location']['lat'],
                place['geometry']['location']['lng'],
              ),

              consumeTapEvents: false,
              icon: pin,
              onTap: () {
                InfoDialog.show(
                  place['name'],
                  place['vicinity'],
                  context,
                  photoUrl,
                );
              },
            );
          }).toSet();
    }
  }

  late BitmapDescriptor customIcon;

  Future<AssetMapBitmap> _loadCustomMarker() async {
    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(42, 42)),
      GiAppAssets.pin,
    );
  }

  void getPolyline({required LatLng end}) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    notifyListeners();
  }
}
