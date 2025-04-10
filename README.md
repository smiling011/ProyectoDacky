# DACKY - Aplicativo de Rastreo GPS para Mascotas

## **Descripción General**

Dacky es una aplicación móvil diseñada para el rastreo GPS de mascotas, permitiendo a los dueños gestionar la información básica de sus perros, su tarjeta virtual de vacunas y facilitar su recuperación en caso de extravío mediante un código QR en el collar.

## **Objetivo del Proyecto**

Desarrollar una aplicación móvil con Flutter y un backend en Flask que permita a los usuarios registrar y rastrear a sus mascotas, integrando funcionalidades como:

✔️ Registro de la información del perro.

✔️ Tarjeta de vacunación digital.

✔️ Seguimiento en tiempo real mediante GPS.

✔️ Escaneo de código QR para mostrar la información de contacto en caso de pérdida.

## **Tecnologías Utilizadas**

- **Frontend:** Dart (Flutter)
- **Backend:** Python (Flask)
- **Base de Datos:** MySQL
- **Control de Versiones:** GitHub
- **Infraestructura:** Servidores en la nube (futuro)

## **Herramientas en DevOps**

1️⃣ **GitHub** → Control de versiones.

2️⃣ **GitHub Actions** → Automatización CI/CD.

3️⃣ **Docker** → Contenedores para el backend y frontend.

4️⃣ **Prometheus** → Monitoreo de métricas en Flask.


## 🛡️ Licencia

Este proyecto es propiedad exclusiva de **Victoria Saleck Adelaide Vielma Romero**.  
Está protegido por una licencia propietaria en español e inglés.  
Consulta el archivo [LICENSE](LICENSE) para más información.



---

## ✅ Requisitos previos

### General
- Sistema operativo: Windows (recomendado) o Linux
- Git instalado
- Conexión a internet

### Frontend (Flutter)
- Flutter SDK: `3.5.0` o superior
- Android Studio o Visual Studio Code con extensiones de Flutter y Dart
- Emulador Android o dispositivo físico
- Conexión AVD configurada (Android Virtual Device)

### Backend (Python)
- Python: `3.10` o superior
- XAMPP (con Apache y MySQL)
- pip

---

## 🛠️ Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/smiling011/ProyectoDacky.git
cd Proyecto Dacky

2. Configurar backend (Flask)
a. Crear entorno virtual (opcional pero recomendado)
bash
Copiar
Editar
python -m venv venv
venv\Scripts\activate  # En Windows
b. Instalar dependencias
bash
Copiar
Editar
pip install flask flask_sqlalchemy pymysql
c. Configurar base de datos
Abrir XAMPP y arrancar MySQL

Ingresar a http://localhost/phpmyadmin

Crear una base de datos llamada dacky

Importar el archivo dacky.sql incluido en el proyecto

d. Archivo config.py (ejemplo)
python
Copiar
Editar
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:@localhost/dacky'
SQLALCHEMY_TRACK_MODIFICATIONS = False
e. Ejecutar servidor Flask
bash
Copiar
Editar
python dacky.py
Deberías ver: Running on http://127.0.0.1:5000/

3. Configurar frontend (Flutter)
a. Ir al directorio del proyecto Flutter
bash
Copiar
Editar
cd dacky_app
b. Verificar y obtener paquetes
bash
Copiar
Editar
flutter pub get
c. Asegurarse de tener configurado un emulador o dispositivo conectado
bash
Copiar
Editar
flutter devices
d. Ejecutar la app
bash
Copiar
Editar
flutter run
🌐 Comunicación entre Flutter y Flask
La app Flutter se comunica con Flask a través de http://10.0.2.2:5000 (si estás usando un emulador Android)

Si usas un dispositivo físico, asegúrate de estar en la misma red y usar la IP local de tu PC (ej. http://192.168.1.10:5000)

📝 Notas adicionales
La app usa una base de datos MySQL alojada localmente.

El código QR redirige a una URL que en futuras versiones podrá conectarse a un backend online.

Los colores y la tipografía están personalizados según la marca Dacky.

📦 Dependencias principales
Backend
Flask

Flask-SQLAlchemy

PyMySQL

Frontend
Flutter SDK 3.5.0+

Google Fonts (Montserrat)

Material Components

🚧 Futuras mejoras
Autenticación segura (tokens JWT)

Subida de imagen del perro

Integración con GPS real y mapas

Portal web para dueños y veterinarias

Planes premium con publicidad personalizada

📬 Contacto
Si tienes alguna duda o sugerencia, no dudes en escribir a:
📧 victoriavielmaromero@gmail.com
