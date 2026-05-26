import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/event_categories.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late String _generalCategory;
  late String _specificCategory;
  final EventService _eventService = EventService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  DateTime? _selectedDateTime;
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _priceController = TextEditingController();
    _generalCategory = EventCategories.generalCategories.first;
    _specificCategory = EventCategories.specificCategoriesFor(_generalCategory).first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _formatSelectedDateTime() {
    final value = _selectedDateTime;
    if (value == null) {
      return 'Selecciona fecha y hora';
    }
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('EEE, d MMM • hh:mm a', locale).format(value);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: 'Selecciona la fecha del evento',
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.fromDateTime(now),
      helpText: 'Selecciona la hora del evento',
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final picked = await _imagePicker.pickMultiImage(imageQuality: 80);
        if (picked.isEmpty || !mounted) return;

        setState(() {
          for (final image in picked) {
            if (_selectedImages.every((current) => current.path != image.path)) {
              _selectedImages.add(image);
            }
          }
        });
      } else {
        final picked = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (picked == null || !mounted) return;

        setState(() {
          if (_selectedImages.every((current) => current.path != picked.path)) {
            _selectedImages.add(picked);
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las imágenes')),
      );
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _openLocationInMaps() async {
    final query = _locationController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una ubicación primero')),
      );
      return;
    }

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el mapa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'Crear Evento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input
              const Text(
                'Nombre del Evento',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ej: Festival de Música',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Category dropdowns
              const Text(
                'Categoría general',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _generalCategory,
                items: EventCategories.generalCategories
                    .map((cat) => DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) {
                  final nextGeneral = val ?? EventCategories.generalCategories.first;
                  final nextSpecifics = EventCategories.specificCategoriesFor(nextGeneral);
                  setState(() {
                    _generalCategory = nextGeneral;
                    _specificCategory = nextSpecifics.isNotEmpty ? nextSpecifics.first : '';
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Categoría específica',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _specificCategory,
                items: EventCategories.specificCategoriesFor(_generalCategory)
                    .map((cat) => DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _specificCategory = val ?? _specificCategory),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fecha y hora',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF078930)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatSelectedDateTime(),
                          style: TextStyle(
                            color: _selectedDateTime == null ? const Color(0xFF9A9A9A) : const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.expand_more, color: Color(0xFF9A9A9A)),
                    ],
                  ),
                ),
              ),
              // Location input
              const Text(
                'Ubicación',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Ej: Centro Histórico',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openLocationInMaps,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Abrir ubicación en mapa'),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Imágenes del evento',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImages(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF078930),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFBFDCC7)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galería'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImages(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF078930),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Cámara'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: _selectedImages.length,
                    controller: PageController(viewportFraction: 0.88),
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(
                                File(image.path),
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => _removeSelectedImage(index),
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              // Description input
              const Text(
                'Descripción',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe tu evento...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Precio',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(
                  hintText: 'Ej: 25000',
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF078930),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                    final selectedDateTime = _selectedDateTime;
                    if (_titleController.text.isEmpty ||
                        _descriptionController.text.isEmpty ||
                        _locationController.text.isEmpty ||
                        selectedDateTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor completa los campos obligatorios'),
                        ),
                      );
                      return;
                    }
                    final user = context.read<AuthProvider>().user;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debes iniciar sesion para crear eventos'),
                        ),
                      );
                      return;
                    }

                    setState(() => _isSubmitting = true);
                    try {
                      final price = double.tryParse(
                            _priceController.text.replaceAll(',', '.'),
                          ) ??
                          0.0;
                      await _eventService.createEvent(
                        userId: user.id,
                        name: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        date: selectedDateTime.toIso8601String(),
                        location: _locationController.text.trim(),
                        category: _specificCategory,
                        categoryGroup: _generalCategory,
                        categorySpecific: _specificCategory,
                        price: price,
                        pictureUrls: _selectedImages.map((image) => image.path).toList(),
                        organizer: user,
                      );
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Evento creado exitosamente!'),
                        ),
                      );
                      context.go('/home');
                    } catch (e) {
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No se pudo crear el evento: $e'),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(
                    _isSubmitting ? 'Creando...' : 'Crear Evento',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
