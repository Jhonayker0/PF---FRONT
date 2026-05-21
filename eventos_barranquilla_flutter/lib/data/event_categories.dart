class EventCategories {
  static const Map<String, List<String>> catalog = {
    'Musica': [
      'champeta',
      'vallenato',
      'cumbia',
      'mapalé',
      'salsa',
      'gaitas',
      'porro',
      'fandango',
      'chandé',
      'merecumbé',
      'reggaeton',
      'electrónica',
      'jazz',
      'rock',
      'rap / hip-hop',
      'reggae',
      'música en vivo',
    ],
    'Tradicional': [
      'picó',
      'verbena',
      'carnaval barrial',
      'feria de artesanos',
      'festival gastronómico',
      'fiesta de fin de año',
      'novena navideña',
      'desfile',
      'reinado popular',
    ],
    'Artes y cultura': [
      'teatro comunitario',
      'cineclub',
      'danza folclórica',
      'stand-up comedy',
      'performance',
      'circo',
      'títeres / marionetas',
      'poesía / declamación',
      'exposición de arte',
      'galería',
      'grafiti / arte urbano',
    ],
    'Gastronomía y mercados': [
      'gastronomía',
      'mercado campesino',
      'food truck',
      'cata de vinos / cocteles',
      'taller de cocina',
      'festival de mariscos',
    ],
    'Deportes y bienestar': [
      'deportes',
      'fútbol',
      'atletismo',
      'ciclismo',
      'yoga / meditación',
      'crossfit',
      'artes marciales',
      'natación',
      'voleibol de playa',
      'skateboarding',
    ],
    'Academia y desarrollo': [
      'academia',
      'conferencia',
      'taller / workshop',
      'hackathon',
      'emprendimiento',
      'feria de ciencia',
      'charla TED-style',
      'networking',
    ],
    'Comunidad y social': [
      'voluntariado',
      'feria comunitaria',
      'minga barrial',
      'evento infantil',
      'evento familiar',
      'mercado de pulgas',
    ],
    'Otros': [
      'religioso / espiritual',
      'turismo cultural',
      'fotografia',
      'moda / pasarela',
      'tecnología',
      'videojuegos / gaming',
    ],
  };

  static List<String> get generalCategories => catalog.keys.toList(growable: false);

  static final Map<String, String> _specificToGeneral = {
    for (final entry in catalog.entries)
      for (final specific in entry.value)
        specific.toLowerCase().trim(): entry.key,
  };

  static List<String> specificCategoriesFor(String generalCategory) {
    return catalog[generalCategory] ?? const [];
  }

  static String? generalCategoryForSpecific(String specificCategory) {
    return _specificToGeneral[specificCategory.toLowerCase().trim()];
  }

  static String displayLabel(String generalCategory, String specificCategory) {
    if (generalCategory.isEmpty) {
      return specificCategory;
    }
    if (specificCategory.isEmpty) {
      return generalCategory;
    }
    return '$generalCategory · $specificCategory';
  }
}