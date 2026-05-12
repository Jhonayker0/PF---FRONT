import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  FlatList,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AuthContext } from '../context/AuthContext';

export const HomeScreen = ({ navigation }) => {
  const { state, signOut } = React.useContext(AuthContext);
  const [events] = useState([
    {
      id: '1',
      title: 'Carnaval de Barranquilla 2024',
      category: 'Festival',
      date: '20 de Febrero',
      location: 'Centro Histórico',
      description: 'El festival cultural más importante del Caribe',
      image: '🎭',
    },
    {
      id: '2',
      title: 'Festival de Música Tropical',
      category: 'Música',
      date: '15 de Marzo',
      location: 'Parque Bolívar',
      description: 'Encuentra lo mejor de la música tropical colombiana',
      image: '🎵',
    },
    {
      id: '3',
      title: 'Exposición de Arte Local',
      category: 'Arte',
      date: '28 de Febrero',
      location: 'Galería del Centro',
      description: 'Artistas locales muestran sus obras',
      image: '🎨',
    },
  ]);

  const isAdmin = state.user?.role === 'admin';

  const handleLogout = () => {
    Alert.alert(
      'Cerrar sesión',
      '¿Estás seguro de que deseas cerrar sesión?',
      [
        { text: 'Cancelar', onPress: () => {}, style: 'cancel' },
        {
          text: 'Cerrar sesión',
          onPress: signOut,
          style: 'destructive',
        },
      ]
    );
  };

  const renderEventCard = ({ item }) => (
    <TouchableOpacity
      style={styles.eventCard}
      onPress={() => navigation.navigate('EventDetail', { event: item })}
      activeOpacity={0.7}
    >
      <View style={styles.eventImage}>
        <Text style={styles.eventEmoji}>{item.image}</Text>
      </View>
      <View style={styles.eventInfo}>
        <View style={styles.categoryBadge}>
          <Text style={styles.categoryText}>{item.category}</Text>
        </View>
        <Text style={styles.eventTitle}>{item.title}</Text>
        <Text style={styles.eventDate}>{item.date}</Text>
        <Text style={styles.eventLocation}>📍 {item.location}</Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container} edges={['top', 'left', 'right']}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.header}>
          <View>
            <Text style={styles.greeting}>Bienvenido,</Text>
            <Text style={styles.userName}>{state.user?.name}</Text>
          </View>
          <TouchableOpacity
            style={styles.logoutButton}
            onPress={handleLogout}
            activeOpacity={0.7}
          >
            <Text style={styles.logoutText}>Salir</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.roleSection}>
          <View
            style={[
              styles.roleBadge,
              isAdmin && styles.roleBadgeAdmin,
            ]}
          >
            <Text style={styles.roleText}>
              {isAdmin ? '👨‍💼 Organizador' : '👤 Cliente'}
            </Text>
          </View>
        </View>

        {isAdmin ? (
          <View style={styles.adminSection}>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>Gestión de Eventos</Text>
            </View>
            <TouchableOpacity
              style={styles.createEventButton}
              onPress={() => navigation.navigate('CreateEvent')}
              activeOpacity={0.7}
            >
              <Text style={styles.createEventButtonText}>+ Crear Nuevo Evento</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <View style={styles.searchSection}>
            <TouchableOpacity style={styles.searchBox} activeOpacity={0.7}>
              <Text style={styles.searchPlaceholder}>🔍 Buscar eventos...</Text>
            </TouchableOpacity>
          </View>
        )}

        <View style={styles.eventsSection}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Eventos Disponibles</Text>
            <TouchableOpacity activeOpacity={0.7}>
              <Text style={styles.seeAll}>Ver todo →</Text>
            </TouchableOpacity>
          </View>

          <FlatList
            data={events}
            renderItem={renderEventCard}
            keyExtractor={(item) => item.id}
            scrollEnabled={false}
            ItemSeparatorComponent={() => <View style={{ height: 12 }} />}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 20,
  },
  greeting: {
    fontSize: 14,
    color: '#999',
  },
  userName: {
    fontSize: 24,
    fontWeight: '700',
    color: '#1A1A1A',
  },
  logoutButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  logoutText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  roleSection: {
    paddingHorizontal: 20,
    paddingBottom: 12,
  },
  roleBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: '#E8F0FF',
  },
  roleBadgeAdmin: {
    backgroundColor: '#FFF0E8',
  },
  roleText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#6C63FF',
  },
  roleBadgeAdmin: {},
  adminSection: {
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#1A1A1A',
  },
  seeAll: {
    fontSize: 14,
    color: '#6C63FF',
    fontWeight: '600',
  },
  createEventButton: {
    backgroundColor: '#6C63FF',
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: 'center',
  },
  createEventButtonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '600',
  },
  searchSection: {
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  searchBox: {
    backgroundColor: '#FFF',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  searchPlaceholder: {
    fontSize: 16,
    color: '#999',
  },
  eventsSection: {
    paddingHorizontal: 20,
    paddingBottom: 30,
  },
  eventCard: {
    backgroundColor: '#FFF',
    borderRadius: 12,
    overflow: 'hidden',
    flexDirection: 'row',
    height: 140,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  eventImage: {
    width: 140,
    backgroundColor: '#F0E8FF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  eventEmoji: {
    fontSize: 48,
  },
  eventInfo: {
    flex: 1,
    padding: 12,
    justifyContent: 'space-between',
  },
  categoryBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    backgroundColor: '#E8F0FF',
  },
  categoryText: {
    fontSize: 10,
    color: '#6C63FF',
    fontWeight: '600',
  },
  eventTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: '#1A1A1A',
  },
  eventDate: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  eventLocation: {
    fontSize: 12,
    color: '#999',
    marginTop: 4,
  },
});
