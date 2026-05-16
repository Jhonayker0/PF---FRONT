# Eventos Barranquilla - Flutter

Aplicación móvil para descubrir y gestionar eventos culturales en Barranquilla, desarrollada con **Flutter** y **Dart**.

## Estructura del Proyecto

```
eventos_barranquilla_flutter/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── app.dart               # Configuración de la app (tema, rutas)
│   ├── models/                # Modelos de datos
│   │   ├── user.dart          # Modelo de usuario
│   │   └── event.dart         # Modelo de evento
│   ├── providers/             # Proveedores de estado
│   │   └── auth_provider.dart # Autenticación y estado global
│   └── screens/               # Pantallas de la app
│       ├── splash_screen.dart
│       ├── login_screen.dart
│       ├── register_screen.dart
│       ├── home_screen.dart
│       ├── event_detail_screen.dart
│       └── create_event_screen.dart
├── assets/
│   ├── CumbeLogo.png          # Logo de la app
│   └── FondoLogin.png         # Fondo de pantalla de login
└── pubspec.yaml               # Dependencias y configuración
```

## Requisitos

- **Flutter**: 3.35.3 o superior
- **Dart**: 3.9.2 o superior
- **Android SDK** (para dispositivos Android)

## Dependencias Principales

- `go_router` (14.8.1+) - Navegación declarativa
- `provider` - Gestión de estado
- `flutter_test` - Testing

## Instalación

1. Clona el repositorio o descarga el código:
```bash
cd eventos_barranquilla_flutter
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la app en un emulador o dispositivo:
```bash
flutter run
```

## Pantallas

### Splash Screen
Pantalla de carga inicial con navegación automática después de 2 segundos.

### Login Screen
Autenticación con email y contraseña.

**Credenciales de demo:**
- Cliente: `cliente@example.com` / `123456`
- Admin: `admin@example.com` / `123456`

### Register Screen
Creación de nueva cuenta con rol (Cliente o Administrador).

### Home Screen
Feed de eventos con:
- Saludo personalizado
- Badge de rol
- Lista de eventos
- Sección exclusiva para administradores (crear evento)
- Botón de logout

### Event Detail Screen
Detalles completos del evento:
- Imagen/ícono del evento
- Categoría, fecha, ubicación
- Descripción
- Botones para registrarse o guardar

### Create Event Screen (Admin)
Formulario para crear nuevos eventos:
- Nombre, categoría, fecha, ubicación
- Descripción
- Validación de campos

## Tema

### Colores
- **Primario**: `#DB6B2F` (Naranja)
- **Secundario**: `#181818` (Negro)
- **Superficie**: `#FFFFFF` (Blanco)
- **Fondo**: `#F6F1E8` (Crema)

### Tipografía
- **Encabezados**: 40px - 22px, peso 700-800
- **Body**: 16px - 14px, peso 400-500

## Arquitectura

### State Management
Utilizamos **Provider** con `ChangeNotifier` para gestionar el estado global de autenticación.

### Navigation
**go_router** proporciona navegación declarativa con soporte para:
- Rutas nombradas
- Parámetros dinámicos
- Redirecciones basadas en autenticación
- Deep linking

### Models
- `User`: Información del usuario (id, nombre, email, rol)
- `Event`: Información del evento (id, título, categoría, fecha, ubicación, descripción, imagen)

## Testing

Ejecuta los tests:
```bash
flutter test
```

## Build

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

El APK se genera en: `build/app/outputs/flutter-apk/app-release.apk`

### Instalar en dispositivo
```bash
flutter install
```

## Mock Data

La app incluye datos mockeados para demo:

**Eventos:**
- Carnaval de Barranquilla
- Festival de Música
- Muestra de Arte

## Autenticación

Actualmente utiliza autenticación mock con credenciales hardcodeadas. Para producción:
1. Reemplazar con API real en `AuthProvider`
2. Implementar persistencia con `SharedPreferences` o similar
3. Agregar token management

## Próximos Pasos

- [ ] Integración con API backend
- [ ] Persistencia de datos con base de datos local
- [ ] Push notifications
- [ ] Filtrado avanzado de eventos
- [ ] Perfil de usuario
- [ ] Favoritos/Bookmarks

## Licencia

Este proyecto está bajo licencia MIT.

## Autor

Desarrollado como parte del proyecto Eventos Barranquilla.

---

**Última actualización**: Migración completada desde React Native a Flutter (2026)
