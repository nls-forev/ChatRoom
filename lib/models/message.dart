import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sendID;
  final String sendEmail;
  final String recID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.sendID,
    required this.sendEmail,
    required this.recID,
    required this.message,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'sendID': sendID,
      'sendEmail': sendEmail,
      'recID': recID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
