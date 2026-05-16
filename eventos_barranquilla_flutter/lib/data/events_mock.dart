import '../models/event.dart';

const List<Event> mockEvents = [
  // Eventos Destacados (para Discover carousel)
  Event(
    id: '1',
    title: 'Carnaval de Barranquilla',
    category: 'Festival',
    date: '20 de Febrero',
    location: 'Centro Histórico',
    description:
        'El festival cultural más importante del Caribe colombiano. Con desfiles, música, danza y tradición.',
    image: '🎭',
  ),
  Event(
    id: '2',
    title: 'Festival de Música Tropical',
    category: 'Música',
    date: '15 de Marzo',
    location: 'Parque Bolívar',
    description:
        'Una noche con lo mejor de la música tropical colombiana con artistas nacionales e internacionales.',
    image: '🎵',
  ),
  Event(
    id: '3',
    title: 'Exposición de Arte Local',
    category: 'Arte',
    date: '28 de Febrero',
    location: 'Galería del Centro',
    description:
        'Artistas locales muestran sus obras en una experiencia única que celebra el talento barranquillero.',
    image: '🎨',
  ),

  // Más eventos por categoría - Música
  Event(
    id: '4',
    title: 'Concierto de Champeta en Vivo',
    category: 'Música',
    date: '5 de Marzo',
    location: 'Estadio Metropolitano',
    description: 'Los mejores artistas de champeta colombiana en un solo escenario.',
    image: '🎤',
  ),
  Event(
    id: '5',
    title: 'Noche de Salsa Caribeña',
    category: 'Música',
    date: '12 de Marzo',
    location: 'Club Nocturno Centro',
    description: 'Disfruta de la mejor salsa con orquesta en vivo toda la noche.',
    image: '💃',
  ),
  Event(
    id: '6',
    title: 'Festival de Jazz Barranquilla',
    category: 'Música',
    date: '22 de Abril',
    location: 'Teatro Amira de la Rosa',
    description: 'Artistas internacionales traen el mejor jazz a la ciudad.',
    image: '🎷',
  ),

  // Eventos por categoría - Arte
  Event(
    id: '7',
    title: 'Taller de Pintura Acrílica',
    category: 'Arte',
    date: '18 de Marzo',
    location: 'Estudio Creativo',
    description: 'Aprende técnicas de pintura acrílica con artistas profesionales.',
    image: '🖌️',
  ),
  Event(
    id: '8',
    title: 'Bienal de Arte Contemporáneo',
    category: 'Arte',
    date: '25 de Abril',
    location: 'Centro de Convenciones',
    description: 'La más importante muestra de arte contemporáneo del Caribe.',
    image: '🖼️',
  ),
  Event(
    id: '9',
    title: 'Exposición Fotográfica "Barranquilla en Colores"',
    category: 'Arte',
    date: '8 de Marzo',
    location: 'Museo Antropológico',
    description: 'Fotos documentales que muestran la cultura y tradición de la ciudad.',
    image: '📸',
  ),

  // Eventos por categoría - Cultura
  Event(
    id: '10',
    title: 'Taller de Cocina Colombiana',
    category: 'Cultura',
    date: '10 de Abril',
    location: 'Centro Comercial',
    description:
        'Aprende a cocinar platos tradicionales colombianos con chefs locales reconocidos.',
    image: '🍳',
  ),
  Event(
    id: '11',
    title: 'Cata de Café Colombiano',
    category: 'Cultura',
    date: '16 de Marzo',
    location: 'Café Casa Mayor',
    description: 'Descubre los sabores únicos del café de diferentes regiones colombianas.',
    image: '☕',
  ),
  Event(
    id: '12',
    title: 'Noche de Poesía y Declamación',
    category: 'Cultura',
    date: '20 de Abril',
    location: 'Biblioteca Pública',
    description: 'Poetas locales e internacionales comparten sus obras y emociones.',
    image: '📖',
  ),

  // Eventos por categoría - Deporte
  Event(
    id: '13',
    title: 'Maratón Barranquilla 2024',
    category: 'Deporte',
    date: '2 de Marzo',
    location: 'Malecón del Río Magdalena',
    description:
        'Corre los 10km, 5km o camina en el recorrido más hermoso de la ciudad.',
    image: '🏃',
  ),
  Event(
    id: '14',
    title: 'Torneo de Fútbol Playa',
    category: 'Deporte',
    date: '30 de Marzo',
    location: 'Playa El Rodadero',
    description: 'Competencia amistosa de fútbol playa con premios y diversión.',
    image: '⚽',
  ),
  Event(
    id: '15',
    title: 'Clase de Yoga Matutina',
    category: 'Deporte',
    date: '5 de Mayo',
    location: 'Parque Simón Bolívar',
    description: 'Sesión de yoga al aire libre para todos los niveles.',
    image: '🧘',
  ),

  // Eventos por categoría - Gastronomía
  Event(
    id: '16',
    title: 'Festival Gastronómico Caribeño',
    category: 'Gastronomía',
    date: '12 de Mayo',
    location: 'Centro de Ferias y Exposiciones',
    description:
        'Los mejores restaurantes de la ciudad presentan sus creaciones culinarias.',
    image: '🍽️',
  ),
  Event(
    id: '17',
    title: 'Degustación de Comida Rápida Gourmet',
    category: 'Gastronomía',
    date: '8 de Mayo',
    location: 'Zona Rosa Comercial',
    description: 'Hamburguesas, pizzas y más en versión premium con chefs reconocidos.',
    image: '🍔',
  ),
];
