import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_db/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  void addCard() async{
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('todos')
      .add({
        'title': '',
        'createdAt': Timestamp.now(),
    });

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 5,
        channelKey: 'basic_channel',
        title: 'To-do Added!',
        body: 'New To-do has been created!\nFill it with your new to-do.',
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Scaffold(
                appBar: AppBar(
                  title: const Text('To-Do List'),
                  centerTitle: true,
                ),
                body: Column(
                    children: [
                      AddButton(onPressed: addCard),
                      Expanded(
                          child: StreamBuilder<QuerySnapshot?>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('todos')
                                .orderBy('createdAt', descending: false)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final docs = snapshot.data!.docs;

                              return ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  return FirestoreCard(
                                    docId: doc.id,
                                    title: doc['title'] ?? '',
                                  );
                                },
                              );
                            },
                          ),
                      ),
                      OutlinedButton(
                          onPressed: () => logout(context),
                          child: const Text('Logout'),
                      ),
                    ],
                ),
            );
          }
          else {
            return const LoginScreen();
          }
        }
    );
  }
}


class FirestoreCard extends StatefulWidget {
  final String docId;
  final String title;

  const FirestoreCard({
    super.key,
    required this.docId,
    required this.title,
  });

  @override
  State<FirestoreCard> createState() => _FirestoreCardState();
}

class _FirestoreCardState extends State<FirestoreCard> {
  late TextEditingController titleCont;

  @override
  void initState() {
    titleCont = TextEditingController(text: widget.title);
    super.initState();
  }

  void updateTitle() async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('todos')
        .doc(widget.docId)
        .update({'title': titleCont.text});

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'basic_channel',
        title: 'List Updated',
        body: 'To-do has been updated!',
        notificationLayout: NotificationLayout.ProgressBar,
      ),
    );
  }

  void deleteCard() async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('todos')
        .doc(widget.docId)
        .delete();

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 4,
        channelKey: 'basic_channel',
        title: 'List Deleted',
        body: 'To-do has been removed!',
        notificationLayout: NotificationLayout.Inbox,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amberAccent[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleCont,
              decoration: const InputDecoration(hintText: 'To-do'),
              onChanged: (_) => updateTitle(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DeleteButton(onPressed: deleteCard),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CardExample extends StatefulWidget {
  final VoidCallback onDelete;

  const CardExample({super.key, required this.onDelete});

  @override
  State<CardExample> createState() => _CardExampleState();
}

class _CardExampleState extends State<CardExample> {
  final titleCont = TextEditingController();
  final contentCont = TextEditingController();

  @override

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleCont.dispose();
    contentCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.amberAccent[100],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: titleCont, decoration: InputDecoration(hintText: 'New To Do')),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DeleteButton(onPressed: widget.onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add),
          label: const Text('Add Things To Do'),
          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blueAccent)),
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
          'Delete',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          )
      ),
    );
  }
}