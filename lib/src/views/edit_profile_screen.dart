import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Untuk pilih gambar
import 'dart:io'; // Untuk akses File

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late File _profileImage; // Menyimpan file gambar lokal
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    // Inisialisasi dengan placeholder default (misalnya avatar default)
    _profileImage = File('assets/images/avatar.png'); // Pastikan path benar
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Foto Profil
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(_profileImage),
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nama Lengkap
            TextFormField(
              decoration: const InputDecoration(labelText: "Nama Lengkap"),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),

            // Deskripsi / Title
            TextFormField(
              decoration: const InputDecoration(labelText: "Deskripsi/Title"),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            ElevatedButton.icon(
              onPressed: () {
                // Simpan perubahan profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil berhasil diperbarui")),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text("Simpan Perubahan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
