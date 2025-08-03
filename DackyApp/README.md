# **DACKY - Aplicativo de Rastreo GPS para Mascotas**

## **Descripción General**

**Dacky** es una aplicación móvil diseñada para el rastreo GPS de mascotas, permitiendo a los dueños gestionar la información básica de las mascotas, su tarjeta virtual de vacunas y facilitar su recuperación en caso de extravío mediante un código QR en el collar.

## **Objetivo del Proyecto**

Desarrollar una aplicación móvil con **Flutter** y un backend en **Flask** que permita a los usuarios:

- ✅ Registrar información básica de las mascotas.
- ✅ Generar una tarjeta de vacunación digital
- ✅ Realizar seguimiento en tiempo real mediante GPS
- ✅ Escanear un código QR para mostrar información de contacto en caso de pérdida

## **Equipo de Trabajo**

Victoria Vielma - Desarrollador 

---

## Objetivo del Manual Técnico

Documentar de forma técnica el funcionamiento y mantenimiento de la aplicación Dacky. A continuación se presentara las tecnologías y herramientas utilizadas, guía de instalación y configuración para trabajar en el proyecto, estructura de la base de datos, control de versiones y anexos técnicos que explican fragmentos de código del proyecto.

## Público Objetivo del Manual Técnico

- Técnicos
- Desarrolladores
- Futuros Mantenedores

## Convenciones Utilizadas

- **Paleta de Colores**
    
    ![AdobeColor-Dacky.jpeg](attachment:18f9c5dc-69d4-4af5-8c5f-864e34446dc6:de1cfe7c-15f0-46f2-ba28-6548cc7424bd.png)
    

- **Tipografía**
    
    Google Fonts (Montserrat)
    

- **Logo de la App**
    
    ![Minilogo dacky.png](attachment:3e8756f8-3be6-416f-982a-64250c4c742d:Minilogo_dacky.png)
    

---

## Arquitectura del Sistema

### Arquitectura Cliente-Servidor

Dacky está basado en una arquitectura cliente-servidor, donde el cliente es la aplicación móvil que usan los dueños de mascotas, y el servidor es una aplicación web desarrollada en Flask (Python) que gestiona la lógica del sistema y la conexión con la base de datos MySQL.

| **Componente** | **Rol** |
| --- | --- |
| **Cliente** | App Flutter en Android (o emulador), interfaz para el usuario |
| **Servidor** | Flask (Python), ejecutando lógica y gestionando la base de datos |
| **Base de Datos** | MySQL, almacena la información de mascotas, usuarios, vacunas, GPS |
| **Red local o IP pública** | Canal de comunicación entre Flutter y Flask |

A continuación un gráfico que lo explica de manera visual: 

![Arquitectura Cliente-Servidor.png](attachment:4acda0a4-606a-4f79-b168-272817c77d21:Arquitectura_Cliente-Servidor.png)

### Modelo-Vista-Controlador (MVC)

Dacky implementa el patrón de diseño Modelo-Vista-Controlador (MVC)

**Modelo**

El modelo, programa que almacena los datos, este representa las tablas de la base de datos mediante clases en Python usando SQLAlchemy.

![imagen_2025-06-10_124623841.png](attachment:1ee4e6c0-e37c-45cc-b9a5-130bfe661ea7:imagen_2025-06-10_124623841.png)

```python
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class InicioSesion(db.Model):
    __tablename__ = 'iniciosesion'
    IdInicioSesion = db.Column(db.Integer, primary_key=True)
    Nom = db.Column(db.String(100), nullable=False)
    Apell = db.Column(db.String(100), nullable=False)
    Email = db.Column(db.String(200), nullable=False)
    Contrasena = db.Column(db.String(100), nullable=False)
    NumTelf = db.Column(db.BigInteger, nullable=False)
    NumCel = db.Column(db.BigInteger, nullable=False)
    Direccion = db.Column(db.Text, nullable=False)
    PerfilDueño_IdPerfilDueño = db.Column(db.Integer, db.ForeignKey('perfildueño.IdPerfilDueño'), nullable=False)

```

**Vista**

Vista, En una API REST, la vista está representada por las respuestas que el servidor Flask envía al cliente Flutter. 

![4.png](attachment:412d86df-bd67-45ba-803c-3b684229ed95:26e76c44-7f3e-4fb2-abc0-ab010bac985a.png)

