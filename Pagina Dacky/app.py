# -*- coding: utf-8 -*- # Añadir encoding por si acaso

# librerias utilizadas
from flask import (Flask, render_template, request, jsonify,
                   session, redirect, url_for, flash) # <--- Añadidos session, redirect, url_for, flash
from functools import wraps # <--- Añadido para el decorador de protección
import mysql.connector # Conector para bases de datos
# IMPORTANTE: Seguridad de Contraseñas (ver nota al final)
# from werkzeug.security import generate_password_hash, check_password_hash

# inicializacion
app = Flask(__name__)

# !!! CLAVE SECRETA PARA SESIONES !!!
# Cambia esto por una cadena de caracteres larga, aleatoria y secreta
app.secret_key = 'tu_llave_muy_secreta_y_dificil_de_adivinar_12345!@#$%'

# configuracion de los parametros de conexion a la base de datos
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "12345", # Considera usar variables de entorno para esto
    "database": "dacky",
    "charset": "utf8mb4" # Añadir charset para soportar caracteres especiales
}

# establece la conexión con la base de datos usando la configuracion anterior
def conectar_db():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        print(f"Error conectando a la base de datos: {err}")
        # En un caso real, podrías manejar esto de forma más robusta
        # Por ahora, si falla la conexión, la app no funcionará correctamente
        return None

# --- Decorador para proteger rutas de administrador ---
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Verificar si el usuario está en sesión Y si su rol es 'admin'
        if 'user_role' not in session or session['user_role'] != 'admin':
            flash('Acceso no autorizado. Debes ser administrador.', 'warning')
            return redirect(url_for('login')) # Redirigir a la página de login
        return f(*args, **kwargs)
    return decorated_function

# ruta para la pagina principal
@app.route('/')
def index():
    return render_template('index.html')

# --- Rutas existentes (sin cambios) ---
@app.route('/sobrenosotros')
def sobrenosotros():
    return render_template('sobrenosotros.html')

@app.route('/servicio')
def servicio():
    return render_template('servicio.html')

@app.route('/descargarapp')
def descargarapp():
    return render_template('descargarapp.html')

# --- Ruta de Perfil (Quizás protegerla para usuarios logueados?) ---
@app.route('/perfil')
def perfil():
    # Ejemplo de protección básica para CUALQUIER usuario logueado
    if 'user_id' not in session:
        flash('Debes iniciar sesión para ver tu perfil.', 'info')
        return redirect(url_for('login'))
    # Aquí podrías cargar datos específicos del usuario desde la BD usando session['user_id']
    return render_template('perfil.html', user_name=session.get('user_name')) # Pasar nombre a la plantilla


# --- Ruta de Registro (Modificada para seguridad de contraseña - RECOMENDADO) ---
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        Nom = request.form['userName']
        Apell = request.form['userLastName']
        Email = request.form['userEmail']
        Contrasena = request.form['userPassword'] # <-- Contraseña en texto plano
        NumTelf = request.form['userPhone']
        Direccion = request.form['userAddress']

        # --- ¡¡¡RECOMENDACIÓN FUERTE: HASHEAR CONTRASEÑA!!! ---
        # hashed_password = generate_password_hash(Contrasena)
        # Guarda hashed_password en lugar de Contrasena
        # ----------------------------------------------------

        db = None
        cursor = None
        try:
            db = conectar_db()
            if db is None:
                 return jsonify({'message': 'Error interno del servidor (DB Connection)'}), 500
            cursor = db.cursor()

            # 1. Verificar si el usuario ya existe
            cursor.execute("SELECT IdInicioSesion FROM iniciosesion WHERE Email = %s", (Email,))
            if cursor.fetchone():
                return jsonify({'message': 'El correo electrónico ya está registrado'}), 409 # 409 Conflict

            # 2. Insertar en perfildueño (si aún es necesario mantenerla separada)
            # Asegúrate que la lógica de negocio realmente requiera perfildueño separada
            # Si no, podrías simplificar y tener todo en iniciosesion
            cursor.execute("INSERT INTO perfildueño (NomDueño, Apell, Email, NumTelf) VALUES (%s, %s, %s, %s)", (Nom, Apell, Email, NumTelf))
            perfil_dueno_id = cursor.lastrowid

            # 3. Insertar en iniciosesion (¡usar contraseña hasheada!)
            # Asegúrate que la columna Contrasena sea lo suficientemente larga para el hash (ej. VARCHAR(255))
            cursor.execute(
                "INSERT INTO iniciosesion (Nom, Apell, Email, Contrasena, NumTelf, Direccion, PerfilDueño_IdPerfilDueño, rol) "
                "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                #(Nom, Apell, Email, hashed_password, NumTelf, Direccion, perfil_dueno_id, 'usuario') # <-- Usar hashed_password
                (Nom, Apell, Email, Contrasena, NumTelf, Direccion, perfil_dueno_id, 'usuario') # <-- Versión insegura actual
            )
            db.commit()

            return jsonify({'message': 'Usuario registrado con éxito'}), 201

        except mysql.connector.Error as err:
            if db: db.rollback()
            print(f"Error en la base de datos durante el registro: {err}")
            return jsonify({'message': f'Error al registrar el usuario: {err}'}), 500
        finally:
            if cursor: cursor.close()
            if db and db.is_connected(): db.close()

    else: # GET
        return render_template('login.html') # Asumo que el registro está en la misma pág que login


