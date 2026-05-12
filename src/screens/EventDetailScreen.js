import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AuthContext } from '../context/AuthContext';

export const EventDetailScreen = ({ route, navigation }) => {
  const { event } = route.params;
  const { state } = React.useContext(AuthContext);
  const isAdmin = state.user?.role === 'admin';

  const handleParticipate = () => {
    Alert.alert('Éxito', '¡Te has registrado en el evento!');
  };

  const handleDelete = () => {
    Alert.alert(
      'Eliminar evento',
      '¿Estás seguro de que deseas eliminar este evento?',
      [
        { text: 'Cancelar', onPress: () => {}, style: 'cancel' },
        {
          text: 'Eliminar',
          onPress: () => {
            Alert.alert('Éxito', 'Evento eliminado');
            navigation.goBack();
          },
          style: 'destructive',
        },
      ]
    );
  };

  return (
    <SafeAreaView style={styles.container} edges={['top', 'left', 'right']}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.backButton}
        >
          <Text style={styles.backText}>← Volver</Text>
        </TouchableOpacity>

        <View style={styles.imageSection}>
          <Text style={styles.eventEmoji}>{event.image}</Text>
        </View>

        <View style={styles.content}>
          <View style={styles.categoryBadge}>
            <Text style={styles.categoryText}>{event.category}</Text>
          </View>

          <Text style={styles.title}>{event.title}</Text>

          <View style={styles.infoCard}>
            <View style={styles.infoRow}>
              <Text style={styles.infoIcon}>📅</Text>
              <View>
                <Text style={styles.infoLabel}>Fecha</Text>
                <Text style={styles.infoValue}>{event.date}</Text>
              </View>
            </View>

            <View style={styles.divider} />

            <View style={styles.infoRow}>
              <Text style={styles.infoIcon}>📍</Text>
              <View style={{ flex: 1 }}>
                <Text style={styles.infoLabel}>Ubicación</Text>
                <Text style={styles.infoValue}>{event.location}</Text>
              </View>
            </View>
          </View>

          <View style={styles.descriptionSection}>
            <Text style={styles.sectionTitle}>Acerca del Evento</Text>
            <Text style={styles.description}>{event.description}</Text>
          </View>

          <View style={styles.statsSection}>
            <View style={styles.stat}>
              <Text style={styles.statNumber}>127</Text>
              <Text style={styles.statLabel}>Asistentes</Text>
            </View>
            <View style={styles.stat}>
              <Text style={styles.statNumber}>4.8</Text>
              <Text style={styles.statLabel}>Calificación</Text>
            </View>
            <View style={styles.stat}>
              <Text style={styles.statNumber}>89</Text>
              <Text style={styles.statLabel}>Comentarios</Text>
            </View>
          </View>

          <View style={styles.buttonSection}>
            {isAdmin ? (
              <>
                <TouchableOpacity
                  style={styles.editButton}
                  activeOpacity={0.7}
                >
                  <Text style={styles.editButtonText}>✏️ Editar Evento</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.deleteButton}
                  onPress={handleDelete}
                  activeOpacity={0.7}
                >
                  <Text style={styles.deleteButtonText}>🗑️ Eliminar Evento</Text>
                </TouchableOpacity>
              </>
            ) : (
              <TouchableOpacity
                style={styles.participateButton}
                onPress={handleParticipate}
                activeOpacity={0.7}
              >
                <Text style={styles.participateButtonText}>Participar en el Evento</Text>
              </TouchableOpacity>
            )}
          </View>
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
  backButton: {
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  backText: {
    color: '#6C63FF',
    fontSize: 16,
    fontWeight: '600',
  },
  imageSection: {
    height: 200,
    backgroundColor: '#F0E8FF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  eventEmoji: {
    fontSize: 80,
  },
  content: {
    paddingHorizontal: 20,
    paddingTop: 20,
  },
  categoryBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: '#E8F0FF',
    marginBottom: 12,
  },
  categoryText: {
    fontSize: 12,
    color: '#6C63FF',
    fontWeight: '600',
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
    color: '#1A1A1A',
    marginBottom: 20,
  },
  infoCard: {
    backgroundColor: '#FFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  infoRow: {
    flexDirection: 'row',
    gap: 12,
    alignItems: 'flex-start',
  },
  infoIcon: {
    fontSize: 20,
  },
  infoLabel: {
    fontSize: 12,
    color: '#999',
    marginBottom: 4,
  },
  infoValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1A1A1A',
  },
  divider: {
    height: 1,
    backgroundColor: '#E0E0E0',
    marginVertical: 12,
  },
  descriptionSection: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#1A1A1A',
    marginBottom: 12,
  },
  description: {
    fontSize: 14,
    color: '#666',
    lineHeight: 22,
  },
  statsSection: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    backgroundColor: '#FFF',
    borderRadius: 12,
    paddingVertical: 16,
    marginBottom: 20,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  stat: {
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 20,
    fontWeight: '700',
    color: '#6C63FF',
  },
  statLabel: {
    fontSize: 12,
    color: '#999',
    marginTop: 4,
  },
  buttonSection: {
    gap: 12,
    paddingBottom: 30,
  },
  participateButton: {
    backgroundColor: '#6C63FF',
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: 'center',
  },
  participateButtonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '600',
  },
  editButton: {
    backgroundColor: '#6C63FF',
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: 'center',
  },
  editButtonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '600',
  },
  deleteButton: {
    backgroundColor: '#FFF',
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#FF6B6B',
    paddingVertical: 14,
    alignItems: 'center',
  },
  deleteButtonText: {
    color: '#FF6B6B',
    fontSize: 16,
    fontWeight: '600',
  },
});
