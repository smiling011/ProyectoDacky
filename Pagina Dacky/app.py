
# librerias utilizadas
from flask import (Flask, render_template, request, jsonify,
                   session, redirect, url_for, flash)
from functools import wraps
import mysql.connector
# --- IMPORTAR HERRAMIENTAS DE HASHEO ---
from werkzeug.security import generate_password_hash, check_password_hash
# --------------------------------------

# inicializacion
app = Flask(__name__)

# Clave secreta (mantenla segura)
app.secret_key = 'tu_llave_muy_secreta_y_dificil_de_adivinar_12345!@#$%'

# Configuración DB (sin cambios)
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "12345",
    "database": "dacky",
    "charset": "utf8mb4"
}

# Función conectar_db (sin cambios)
def conectar_db():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        print(f"Error conectando a la base de datos: {err}")
        return None

# Decorador admin_required (sin cambios)
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_role' not in session or session['user_role'] != 'admin':
            flash('Acceso no autorizado. Debes ser administrador.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# Rutas /, sobrenosotros, servicio, descargarapp (sin cambios)
@app.route('/')
def index():
    return render_template('index.html')
@app.route('/sobrenosotros')
def sobrenosotros():
    return render_template('sobrenosotros.html')
@app.route('/servicio')
def servicio():
    return render_template('servicio.html')
@app.route('/descargarapp')
def descargarapp():
    return render_template('descargarapp.html')

# Ruta perfil (sin cambios funcionales, solo protección básica)
@app.route('/perfil')
def perfil():
    if 'user_id' not in session:
        flash('Debes iniciar sesión para ver tu perfil.', 'info')
        return redirect(url_for('login'))
    return render_template('perfil.html', user_name=session.get('user_name'))

# --- Ruta de Registro (MODIFICADA PARA HASHEAR) ---
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        Nom = request.form['userName']
        Apell = request.form['userLastName']
        Email = request.form['userEmail']
        Contrasena = request.form['userPassword'] # <-- Contraseña en texto plano del form
        NumTelf = request.form['userPhone']
        Direccion = request.form['userAddress']

        # --- GENERAR HASH DE LA CONTRASEÑA ---
        # El método 'pbkdf2:sha256' es un buen estándar actual.
        # Puedes ajustar el salt_length si lo deseas.
        hashed_password = generate_password_hash(Contrasena, method='pbkdf2:sha256')
        # ---------------------------------------

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
                return jsonify({'message': 'El correo electrónico ya está registrado'}), 409

            # 2. Insertar en perfildueño (si es necesario)
            cursor.execute("INSERT INTO perfildueño (NomDueño, Apell, Email, NumTelf) VALUES (%s, %s, %s, %s)", (Nom, Apell, Email, NumTelf))
            perfil_dueno_id = cursor.lastrowid

            # 3. --- INSERTAR EN iniciosesion CON CONTRASEÑA HASHEADA ---
            cursor.execute(
                "INSERT INTO iniciosesion (Nom, Apell, Email, Contrasena, NumTelf, Direccion, PerfilDueño_IdPerfilDueño, rol) "
                "VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                (Nom, Apell, Email, hashed_password, NumTelf, Direccion, perfil_dueno_id, 'usuario') # <-- Usar hashed_password
            )
            # ---------------------------------------------------------
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
        return render_template('login.html')

# --- Ruta para iniciar sesión (MODIFICADA PARA VERIFICAR HASH) ---
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        # Redirigir si ya está logueado
        return redirect(url_for('admin_dashboard') if session.get('user_role') == 'admin' else url_for('perfil'))

    if request.method == 'POST':
        Email = request.form['userEmail']
        # Contraseña ingresada por el usuario en el formulario
        Contrasena_ingresada = request.form['userPassword']

        db = None
        cursor = None
        try:
            db = conectar_db()
            if db is None:
                 return jsonify({'message': 'Error interno del servidor (DB Connection)'}), 500

            cursor = db.cursor(dictionary=True) # Usar dictionary=True es útil

            # Seleccionar usuario y obtener su HASH de contraseña guardado
            cursor.execute(
                "SELECT IdInicioSesion, Email, Nom, rol, Contrasena FROM iniciosesion WHERE Email = %s",
                (Email,)
            )
            user = cursor.fetchone() # user['Contrasena'] contiene el HASH guardado

            # --- VERIFICAR CONTRASEÑA USANDO check_password_hash ---
            # Comprueba si se encontró un usuario Y si el hash guardado coincide
            # con la contraseña ingresada.
            if user and check_password_hash(user['Contrasena'], Contrasena_ingresada):
            # ---------------------------------------------------------

                # Usuario autenticado -> Guardar en sesión
                session['user_id'] = user['IdInicioSesion']
                session['user_email'] = user['Email']
                session['user_name'] = user['Nom']
                session['user_role'] = user['rol']
                session.permanent = True # Opcional: hacer sesión más duradera

                # Determinar URL de redirección según el rol
                redirect_url = url_for('admin_dashboard' if user['rol'] == 'admin' else 'perfil')
                message = 'Inicio de sesión exitoso' + (' (Admin)' if user['rol'] == 'admin' else '')

                return jsonify({'message': message, 'redirect_url': redirect_url}), 200

            else:
                # Usuario no encontrado O la contraseña no coincide con el hash
                return jsonify({'message': 'Correo o contraseña incorrectos'}), 401

        except mysql.connector.Error as err:
            print(f"Error en la base de datos durante el login: {err}")
            return jsonify({'message': f'Error durante el inicio de sesión: {err}'}), 500
        finally:
            if cursor: cursor.close()
            if db and db.is_connected(): db.close()

    else: # GET
        return render_template('login.html')


# Ruta admin (protegida, sin cambios en lógica interna)
@app.route('/admin')
@admin_required
def admin_dashboard():
    return render_template('admin.html', admin_name=session.get('user_name'))

# Ruta logout (sin cambios)
@app.route('/logout')
def logout():
    session.clear()
    flash('Has cerrado sesión exitosamente.', 'success')
    return redirect(url_for('login'))

# Ruta test (sin cambios)
@app.route('/test')
def test():
    return '¡La aplicación Flask está funcionando!'

# Punto de entrada (sin cambios)
if __name__ == '__main__':
    app.run(debug=True)