/**
 * EJEMPLOS DE IMPLEMENTACIÓN FUTURA
 * 
 * Este archivo contiene ejemplos de cómo se usarán las APIs del backend
 * cuando se complete la integración. Actualmente, la app usa mockups.
 */

/**
 * EJEMPLO 1: Autenticación con API Real
 * 
 * Reemplazar en AuthContext.js cuando el backend esté listo
 */

import { authAPI, handleAPIError } from '../utils/api';

export const exampleAuthentication = {
  signIn: async (email, password) => {
    try {
      const response = await authAPI.login(email, password);
      const { token, user } = response.data;

      await AsyncStorage.setItem('userToken', token);
      await AsyncStorage.setItem('user', JSON.stringify(user));

      return { success: true, user, token };
    } catch (error) {
      const errorInfo = handleAPIError(error);
      return { success: false, error: errorInfo.message };
    }
  },

  signUp: async (email, password, name, role) => {
    try {
      const response = await authAPI.register(email, password, name, role);
      const { token, user } = response.data;

      await AsyncStorage.setItem('userToken', token);
      await AsyncStorage.setItem('user', JSON.stringify(user));

      return { success: true, user, token };
    } catch (error) {
      const errorInfo = handleAPIError(error);
      return { success: false, error: errorInfo.message };
    }
  },
};

/**
 * EJEMPLO 2: Obtener Eventos del API
 * 
 * Reemplazar en HomeScreen.js cuando el backend esté listo
 */

import { eventsAPI } from '../utils/api';
import { useState, useEffect } from 'react';

export const exampleGetEvents = () => {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchEvents = async () => {
      setLoading(true);
      try {
        const response = await eventsAPI.getAll();
        setEvents(response.data);
      } catch (error) {
        console.error('Error fetching events:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchEvents();
  }, []);

  return { events, loading };
};

/**
 * EJEMPLO 3: Crear Evento
 * 
 * Reemplazar en CreateEventScreen.js cuando el backend esté listo
 */

export const exampleCreateEvent = async (eventData) => {
  try {
    const response = await eventsAPI.create({
      title: eventData.title,
      category: eventData.category,
      date: eventData.date,
      location: eventData.location,
      description: eventData.description,
      image: eventData.image || null,
    });

    return { success: true, event: response.data };
  } catch (error) {
    const errorInfo = handleAPIError(error);
    return { success: false, error: errorInfo.message };
  }
};

/**
 * EJEMPLO 4: Buscar Eventos
 * 
 * Para implementar en HomeScreen cuando se active búsqueda
 */

export const exampleSearchEvents = async (query) => {
  try {
    const response = await eventsAPI.search(query);
    return { success: true, results: response.data };
  } catch (error) {
    const errorInfo = handleAPIError(error);
    return { success: false, error: errorInfo.message };
  }
};

/**
 * EJEMPLO 5: Participar en Evento
 * 
 * Para implementar en EventDetailScreen para clientes
 */

export const exampleJoinEvent = async (eventId) => {
  try {
    const response = await participationAPI.join(eventId);
    return { success: true, message: response.data.message };
  } catch (error) {
    const errorInfo = handleAPIError(error);
    return { success: false, error: errorInfo.message };
  }
};

/**
 * EJEMPLO 6: Obtener Recomendaciones
 * 
 * Para implementar en HomeScreen cuando se active sistema de recomendación
 */

import { recommendationsAPI } from '../utils/api';

export const exampleGetRecommendations = async () => {
  try {
    const response = await recommendationsAPI.getRecommendations(10);
    return { success: true, events: response.data };
  } catch (error) {
    const errorInfo = handleAPIError(error);
    return { success: false, error: errorInfo.message };
  }
};

/**
 * EJEMPLO 7: Agregar Comentario
 * 
 * Para implementar cuando se agregue sección de comentarios
 */

import { reviewsAPI } from '../utils/api';

export const exampleAddComment = async (eventId, rating, comment) => {
  try {
    const response = await reviewsAPI.createReview(eventId, rating, comment);
    return { success: true, review: response.data };
  } catch (error) {
    const errorInfo = handleAPIError(error);
    return { success: false, error: errorInfo.message };
  }
};

/**
 * NOTAS IMPORTANTES PARA LA INTEGRACIÓN:
 * 
 * 1. Reemplazar las funciones mockup en AuthContext con las del API
 * 2. Agregar estados de carga en cada pantalla
 * 3. Manejar errores de conexión apropiadamente
 * 4. Implementar reintentos para fallos de red
 * 5. Cachear datos cuando sea posible
 * 6. Validar datos en backend y frontend
 * 7. Implementar tokens de acceso con expiración
 * 8. Usar la función handleAPIError para consistencia
 * 9. Agregar logs para debugging en desarrollo
 * 10. Implementar notificaciones de error para el usuario
 */
