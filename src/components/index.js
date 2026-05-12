import React from 'react';
import { StyleSheet } from 'react-native';

/**
 * EventCard Component
 * 
 * Componente reutilizable para mostrar eventos en formato tarjeta.
 * Será usado en HomeScreen y en listas de búsqueda.
 * 
 * @example
 * <EventCard 
 *   event={event} 
 *   onPress={() => navigation.navigate('EventDetail')} 
 *   showDescription={false}
 * />
 */

export const EventCard = ({
  event,
  onPress,
  showDescription = true,
  variant = 'compact', // 'compact' | 'detailed'
}) => {
  // Implementación pendiente
  return null;
};

const styles = StyleSheet.create({
  // Estilos pendientes
});

/**
 * Button Component
 * 
 * Botón reutilizable con variantes.
 * 
 * @example
 * <Button 
 *   title="Crear Evento" 
 *   onPress={handleCreate}
 *   variant="primary"
 *   loading={isLoading}
 *   disabled={false}
 * />
 */

export const Button = ({
  title,
  onPress,
  variant = 'primary', // 'primary' | 'secondary' | 'danger'
  loading = false,
  disabled = false,
  icon = null,
}) => {
  // Implementación pendiente
  return null;
};

/**
 * Input Component
 * 
 * Input reutilizable con validación.
 * 
 * @example
 * <Input
 *   placeholder="Ingresa tu email"
 *   value={email}
 *   onChangeText={setEmail}
 *   type="email"
 *   error={emailError}
 * />
 */

export const Input = ({
  placeholder,
  value,
  onChangeText,
  type = 'text',
  error = null,
  multiline = false,
  disabled = false,
}) => {
  // Implementación pendiente
  return null;
};

/**
 * CategoryBadge Component
 * 
 * Insignia para mostrar categoría de evento.
 * 
 * @example
 * <CategoryBadge category="Música" />
 */

export const CategoryBadge = ({ category }) => {
  // Implementación pendiente
  return null;
};

/**
 * LoadingSpinner Component
 * 
 * Indicador de carga reutilizable.
 * 
 * @example
 * <LoadingSpinner message="Cargando eventos..." />
 */

export const LoadingSpinner = ({ message = '' }) => {
  // Implementación pendiente
  return null;
};

/**
 * EmptyState Component
 * 
 * Componente para mostrar cuando no hay datos.
 * 
 * @example
 * <EmptyState 
 *   icon="🎭"
 *   title="Sin eventos"
 *   message="No hay eventos disponibles"
 *   action={{
 *     title: "Crear evento",
 *     onPress: handleCreate
 *   }}
 * />
 */

export const EmptyState = ({
  icon = '📭',
  title = '',
  message = '',
  action = null,
}) => {
  // Implementación pendiente
  return null;
};

/**
 * Modal Component
 * 
 * Modal reutilizable para confirmaciones y dialogs.
 * 
 * @example
 * <Modal
 *   visible={showModal}
 *   title="¿Eliminar evento?"
 *   message="Esta acción no se puede deshacer"
 *   buttons={[
 *     { text: 'Cancelar', onPress: () => {}, style: 'cancel' },
 *     { text: 'Eliminar', onPress: handleDelete, style: 'destructive' }
 *   ]}
 * />
 */

export const Modal = ({
  visible,
  title,
  message,
  buttons = [],
}) => {
  // Implementación pendiente
  return null;
};

/**
 * Header Component
 * 
 * Header reutilizable para pantallas.
 * 
 * @example
 * <Header
 *   title="Eventos"
 *   subtitle="Descubre eventos culturales"
 *   rightAction={{ icon: '⚙️', onPress: handleSettings }}
 *   onBackPress={handleBack}
 * />
 */

export const Header = ({
  title,
  subtitle = null,
  rightAction = null,
  onBackPress = null,
}) => {
  // Implementación pendiente
  return null;
};

/**
 * RatingBar Component
 * 
 * Barra de calificación interactiva.
 * 
 * @example
 * <RatingBar
 *   rating={4.5}
 *   onRate={handleRate}
 *   editable={true}
 * />
 */

export const RatingBar = ({
  rating = 0,
  onRate = null,
  editable = false,
}) => {
  // Implementación pendiente
  return null;
};
