import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

/// 디바이스 목록 가져오기
Future<List<Map<String, dynamic>>> getDevices(String token) async {
  final url = Uri.parse('https://api.smartthings.com/v1/devices');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final devices = data['items'] as List;

      return devices.map((device) {
        return {
          'deviceId': device['deviceId'],
          'name': device['label'] ?? device['name'],
        };
      }).toList();
    } else {
      print(
          'Failed to load devices: ${response.statusCode} - ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error loading devices: $e');
    return [];
  }
}

/// 특정 디바이스의 상태 가져오기
Future<String> getDeviceStatus(String deviceId, String token) async {
  final url = Uri.parse(
      'https://api.smartthings.com/v1/devices/$deviceId/components/main/capabilities/switch/status');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['switch']['value'] as String; // "on" 또는 "off" 반환
    } else {
      print('Failed to get status: ${response.statusCode} - ${response.body}');
      return 'unknown';
    }
  } catch (e) {
    print('Error getting status: $e');
    return 'unknown';
  }
}

/// 디바이스 상태 업데이트 (On/Off)
Future<bool> controlDevice(String deviceId, String state, String token) async {
  print(deviceId);
  print(token);
  CollectionReference gpio_collection =
      FirebaseFirestore.instance.collection('gpio');
  final url =
      Uri.parse('https://api.smartthings.com/v1/devices/$deviceId/commands');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final body = {
    "commands": [
      {
        "component": "main",
        "capability": "switch",
        "command": state,
      }
    ]
  };

  try {
    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));
    if (response.statusCode == 200) {
      print('Device controlled successfully: ${response.body}');
      //db 수정 하는 코드
      //deviceId에 해당하는 문서 찾아서 필드 업데이트 하기.
      // Firestore에서 디바이스 상태 업데이트하기
      CollectionReference gpio_collection =
          FirebaseFirestore.instance.collection('gpio');

      // deviceId와 일치하는 문서 찾기
      final querySnapshot =
          await gpio_collection.where('id', isEqualTo: deviceId).get();

      if (querySnapshot.docs.isNotEmpty) {
        // 문서가 존재할 경우 업데이트
        await querySnapshot.docs.first.reference.update({
          'status': state // 상태 업데이트
        });
      } else {
        print('No document found with device_id: $deviceId');
      }
      return true;
    } else {
      print(
          'Failed to control device: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error controlling device: $e');
    return false;
  }
}
