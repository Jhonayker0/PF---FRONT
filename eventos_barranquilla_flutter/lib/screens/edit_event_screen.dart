import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../data/event_categories.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({required this.event, super.key});

  final Event event;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late String _generalCategory;
  late String _specificCategory;
  late DateTime? _selectedDateTime;
  final EventService _eventService = EventService();
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
  final List<String> _keptImages = [];
  final List<String> _newImagePaths = [];

  List<String> get _existingImages {
    return _keptImages;
  }

  Future<void> _pickNewImages() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage(maxWidth: 1200, imageQuality: 80);
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          _newImagePaths.addAll(picked.map((e) => e.path));
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _deleteExistingImageAt(int index) async {
    if (index < 0 || index >= _keptImages.length) {
      return;
    }

    final imageUrl = _keptImages[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar imagen'),
        content: const Text('¿Quieres borrar esta imagen del evento?'),
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

    if (confirmed != true || !mounted) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    try {
      await _eventService.deleteEventImage(
        eventId: widget.event.id,
        imageUrl: imageUrl,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _keptImages.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagen eliminada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar la imagen: $e')));
    }
  }

  void _removeNewImageAt(int index) {
    setState(() {
      _newImagePaths.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _priceController = TextEditingController(
      text: widget.event.price == 0 ? '' : widget.event.price.toStringAsFixed(0),
    );

    _generalCategory = widget.event.categoryGroup.isNotEmpty
        ? widget.event.categoryGroup
        : EventCategories.generalCategories.first;
    _specificCategory = widget.event.categorySpecific.isNotEmpty
        ? widget.event.categorySpecific
        : EventCategories.specificCategoriesFor(_generalCategory).first;

    try {
      _selectedDateTime = DateTime.parse(widget.event.date).toLocal();
    } catch (_) {
      _selectedDateTime = null;
    }
    _keptImages.addAll(widget.event.pictureUrls);
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
    if (value == null) return 'Selecciona fecha y hora';
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
    final existingImages = _existingImages;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'Editar Evento',
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
              const Text('Nombre del Evento', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Categoría general', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _generalCategory,
                items: EventCategories.generalCategories
                    .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  final nextGeneral = val ?? EventCategories.generalCategories.first;
                  final nextSpecifics = EventCategories.specificCategoriesFor(nextGeneral);
                  setState(() {
                    _generalCategory = nextGeneral;
                    _specificCategory = nextSpecifics.isNotEmpty ? nextSpecifics.first : '';
                  });
                },
                decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              const Text('Categoría específica', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _specificCategory,
                items: EventCategories.specificCategoriesFor(_generalCategory)
                    .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _specificCategory = val ?? _specificCategory),
                decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              const Text('Fecha y hora', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatSelectedDateTime(),
                          style: TextStyle(color: _selectedDateTime == null ? const Color(0xFF9A9A9A) : const Color(0xFF1A1A1A), fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Icon(Icons.expand_more, color: Color(0xFF9A9A9A)),
                    ],
                  ),
                ),
              ),
              const Text('Ubicación', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Ej: Centro Histórico',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Imágenes del evento', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                  TextButton.icon(onPressed: _pickNewImages, icon: const Icon(Icons.add_a_photo), label: const Text('Agregar')),
                ],
              ),
              const SizedBox(height: 8),
              if (existingImages.isNotEmpty || _newImagePaths.isNotEmpty) ...[
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    itemCount: existingImages.length + _newImagePaths.length,
                    controller: PageController(viewportFraction: 0.88),
                    itemBuilder: (context, index) {
                      if (index < existingImages.length) {
                        final imageUrl = existingImages[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 180,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFEDE7DE),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: InkWell(
                                  onTap: () => _deleteExistingImageAt(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                                    child: const Icon(Icons.delete, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final newIndex = index - existingImages.length;
                      final path = _newImagePaths[newIndex];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: 180),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: InkWell(
                                onTap: () => _removeNewImageAt(newIndex),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (existingImages.isEmpty && _newImagePaths.isEmpty)
                Container(
                  height: 180,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7DE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'No hay imágenes cargadas',
                    style: TextStyle(color: Color(0xFF8A7F73)),
                  ),
                ),
              const SizedBox(height: 20),
              const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe tu evento...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Precio', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
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
                              const SnackBar(content: Text('Por favor completa los campos obligatorios')),
                            );
                            return;
                          }

                          final user = context.read<AuthProvider>().user;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Debes iniciar sesion para editar eventos')),
                            );
                            return;
                          }

                          setState(() => _isSubmitting = true);
                          try {
                            final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
                            final token = context.read<AuthProvider>().token;
                            final uploadedUrls = <String>[];
                            if (_newImagePaths.isNotEmpty) {
                              for (final path in _newImagePaths) {
                                try {
                                  final url = await _eventService.uploadEventImage(
                                    eventId: widget.event.id,
                                    filePath: path,
                                    token: token,
                                  );
                                  uploadedUrls.add(url);
                                } catch (e) {
                                  rethrow;
                                }
                              }
                            }

                            final allPictures = [..._keptImages, ...uploadedUrls];
                            await _eventService.updateEvent(
                              eventId: widget.event.id,
                              name: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                              date: selectedDateTime.toIso8601String(),
                              location: _locationController.text.trim(),
                              category: _specificCategory,
                              categoryGroup: _generalCategory,
                              categorySpecific: _specificCategory,
                              price: price,
                              organizerId: user.id.isNotEmpty ? user.id : widget.event.organizerId,
                              pictureUrls: allPictures,
                            );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('¡Evento actualizado exitosamente!')),
                            );
                            context.pop();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No se pudo actualizar el evento: $e')),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_isSubmitting ? 'Guardando...' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}