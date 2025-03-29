import os
from flask import Flask, request, jsonify, render_template, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_cors import CORS

# Configuración de Flask
app = Flask(__name__, template_folder=os.path.abspath("C:/Proyecto Dacky/Pagina Dacky"), static_folder=None)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/dacky'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Inicialización de extensiones
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
CORS(app)  # Habilita CORS para todas las rutas

# Modelo de base de datos
class InicioSesion(db.Model):
    __tablename__ = 'iniciosesion'
    IdInicioSesion = db.Column(db.Integer, primary_key=True)
    Nom = db.Column(db.String(100), nullable=False)
    Apell = db.Column(db.String(100), nullable=False)
    Email = db.Column(db.String(200), unique=True, nullable=False)
    Contrasena = db.Column(db.String(100), nullable=False)
    NumTelf = db.Column(db.BigInteger, nullable=False)
    NumCel = db.Column(db.BigInteger, nullable=False)
    Direccion = db.Column(db.Text, nullable=False)
    Rol = db.Column(db.Enum('admin', 'usuario'), default='usuario', nullable=False)

# Middleware para agregar encabezados CORS
@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    return response

@app.route("/<path:path>", methods=["OPTIONS"])
def options_handler(path):
    response = jsonify({"msg": "CORS preflight successful"})
    response.status_code = 204
    return add_cors_headers(response)

# Ruta de la página principal
@app.route('/')
def home():
    return render_template('index.html')  # Página de inicio

# Ruta de registro
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    print("Datos recibidos en /register:", data)  # Para depuración

    if not data or not all([data.get('name'), data.get('email'), data.get('password')]):
        return jsonify({'success': False, 'message': 'Todos los campos son obligatorios'}), 400

    hashed_password = bcrypt.generate_password_hash(data['password']).decode('utf-8')

    new_user = InicioSesion(
        Nom=data['name'],
        Apell=data['lastname'],
        Email=data['email'],
        Contrasena=hashed_password,
        NumTelf=data['phone'],
        NumCel=data['cell'],
        Direccion=data['address'],
        Rol=data.get('role', 'usuario')
    )
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({'message': 'Usuario registrado exitosamente'}), 201

# Ruta de inicio de sesión
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    
    if not data or not all([data.get('email'), data.get('password')]):
        return jsonify({'success': False, 'message': 'Todos los campos son obligatorios'}), 400

    print("Datos recibidos en /login:", data)

    user = InicioSesion.query.filter_by(Email=data['email']).first()
    
    if user and bcrypt.check_password_hash(user.Contrasena, data['password']):
        return jsonify({
            'message': 'Inicio de sesión exitoso',
            'user': {'id': user.IdInicioSesion, 'name': user.Nom, 'role': user.Rol}
        })
    
    return jsonify({'message': 'Correo o contraseña incorrectos'}), 401

# Rutas para servir archivos estáticos manualmente
@app.route('/css/<path:filename>')
def serve_css(filename):
    return send_from_directory(os.path.join(os.getcwd(), 'css'), filename)

@app.route('/js/<path:filename>')
def serve_js(filename):
    return send_from_directory(os.path.join(os.getcwd(), 'js'), filename)

@app.route('/img/<path:filename>')
def serve_img(filename):
    return send_from_directory(os.path.join(os.getcwd(), 'img'), filename)

# Ejecutar la aplicación
if __name__ == '__main__':
    app.run(debug=True)
