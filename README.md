# DACKY - Aplicativo de Rastreo GPS para Mascotas

## ✨ Descripción General

**Dacky** es una aplicación móvil diseñada para el rastreo GPS de mascotas, permitiendo a los dueños gestionar la información básica de sus perros, su tarjeta virtual de vacunas y facilitar su recuperación en caso de extravío mediante un código QR en el collar.

## 💡 Objetivo del Proyecto

Desarrollar una aplicación móvil con **Flutter** y un backend en **Flask** que permita a los usuarios:

- ✅ Registrar información básica del perro
- ✅ Generar una tarjeta de vacunación digital
- ✅ Realizar seguimiento en tiempo real mediante GPS
- ✅ Escanear un código QR para mostrar información de contacto en caso de pérdida

## **Tecnologías Utilizadas**

- **Frontend:** Dart 3.6.1 (Flutter **3.27.2** )
- **Backend:** Python **3.11+** (Flask)
- **Base de Datos:** PostgreSQL (migrado desde MySQL durante despliegue)
- **Android Studio:** (con Android SDK)
- **Control de Versiones:** Git y GitHub
- **Docker Desktop** para Windows

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
- Python `3.11.9` o superior
- Flask  `3.0.3`
- pip install (dependencias en `requirements.txt`)

### Base de Datos
- PostgreSQL 17+
- pgAdmin 4
- Conexión remota a PostgreSQL en Render
- Archivo `.env` para configurar credenciales del servidor

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

- Crear archivo `.env`.
- Render maneja automáticamente:
    - creación de la BD
    - conexión SSL
    - host y puerto

**d. Archivo config.py (ejemplo)**

```python
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = os.getenv("DB_PORT")
    DB_NAME = os.getenv("DB_NAME")

    SQLALCHEMY_DATABASE_URI = (
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}?sslmode=require&options=-csearch_path%3Ddacky"
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = os.getenv("SECRET_KEY", "default-secret")
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

- La app ahora usa una **base de datos PostgreSQL en Render**, no MySQL.
- El código QR está diseñado para redirigir a URLs del backend alojado en **Render**.
- La app utiliza colores y tipografía personalizados (paleta Dacky + fuente Montserrat).
- Este manual documenta la ejecución, despliegue, mantenimiento y configuración de la aplicación móvil y su backend.

## 📆 Dependencias Principales

### Backend
- Flask
- Flask-SQLAlchemy

### Frontend
- Flutter SDK 3.5.0+
- Google Fonts (Montserrat)
- Material Components

---

## 🚧 Futuras Mejoras

- Integración con GPS real y mapas
- Portal web para dueños y veterinarias
- Funciones adicionales añadidas en versiones posteriores.

## 📨 Contacto

Si tienes alguna duda o sugerencia, no dudes en escribir a:

**victoriavielmaromero@gmail.com**

