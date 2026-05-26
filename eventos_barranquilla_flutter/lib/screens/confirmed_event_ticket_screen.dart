import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../models/event.dart';

class ConfirmedEventTicketScreen extends StatelessWidget {
  const ConfirmedEventTicketScreen({required this.event, super.key});

  final Event event;

  String _formatDate(String raw, BuildContext context) {
    try {
      final parsed = DateTime.parse(raw).toLocal();
      final locale = Localizations.localeOf(context).toString();
      return DateFormat('EEE, d MMM yyyy', locale).format(parsed);
    } catch (_) {
      return raw;
    }
  }

  String _formatTime(String raw, BuildContext context) {
    try {
      final parsed = DateTime.parse(raw).toLocal();
      final locale = Localizations.localeOf(context).toString();
      return DateFormat.jm(locale).format(parsed);
    } catch (_) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EFE8),
        title: const Text('Tiquete confirmado'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: _TicketCard(
              event: event,
              date: _formatDate(event.date, context),
              time: _formatTime(event.date, context),
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.event,
    required this.date,
    required this.time,
  });

  final Event event;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF078930),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              width: double.infinity,
              height: 185,
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _TicketImageFallback(category: event.categoryLabel),
                    )
                  : _TicketImageFallback(category: event.categoryLabel),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 242, 241, 241),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoColumn(label: 'Fecha', value: date),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _InfoColumn(label: 'Hora', value: time),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoColumn(
                  label: 'Lugar',
                  value: event.location,
                ),
              ],
            ),
          ),
          const _TicketDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
            child: Container(
              width: double.infinity,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE3E3E3)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: event.id,
                  drawText: true,
                  style: const TextStyle(
                    color: Color(0xFF5F5F5F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  color: const Color(0xFF1D1D1D),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 189, 189, 189),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ],
    );
  }
}

class _TicketImageFallback extends StatelessWidget {
  const _TicketImageFallback({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252B66),
      child: Center(
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Divider(
                color: Color(0xFFD8D8D8),
                thickness: 1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF3EFE8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF3EFE8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