# --- Ruta para iniciar sesión (MODIFICADA) ---
@app.route('/login', methods=['GET', 'POST'])
def login():
    # Si el usuario ya está logueado, redirigir según su rol
    if 'user_id' in session:
        if session.get('user_role') == 'admin':
            return redirect(url_for('admin_dashboard'))
        else:
            return redirect(url_for('perfil')) # O a donde vayan los usuarios normales

    if request.method == 'POST':
        Email = request.form['userEmail']
        Contrasena = request.form['userPassword'] # Contraseña enviada por el usuario

        db = None
        cursor = None
        try:
            db = conectar_db()
            if db is None:
                 return jsonify({'message': 'Error interno del servidor (DB Connection)'}), 500

            # Usar un diccionario para obtener resultados por nombre de columna es más claro
            cursor = db.cursor(dictionary=True)

            # Seleccionar usuario por email Y OBTENER LA CONTRASEÑA (¡hasheada!) Y EL ROL
            # En tu caso actual, obtienes la contraseña en texto plano (INSEGURO)
            cursor.execute(
                "SELECT IdInicioSesion, Email, Nom, rol, Contrasena FROM iniciosesion WHERE Email = %s",
                (Email,)
            )
            user = cursor.fetchone() # Obtiene un usuario o None

            # Verificar si se encontró el usuario Y si la contraseña coincide
            # ¡¡¡DEBERÍAS USAR check_password_hash(user['Contrasena'], Contrasena) !!!
            if user and user['Contrasena'] == Contrasena: # <-- Comparación insegura actual

                # Usuario autenticado -> Guardar en sesión
                session['user_id'] = user['IdInicioSesion']
                session['user_email'] = user['Email']
                session['user_name'] = user['Nom']
                session['user_role'] = user['rol']
                session.permanent = True # Puedes hacer la sesión más duradera si quieres

                # Redirigir según el rol
                if user['rol'] == 'admin':
                    redirect_url = url_for('admin_dashboard')
                    message = 'Inicio de sesión exitoso (Admin)'
                else:
                    redirect_url = url_for('perfil') # O la ruta para usuarios normales
                    message = 'Inicio de sesión exitoso'

                return jsonify({'message': message, 'redirect_url': redirect_url}), 200

            else:
                # Credenciales incorrectas
                return jsonify({'message': 'Correo o contraseña incorrectos'}), 401

        except mysql.connector.Error as err:
            print(f"Error en la base de datos durante el login: {err}")
            return jsonify({'message': f'Error durante el inicio de sesión: {err}'}), 500
        finally:
            if cursor: cursor.close()
            if db and db.is_connected(): db.close()

    else: # GET
        # Mostrar formulario de login (asegúrate que muestre mensajes flash si hay)
        return render_template('login.html')

# --- Ruta del Panel de Administrador (NUEVA Y PROTEGIDA) ---
@app.route('/admin')
@admin_required # <--- Aplicar el decorador de protección
def admin_dashboard():
    # Solo usuarios con rol 'admin' en la sesión llegarán aquí
    # Aquí podrías cargar datos específicos para el admin si fuera necesario
    return render_template('admin.html', admin_name=session.get('user_name')) # Pasar nombre a la plantilla

# --- Ruta de Logout (NUEVA) ---
@app.route('/logout')
def logout():
    session.clear() # Limpiar toda la sesión
    flash('Has cerrado sesión exitosamente.', 'success')
    return redirect(url_for('login')) # Redirigir a la página de login


# Ruta de prueba (sin cambios)
@app.route('/test')
def test():
    return '¡La aplicación Flask está funcionando!'

# Punto de entrada (sin cambios)
if __name__ == '__main__':
    app.run(debug=True)