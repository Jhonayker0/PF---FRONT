import 'package:flutter/material.dart';

class CategoryBrowser extends StatelessWidget {
  const CategoryBrowser({
    required this.generalCategories,
    required this.specificCategories,
    required this.selectedGeneral,
    required this.selectedSpecific,
    required this.onGeneralSelected,
    required this.onSpecificSelected,
    super.key,
  });

  final List<String> generalCategories;
  final Map<String, List<String>> specificCategories;
  final String? selectedGeneral;
  final String? selectedSpecific;
  final ValueChanged<String> onGeneralSelected;
  final ValueChanged<String?> onSpecificSelected;

  static const Map<String, IconData> _generalIcons = {
    'Musica': Icons.music_note,
    'Tradicionales': Icons.event,
    'Artes': Icons.theater_comedy,
    'Gastronomía': Icons.restaurant,
    'Deportes y bienestar': Icons.fitness_center,
    'Academia y desarrollo': Icons.school,
    'Comunidad y social': Icons.people,
    'Otros': Icons.more_horiz,
  };

  IconData _iconFor(String generalCategory) {
    return _generalIcons[generalCategory] ?? Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final selectedSpecifics =
      selectedGeneral != null ? (specificCategories[selectedGeneral!] ?? const []) : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categorías',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: generalCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final generalCategory = generalCategories[index];
              final isSelected = selectedGeneral != null && generalCategory == selectedGeneral;
              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onGeneralSelected(generalCategory),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 92,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF078930).withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF078930)
                          : const Color(0xFFE7DFD4),
                      width: isSelected ? 1.3 : 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF078930)
                              : const Color(0xFFF5EFE7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconFor(generalCategory),
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF078930),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        generalCategory,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.1,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF078930)
                              : const Color(0xFF3E352E),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedSpecifics.isNotEmpty) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              selectedGeneral ?? '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A7F73),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: selectedSpecific == null,
                  onSelected: (_) => onSpecificSelected(null),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF078930),
                  labelStyle: TextStyle(
                    color: selectedSpecific == null ? Colors.white : const Color(0xFF3E352E),
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: selectedSpecific == null
                          ? const Color(0xFF078930)
                          : const Color(0xFFE7DFD4),
                    ),
                  ),
                ),
                ...selectedSpecifics.map((specificCategory) {
                  final isSelected = specificCategory == selectedSpecific;
                  return ChoiceChip(
                    label: Text(specificCategory),
                    selected: isSelected,
                    onSelected: (_) => onSpecificSelected(specificCategory),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF078930),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF3E352E),
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: isSelected
                          ? const Color(0xFF078930)
                            : const Color(0xFFE7DFD4),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}