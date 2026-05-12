# Instalación y Resolución de Dependencias

## Pasos para corregir los problemas de Expo

Ejecuta estos comandos en orden:

### 1. Limpiar dependencias antiguas
```bash
rm -r node_modules
rm package-lock.json
```

**En PowerShell:**
```powershell
Remove-Item -Recurse -Force node_modules
Remove-Item -Force package-lock.json
```

### 2. Instalar dependencias actualizadas
```bash
npm install
```

### 3. Instalar herramientas de Expo
```bash
npm install --global expo-cli
```

### 4. Verificar con expo-doctor
```bash
npx expo-doctor
```

### 5. Instalar y ejecutar
```bash
npx expo install
npm start
```

---

## Cambios Realizados

✅ **app.json**: 
- Removido campo inválido `ios.supportsTabletMode`
- Simplificado la configuración de assets
- Removidas referencias a archivos que no existen

✅ **package.json**:
- Removido `@types/react-native` (incluido en react-native)
- Actualizado a versiones correctas de Expo SDK 55
- Todas las dependencias ahora son compatibles

✅ **.npmrc**:
- Agregado para manejar dependencias de forma correcta

---

## Versiones Correctas Instaladas

```
expo                                  ^55.0.23
react                                 19.2.0
react-native                          0.83.6
@react-navigation/native              ^6.1.7
@react-navigation/bottom-tabs         ^6.5.10
@react-navigation/stack               ^6.3.17
react-native-screens                  ~4.23.0
react-native-safe-area-context        ~5.6.2
react-native-gesture-handler          ~2.30.0
@react-native-async-storage/async-storage  2.2.0
expo-status-bar                       ~55.0.6
```

---

## Si aún hay problemas

Si después de estos pasos aún hay problemas:

1. Ejecuta: `npx expo install --check`
2. Deja que Expo instale las versiones recomendadas
3. O ejecuta: `npx expo install --fix`

---

## Para ejecutar la app

```bash
# En tu terminal, en la carpeta del proyecto:
npm start

# Luego elige:
# - a para Android
# - i para iOS
# - w para Web
```
