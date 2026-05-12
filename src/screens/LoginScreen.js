import React, { useState } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  Image,
  Text,
  StyleSheet,
  ActivityIndicator,
  Alert,
  ImageBackground,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { AuthContext } from '../context/AuthContext';

export const LoginScreen = ({ navigation }) => {
  const { signIn } = React.useContext(AuthContext);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Por favor completa todos los campos');
      return;
    }

    setLoading(true);
    const result = await signIn(email, password);
    setLoading(false);

    if (!result.success) {
      Alert.alert('Error de Login', result.error);
    }
  };

  return (
    <SafeAreaView style={styles.container} edges={['left', 'right']}>
      <ImageBackground
        source={require('../../assets/FondoLogin.png')}
        style={{ flex: 1 }}
        resizeMode="cover"
      >

      <View style={styles.content}>
        <Image
          source={require('../../assets/CumbeLogo.png')}
          style={{ width: 210, height: 160, alignSelf: 'center', marginBottom: 20 }}
        />
        <Text style={styles.subtitle}>Vive lo que pasa</Text>

        <View style={styles.form}>
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

          {loading ? (
            <ActivityIndicator size="large" color="#6C63FF" style={styles.loader} />
          ) : (
            <TouchableOpacity
              style={styles.button}
              onPress={handleLogin}
              activeOpacity={0.7}
            >
              <Text style={styles.buttonText}>Iniciar Sesión</Text>
            </TouchableOpacity>
          )}

          <TouchableOpacity
            style={styles.linkButton}
            onPress={() => navigation.navigate('Register')}
            disabled={loading}
          >
            <Text style={styles.linkText}>¿No tienes cuenta? Regístrate</Text>
          </TouchableOpacity>

          <View style={styles.demoContainer}>
            <Text style={styles.demoTitle}>Cuentas demo:</Text>
            <TouchableOpacity
              onPress={() => {
                setEmail('cliente@example.com');
                setPassword('123456');
              }}
              disabled={loading}
            >
              <Text style={styles.demoText}>Cliente: cliente@example.com / 123456</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => {
                setEmail('admin@example.com');
                setPassword('123456');
              }}
              disabled={loading}
            >
              <Text style={styles.demoText}>Admin: admin@example.com / 123456</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>

      </ImageBackground>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  content: {
    flex: 1,
    paddingHorizontal: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#1A1A1A',
    marginBottom: 8,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 40,
  },
  form: {
    gap: 16,
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
  button: {
    backgroundColor: '#a60d13',
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: 8,
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
    color: '#a60d13',
    fontSize: 14,
    textAlign: 'center',
  },
  loader: {
    marginVertical: 20,
  },
  demoContainer: {
    marginTop: 30,
    paddingTop: 20,
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    gap: 8,
  },
  demoTitle: {
    fontSize: 12,
    fontWeight: '600',
    color: '#666',
    marginBottom: 8,
  },
  demoText: {
    fontSize: 12,
    color: '#a60d13',
    padding: 8,
  },
});