```dart
// Contenedor del formulario 
              top:              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF565449), // fondo del form
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                        height:
                            80), 
                    _buildTextField('Correo', false),
                    const SizedBox(height: 15),
                    _buildTextField('Nombre', false),
                    const SizedBox(height: 15),
                    _buildTextField('Apellido', false),
                    const SizedBox(height: 15),
                    _buildTextField('Contraseña', true),
                    const SizedBox(height: 15),
                    _buildTextField('Repita Contraseña', true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Funcionn de registro
                      },
```

**Controlador**

El controlador es el encargado de recibir las solicitudes HTTPS, procesarlas, interactuar con el modelo y devolver una respuesta a la vista.

![imagen_2025-06-10_130118776.png](attachment:521b55f3-8448-4e78-b830-aa48c7d40fe4:imagen_2025-06-10_130118776.png)

```python
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        Nom = request.form['userName']
        Apell = request.form['userLastName']
        Email = request.form['userEmail']
        Contrasena = request.form['userPassword'] 
        NumTelf = request.form['userPhone']
        Direccion = request.form['userAddress']

        hashed_password = generate_password_hash(Contrasena, method='pbkdf2:sha256')

        db = None
        cursor = None
        try:
            db = conectar_db()
            if db is None:
                 return jsonify({'message': 'Error interno del servidor (DB Connection)'}), 500
            cursor = db.cursor()
```

A continuación adjunto un diagrama visual de (MVC)

![Modelo-Vista-Controlador(MVC).png](attachment:a1a83931-1a80-4004-9ec8-946775710b45:Modelo-Vista-Controlador(MVC).png)

## **Tecnologías Utilizadas**

- **Frontend:** Dart 3.6.1 (Flutter **3.27.2** )
- **Backend:** Python **3.11+** (Flask)
- **Base de Datos:** MySQL **(local)**
- **Android Studio:** (con Android SDK)
- **Control de Versiones:** Git y GitHub
- **Docker Desktop** para Windows
- **Infraestructura:** Servidores en la nube (futuro)

## **Herramientas DevOps**

- **GitHub** → Control de versiones
- **GitHub Actions** → Automatización CI/CD
- **Docker** → Contenedores para backend y frontend
- **Prometheus** → Monitoreo de métricas en Flask

## **Flujo de datos**

(Explicación de como funciona el sistema)

![Diagrama de Casos de Usos.png](attachment:250e30df-6f84-423f-82eb-937b775cf12d:Diagrama_de_Casos_de_Usos.png)

---

## **Requisitos Técnicos del Sistema**

### Requisitos de hardware y software para instalación

### **General**

- Sistema operativo: Windows (recomendado) o Linux
- Git instalado
- Conexión a internet

### **Frontend (Flutter)**

- Flutter SDK `3.5.0` o superior
- Android Studio y VS Code con extensiones de Flutter y Dart
- Emulador Android o dispositivo físico
- Configuración de AVD (Android Virtual Device)

### **Backend (Python)**

- Python `3.10` o superior
- XAMPP (Apache y MySQL)
- pip

### Requisitos de red y servicios

- Abrir XAMPP y arrancar MySQL
- Ir a http://localhost/phpmyadmin
- Crear una base de datos llamada `dacky`
- Importar el archivo `dacky.sql` incluido en el proyecto

### Dependencias del sistema

Archivo `requirements.txt` con las siguientes dependencias:

```bash
Flask==3.0.3
Flask-Bcrypt==1.0.1
flask-cors==5.0.1
Flask-Login==0.6.3
Flask-SQLAlchemy==3.1.1
Flask-WTF==1.2.2
mysql-connector-python==9.0.0
mysqlclient==2.2.4
PyMySQL==1.1.1
```

---

## Estructura de la Base de Datos

### **Diagrama Entidad Relación**

En este diagrama Entidad-Relación se representa cada tabla con sus respectivos atributos y como se relacionan entre si dentro del sistema de manera visual

![Diagrama_Entidad-Relacion.png](attachment:b4135700-cb7b-472a-8d25-3bcd5f4c3743:Diagrama_Entidad-Relacion.png)

### **Listado de tablas (Diccionario de Datos)**

En este documento adjunto se mostrara un listado de tablas con descripción de cada campo clave y sus atributos.

‣

### **Relaciones y restricciones importantes**

