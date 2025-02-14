import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demodb/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMsg(String recID, msg) async {
    final String curID = _auth.currentUser!.uid;
    final String curEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message message = Message(
      sendID: curID,
      sendEmail: curEmail,
      recID: recID,
      message: msg,
      timestamp: timestamp,
    );

    List<String> ids = [curID, recID];
    ids.sort();
    String cID = ids.join('_');
    await _firestore
        .collection('chat_rooms')
        .doc(cID)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<QuerySnapshot> getMsgs(String userID, otherUserId) {
    List<String> ids = [userID, otherUserId];
    ids.sort();
    String cID = ids.join('_');
    return _firestore
        .collection('chat_rooms')
        .doc(cID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
