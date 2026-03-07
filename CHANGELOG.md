# Changelog - My Horario U

Todos los cambios notables en este proyecto se documentarán en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

# [Unreleased]

## Agregado

### 🌙 Modo Oscuro Total

* Implementación completa del **Modo Oscuro** en toda la aplicación.
* La interfaz ahora adapta automáticamente colores de fondos, tarjetas y textos.
* Permite una experiencia más cómoda en ambientes con poca luz.

### ⚙️ Pantalla de Configuración

* Nueva pantalla **Settings** accesible desde el avatar del perfil en el **Dashboard**.
* Permite cambiar entre **Modo Claro** y **Modo Oscuro**.
* La preferencia de tema se guarda y se mantiene entre sesiones.

### ⏱ Temporizador de Clase en Curso

* El sistema detecta cuando una clase está ocurriendo en tiempo real.
* Se muestra una tarjeta especial **“EN CURSO”** en el Dashboard.
* Incluye un contador regresivo que indica cuánto falta para terminar la clase.

---

## Modificado

### 🎨 Interfaz Adaptada al Tema

Se actualizaron múltiples áreas de la aplicación para soportar correctamente el nuevo sistema de temas:

* **Dashboard**

  * Tarjetas principales adaptadas al tema activo.
  * Tarjeta de **Próxima Clase** ahora usa colores dinámicos.

* **Materias**

  * Tarjetas y modales de detalle adaptados a modo oscuro.
  * Mejor contraste visual.

* **Horario**

  * La grilla del horario usa fondos consistentes con el tema seleccionado.

* **Notas**

  * Menús, dropdowns y alertas visuales ahora cambian según el tema.

* **Tareas**

  * Formularios y tarjetas informativas optimizadas para ambos modos.

* **Apuntes**

  * El visor de contenido ahora soporta correctamente el modo oscuro.

### 🎨 Mejora de consistencia visual

* Se eliminaron colores fijos en la interfaz para permitir cambios dinámicos de tema.
* Se mejoró la coherencia visual entre pantallas.

---

## Eliminado

* Eliminado el icono temporal de **notificación (campana)** que había sido añadido como prueba en la sección de apuntes.

---

## Arreglado

### 🐞 Pantalla Negra en Android Release

* Se solucionó un problema donde la app aparecía completamente negra al compilar con:

```
flutter build apk --release
```

### 🐞 Error crítico en gestión de notas

* Corregido un error que provocaba un cierre inesperado al calcular promedios en la pantalla de **Notas**.

### 🐞 Advertencias del compilador

* Se corrigieron advertencias relacionadas con:

  * estilos de texto
  * uso del contexto de Flutter
  * llamadas asíncronas

---

# [0.1.0] - Versión Inicial

## Agregado

### 📚 Gestión de Materias

* Registro de materias académicas.
* Visualización de materias activas.

### 📅 Horario Semanal

* Vista de horario para organizar clases durante la semana.

### 📊 Panel Principal (Dashboard)

* Vista resumen del estado académico del estudiante.
* Información rápida de clases y materias.

### 📝 Sistema de Notas

* Registro de evaluaciones.
* Cálculo de promedios por materia.

### 📓 Apuntes

* Espacio para guardar información o notas relacionadas con materias.

### ✅ Gestión de Tareas

* Registro de actividades académicas pendientes.

---

# Notas

My Horario U es un proyecto en desarrollo activo.
Las próximas versiones incorporarán nuevas funcionalidades enfocadas en mejorar la organización académica de los estudiantes universitarios.
