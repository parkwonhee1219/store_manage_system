import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String id;
  final String name;
  final String status;

  Device(
      {required this.id,
      required this.name,
      required this.status});
}

class FireStoreDevice {
  CollectionReference gpio_collection =
      FirebaseFirestore.instance.collection('gpio');

  // Future<void> addEvent(Event event) async {
  //   await product.add({
  //     'id' : '',
  //     'name': event.name,
  //     'startTime': Timestamp.fromDate(event.startTime),
  //     'endTime': Timestamp.fromDate(event.endTime),
  //   });
  // }

  
}