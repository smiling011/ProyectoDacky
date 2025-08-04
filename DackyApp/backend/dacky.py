from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import Config
from models import db, InicioSesion, PerfilDueño
from werkzeug.security import check_password_hash  # si usas hash

# Crear la app
app = Flask(__name__)
app.config.from_object(Config)

# Inicializar SQLAlchemy con la app
db.init_app(app)

# Registro de usuario
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

    nuevo_perfil = PerfilDueño(
        NomDueño=nuevo_usuario.Nom,
        Apell=nuevo_usuario.Apell,
        Email=nuevo_usuario.Email,
        NumTelf=nuevo_usuario.NumTelf or 0,
        NumCel=nuevo_usuario.NumCel or 0,
    )

    db.session.add(nuevo_perfil)
    db.session.commit()

    return jsonify({'mensaje': 'Usuario registrado correctamente'})

# Login
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    contrasena = data.get('contrasena')

    user = InicioSesion.query.filter_by(Email=email).first()

    if not user:
        return jsonify({'success': False, 'message': 'Correo no registrado'}), 401

    if user.Contrasena != contrasena:
        return jsonify({'success': False, 'message': 'Contraseña incorrecta'}), 401

    return jsonify({
        'success': True,
        'message': 'Inicio de sesión exitoso',
        'email': user.Email  # Devuelve el email en lugar del ID
    })

# Obtener perfil por email
@app.route('/perfil', methods=['POST'])
def perfil_usuario():
    data = request.get_json()
    email = data.get('email')

    if not email:
        return jsonify({'mensaje': 'Correo no proporcionado'}), 400

    perfil = PerfilDueño.query.filter_by(Email=email).first()

    if not perfil:
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404

    return jsonify({
        'NomDueño': perfil.NomDueño or '',
        'Apell': perfil.Apell or '',
        'Email': perfil.Email or '',
        'NumTelf': str(perfil.NumTelf) if perfil.NumTelf else '',
        'NumCel': str(perfil.NumCel) if perfil.NumCel else '',
        'Direccion': ''  # Ajusta si tienes esta columna en tu modelo
    })

# Ejecutar app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
