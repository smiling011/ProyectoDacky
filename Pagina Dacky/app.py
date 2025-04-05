# librerias utilizadas
from flask import Flask, render_template, request, jsonify  # Flask 
import mysql.connector  # Conector para bases de datos

# inicializacion
app = Flask(__name__)

# configuracion de los parametros de conexion a la base de datos 
db_config = {
    "host": "localhost",
    "user": "root",
    "password": "12345",
    "database": "dacky"
}

# establece la conexión con la base de datos usando la configuracion anterior
def conectar_db():
    return mysql.connector.connect(**db_config)

# ruta para la pagina principal
@app.route('/')
def index():
    return render_template('index.html')


# rutas para que al ejecutar la pag en el navegador se vean las otras pestañas
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
    return render_template('perfil.html')


# ruta para registrar un nuevo usuario
@app.route('/register', methods=['GET', 'POST'])  # metodos GET y POST
def register():
    if request.method == 'POST':
        # para obtener los datos del formulario enviado
        Nom = request.form['userName']
        Apell = request.form['userLastName']
        Email = request.form['userEmail']
        Contrasena = request.form['userPassword']
        NumTelf = request.form['userPhone']
        Direccion = request.form['userAddress']

        # xonecta con la base de datos
        db = conectar_db()
        cursor = db.cursor()

# error corregido por la ia
        try:
            # 1. Verificar si el usuario ya existe por Email en iniciosesion
            cursor.execute("SELECT * FROM iniciosesion WHERE Email = %s", (Email,))
            if cursor.fetchone():
                return jsonify({'message': 'El usuario ya existe'}), 409

            # 2. Insertar datos en la tabla perfildueño
            cursor.execute("INSERT INTO perfildueño (NomDueño, Apell, Email, NumTelf) VALUES (%s, %s, %s, %s)", (Nom, Apell, Email, NumTelf))
            db.commit()
            perfil_dueno_id = cursor.lastrowid  # Obtener el ID generado para el dueño

            # 3. Insertar datos en la tabla iniciosesion, incluyendo la clave foránea
            cursor.execute("INSERT INTO iniciosesion (Nom, Apell, Email, Contrasena, NumTelf, Direccion, PerfilDueño_IdPerfilDueño) VALUES (%s, %s, %s, %s, %s, %s, %s)", (Nom, Apell, Email, Contrasena, NumTelf, Direccion, perfil_dueno_id))
            db.commit()

            return jsonify({'message': 'Usuario registrado con éxito'}), 201  # Código 201 = creado exitosamente

        except mysql.connector.Error as err:
            db.rollback()  # En caso de error, deshacer cualquier cambio
            print(f"Error en la base de datos durante el registro: {err}")  # Imprimir el error en la consola
            return jsonify({'message': f'Error al registrar el usuario: {err}'}), 500
        finally:
            cursor.close()
            db.close()
    else:
        # Si es un get, se muestra el formulario de registro
        return render_template('login.html')

# ruta para iniciar sesion
@app.route('/login', methods=['GET', 'POST'])  # metodos GET y POST
def login():
    if request.method == 'POST':
        # esto para obtener los datos del formulario
        Email = request.form['userEmail']
        Contrasena = request.form['userPassword']

        # conecta con la base de datos 
        db = conectar_db()
        cursor = db.cursor()

        # Aca se verifica si el usuario y la contraseña coinciden segun la IA
        cursor.execute("SELECT * FROM iniciosesion WHERE Email = %s AND Contrasena = %s", (Email, Contrasena))
        user = cursor.fetchone()

        if user:
            # para q diga inicio de sesion exitoso
            return jsonify({'message': 'Inicio de sesion exitoso'}), 200
        else:
            # para credenciales incorrectas
            return jsonify({'message': 'Credenciales incorrectas'}), 401
    else:
        # Si es un GET, simplemente se muestra el formulario de inicio de sesión
        return render_template('login.html')

# Ruta de prueba para comprobar si la aplicación está funcionando 
#esto me lo dio la IA, ni idea de por que es util
@app.route('/test')
def test():
    return '¡La aplicación Flask está funcionando!'

# Punto de entrada de la aplicacion
if __name__ == '__main__':
    app.run(debug=True)  # Ejecutar la app en modo debug (útil para desarrollo)
    
