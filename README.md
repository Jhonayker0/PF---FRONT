# Eventos Barranquilla - Frontend

Aplicación móvil desarrollada con **React Native** y **Expo** para la gestión de eventos culturales en Barranquilla.

## Estructura del Proyecto

```
PF - FRONT/
├── App.js                          # Punto de entrada principal
├── app.json                        # Configuración de Expo
├── package.json                    # Dependencias del proyecto
├── src/
│   ├── context/
│   │   └── AuthContext.js         # Contexto de autenticación y gestión de roles
│   ├── screens/
│   │   ├── SplashScreen.js        # Pantalla de carga inicial
│   │   ├── LoginScreen.js         # Pantalla de inicio de sesión
│   │   ├── RegisterScreen.js      # Pantalla de registro con selección de roles
│   │   ├── HomeScreen.js          # Pantalla principal (diferente según rol)
│   │   ├── CreateEventScreen.js   # Pantalla para crear eventos (solo admin)
│   │   └── EventDetailScreen.js   # Pantalla de detalle del evento
│   ├── navigation/
│   │   └── RootNavigator.js       # Configuración de navegación
│   ├── components/                # Componentes reutilizables (próximas fases)
│   └── utils/                     # Utilidades y funciones auxiliares
```

## Funcionalidades Implementadas

### ✅ Autenticación
- **Login**: Inicio de sesión con email y contraseña
- **Registro**: Registro nuevo de usuarios con selección de rol
- **Roles**: Cliente y Administrador de eventos
- **Persistencia**: Almacenamiento de sesión con AsyncStorage

### ✅ Pantalla de Inicio (Home)
- **Diferenciación de roles**: Interfaz diferente para cliente y administrador
- **Listado de eventos**: Muestra eventos disponibles con información básica
- **Búsqueda**: Preparado para búsqueda (pendiente de implementación completa)
- **Cerrar sesión**: Opción para salir de la aplicación

### ✅ Gestión de Eventos (Admin)
- **Crear evento**: Formulario completo con campos de título, categoría, fecha, ubicación y descripción
- **Categorías**: Festival, Música, Arte, Teatro, Gastronomía
- **Validación**: Validación básica de campos requeridos

### ✅ Detalle del Evento
- **Información completa**: Muestra todos los detalles del evento
- **Estadísticas**: Asistentes, calificación, comentarios
- **Acciones por rol**:
  - Cliente: Participar en evento
  - Admin: Editar o eliminar evento

### ✅ Experiencia de Usuario
- Interfaz limpia y moderna
- Navegación fluida entre pantallas
- Indicadores de carga
- Alertas informativas

## Cuentas Demo

Para probar la aplicación:

**Cliente:**
- Email: `cliente@example.com`
- Contraseña: `123456`

**Administrador:**
- Email: `admin@example.com`
- Contraseña: `123456`

## Requisitos

- Node.js (v14 o superior)
- npm o yarn
- Expo CLI: `npm install -g expo-cli`

## Instalación y Ejecución

1. **Instalar dependencias:**
   ```bash
   npm install
   ```

2. **Iniciar la aplicación:**
   ```bash
   npm start
   ```

3. **Opciones de ejecución:**
   - Android: Presiona `a`
   - iOS: Presiona `i`
   - Web: Presiona `w`

## Próximas Fases

- [ ] Integración con backend (FastAPI)
- [ ] Sistema de recomendación híbrida
- [ ] Búsqueda y filtrado avanzado de eventos
- [ ] Sistema de comentarios y calificaciones
- [ ] Notificaciones push
- [ ] Pasarela de pagos (PSE)
- [ ] Perfiles de usuario
- [ ] Chat entre usuarios
- [ ] Integración con redes sociales
- [ ] Análisis de datos (CloudWatch)

## Notas Importantes

- Los datos de eventos actuales son **mockups** (datos de prueba)
- La autenticación es **simulada** hasta que se implemente el backend
- Los tokens de sesión se almacenan en **AsyncStorage**
- La navegación está configurada para cambiar según el estado de autenticación y rol del usuario

## Estilos y Colores

- **Color primario**: #6C63FF (Púrpura)
- **Fondo**: #F5F5F5 (Gris claro)
- **Texto principal**: #1A1A1A (Gris oscuro)
- **Texto secundario**: #666, #999
- **Borders**: #E0E0E0 (Gris muy claro)

## Contacto y Contribuciones

Este proyecto es parte del desarrollo de una plataforma para la gestión de eventos culturales en Barranquilla.