### **Tabla `perfildueño`**

### **Tabla `iniciosesion`** (modificada)

| Campo | Clave | Relación |
| --- | --- | --- |
| IdPerfilDueño | PK | 1:1 iniciosesion |
| NomDueño |  | 1:N perfilmascota |
| Apell |  | 1:N mascotaeliminada |
| Email |  |  |
| NumTelf |  |  |
| NumCel |  |  |

| Campo | Clave | Relación |
| --- | --- | --- |
| IdInicioSesion | PK | 1:1 perfilcriador |
| Contrasena |  |  |
| PerfilDueño_IdPerfilDueño | FK |  |

### **Tabla `perfilmascota`**

### **Tabla `razamascota`**

| Campo | Clave | Relación |
| --- | --- | --- |
| IdPerfilMascota | PK | 1:1 mascota |
| NomMascota |  |  |
| Peso |  |  |
| Altura |  |  |
| Descripcion |  |  |
| Edad |  |  |
| PerfilDueño_IdPerfilDueño | FK |  |

| Campo | Clave | Relación |
| --- | --- | --- |
| IdRazaMascota | PK | 1:N mascota |
| Mascota_IdMascota | FK |  |
| Raza_IdRaza | FK |  |

### **Tabla `raza`**

### **Tabla `vacunasmascota`**

| Campo | Clave | Relación |
| --- | --- | --- |
| IdRaza | PK | 1:N razamascota |
| NomRaza |  |  |

| Campo | Clave | Relación |
| --- | --- | --- |
| IdVacunasMascota | PK | 1:N mascota |
| Mascota_IdMascota | FK |  |
| Vacunas_IdVacunas | FK |  |

### **Tabla `dispositivogps`**

| Campo | Clave | Relación |
| --- | --- | --- |
| IdDispositivoGPS | PK | 1:1 mascota |
| Mascota_IdMascota | FK |  |

---

## **Instalación y Configuración**

### **1. Clonar el repositorio**

```bash
git clone https://github.com/smiling011/ProyectoDacky.git
cd "Proyecto Dacky"
```

Asegurarse de que las carpetas y archivos estén organizados así:

```visual-basic
DackyApp/
├── backend/
│   ├── dacky.py
│   ├── config.py
│   ├── models.py
│   └── ...
├── frontend/
|	   └── dacky_app/
|	       ├── lib/
|	       ├── assets/
|	       ├── pubspec.yaml
|	       └── ...
└── docker/
    ├── backend.Dockerfile
    ├── flutter.Dockerfile
    └── docker-compose.yml

```

### **2. Instalación y Configuración de Flutter**

- Descargar Flutter desde el sitio oficial:
    
     https://docs.flutter.dev/get-started/install 
    
- Extraer la carpeta `flutter` en una ruta permanente, por ejemplo:
    
    `C:\src\flutter`
    
- Agregar Flutter al **PATH del sistema**:
    - Buscar "Variables de entorno" en Windows.
    - Editar la variable `Path` del sistema.
    - Agregar:
        
        `C:\src\flutter\bin`
        
- Verificar instalación en CMD:
    
    ```bash
    flutter doctor
    ```
    

![image.png](attachment:d877a866-490b-4277-bdef-ecf5140440a2:image.png)

### 3. Instalación y Configuración de Android Studio

- Descargar desde:
    
     https://developer.android.com/studio
    
- Durante la instalación, seleccionar los siguientes componentes:
    - Android SDK
    - Android SDK Platform-Tools
    - Android Virtual Device (AVD)
- Una vez instalado:
    - Abrir Android Studio
    - **Verifica el SDK de Android**
    - Despliega en Menú > File > Project Structure:
        
        ![Captura de pantalla (108).png](attachment:76108a5a-a4e0-47f2-b23a-247295b10184:2c14521e-5001-4624-9bd7-66487c74330c.png)
        
    - Verifica si la ruta del SDK Location es correcta:
        
        ![image.png](attachment:b2175e88-8d8f-4e45-ae5b-ca4ff6819c70:image.png)
        
    - Luego en Android Studio > **Settings** > **Appearance & Behavior > System Settings > Android SDK**
        
        Instala lo siguiente que:
        
        - **Android API 35 o inferior**
        
        ![imagen_2025-06-10_183625002.png](attachment:16403637-fe73-453a-a7d4-3f0d7fc2991f:imagen_2025-06-10_183625002.png)
        
        - **Android SDK Command-line Tools**
        
        ![imagen_2025-06-10_183913934.png](attachment:133c48cd-e907-44e8-97f2-2c82e73a95eb:imagen_2025-06-10_183913934.png)
        
    - Ir a: `Settings > Plugins > Marketplace`
    - **Instalar el plugin Flutter**
        
        > Esto también instalará el plugin Dart
        > 
        
        ![imagen_2025-06-10_190527896.png](attachment:17bb043c-b597-4166-806f-1c96c507cd59:imagen_2025-06-10_190527896.png)
        
