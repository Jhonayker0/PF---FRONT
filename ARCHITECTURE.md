# Arquitectura del Frontend

## Flujo de Autenticación

```
┌─────────────────────────────────────────────┐
│        App.js (Punto de entrada)            │
├─────────────────────────────────────────────┤
│         AuthProvider (Context)              │
│  ✓ Maneja estado de autenticación           │
│  ✓ Persiste sesión con AsyncStorage         │
│  ✓ Gestiona roles de usuario                │
└────────────────┬────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
    ┌───▼──────┐    ┌─────▼──────┐
    │ Login    │    │ Register   │
    │ Screen   │    │ Screen     │
    │ (Public) │    │ (Public)   │
    └───┬──────┘    └─────┬──────┘
        │                 │
        └────────┬────────┘
                 │
         ┌───────▼────────┐
         │   AuthContext  │
         │   signIn()     │
         │   signUp()     │
         └────────┬───────┘
                  │
         ┌────────▼────────┐
         │  AsyncStorage   │
         │  • userToken    │
         │  • user (datos) │
         └────────┬────────┘
                  │
         ┌────────▼────────────┐
         │ RootNavigator       │
         │ (verifica token)    │
         └─────┬───────────────┘
              │
        ┌─────▼─────┐
        │ AppStack  │
        │ (Home)    │
        └───────────┘
```

## Flujo de Navegación

### Stack Navegación (Auth)
```
LoginScreen
├── Register Link → RegisterScreen
└── Demo Accounts
```

### Stack Navegación (App)
```
HomeScreen (Cliente)
├── EventCard → EventDetailScreen
│   └── Participar en evento
└── Logout

HomeScreen (Admin)
├── Create Event Button → CreateEventScreen
│   ├── Formulario evento
│   └── Categorías
├── EventCard → EventDetailScreen
│   ├── Editar evento
│   └── Eliminar evento
└── Logout
```

## Gestión de Estado

### AuthContext
```javascript
{
  state: {
    isLoading: boolean,
    isSignout: boolean,
    userToken: string | null,
    user: {
      id: string,
      email: string,
      name: string,
      role: 'client' | 'admin'
    } | null
  },
  methods: {
    signIn(email, password),
    signUp(email, password, name, role),
    signOut()
  }
}
```

## Componentes Principales

### Pantallas (Screens)

#### SplashScreen
- Muestra mientras se carga la autenticación
- Verifica si existe sesión previa

#### LoginScreen
- Formulario de login
- Email y contraseña
- Cuentas demo para testing

#### RegisterScreen
- Formulario de registro
- Selección de rol (Cliente/Organizador)
- Validación de contraseñas

#### HomeScreen
- **Versión Cliente**:
  - Búsqueda de eventos
  - Listado de eventos
  - Acceso a detalle
  
- **Versión Admin**:
  - Botón crear evento
  - Gestión de eventos propios
  - Acceso a detalle para editar/eliminar

#### CreateEventScreen
- Formulario para crear evento
- Campos: título, categoría, fecha, ubicación, descripción
- Validación de campos
- Solo accesible para admin

#### EventDetailScreen
- Información completa del evento
- Estadísticas (asistentes, rating)
- **Cliente**: Botón "Participar"
- **Admin**: Botones "Editar" y "Eliminar"

## Almacenamiento de Datos

### AsyncStorage
```javascript
{
  userToken: 'mock_token_...',
  user: {
    id: '123',
    email: 'user@example.com',
    name: 'Nombre',
    role: 'client' | 'admin'
  }
}
```

### Mock Data (Events)
Los eventos están almacenados en HomeScreen como estado local.

**En producción**, se obtendrán del backend mediante API calls.

## Integración con Backend (Próxima Fase)

La estructura actual está preparada para integrar API calls usando **Axios**:

```javascript
// Ejemplo de cómo será:
const handleCreateEvent = async () => {
  const response = await axios.post(
    'https://api-backend.com/events',
    eventData,
    { headers: { Authorization: `Bearer ${userToken}` } }
  );
};
```

## Convenciones de Código

### Naming
- **Screens**: PascalCase + "Screen" (LoginScreen)
- **Components**: PascalCase (EventCard)
- **Functions**: camelCase (handleLogin)
- **Variables**: camelCase (userToken)

### Estructura de estilos
Cada componente tiene su StyleSheet al final del archivo.

### Colores
- **Primario**: #6C63FF (Azul púrpura)
- **Fondo**: #F5F5F5
- **Texto**: #1A1A1A / #666 / #999
- **Bordes**: #E0E0E0

## Performance

- AsyncStorage para persistencia local (sin servidor en esta fase)
- FlatList para listas optimizadas
- ScrollView en pantallas con contenido variable
- Carga lazy de componentes mediante React Navigation

## Testing (Recomendaciones)

```bash
# Prueba con cuentas demo:
Cliente: cliente@example.com / 123456
Admin: admin@example.com / 123456

# Flujos a validar:
1. Login → Home (cliente)
2. Login → Home (admin) → Crear evento → Detalle
3. Registro → Home → Logout
4. Navegación entre pantallas
5. Validación de formularios
```

## Problemas Conocidos y Mejoras Futuras

- [ ] Backend aún no integrado
- [ ] Sistema de recomendación no implementado
- [ ] Búsqueda/filtrado básico
- [ ] Notificaciones push
- [ ] Imágenes reales en eventos (actualmente emojis)
- [ ] Validación más robusta
- [ ] Manejo de errores mejorado
