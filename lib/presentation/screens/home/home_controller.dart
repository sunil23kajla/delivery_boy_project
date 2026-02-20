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
  final shipments = <Map<String, dynamic>>[
    {
      'tracking_id': 'SK45621',
      'order_id': 'ORD-1001',
      'name': 'Sunil Kumar',
      'phone': '9876543210',
      'lat': 28.6139,
      'lng': 77.2090,
      'address': '123, Street Name, Delhi',
      'type': 'COD',
      'amount': '500.00',
      'status': 'FWD',
      'items': [
        {'name': 'Sneakers (Size 9)', 'qty': '1'},
        {'name': 'Sports Socks', 'qty': '3'},
      ],
    },
    {
      'tracking_id': 'SK45622',
      'order_id': 'ORD-1002',
      'name': 'Amit Raj',
      'phone': '9876543211',
      'lat': 28.6138,
      'lng': 77.2091,
      'address': 'Sector 15, Rohini',
      'type': 'Prepaid',
      'amount': '450.00',
      'status': 'FWD',
      'items': [
        {'name': 'Formal Shirt (L)', 'qty': '2'},
      ],
    },
    {
      'tracking_id': 'SK45623',
      'order_id': 'ORD-1003',
      'name': 'Vijay Pal',
      'phone': '9876543212',
      'lat': 28.6137,
      'lng': 77.2092,
      'address': 'Pitampura, Delhi',
      'type': 'COD',
      'amount': '300.00',
      'status': 'FWD',
      'items': [
        {'name': 'Bluetooth Earphones', 'qty': '1'},
      ],
    },
    {
      'tracking_id': 'SK98745',
      'order_id': 'ORD-2001',
      'name': 'Rahul Sharma',
      'phone': '9123456789',
      'lat': 19.0760,
      'lng': 72.8777,
      'address': '456, Area Name, Mumbai',
      'type': 'Prepaid',
      'amount': '800.00',
      'status': 'RVP',
      'items': [
        {'name': 'Kurta Set', 'qty': '1'},
        {'name': 'Dupatta', 'qty': '2'},
      ],
    },
    {
      'tracking_id': 'SK98746',
      'order_id': 'ORD-2002',
      'name': 'Sanjay Gupta',
      'phone': '9123456780',
      'lat': 19.0761,
      'lng': 72.8778,
      'address': 'Bandra West, Mumbai',
      'type': 'COD',
      'amount': '1200.00',
      'status': 'RVP',
      'items': [
        {'name': 'Mobile Phone', 'qty': '1'},
        {'name': 'Phone Cover', 'qty': '1'},
      ],
    },
    {
      'tracking_id': 'SK98747',
      'order_id': 'ORD-2003',
      'name': 'Karan Singh',
      'phone': '9123456781',
      'lat': 19.0762,
      'lng': 72.8779,
      'address': 'Andheri, Mumbai',
      'type': 'Prepaid',
      'amount': '950.00',
      'status': 'RVP',
      'items': [
        {'name': 'Running Shoes', 'qty': '1'},
      ],
    },
    {
      'tracking_id': 'SK65412',
      'order_id': 'ORD-3001',
      'name': 'Deepak Singh',
      'phone': '8877665544',
      'lat': 12.9716,
      'lng': 77.5946,
      'address': '789, Road 5, Bangalore',
      'type': 'COD',
      'amount': '1200.00',
      'status': 'RT',
      'items': [
        {'name': 'Laptop Bag', 'qty': '1'},
      ],
    },
    {
      'tracking_id': 'SK65413',
      'order_id': 'ORD-3002',
      'name': 'Pankaj Mourya',
      'phone': '8877665545',
      'lat': 12.9717,
      'lng': 77.5947,
      'address': 'HSR Layout, Bangalore',
      'type': 'Prepaid',
      'amount': '700.00',
      'status': 'RT',
      'items': [
        {'name': 'Jeans (32)', 'qty': '1'},
        {'name': 'T-Shirt (M)', 'qty': '2'},
      ],
    },
    {
      'tracking_id': 'SK65414',
      'order_id': 'ORD-3003',
      'name': 'Anil Dhiman',
      'phone': '8877665546',
      'lat': 12.9718,
      'lng': 77.5948,
      'address': 'Indiranagar, Bangalore',
      'type': 'COD',
      'amount': '1500.00',
      'status': 'RT',
      'items': [
        {'name': 'Smart Watch', 'qty': '1'},
      ],
    },
    {
      'tracking_id': 'SK32145',
      'order_id': 'ORD-4001',
      'name': 'Mohit Verma',
      'phone': '7011223344',
      'status': 'RIF',
      'address': 'Jaipur, Rajasthan',
      'type': 'COD',
      'amount': '400.00',
      'items': [
        {'name': 'Perfume Bottle', 'qty': '1'},
      ],
    },
    {
      'tracking_id': 'SK32146',
      'order_id': 'ORD-4002',
      'name': 'Rakesh Jain',
      'phone': '7011223345',
      'status': 'RIF',
      'address': 'Ajmer Rd, Jaipur',
      'type': 'Prepaid',
      'amount': '650.00',
      'items': [
        {'name': 'Book Set (5 pcs)', 'qty': '1'},
      ],
    },
  ].obs;

  List<Map<String, dynamic>> get filteredShipments {
    if (rxSelectedFilter.value == 'All') {
      return shipments;
    }
    return shipments
        .where((s) => s['status'] == rxSelectedFilter.value)
        .toList();
  }

  int getCount(String status) {
    if (status == 'All') return shipments.length;
    return shipments.where((s) => s['status'] == status).length;
  }
}