- **Ir a:** `More Actions > SDK Manager`
    - Verifica que tienes una versión reciente de SDK, por ejemplo: `Android 33`
- **Crear un emulador:**
    - **Ir a** `Device Manager > Create Device`
    
    ![imagen_2025-06-10_190816431.png](attachment:63fad25a-3578-4a92-86e6-8ab3a441b37d:fd00cc0a-e595-4911-9850-2a30b384f6e8.png)
    
    - **Escoger el modelo (Medium Phone)**
    
    ![imagen_2025-06-10_191001840.png](attachment:f45ddfd1-80ad-47c1-956d-695602de5de1:imagen_2025-06-10_191001840.png)
    
    - **Descargar imagen del sistema (API 30 o superior)**
    
    ![imagen_2025-06-10_191135082.png](attachment:2e71f9f7-0a6d-4468-bfcf-9a1adf05153f:imagen_2025-06-10_191135082.png)
    
    - **Por ultimo nombrar a gusto AVD name y finalizar**
    
    ![imagen_2025-06-10_191241682.png](attachment:dd7cccf3-9fac-4c8c-946f-ccf8dace2d57:imagen_2025-06-10_191241682.png)
    

### **4. Configurar Backend (Flask)**

**a. Crear entorno virtual (opcional)**

```bash
python -m venv venv
venv\Scripts\activate  # En Windows
```

**b. Instalar dependencias**

```bash
pip install -r requirements.txt
```

**c. Configurar base de datos**

- Abrir XAMPP y arrancar MySQL
- Ir a http://localhost/phpmyadmin
- Crear una base de datos llamada `dacky`
- Importar el archivo `dacky.sql` incluido en el proyecto

**d. Archivo config.py (ejemplo)**

```
SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:(tu_contraseña)@localhost/dacky'
SQLALCHEMY_TRACK_MODIFICATIONS = False
```

**e. Ejecutar servidor Flask**

```
cd C:\Proyecto Dacky\DackyApp\backend (o ruta donde clonaste el Respositorio)
python dacky.py
```

Deberías ver: `Running on http://127.0.0.1:5000/`

### **5. Configurar Frontend (Flutter)**

1. Abrir VS Code y entrar en la sección de **extensiones** (`Ctrl + Shift + X`):
- Instalar:
    - **Flutter**
    - **Dart**

**b. Ir al directorio del proyecto Flutter**

```
cd C:\Proyecto Dacky\DackyApp\frontend\dacky_app (o ruta donde clonaste el Respositorio)
```

**c. Obtener paquetes**

```
flutter pub get
```

**d. Verificar emulador o dispositivo**

```
flutter devices
```

**e. Ejecutar la app**

```
flutter run
```

### **Comunicación entre Flutter y Flask**

- Si usas emulador Android: `http://10.0.2.2:5000`
- Si usas un dispositivo físico: usa tu IP local (ej. `http://192.168.1.10:5000`)

---

## Pruebas Técnicas

**En progreso**

Durante el desarrollo de Dacky se realizaron **pruebas manuales** y algunas pruebas básicas con **Postman** para validar el correcto funcionamiento de las rutas del backend.

### Tipos de pruebas realizadas:

- **Pruebas unitarias (manuales):** validación de funciones como registro, inicio de sesión y consulta de datos.
- **Pruebas de integración:** pruebas entre Flutter y Flask asegurando que las solicitudes HTTP respondan correctamente.
- **Pruebas funcionales:** asegurando que el flujo de registro de mascotas, visualización de la tarjeta de vacunas y lectura del código QR funcionen como se espera.
- **Integración Continua (CI) con GitHub Actions:** Se configuró un flujo de trabajo en GitHub Actions para verificar automáticamente que el backend se ejecute correctamente y que se instalen las dependencias necesarias en cada push o pull request. Esto permite detectar errores temprano y mantener la estabilidad del proyecto.

