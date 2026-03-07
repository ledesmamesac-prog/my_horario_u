# Changelog - My Horario U

Todos los cambios notables en este proyecto se documentarán en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [3.5.0] - Firebase & Sync Social Pro - 2026-03-07

### Agregado
- **🔥 Firebase Integration**: Integración completa con Firebase Auth y Cloud Firestore para persistencia en la nube.
- **🌐 Sincronización en Tiempo Real**: Sincronización bidireccional automática de Materias, Horarios, Tareas, Notas y Apuntes entre SQLite (local) y Firestore (nube).
- **📱 Sistema Social por QR**:
  - Generación de código QR único por usuario desde la nueva sección de Perfil.
  - Escáner de QR integrado para agregar compañeros como amigos.
- **🤝 Comparador de Horarios Pro**:
  - Vista comparativa de horarios "Lado a Lado" con amigos.
  - **Identificación de Materias**: Ahora se muestran los nombres reales de las clases de tus amigos.
  - **Botón de Importación**: Permite copiar una materia completa de un amigo (con todos sus horarios) a tu propia agenda con un toque.
  - **Algoritmo de Huecos Comunes**: Detección automática de espacios libres compartidos entre 6:00 AM y 10:00 PM para facilitar el estudio en grupo.
- **👤 Perfil Personalizado**: El Dashboard ahora muestra la foto real del usuario obtenida de Google Auth.

### Modificado
- **🏗️ Refactorización de Interfaz**:
  - Navegación principal simplificada a 5 pestañas.
  - Funciones de Perfil, QR y Amigos movidas a la pantalla de **Configuración** para una UI más despejada.
  - El botón de "Cerrar Sesión" ahora está integrado en Configuración.
- **💾 Database Layer**: Actualización de `DatabaseService` para soportar conflictos de sincronización mediante `replace`.
- **🎨 Mejoras de Legibilidad**: El código QR ahora se genera siempre en formato de alto contraste (fondo blanco) para asegurar su lectura en modo oscuro.

---

## [2.0.0] - Modo Oscuro & UI Polishing

### Modificado
- **🎨 Interfaz Adaptada al Tema**: Se actualizaron múltiples áreas de la aplicación para soportar correctamente el nuevo sistema de temas:
  - **Dashboard**: Tarjetas principales adaptadas al tema activo y la tarjeta de *Próxima Clase* ahora usa colores dinámicos.
  - **Materias**: Tarjetas y modales de detalle adaptados a modo oscuro mejorando el contraste visual.
  - **Horario**: La grilla interviene sus fondos para ser consistentes con el tema seleccionado.
  - **Notas**: Menús, dropdowns y alertas visuales ahora varían y cambian de color según el tema.
  - **Tareas**: Formularios y tarjetas informativas optimizadas para ambos modos.
  - **Apuntes**: El visor de contenido ahora soporta correctamente fondos oscuros.
- **🎨 Mejora de consistencia visual**: Se eliminaron los colores fijos absolutos (hardcodeados) en la interfaz para permitir cambios dinámicos en el `Theme.of(context)` favoreciendo la coherencia visual entre la app.

### Eliminado
- Eliminado el icono temporal de **notificación (campana)** que había sido añadido como botón de prueba rápida en la sección de apuntes.

### Arreglado
- **🐞 Pantalla Negra en Android Release**: Se solucionó un problema crítico originado por el ofuscador de ProGuard donde la app aparecía completamente negra y vacía al compilar con `flutter build apk --release`.
- **🐞 Error crítico en gestión de notas**: Corregido un casteo de variable erróneo que provocaba un cierre inesperado de la aplicación al tratar de calcular promedios en la pantalla de Notas.
- **🐞 Advertencias del compilador**: Se sanearon y corrigieron múltiples advertencias (Lint errors) relacionadas con el uso de estilos inmutables `const`, invocaciones descontinuadas de opacidad (`withOpacity`) y uso del contexto de Flutter en brechas asíncronas (`BuildContext`).

---

## [0.1.0] - Versión Inicial

### Agregado
- **📚 Gestión de Materias**: Registro de materias académicas y visualización de las activas.
- **📅 Horario Semanal**: Vista de horario para organizar las clases durante los 7 días de la semana.
- **📊 Panel Principal (Dashboard)**: Vista resumen inteligente del estado académico personal, registro de promedios e información rápida.
- **📝 Sistema de Notas**: Registro de cortes, evaluaciones y cálculo interno de promedios por materia.
- **📓 Apuntes**: Accesibilidad a un espacio de cuaderno virtual enfocado en adjuntar y guardar clases o fotos para cada materia.
- **✅ Gestión de Tareas**: Registro de actividades académicas pendientes, prioridades y urgencias evaluables por fecha límite.

---

## Notas de Desarrollo
> **My Horario U** es un proyecto enfocado en un entorno de desarrollo activo. 
> Las próximas versiones incorporarán nuevas funcionalidades enfocadas a mejorar la organización y accesibilidad de los estudiantes universitarios.
