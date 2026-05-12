/**
 * Utilidades generales para la aplicación
 */

/**
 * Valida formato de email
 * @param {string} email - Email a validar
 * @returns {boolean} - True si es válido
 */
export const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Valida contraseña (mínimo 6 caracteres)
 * @param {string} password - Contraseña a validar
 * @returns {boolean} - True si es válida
 */
export const validatePassword = (password) => {
  return password && password.length >= 6;
};

/**
 * Valida nombre (mínimo 2 caracteres)
 * @param {string} name - Nombre a validar
 * @returns {boolean} - True si es válido
 */
export const validateName = (name) => {
  return name && name.trim().length >= 2;
};

/**
 * Formatea fecha para mostrar
 * @param {string} dateString - Fecha en formato string
 * @returns {string} - Fecha formateada
 */
export const formatDate = (dateString) => {
  try {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  } catch (e) {
    return dateString;
  }
};

/**
 * Obtiene iniciales de un nombre
 * @param {string} name - Nombre completo
 * @returns {string} - Iniciales
 */
export const getInitials = (name) => {
  return name
    .split(' ')
    .map((word) => word[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
};

/**
 * Capitaliza primera letra de un string
 * @param {string} str - String a capitalizar
 * @returns {string} - String capitalizado
 */
export const capitalize = (str) => {
  return str.charAt(0).toUpperCase() + str.slice(1);
};

/**
 * Trunca texto a cierta longitud
 * @param {string} text - Texto a truncar
 * @param {number} length - Longitud máxima
 * @returns {string} - Texto truncado
 */
export const truncateText = (text, length = 50) => {
  if (text.length <= length) return text;
  return text.substring(0, length) + '...';
};

/**
 * Calcula diferencia de días entre dos fechas
 * @param {Date} date1 - Primera fecha
 * @param {Date} date2 - Segunda fecha
 * @returns {number} - Diferencia en días
 */
export const daysDifference = (date1, date2) => {
  const diffTime = Math.abs(date2 - date1);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
};

/**
 * Ordena array de eventos por fecha
 * @param {Array} events - Array de eventos
 * @param {string} order - 'asc' o 'desc'
 * @returns {Array} - Array ordenado
 */
export const sortEventsByDate = (events, order = 'asc') => {
  const sorted = [...events].sort((a, b) => {
    const dateA = new Date(a.date);
    const dateB = new Date(b.date);
    return order === 'asc' ? dateA - dateB : dateB - dateA;
  });
  return sorted;
};

/**
 * Filtra eventos por categoría
 * @param {Array} events - Array de eventos
 * @param {string} category - Categoría a filtrar
 * @returns {Array} - Array filtrado
 */
export const filterEventsByCategory = (events, category) => {
  if (!category) return events;
  return events.filter((event) => event.category === category);
};

/**
 * Busca eventos por palabra clave
 * @param {Array} events - Array de eventos
 * @param {string} query - Término de búsqueda
 * @returns {Array} - Array filtrado
 */
export const searchEvents = (events, query) => {
  if (!query) return events;
  const lowerQuery = query.toLowerCase();
  return events.filter(
    (event) =>
      event.title.toLowerCase().includes(lowerQuery) ||
      event.description.toLowerCase().includes(lowerQuery) ||
      event.location.toLowerCase().includes(lowerQuery)
  );
};

/**
 * Validación de formulario genérica
 * @param {Object} formData - Datos del formulario
 * @param {Array} requiredFields - Campos requeridos
 * @returns {Object} - Errores encontrados
 */
export const validateForm = (formData, requiredFields) => {
  const errors = {};
  
  requiredFields.forEach((field) => {
    if (!formData[field] || formData[field].trim() === '') {
      errors[field] = `${capitalize(field)} es requerido`;
    }
  });

  return errors;
};

/**
 * Genera ID único temporal (para mockups)
 * @returns {string} - ID único
 */
export const generateId = () => {
  return `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

/**
 * Calcula porcentaje
 * @param {number} value - Valor
 * @param {number} total - Total
 * @returns {number} - Porcentaje
 */
export const calculatePercentage = (value, total) => {
  if (total === 0) return 0;
  return Math.round((value / total) * 100);
};

/**
 * Paleta de colores
 */
export const colors = {
  primary: '#6C63FF',
  secondary: '#FF6B6B',
  success: '#51CF66',
  warning: '#FFD93D',
  danger: '#FF6B6B',
  background: '#F5F5F5',
  surface: '#FFF',
  text: '#1A1A1A',
  textSecondary: '#666',
  textTertiary: '#999',
  border: '#E0E0E0',
};

/**
 * Tamaños de fuente consistentes
 */
export const fontSizes = {
  h1: 28,
  h2: 24,
  h3: 20,
  h4: 18,
  h5: 16,
  h6: 14,
  body: 16,
  small: 12,
  tiny: 10,
};

/**
 * Espaciado consistente
 */
export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
};
