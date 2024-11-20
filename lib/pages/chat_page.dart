import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demodb/components/chat_bubble.dart';
import 'package:demodb/components/my_textfield.dart';
import 'package:demodb/services/auth/auth_service.dart';
import 'package:demodb/services/chat/chat_services.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String recieverEmail;
  final String recieverID;
  ChatPage({super.key, required this.recieverEmail, required this.recieverID});

  final TextEditingController _msgController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void _sendMsg() async {
    if (_msgController.text.isNotEmpty) {
      await _chatService.sendMsg(recieverID, _msgController.text);
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(recieverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMsgList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMsgList() {
    String sendID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMsgs(recieverID, sendID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error!");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading!");
          }
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMsgItem(doc, context))
                .toList(),
          );
        });
  }

  Widget _buildMsgItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String messageID = doc.id;

    bool isCurrentUser = data['sendID'] == _authService.getCurrentUser()!.uid;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return GestureDetector(
      onLongPress: () {
        _showEditDialog(context, messageID, data['message']);
      },
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data['message'],
              isCurrentUser: isCurrentUser,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hintText: 'Type a message',
              isPass: false,
              controller: _msgController,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: _sendMsg,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String messageID, String currentMessage) {
    TextEditingController editController =
        TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Message"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: "Edit your message"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String updatedMessage = editController.text.trim();
                if (updatedMessage.isNotEmpty) {
                  try {
                    // Get the current user and receiver IDs
                    String sendID = _authService.getCurrentUser()!.uid;
                    String recID = recieverID;

                    // Sort IDs to create the chat room ID
                    List<String> ids = [sendID, recID];
                    ids.sort();
                    String cID = ids.join('_');

                    // Update the specific message in the nested messages collection
                    await FirebaseFirestore.instance
                        .collection('chat_rooms')
                        .doc(cID)
                        .collection('messages')
                        .doc(messageID)
                        .update({
                      'message': updatedMessage,
                      'timestamp': Timestamp.now(),
                    });
                  } catch (e) {
                    print("Error updating message: $e");
                  }
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
