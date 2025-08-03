from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import Config
from models import db, InicioSesion

# Crear la app
app = Flask(__name__)
app.config.from_object(Config)

# Inicializar SQLAlchemy con la app
db.init_app(app)

# registro de usuario
@app.route('/registro', methods=['POST'])
def registro():
    data = request.get_json()

    if not all(k in data for k in ('Nom', 'Apell', 'Email', 'Contrasena')):
        return jsonify({'mensaje': 'Faltan campos obligatorios'}), 400

    nuevo_usuario = InicioSesion(
    Nom=data['Nom'],
    Apell=data['Apell'],
    Email=data['Email'],
    Contrasena=data['Contrasena'],
    NumTelf=data.get('NumTelf', 0),
    NumCel=data.get('NumCel', 0),
    Direccion=data.get('Direccion', ''),
    Rol='usuario'
)

    db.session.add(nuevo_usuario)
    db.session.commit()

    return jsonify({'mensaje': 'Usuario registrado correctamente'})


# inicio de sesion del user
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    contrasena = data.get('contrasena')

    user = InicioSesion.query.filter_by(Email=email).first()

    if not user:
        return jsonify({'success': False, 'message': 'Correo no registrado'}), 401

    # Si usas contraseñas sin hash:
    if user.Contrasena != contrasena:
        return jsonify({'success': False, 'message': 'Contraseña incorrecta'}), 401

    # Si todo está bien:
    return jsonify({'success': True, 'message': 'Inicio de sesión exitoso'})

# Ejecutar app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
