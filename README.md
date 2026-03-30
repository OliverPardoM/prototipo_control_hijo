# 🧒 Child Control App

**Aprende, juega y usa tu dispositivo de forma segura**

---

## 📖 Descripción

**Child Control App** es una aplicación Flutter diseñada para el uso de niños dentro de un entorno seguro y controlado por sus padres.

La aplicación proporciona acceso a juegos educativos, controla el tiempo de uso del dispositivo y aplica restricciones automáticas según las configuraciones definidas por el administrador (padre). Además, incorpora mecanismos de bloqueo, recomendaciones y vinculación segura con el dispositivo del padre.

---

## 🚀 Funcionalidades principales (HIJO)

### 🎮 Juegos educativos

- Juegos interactivos diseñados para aprendizaje y estimulación:
  - Colores
  - Memoria
  - Formas
  - Sonidos

- Interfaz amigable y visual

### ⏱ Control de tiempo de uso

- Monitoreo automático del tiempo de uso
- Restricción basada en límites definidos por el padre
- Bloqueo al alcanzar el límite

### 🔒 Bloqueo automático

- Pantalla de bloqueo cuando se excede el tiempo permitido
- Acceso restringido hasta autorización del padre

### 🔗 Vinculación de dispositivo

- Escaneo de código QR o ingreso manual de código
- Conexión segura con la app del padre
- Validación de vinculación

### 🧠 Recomendaciones educativas

- Sugerencias de actividades dentro de la app
- Promoción de uso saludable del dispositivo

### ⚙️ Configuración aplicada (desde el padre)

- Filtros de contenido según edad
- Restricciones de acceso
- Horarios permitidos de uso

---

## 🧱 Arquitectura

El proyecto sigue una arquitectura moderna basada en:

### 🧩 Feature-First + Clean Architecture

Cada funcionalidad está organizada como un módulo independiente, facilitando mantenimiento y escalabilidad.

### 🔹 Separación de capas

- **UI (Presentation)**: Pantallas, widgets e interacción con el usuario
- **Domain**: Modelos, lógica de negocio y reglas
- **Services / Data**: Manejo de datos y lógica externa

### 🔄 Gestión de estado

- Uso de **Provider** para manejo reactivo del estado
- Separación clara entre lógica y presentación

---

## 📂 Estructura del proyecto

```id="l7p9ab"
lib/
├── app.dart
├── core
│   └── theme              # Configuración de tema global
│       ├── app_theme.dart
│       └── theme_provider.dart
│
├── features
│   ├── colorGame          # Juego de identificación de colores
│   │   ├── domain         # Modelos del juego
│   │   └── ui             # UI del juego
│
│   ├── home               # Pantalla principal y control de tiempo
│   │   ├── domain
│   │   │   ├── controller
│   │   │   ├── mixins
│   │   │   ├── models
│   │   │   ├── provider
│   │   │   ├── repository
│   │   │   └── services
│   │   └── ui             # Home, juegos y pantalla de bloqueo
│
│   ├── link_device        # Vinculación con dispositivo del padre
│   │   ├── domain
│   │   └── ui
│
│   ├── memoryGame         # Juego de memoria
│   │   └── ui
│
│   ├── ShapeGame          # Juego de formas
│   │   ├── domain
│   │   └── ui
│
│   └── soundGame          # Juego de sonidos
│       ├── domain
│       └── ui
│
└── main.dart
```

---

## 🛠 Tecnologías utilizadas

- **Flutter**
- **Dart**
- **Provider** (gestión de estado)
- Arquitectura basada en **Clean Architecture**
- Manejo de estado local y lógica desacoplada

---

## ⚙️ Instalación

Sigue estos pasos para ejecutar el proyecto:

```bash id="p4k2sm"
# Clonar el repositorio
git clone https://github.com/tc-innova/prototipo_control_hijo.git

# Entrar al proyecto
cd prototipo_control_hijo

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

---

## ▶️ Uso

Flujo básico del niño dentro de la aplicación:

1. Abrir la aplicación
2. (Primera vez) Vincular el dispositivo con el padre:
   - Escanear código QR o ingresar código manual

3. Acceder a la pantalla principal
4. Seleccionar un juego o actividad
5. Usar la app dentro del tiempo permitido
6. Recibir bloqueo automático si se excede el límite

---

## 📸 Screenshots

> _(Agregar aquí capturas de pantalla de los juegos y la interfaz infantil)_

---

## ✅ Buenas prácticas aplicadas

- Arquitectura limpia (Clean Architecture)
- Separación por features (modularidad)
- Reutilización de widgets
- Uso de Provider para estado global
- Código desacoplado y mantenible
- Uso de mixins para lógica reutilizable (ej. control de tiempo)
- Estructura preparada para testing

---

## 📈 Escalabilidad del proyecto

El proyecto está diseñado para evolucionar fácilmente:

- Integración sencilla de nuevos juegos (nuevas features)
- Bajo acoplamiento entre módulos
- Posibilidad de añadir backend o sincronización en la nube
- Preparado para ampliar lógica de control parental
- Soporte para nuevas configuraciones sin afectar módulos existentes