![imagen_2025-06-10_205502629.png](attachment:f33a2c71-6ca0-40d1-8b0a-744b15e30419:imagen_2025-06-10_205502629.png)

### Herramientas usadas:

- `Postman` para pruebas de las rutas del backend (`GET`, `POST`)
- `flutter run` y dispositivo/emulador para probar funcionalidades visuales

---

## Seguridad del Sistema

**En progreso**

Actualmente, la app implementa medidas de seguridad básicas, y se tienen consideradas mejoras para futuras versiones.

### Implementadas:

- **Validación de entradas** en formularios (correo, contraseñas, datos del perro).
- Separación cliente-servidor: el frontend no accede directamente a la base de datos.
- **Control de rutas seguras**: el backend Flask maneja cada solicitud validando los datos.
- **Contraseñas Cifradas:** El sistema cifra las contraseñas de los usuarios usando [werkzeug.security](http://werkzeug.security) o una función equivalente, aplicando hashing seguro (como una función equivalente, aplicando hashing seguro (como generate_password_hash ) para evitar almacenar contraseñas en texto plano.

### Planeadas (futuras mejoras):

- **Autenticación con JWT** para asegurar el inicio de sesión.
- **Prevención de ataques comunes**:
    - SQL Injection: usando SQLAlchemy para evitar inyecciones.
    - CSRF y XSS: se implementarán al crear la versión web o autenticación avanzada.

---

## Mantenimiento y Actualización

**En progreso**

### Procedimiento para actualizar la app

1. Clonar la última versión del repositorio desde GitHub.
2. Actualizar dependencias:
    
    ```bash
    flutter pub get
    pip install -r requirements.txt
    ```
    
3. Reiniciar el servidor Flask y reiniciar la app en el emulador/dispositivo.

### Backup de base de datos

1. Abrir phpMyAdmin.
2. Seleccionar la base `dacky`.
3. Ir a la pestaña “Exportar” > Formato: SQL > Descargar.

### Restaurar base de datos

1. Ir a phpMyAdmin > pestaña “Importar”.
2. Subir el archivo `dacky.sql` exportado anteriormente.

### Logs y depuración

- Flask muestra los errores en la terminal con detalles útiles para depuración.
- Se pueden agregar logs personalizados con `app.logger.info()` o `app.logger.error()`

---

## Control de Versiones

 **Clonar repositorio** 

```bash
git clone https://github.com/smiling011/ProyectoDacky.git
```

**Verificar el estado del repositorio**

Antes de actualizar, revisa qué archivos han cambiado o no están en seguimiento:

```bash
git status
```

Agregar **todos los archivos modificados y nuevos:** 

```bash
git add .
```

**Confirmar los cambios (c**ada cambio debe tener un mensaje descriptivo):

```bash
git commit -m "Descripcion del cambio"
```

**Subir los cambios a GitHub** en la rama `main`, ejecuta:

```bash
git push origin main
```

### **Actualizar el repositorio local** *(para trabajar en varias PC o en equipo)*

Si otros hicieron cambios en GitHub, antes de empezar a trabajar en tu código, descárgalos con:

```bash
git pull origin main --rebase
```

---

## **Notas Adicionales**

- La app usa una base de datos MySQL alojada localmente
- El código QR redirige a una URL que podrá conectarse a un backend online
- Colores y tipografía personalizados según la marca Dacky
- Este manual es exclusivamente para la ejecución y configuración de la aplicación móvil

---

## **Futuras Mejoras**

- Autenticación segura (JWT)
- Subida de imagen de la mascota
- Integración con GPS real y mapas
- Portal web para dueños y veterinarias
- Funciones adicionales añadidas en versiones posteriores.

---

## **Contacto**

Si tienes alguna duda o sugerencia, no dudes en escribir a:

[**victoriavielmaromero@gmail.com**](mailto:victoriavielmaromero@gmail.com)

---

## Enlace del Repositorio

https://github.com/smiling011/ProyectoDacky.git

---

## Enlace de la Documentación Técnica (Notion)

En Notion esta organizada toda la documentación original

[Proyecto Dacky](https://www.notion.so/Proyecto-Dacky-21b943cbb6a380888af8fcc987ac841b?pvs=21)