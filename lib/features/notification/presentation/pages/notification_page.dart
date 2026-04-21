import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.notifications_active, color: Colors.white),
            ),
            title: Text('Tiket #${100 - index} Anda diperbarui'),
            subtitle: const Text('Status berubah menjadi "Selesai", cek detail selengkapnya.'),
            trailing: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                // TODO: Buka detail tiket
              },
            ),
          );
        },
      ),
    );
  }
}
