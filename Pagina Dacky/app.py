# app.py
# ==============================
# 📌 Librerías utilizadas
# ==============================
from flask import (
    Flask, render_template, request, jsonify,
    session, redirect, url_for, flash
)
from functools import wraps
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash

# ==============================
# 📌 Inicialización de la App
# ==============================
app = Flask(__name__)
app.secret_key = 'tu_llave_muy_secreta_y_dificil_de_adivinar_12345!@#$%'

# ==============================
# 📌 Configuración Base de Datos
# ==============================
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "12345",   # <- Cambia si tu password es distinta
    "database": "dacky",
    "charset": "utf8mb4"
}

def conectar_db():
    """Función para conectar a la base de datos MySQL"""
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except mysql.connector.Error as err:
        print(f"❌ Error conectando a la base de datos: {err}")
        return None

# ==============================
# 📌 Decoradores
# ==============================
def admin_required(f):
    """Verifica que el usuario tenga rol admin antes de acceder a ciertas rutas"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_role' not in session or session['user_role'] != 'admin':
            flash('Acceso no autorizado. Debes ser administrador.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# ------------------------------
# Mapeo de "views" del admin a tablas reales
# usamos nombres de endpoint amigables (sin ñ)
TABLE_MAP = {
    "iniciosesion": "iniciosesion",
    "perfildueno": "perfildueño",   # ten en cuenta la ñ en la BD (si tu DB la tiene)
    "perfilmascota": "perfilmascota",
    "mascota": "mascota",
    "vacunasmascota": "vacunasmascota"
}
# ==============================
# 📌 Rutas públicas y auth mínimo
# ==============================
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

# -------------------------------------------------
# (mantén las demás rutas públicas que tengas)
# -------------------------------------------------

# Rutas de login/register/perfil (resumidas)
# -------------------------------------------------
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        return redirect(url_for('admin_dashboard') if session.get('user_role') == 'admin' else url_for('perfil'))

    if request.method == 'POST':
        Email = request.form.get('userEmail')
        Contrasena_ingresada = request.form.get('userPassword')
        db = conectar_db()
        if db is None:
            return jsonify({'message': 'Error interno DB'}), 500
        cursor = db.cursor(dictionary=True)
        try:
            cursor.execute("SELECT IdInicioSesion, Email, Nom, rol, Contrasena FROM iniciosesion WHERE Email = %s", (Email,))
            user = cursor.fetchone()
            if user and check_password_hash(user['Contrasena'], Contrasena_ingresada):
                session['user_id'] = user['IdInicioSesion']
                session['user_email'] = user['Email']
                session['user_name'] = user['Nom']
                session['user_role'] = user['rol']
                session.permanent = True
                redirect_url = url_for('admin_dashboard' if user['rol'] == 'admin' else 'perfil')
                return jsonify({'message': 'ok', 'redirect_url': redirect_url}), 200
            return jsonify({'message': 'Credenciales inválidas'}), 401
        finally:
            cursor.close()
            db.close()
    return render_template('login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    # Mantén tu implementación actual o la que ya tenías.
    return render_template('login.html')

# @app.route('/perfil')
# def perfil():
#     # tu implementación de perfil (ya la tienes)
#     return render_template('perfil.html')

# ==============================
# 📌 Panel Administrador (UN SOLO admin.html)
# - Parámetro GET ?view=<iniciosesion|perfildueno|perfilmascota|mascota|vacunasmascota>
# - Por defecto view=iniciosesion (usuarios)
# ==============================
@app.route('/admin')
@admin_required
def admin_dashboard():
    view = request.args.get('view', 'iniciosesion')
    if view not in TABLE_MAP:
        view = 'iniciosesion'

    db = conectar_db()
    if db is None:
        flash('Error al conectar con la base de datos.', 'danger')
        return redirect(url_for('index'))
    cursor = db.cursor(dictionary=True)

    # Prepara variables para render
    titulo = ""
    columnas = []
    datos = []

    try:
        # --- INICIOSESION ---
        if view == 'iniciosesion':
            titulo = "Inicio Sesión / Usuarios"
            columnas = ["IdInicioSesion", "Nom", "Apell", "Email", "NumTelf", "Direccion", "Rol"]
            cursor.execute("SELECT IdInicioSesion, Nom, Apell, Email, NumTelf, Direccion, rol FROM iniciosesion ORDER BY IdInicioSesion ASC")
            datos = cursor.fetchall()

        # --- PERFIL DUEÑO ---
        elif view == 'perfildueno':
            titulo = "Perfiles Dueño"
            columnas = ["IdPerfilDueño", "NomDueño", "Apell", "Email", "NumTelf", "NumCel", "Direccion", "IdInicioSesion"]
            # tabla en DB llamada 'perfildueño' - usamos la consulta tal cual
            cursor.execute("SELECT IdPerfilDueño, NomDueño, Apell, Email, NumTelf, NumCel, Direccion, IdInicioSesion FROM `perfildueño` ORDER BY IdPerfilDueño ASC")
            datos = cursor.fetchall()

        # --- PERFIL MASCOTA ---
        elif view == 'perfilmascota':
            titulo = "Perfiles Mascota"
            columnas = ["IdPerfilMascota", "NomMascota", "Raza", "Peso", "Altura", "Edad", "PerfilDueño_IdPerfilDueño"]
            cursor.execute("SELECT IdPerfilMascota, NomMascota, Raza, Peso, Altura, Edad, PerfilDueño_IdPerfilDueño FROM perfilmascota ORDER BY IdPerfilMascota ASC")
            datos = cursor.fetchall()

        # --- MASCOTA (relaciona perfilMascota y perfildueño para mostrar nombre) ---
        elif view == 'mascota':
            titulo = "Mascotas (vinculación)"
            columnas = ["IdMascota", "NumMascota", "PerfilDueño_IdPerfilDueño", "PerfilMascota_IdPerfilMascota", "NomMascota"]
            # hacemos join para mostrar NomMascota si existe
            cursor.execute("""
                SELECT m.IdMascota, m.NumMascota, m.PerfilDueño_IdPerfilDueño, m.PerfilMascota_IdPerfilMascota,
                       pm.NomMascota
                FROM mascota m
                LEFT JOIN perfilmascota pm ON m.PerfilMascota_IdPerfilMascota = pm.IdPerfilMascota
                ORDER BY m.IdMascota ASC
            """)
            datos = cursor.fetchall()

        # --- VACUNAS MASCOTA ---
        elif view == 'vacunasmascota':
            titulo = "Vacunas Mascota"
            columnas = ["IdVacunasMascota", "NomVacuna", "Mascota_IdMascota", "FechaVac", "Edad", "FechaVenVac", "NumDosis", "Nota"]
            cursor.execute("""
                SELECT IdVacunasMascota, NomVacuna, Mascota_IdMascota, FechaVac, Edad, FechaVenVac, NumDosis, Nota
                FROM vacunasmascota
                ORDER BY IdVacunasMascota ASC
            """)
            datos = cursor.fetchall()

    except mysql.connector.Error as err:
        print(f"❌ Error al consultar datos admin: {err}")
        flash('Ocurrió un error al cargar los datos.', 'danger')
    finally:
        cursor.close()
        db.close()

    # Renderizamos admin.html con datos relevantes
    return render_template(
        'admin.html',
        admin_name=session.get('user_name'),
        titulo=titulo,
        columnas=columnas,
        datos=datos,
        active=view
    )

# ==============================
# 📌 CRUD genérico por entidad (ADD / GET / UPDATE / DELETE)
# Endpoints:
#  - POST   /admin/add/<entity>
#  - GET    /admin/get/<entity>/<int:id>
#  - POST   /admin/update/<entity>/<int:id>
#  - DELETE /admin/delete/<entity>/<int:id>
# entity debe ser uno de las keys en TABLE_MAP
# ==============================

def entity_table(entity):
    """Devuelve el nombre real de tabla en DB para la entidad dada"""
    return TABLE_MAP.get(entity)

# ---- ADD ----
@app.route('/admin/add/<entity>', methods=['POST'])
@admin_required
def admin_add(entity):
    if entity not in TABLE_MAP:
        return jsonify({'success': False, 'message': 'Entidad inválida'}), 400

    data = request.json or request.form
    db = conectar_db()
    if db is None:
        return jsonify({'success': False, 'message': 'Error de conexión DB'}), 500
    cursor = db.cursor()

    try:
        # === iniciosesion ===
        if entity == 'iniciosesion':
            Nom = data.get('Nom')
            Apell = data.get('Apell')
            Email = data.get('Email')
            Contrasena = data.get('Contrasena')  # texto plano desde admin: lo hasheamos
            NumTelf = data.get('NumTelf')
            Direccion = data.get('Direccion')
            PerfilDueño_IdPerfilDueño = data.get('PerfilDueño_IdPerfilDueño') or None
            hashed = generate_password_hash(Contrasena, method='pbkdf2:sha256') if Contrasena else ''
            cursor.execute("""
                INSERT INTO iniciosesion (Nom, Apell, Email, Contrasena, NumTelf, Direccion, PerfilDueño_IdPerfilDueño, rol)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (Nom, Apell, Email, hashed, NumTelf, Direccion, PerfilDueño_IdPerfilDueño, data.get('rol','usuario')))
            db.commit()
            return jsonify({'success': True, 'id': cursor.lastrowid}), 201

        # === perfildueño ===
        if entity == 'perfildueno':
            NomDueño = data.get('NomDueño')
            Apell = data.get('Apell')
            Email = data.get('Email')
            NumTelf = data.get('NumTelf')
            NumCel = data.get('NumCel')
            Direccion = data.get('Direccion')
            IdInicioSesion = data.get('IdInicioSesion')
            cursor.execute("INSERT INTO `perfildueño` (NomDueño, Apell, Email, NumTelf, NumCel, Direccion, IdInicioSesion) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                           (NomDueño, Apell, Email, NumTelf, NumCel, Direccion, IdInicioSesion))
            db.commit()
            return jsonify({'success': True, 'id': cursor.lastrowid}), 201

        # === perfilmascota ===
        if entity == 'perfilmascota':
            NomMascota = data.get('NomMascota')
            Raza = data.get('Raza')
            Peso = data.get('Peso') or 0
            Altura = data.get('Altura') or 0
            Descripcion = data.get('Descripcion') or ''
            Edad = data.get('Edad') or 0
            PerfilDueño_IdPerfilDueño = data.get('PerfilDueño_IdPerfilDueño')
            cursor.execute("""
                INSERT INTO perfilmascota (NomMascota, Raza, Peso, Altura, Descripcion, Edad, PerfilDueño_IdPerfilDueño)
                VALUES (%s,%s,%s,%s,%s,%s,%s)
            """, (NomMascota, Raza, Peso, Altura, Descripcion, Edad, PerfilDueño_IdPerfilDueño))
            db.commit()
            return jsonify({'success': True, 'id': cursor.lastrowid}), 201

        # === mascota ===
        if entity == 'mascota':
            NumMascota = data.get('NumMascota')
            PerfilDueño_IdPerfilDueño = data.get('PerfilDueño_IdPerfilDueño')
            PerfilMascota_IdPerfilMascota = data.get('PerfilMascota_IdPerfilMascota')
            cursor.execute("INSERT INTO mascota (NumMascota, PerfilDueño_IdPerfilDueño, PerfilMascota_IdPerfilMascota) VALUES (%s,%s,%s)",
                           (NumMascota, PerfilDueño_IdPerfilDueño, PerfilMascota_IdPerfilMascota))
            db.commit()
            return jsonify({'success': True, 'id': cursor.lastrowid}), 201

        # === vacunasmascota ===
        if entity == 'vacunasmascota':
            NomVacuna = data.get('NomVacuna')
            Mascota_IdMascota = data.get('Mascota_IdMascota')
            Vacunas_IdVacunas = data.get('Vacunas_IdVacunas') or None
            FechaVac = data.get('FechaVac') or None
            Edad = data.get('Edad') or 0
            FechaVenVac = data.get('FechaVenVac') or None
            NumDosis = data.get('NumDosis') or 1
            Nota = data.get('Nota') or None
            cursor.execute("""
                INSERT INTO vacunasmascota (NomVacuna, Mascota_IdMascota, Vacunas_IdVacunas, FechaVac, Edad, FechaVenVac, NumDosis, Nota)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (NomVacuna, Mascota_IdMascota, Vacunas_IdVacunas, FechaVac, Edad, FechaVenVac, NumDosis, Nota))
            db.commit()
            return jsonify({'success': True, 'id': cursor.lastrowid}), 201

        return jsonify({'success': False, 'message': 'Entidad no soportada'}), 400

    except mysql.connector.Error as err:
        if db: db.rollback()
        print("Error add:", err)
        return jsonify({'success': False, 'message': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# ---- GET single record ----
@app.route('/admin/get/<entity>/<int:rec_id>', methods=['GET'])
@admin_required
def admin_get(entity, rec_id):
    if entity not in TABLE_MAP:
        return jsonify({'success': False, 'message': 'Entidad inválida'}), 400

    db = conectar_db()
    if db is None:
        return jsonify({'success': False, 'message': 'Error de conexión DB'}), 500
    cursor = db.cursor(dictionary=True)

    try:
        if entity == 'iniciosesion':
            cursor.execute("SELECT IdInicioSesion, Nom, Apell, Email, NumTelf, Direccion, rol FROM iniciosesion WHERE IdInicioSesion = %s", (rec_id,))
            row = cursor.fetchone()
            return jsonify(row or {}), 200

        if entity == 'perfildueno':
            cursor.execute("SELECT IdPerfilDueño, NomDueño, Apell, Email, NumTelf, NumCel, Direccion, IdInicioSesion FROM `perfildueño` WHERE IdPerfilDueño = %s", (rec_id,))
            row = cursor.fetchone()
            return jsonify(row or {}), 200

        if entity == 'perfilmascota':
            cursor.execute("SELECT * FROM perfilmascota WHERE IdPerfilMascota = %s", (rec_id,))
            row = cursor.fetchone()
            return jsonify(row or {}), 200

        if entity == 'mascota':
            cursor.execute("SELECT * FROM mascota WHERE IdMascota = %s", (rec_id,))
            row = cursor.fetchone()
            return jsonify(row or {}), 200

        if entity == 'vacunasmascota':
            cursor.execute("SELECT * FROM vacunasmascota WHERE IdVacunasMascota = %s", (rec_id,))
            row = cursor.fetchone()
            return jsonify(row or {}), 200

        return jsonify({}), 404

    except mysql.connector.Error as err:
        print("Error get:", err)
        return jsonify({'success': False, 'message': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# ---- UPDATE ----
@app.route('/admin/update/<entity>/<int:rec_id>', methods=['POST'])
@admin_required
def admin_update(entity, rec_id):
    if entity not in TABLE_MAP:
        return jsonify({'success': False, 'message': 'Entidad inválida'}), 400

    data = request.json or request.form
    db = conectar_db()
    if db is None:
        return jsonify({'success': False, 'message': 'Error DB'}), 500
    cursor = db.cursor()

    try:
        if entity == 'iniciosesion':
            # Permitir actualizar campos principales. Contraseña opcional.
            Nom = data.get('Nom')
            Apell = data.get('Apell')
            Email = data.get('Email')
            NumTelf = data.get('NumTelf')
            Direccion = data.get('Direccion')
            rol = data.get('rol', 'usuario')
            if data.get('Contrasena'):
                hashed = generate_password_hash(data.get('Contrasena'), method='pbkdf2:sha256')
                cursor.execute("UPDATE iniciosesion SET Nom=%s, Apell=%s, Email=%s, Contrasena=%s, NumTelf=%s, Direccion=%s, rol=%s WHERE IdInicioSesion=%s",
                               (Nom, Apell, Email, hashed, NumTelf, Direccion, rol, rec_id))
            else:
                cursor.execute("UPDATE iniciosesion SET Nom=%s, Apell=%s, Email=%s, NumTelf=%s, Direccion=%s, rol=%s WHERE IdInicioSesion=%s",
                               (Nom, Apell, Email, NumTelf, Direccion, rol, rec_id))
            db.commit()
            return jsonify({'success': True}), 200

        if entity == 'perfildueno':
            cursor.execute("UPDATE `perfildueño` SET NomDueño=%s, Apell=%s, Email=%s, NumTelf=%s, NumCel=%s, Direccion=%s WHERE IdPerfilDueño=%s",
                           (data.get('NomDueño'), data.get('Apell'), data.get('Email'), data.get('NumTelf'), data.get('NumCel'), data.get('Direccion'), rec_id))
            db.commit()
            return jsonify({'success': True}), 200

        if entity == 'perfilmascota':
            cursor.execute("UPDATE perfilmascota SET NomMascota=%s, Raza=%s, Peso=%s, Altura=%s, Descripcion=%s, Edad=%s WHERE IdPerfilMascota=%s",
                           (data.get('NomMascota'), data.get('Raza'), data.get('Peso'), data.get('Altura'), data.get('Descripcion'), data.get('Edad'), rec_id))
            db.commit()
            return jsonify({'success': True}), 200

        if entity == 'mascota':
            cursor.execute("UPDATE mascota SET NumMascota=%s, PerfilDueño_IdPerfilDueño=%s, PerfilMascota_IdPerfilMascota=%s WHERE IdMascota=%s",
                           (data.get('NumMascota'), data.get('PerfilDueño_IdPerfilDueño'), data.get('PerfilMascota_IdPerfilMascota'), rec_id))
            db.commit()
            return jsonify({'success': True}), 200

        if entity == 'vacunasmascota':
            cursor.execute("UPDATE vacunasmascota SET NomVacuna=%s, Mascota_IdMascota=%s, FechaVac=%s, Edad=%s, FechaVenVac=%s, NumDosis=%s, Nota=%s WHERE IdVacunasMascota=%s",
                           (data.get('NomVacuna'), data.get('Mascota_IdMascota'), data.get('FechaVac'), data.get('Edad'), data.get('FechaVenVac'), data.get('NumDosis'), data.get('Nota'), rec_id))
            db.commit()
            return jsonify({'success': True}), 200

        return jsonify({'success': False, 'message': 'Entidad no soportada'}), 400

    except mysql.connector.Error as err:
        if db: db.rollback()
        print("Error update:", err)
        return jsonify({'success': False, 'message': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# ---- DELETE general ----
@app.route('/admin/delete/<entity>/<int:rec_id>', methods=['DELETE'])
@admin_required
def admin_delete(entity, rec_id):
    if entity not in TABLE_MAP:
        return jsonify({'success': False, 'message': 'Entidad inválida'}), 400

    db = conectar_db()
    if db is None:
        return jsonify({'success': False, 'message': 'Error DB'}), 500
    cursor = db.cursor()

    try:
        table = entity_table(entity)
        # map entity to primary key column name
        pk = {
            'iniciosesion': 'IdInicioSesion',
            'perfildueno': 'IdPerfilDueño',
            'perfilmascota': 'IdPerfilMascota',
            'mascota': 'IdMascota',
            'vacunasmascota': 'IdVacunasMascota'
        }.get(entity)

        cursor.execute(f"DELETE FROM `{table}` WHERE {pk} = %s", (rec_id,))
        db.commit()
        if cursor.rowcount > 0:
            return jsonify({'success': True}), 200
        else:
            return jsonify({'success': False, 'message': 'No encontrado'}), 404

    except mysql.connector.Error as err:
        if db: db.rollback()
        print("Error delete:", err)
        return jsonify({'success': False, 'message': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# ==============================
# 📌 Logout
# ==============================
@app.route('/logout')
def logout():
    session.clear()
    flash('Has cerrado sesión exitosamente.', 'success')
    return redirect(url_for('login'))

# ==============================
# 📌 Ruta de Test
# ==============================
@app.route('/test')
def test():
    return '¡La aplicación Flask está funcionando!'

# ==============================
# 📌 Punto de entrada
# ==============================
if __name__ == '__main__':
    app.run(debug=True)
