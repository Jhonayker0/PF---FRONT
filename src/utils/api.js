import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Configuración de API para conexión con backend
 * 
 * En desarrollo: usa endpoints locales
 * En producción: usa endpoints del servidor
 */

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

// Crear instancia de axios
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para agregar token a cada request
apiClient.interceptors.request.use(
  async (config) => {
    try {
      const token = await AsyncStorage.getItem('userToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    } catch (error) {
      console.error('Error getting token:', error);
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para manejar errores
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Token expirado, limpiar sesión
      await AsyncStorage.removeItem('userToken');
      await AsyncStorage.removeItem('user');
      // Aquí podría redirigirse a login
    }
    return Promise.reject(error);
  }
);

/**
 * Endpoints de Autenticación
 */
export const authAPI = {
  login: (email, password) =>
    apiClient.post('/auth/login', { email, password }),
  
  register: (email, password, name, role) =>
    apiClient.post('/auth/register', { email, password, name, role }),
  
  logout: () =>
    apiClient.post('/auth/logout'),
  
  refreshToken: () =>
    apiClient.post('/auth/refresh'),
};

/**
 * Endpoints de Eventos
 */
export const eventsAPI = {
  // Obtener todos los eventos
  getAll: (params = {}) =>
    apiClient.get('/events', { params }),
  
  // Obtener un evento por ID
  getById: (id) =>
    apiClient.get(`/events/${id}`),
  
  // Crear evento (solo admin)
  create: (eventData) =>
    apiClient.post('/events', eventData),
  
  // Actualizar evento (solo admin)
  update: (id, eventData) =>
    apiClient.put(`/events/${id}`, eventData),
  
  // Eliminar evento (solo admin)
  delete: (id) =>
    apiClient.delete(`/events/${id}`),
  
  // Buscar eventos
  search: (query) =>
    apiClient.get('/events/search', { params: { q: query } }),
  
  // Filtrar por categoría
  filterByCategory: (category) =>
    apiClient.get('/events/category', { params: { category } }),
};

/**
 * Endpoints de Participación
 */
export const participationAPI = {
  // Registrarse en un evento
  join: (eventId) =>
    apiClient.post(`/events/${eventId}/join`),
  
  // Cancelar participación
  leave: (eventId) =>
    apiClient.post(`/events/${eventId}/leave`),
  
  // Obtener eventos del usuario
  getUserEvents: () =>
    apiClient.get('/user/events'),
  
  // Obtener eventos a los que participa
  getUserParticipations: () =>
    apiClient.get('/user/participations'),
};

/**
 * Endpoints de Recomendaciones
 */
export const recommendationsAPI = {
  // Obtener eventos recomendados
  getRecommendations: (limit = 10) =>
    apiClient.get('/recommendations', { params: { limit } }),
  
  // Obtener recomendaciones por categoría
  getByCategory: (category, limit = 10) =>
    apiClient.get(`/recommendations/category/${category}`, { params: { limit } }),
};

/**
 * Endpoints de Usuario
 */
export const userAPI = {
  // Obtener perfil
  getProfile: () =>
    apiClient.get('/user/profile'),
  
  // Actualizar perfil
  updateProfile: (userData) =>
    apiClient.put('/user/profile', userData),
  
  // Cambiar contraseña
  changePassword: (currentPassword, newPassword) =>
    apiClient.post('/user/change-password', {
      currentPassword,
      newPassword,
    }),
  
  // Obtener preferencias
  getPreferences: () =>
    apiClient.get('/user/preferences'),
  
  // Actualizar preferencias
  updatePreferences: (preferences) =>
    apiClient.put('/user/preferences', preferences),
};

/**
 * Endpoints de Comentarios y Calificaciones
 */
export const reviewsAPI = {
  // Obtener comentarios de un evento
  getEventReviews: (eventId) =>
    apiClient.get(`/events/${eventId}/reviews`),
  
  // Crear comentario
  createReview: (eventId, rating, comment) =>
    apiClient.post(`/events/${eventId}/reviews`, { rating, comment }),
  
  // Actualizar comentario
  updateReview: (eventId, reviewId, rating, comment) =>
    apiClient.put(`/events/${eventId}/reviews/${reviewId}`, { rating, comment }),
  
  // Eliminar comentario
  deleteReview: (eventId, reviewId) =>
    apiClient.delete(`/events/${eventId}/reviews/${reviewId}`),
};

/**
 * Manejo de errores genérico
 */
export const handleAPIError = (error) => {
  if (error.response) {
    // Error del servidor
    return {
      status: error.response.status,
      message: error.response.data?.message || 'Error del servidor',
      errors: error.response.data?.errors || {},
    };
  } else if (error.request) {
    // No hay respuesta
    return {
      status: 0,
      message: 'No hay conexión con el servidor',
    };
  } else {
    // Error en la solicitud
    return {
      status: 0,
      message: error.message || 'Error desconocido',
    };
  }
};

export default apiClient;
