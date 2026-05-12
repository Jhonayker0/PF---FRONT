import React, { useState } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  Text,
  StyleSheet,
  ScrollView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export const CreateEventScreen = ({ navigation }) => {
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('');
  const [date, setDate] = useState('');
  const [location, setLocation] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);

  const categories = ['Festival', 'Música', 'Arte', 'Teatro', 'Gastronomía', 'Otro'];

  const handleCreateEvent = async () => {
    if (!title || !category || !date || !location || !description) {
      Alert.alert('Error', 'Por favor completa todos los campos');
      return;
    }

    setLoading(true);
    // Simular envío al servidor
    setTimeout(() => {
      setLoading(false);
      Alert.alert('Éxito', 'Evento creado exitosamente', [
        {
          text: 'OK',
          onPress: () => navigation.goBack(),
        },
      ]);
    }, 1500);
  };

  return (
    <SafeAreaView style={styles.container} edges={['top', 'left', 'right']}>
      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <TouchableOpacity
          onPress={() => navigation.goBack()}
          style={styles.backButton}
          disabled={loading}
        >
          <Text style={styles.backText}>← Volver</Text>
        </TouchableOpacity>

        <Text style={styles.title}>Crear Nuevo Evento</Text>
        <Text style={styles.subtitle}>Comparte tu evento con la comunidad</Text>

        <View style={styles.form}>
          <View style={styles.formGroup}>
            <Text style={styles.label}>Nombre del Evento *</Text>
            <TextInput
              style={styles.input}
              placeholder="ej: Carnaval 2024"
              value={title}
              onChangeText={setTitle}
              editable={!loading}
              placeholderTextColor="#999"
            />
          </View>

          <View style={styles.formGroup}>
            <Text style={styles.label}>Categoría *</Text>
            <View style={styles.categoryContainer}>
              {categories.map((cat) => (
                <TouchableOpacity
                  key={cat}
                  style={[
                    styles.categoryButton,
                    category === cat && styles.categoryButtonActive,
                  ]}
                  onPress={() => setCategory(cat)}
                  disabled={loading}
                >
                  <Text
                    style={[
                      styles.categoryButtonText,
                      category === cat && styles.categoryButtonTextActive,
                    ]}
                  >
                    {cat}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          <View style={styles.formGroup}>
            <Text style={styles.label}>Fecha *</Text>
            <TextInput
              style={styles.input}
              placeholder="ej: 20 de Febrero de 2024"
              value={date}
              onChangeText={setDate}
              editable={!loading}
              placeholderTextColor="#999"
            />
          </View>

          <View style={styles.formGroup}>
            <Text style={styles.label}>Ubicación *</Text>
            <TextInput
              style={styles.input}
              placeholder="ej: Centro Histórico de Barranquilla"
              value={location}
              onChangeText={setLocation}
              editable={!loading}
              placeholderTextColor="#999"
            />
          </View>

          <View style={styles.formGroup}>
            <Text style={styles.label}>Descripción *</Text>
            <TextInput
              style={[styles.input, styles.textArea]}
              placeholder="Describe tu evento..."
              value={description}
              onChangeText={setDescription}
              editable={!loading}
              multiline
              numberOfLines={5}
              textAlignVertical="top"
              placeholderTextColor="#999"
            />
          </View>

          {loading ? (
            <ActivityIndicator size="large" color="#6C63FF" style={styles.loader} />
          ) : (
            <>
              <TouchableOpacity
                style={styles.button}
                onPress={handleCreateEvent}
                activeOpacity={0.7}
              >
                <Text style={styles.buttonText}>Crear Evento</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.cancelButton}
                onPress={() => navigation.goBack()}
              >
                <Text style={styles.cancelButtonText}>Cancelar</Text>
              </TouchableOpacity>
            </>
          )}
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
  content: {
    paddingHorizontal: 20,
    paddingTop: 10,
  },
  backButton: {
    paddingVertical: 10,
  },
  backText: {
    color: '#6C63FF',
    fontSize: 16,
    fontWeight: '600',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#1A1A1A',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 30,
  },
  form: {
    gap: 20,
    paddingBottom: 30,
  },
  formGroup: {
    gap: 8,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1A1A1A',
  },
  input: {
    backgroundColor: '#FFF',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 12,
    fontSize: 16,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    color: '#1A1A1A',
  },
  textArea: {
    paddingVertical: 12,
    minHeight: 100,
  },
  categoryContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  categoryButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    backgroundColor: '#FFF',
  },
  categoryButtonActive: {
    borderColor: '#6C63FF',
    backgroundColor: '#6C63FF',
  },
  categoryButtonText: {
    fontSize: 12,
    color: '#1A1A1A',
    fontWeight: '500',
  },
  categoryButtonTextActive: {
    color: '#FFF',
  },
  button: {
    backgroundColor: '#6C63FF',
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '600',
  },
  cancelButton: {
    backgroundColor: '#FFF',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    paddingVertical: 14,
    alignItems: 'center',
  },
  cancelButtonText: {
    color: '#666',
    fontSize: 16,
    fontWeight: '600',
  },
  loader: {
    marginVertical: 20,
  },
});
