from flask import Flask, render_template, request, redirect, url_for, send_from_directory
import pymysql
import os

# Configuración de la aplicación Flask
app = Flask(__name__)

# Configura el directorio estático (por ejemplo: css, js, imágenes)
app.config['STATIC_FOLDER'] = 'assets'

# Conexión a la base de datos MySQL
def get_db_connection():
    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='12345',  # Cambia esto si tienes una contraseña para tu base de datos
        db='dacky',
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection

# Configura el directorio de plantillas manualmente
app.template_folder = 'Pagina Dacky'

@app.route('/')
def home():
    try:
        return render_template('login.html')  # Ahora busca en la carpeta 'Pagina Dacky'
    except FileNotFoundError:
        return "Archivo HTML no encontrado", 404


# Ruta para servir archivos estáticos como CSS, JS, imágenes
@app.route('/css/<path:filename>')
def serve_css(filename):
    return send_from_directory(os.path.join('Pagina Dacky', 'css'), filename)

@app.route('/js/<path:filename>')
def serve_js(filename):
    return send_from_directory(os.path.join('Pagina Dacky', 'js'), filename)

@app.route('/img/<path:filename>')
def serve_img(filename):
    return send_from_directory(os.path.join('Pagina Dacky', 'img'), filename)

# Ruta para procesar el login (conexión con la base de datos)
@app.route('/login', methods=['POST'])
def login():
    email = request.form['email']
    password = request.form['password']
    
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # Consulta SQL para validar al usuario
            sql = "SELECT * FROM iniciosesion WHERE correo = %s AND contrasena = %s"
            cursor.execute(sql, (email, password))
            user = cursor.fetchone()
            if user:
                return redirect(url_for('welcome', username=user['correo']))
            else:
                return "Credenciales incorrectas", 401
    finally:
        connection.close()

# Ruta para la página de bienvenida después del login
@app.route('/welcome/<username>')
def welcome(username):
    return f"¡Bienvenido, {username}!"

if __name__ == '__main__':
    app.run(debug=True)
