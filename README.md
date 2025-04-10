# DACKY - Aplicativo de Rastreo GPS para Mascotas

## ✨ Descripción General

**Dacky** es una aplicación móvil diseñada para el rastreo GPS de mascotas, permitiendo a los dueños gestionar la información básica de sus perros, su tarjeta virtual de vacunas y facilitar su recuperación en caso de extravío mediante un código QR en el collar.

## 💡 Objetivo del Proyecto

Desarrollar una aplicación móvil con **Flutter** y un backend en **Flask** que permita a los usuarios:

- ✅ Registrar información básica del perro
- ✅ Generar una tarjeta de vacunación digital
- ✅ Realizar seguimiento en tiempo real mediante GPS
- ✅ Escanear un código QR para mostrar información de contacto en caso de pérdida

## 🚀 Tecnologías Utilizadas

- **Frontend:** Dart (Flutter)
- **Backend:** Python (Flask)
- **Base de Datos:** MySQL
- **Control de Versiones:** GitHub
- **Infraestructura:** Servidores en la nube (futuro)

## 🚧 Herramientas DevOps

- **GitHub** → Control de versiones
- **GitHub Actions** → Automatización CI/CD
- **Docker** → Contenedores para backend y frontend
- **Prometheus** → Monitoreo de métricas en Flask

## 🛡️ Licencia

Este proyecto es propiedad exclusiva de **Victoria Saleck Adelaide Vielma Romero**.

Está protegido por una licencia propietaria en español e inglés.
Consulta el archivo [LICENSE](LICENSE) para más información.

---

## ✅ Requisitos Previos

### General
- Sistema operativo: Windows (recomendado) o Linux
- Git instalado
- Conexión a internet

### Frontend (Flutter)
- Flutter SDK `3.5.0` o superior
- Android Studio o VS Code con extensiones de Flutter y Dart
- Emulador Android o dispositivo físico
- Configuración de AVD (Android Virtual Device)

### Backend (Python)
- Python `3.10` o superior
- XAMPP (Apache y MySQL)
- pip

---

## 🛠️ Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/smiling011/ProyectoDacky.git
cd "Proyecto Dacky"
```

### 2. Configurar Backend (Flask)

**a. Crear entorno virtual**

```bash
python -m venv venv
venv\Scripts\activate  # En Windows
```

**b. Instalar dependencias**

```bash
pip install flask flask_sqlalchemy pymysql
```

**c. Configurar base de datos**

- Abrir XAMPP y arrancar MySQL
- Ir a http://localhost/phpmyadmin
- Crear una base de datos llamada `dacky`
- Importar el archivo `dacky.sql` incluido en el proyecto

**d. Archivo config.py (ejemplo)**

```python
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:@localhost/dacky'
SQLALCHEMY_TRACK_MODIFICATIONS = False
```

**e. Ejecutar servidor Flask**

```bash
python dacky.py
```

Deberías ver: `Running on http://127.0.0.1:5000/`

### 3. Configurar Frontend (Flutter)

**a. Ir al directorio del proyecto Flutter**

```bash
cd dacky_app
```

**b. Obtener paquetes**

```bash
flutter pub get
```

**c. Verificar emulador o dispositivo**

```bash
flutter devices
```

**d. Ejecutar la app**

```bash
flutter run
```

## 🌐 Comunicación entre Flutter y Flask

- Si usas emulador Android: `http://10.0.2.2:5000`
- Si usas un dispositivo físico: usa tu IP local (ej. `http://192.168.1.10:5000`)

---

## 📝 Notas Adicionales

- La app usa una base de datos MySQL alojada localmente
- El código QR redirige a una URL que podrá conectarse a un backend online
- Colores y tipografía personalizados según la marca Dacky

## 📆 Dependencias Principales

### Backend
- Flask
- Flask-SQLAlchemy
- PyMySQL

### Frontend
- Flutter SDK 3.5.0+
- Google Fonts (Montserrat)
- Material Components

---

## 🚧 Futuras Mejoras

- Autenticación segura (JWT)
- Subida de imagen del perro
- Integración con GPS real y mapas
- Portal web para dueños y veterinarias
- Planes premium con publicidad personalizada

## 📨 Contacto

Si tienes alguna duda o sugerencia, no dudes en escribir a:

**victoriavielmaromero@gmail.com**

