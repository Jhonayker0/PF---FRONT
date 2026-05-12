import React, { useState } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  Alert,
  ScrollView,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AuthContext } from '../context/AuthContext';

export const RegisterScreen = ({ navigation }) => {
  const { signUp } = React.useContext(AuthContext);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [role, setRole] = useState('client');
  const [loading, setLoading] = useState(false);

  const handleRegister = async () => {
    if (!name || !email || !password || !confirmPassword) {
      Alert.alert('Error', 'Por favor completa todos los campos');
      return;
    }

    if (password !== confirmPassword) {
      Alert.alert('Error', 'Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      Alert.alert('Error', 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setLoading(true);
    const result = await signUp(email, password, name, role);
    setLoading(false);

    if (!result.success) {
      Alert.alert('Error de Registro', result.error);
    }
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

        <Text style={styles.title}>Crear Cuenta</Text>
        <Text style={styles.subtitle}>Únete a nuestra comunidad</Text>

        <View style={styles.form}>
          <TextInput
            style={styles.input}
            placeholder="Nombre completo"
            value={name}
            onChangeText={setName}
            editable={!loading}
            placeholderTextColor="#999"
          />

          <TextInput
            style={styles.input}
            placeholder="Correo electrónico"
            value={email}
            onChangeText={setEmail}
            editable={!loading}
            keyboardType="email-address"
            placeholderTextColor="#999"
          />

          <TextInput
            style={styles.input}
            placeholder="Contraseña"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            editable={!loading}
            placeholderTextColor="#999"
          />

          <TextInput
            style={styles.input}
            placeholder="Confirmar contraseña"
            value={confirmPassword}
            onChangeText={setConfirmPassword}
            secureTextEntry
            editable={!loading}
            placeholderTextColor="#999"
          />

          <View style={styles.roleSection}>
            <Text style={styles.roleLabel}>¿Cuál es tu rol?</Text>
            <View style={styles.roleButtons}>
              <TouchableOpacity
                style={[
                  styles.roleButton,
                  role === 'client' && styles.roleButtonActive,
                ]}
                onPress={() => setRole('client')}
                disabled={loading}
              >
                <Text
                  style={[
                    styles.roleButtonText,
                    role === 'client' && styles.roleButtonTextActive,
                  ]}
                >
                  Cliente
                </Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  styles.roleButton,
                  role === 'admin' && styles.roleButtonActive,
                ]}
                onPress={() => setRole('admin')}
                disabled={loading}
              >
                <Text
                  style={[
                    styles.roleButtonText,
                    role === 'admin' && styles.roleButtonTextActive,
                  ]}
                >
                  Organizador
                </Text>
              </TouchableOpacity>
            </View>
            <Text style={styles.roleDescription}>
              {role === 'client'
                ? 'Busca y participa en eventos'
                : 'Crea y gestiona tus eventos'}
            </Text>
          </View>

          {loading ? (
            <ActivityIndicator size="large" color="#6C63FF" style={styles.loader} />
          ) : (
            <TouchableOpacity
              style={styles.button}
              onPress={handleRegister}
              activeOpacity={0.7}
            >
              <Text style={styles.buttonText}>Registrarse</Text>
            </TouchableOpacity>
          )}

          <TouchableOpacity
            style={styles.linkButton}
            onPress={() => navigation.navigate('Login')}
            disabled={loading}
          >
            <Text style={styles.linkText}>¿Ya tienes cuenta? Inicia sesión</Text>
          </TouchableOpacity>
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
    gap: 16,
    paddingBottom: 30,
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
  roleSection: {
    marginVertical: 10,
  },
  roleLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1A1A1A',
    marginBottom: 12,
  },
  roleButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  roleButton: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 8,
    borderWidth: 2,
    borderColor: '#E0E0E0',
    backgroundColor: '#FFF',
    alignItems: 'center',
  },
  roleButtonActive: {
    borderColor: '#6C63FF',
    backgroundColor: '#6C63FF',
  },
  roleButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1A1A1A',
  },
  roleButtonTextActive: {
    color: '#FFF',
  },
  roleDescription: {
    fontSize: 12,
    color: '#666',
    marginTop: 8,
    fontStyle: 'italic',
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
  linkButton: {
    paddingVertical: 10,
  },
  linkText: {
    color: '#6C63FF',
    fontSize: 14,
    textAlign: 'center',
  },
  loader: {
    marginVertical: 20,
  },
});
