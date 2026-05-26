import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImagePath = picked.path);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(name: name, profileImagePath: _pickedImagePath);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
      context.go('/profile');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Error al actualizar')));
    }
  }

  Future<void> _deleteProfilePicture() async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar foto de perfil'),
        content: const Text('¿Quieres eliminar la foto de perfil actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await auth.deleteProfilePicture();
    if (success && context.mounted) {
      setState(() {
        _pickedImagePath = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto de perfil eliminada')));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'No se pudo eliminar la foto')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final String profileUrl = user?.profilePicture?.trim() ?? '';
    final hasExistingProfileImage = profileUrl.isNotEmpty;
    final ImageProvider? avatarImage = _pickedImagePath != null
        ? FileImage(File(_pickedImagePath!))
        : (profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: auth.isLoading ? null : _pickImage,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFFF3E6D8),
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(Icons.camera_alt, size: 32, color: Color(0xFF8E4A1F))
                        : null,
                  ),
                ),
                if (hasExistingProfileImage || _pickedImagePath != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: const Color(0xFFB71C1C),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: auth.isLoading ? null : _deleteProfilePicture,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.delete_outline, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Nombre completo', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _save,
                child: auth.isLoading ? const CircularProgressIndicator() : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
