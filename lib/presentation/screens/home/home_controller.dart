import 'package:get/get.dart';

class HomeController extends GetxController {
  final rxIndex = 0.obs;
  final rxSelectedFilter = 'All'.obs;

  void changeTabIndex(int index) {
    rxIndex.value = index;
  }

  void selectFilter(String filter) {
    rxSelectedFilter.value = filter;
  }

  // Mock shipment data
  final shipments = [
    {
      'tracking_id': 'SK45621',
      'name': 'Sunil Kumar',
      'phone': '9876543210',
      'lat': 28.6139,
      'lng': 77.2090,
      'address': '123, Street Name, City, State, 110001',
      'type': 'COD',
      'amount': '₹500.00',
      'status': 'FWD',
    },
    {
      'tracking_id': 'SK98745',
      'name': 'Rahul Sharma',
      'phone': '9123456789',
      'lat': 19.0760,
      'lng': 72.8777,
      'address': '456, Area Name, Mumbai, Maharashtra, 400001',
      'type': 'Prepaid',
      'amount': '₹800.00',
      'status': 'RVP',
    },
    {
      'tracking_id': 'SK65412',
      'name': 'Deepak Singh',
      'phone': '8877665544',
      'lat': 12.9716,
      'lng': 77.5946,
      'address': '789, Road 5, Bangalore, Karnataka, 560001',
      'type': 'COD',
      'amount': '₹1200.00',
      'status': 'RT',
    },
  ].obs;
}
