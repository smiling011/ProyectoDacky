
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
    # 1. Verificar si el usuario está logueado
    if 'user_id' not in session:
        flash('Debes iniciar sesión para ver tu perfil.', 'info')
        return redirect(url_for('login'))

    # 2. Obtener el ID del usuario de la sesión
    user_id_logueado = session['user_id']

    db = None
    cursor = None
    user_profile_data = None # Variable para guardar los datos

    try:
        db = conectar_db()
        if db is None:
            flash('Error al conectar con la base de datos.', 'danger')
            # Redirigir a alguna página de error o al index
            return redirect(url_for('index'))

        # Usar dictionary=True para acceder a los datos por nombre de columna
        cursor = db.cursor(dictionary=True)

        # 3. Consulta SQL con JOIN para obtener datos de perfildueño e iniciosesion
        #    Basado en el IdInicioSesion del usuario logueado.
        sql_query = """
            SELECT
                pd.NomDueño,
                pd.Apell,
                pd.Email,       -- Email de perfildueño
                pd.NumTelf,     -- Telefono Fijo de perfildueño
                pd.NumCel,      -- Celular de perfildueño
                i.Direccion     -- Direccion de iniciosesion
            FROM
                iniciosesion i
            JOIN
                perfildueño pd ON i.PerfilDueño_IdPerfilDueño = pd.IdPerfilDueño
            WHERE
                i.IdInicioSesion = %s
        """
        cursor.execute(sql_query, (user_id_logueado,))
        user_profile_data = cursor.fetchone() # Obtener la fila de datos

        if not user_profile_data:
            # Esto no debería pasar si la BD está consistente, pero es bueno verificarlo
            flash('No se pudo encontrar la información de tu perfil.', 'warning')
            session.clear() # Limpiar sesión si hay inconsistencia
            return redirect(url_for('login'))

    except mysql.connector.Error as err:
        print(f"Error al consultar perfil: {err}")
        flash('Ocurrió un error al cargar tu perfil.', 'danger')
        # Considera redirigir a una página de error o al index
        return redirect(url_for('index'))
    finally:
        # 4. Cerrar cursor y conexión
        if cursor: cursor.close()
        if db and db.is_connected(): db.close()

    # 5. Renderizar la plantilla pasando los datos obtenidos
    #    user_profile_data es ahora un diccionario con los datos del usuario
    return render_template('perfil.html', user_profile=user_profile_data)

# (Resto de las rutas: register, login, admin_dashboard, logout, etc. sin cambios necesarios para esta funcionalidad)
# ... (código posterior) ...

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


# --- Ruta del Panel de Administrador (MODIFICADA PARA MOSTRAR USUARIOS) ---
@app.route('/admin')
@admin_required # Aplicar el decorador de protección
def admin_dashboard():
    db = None
    cursor = None
    lista_usuarios = [] # Lista para guardar los usuarios

    try:
        db = conectar_db()
        if db is None:
            flash('Error al conectar con la base de datos.', 'danger')
            return redirect(url_for('index')) # O redirigir a login?

        cursor = db.cursor(dictionary=True) # Usar dictionary=True

        # Consulta para obtener los usuarios de la tabla iniciosesion
        # NO seleccionamos la contraseña por seguridad.
        # Seleccionamos las columnas que coinciden con la tabla HTML
        # Asumiendo que NumTelf en iniciosesion es 'TELEFONO' en la tabla
        # Necesitaríamos saber qué campo es 'CELULAR' (¿está en perfildueño?)
        # Por ahora, mostraremos los campos de iniciosesion
        sql_query = """
            SELECT IdInicioSesion, Nom, Apell, Email, NumTelf, Direccion
            FROM iniciosesion
            ORDER BY IdInicioSesion ASC
        """
        cursor.execute(sql_query)
        lista_usuarios = cursor.fetchall() # Obtener todos los usuarios

    except mysql.connector.Error as err:
        print(f"Error al consultar usuarios para admin: {err}")
        flash('Ocurrió un error al cargar la lista de usuarios.', 'danger')
    finally:
        if cursor: cursor.close()
        if db and db.is_connected(): db.close()

    # Pasar la lista de usuarios a la plantilla
    return render_template('admin.html',
                           admin_name=session.get('user_name'),
                           users=lista_usuarios) # Pasamos la lista como 'users'

# --- Ruta para Borrar Usuario (NUEVA) ---
@app.route('/admin/delete_user/<int:user_id>', methods=['DELETE'])
@admin_required # Proteger la ruta
def delete_user(user_id):
    db = None
    cursor = None
    try:
        db = conectar_db()
        if db is None:
            return jsonify({'success': False, 'message': 'Error de conexión'}), 500

        cursor = db.cursor()

        # OPCIONAL: Borrar primero de perfildueño si existe dependencia y no hay CASCADE DELETE
        # Necesitarías obtener el PerfilDueño_IdPerfilDueño primero
        # cursor.execute("SELECT PerfilDueño_IdPerfilDueño FROM iniciosesion WHERE IdInicioSesion = %s", (user_id,))
        # result = cursor.fetchone()
        # if result and result[0]:
        #     perfil_id = result[0]
        #     cursor.execute("DELETE FROM perfildueño WHERE IdPerfilDueño = %s", (perfil_id,))
        #     # Considerar manejo de errores aquí también

        # Borrar de la tabla iniciosesion
        cursor.execute("DELETE FROM iniciosesion WHERE IdInicioSesion = %s", (user_id,))
        db.commit() # Confirmar la transacción

        # Verificar si se borró la fila
        if cursor.rowcount > 0:
             return jsonify({'success': True, 'message': 'Usuario eliminado correctamente'}), 200
        else:
             return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404


    except mysql.connector.Error as err:
        if db: db.rollback() # Revertir cambios en caso de error
        print(f"Error al eliminar usuario: {err}")
        # Verificar si es un error de Foreign Key (si intentas borrar de iniciosesion y perfildueño depende de él sin CASCADE)
        # Código de error para Foreign Key constraint suele ser 1451 o similar
        if err.errno == 1451:
             return jsonify({'success': False, 'message': 'Error: No se puede eliminar el usuario debido a registros relacionados.'}), 409 # 409 Conflict
        return jsonify({'success': False, 'message': f'Error de base de datos: {err}'}), 500
    finally:
        if cursor: cursor.close()
        if db and db.is_connected(): db.close()

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
    
    