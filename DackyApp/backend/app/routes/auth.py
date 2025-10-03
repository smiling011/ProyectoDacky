from flask import Blueprint, request, jsonify
from app import db
from app.utils.models import InicioSesion, PerfilDueño
from werkzeug.security import generate_password_hash, check_password_hash

auth_bp = Blueprint("auth", __name__)

# Registro
@auth_bp.route('/registro', methods=['POST'])
def registro():
    data = request.get_json()

    if not all(k in data for k in ('Nom', 'Apell', 'Email', 'Contrasena')):
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    if InicioSesion.query.filter_by(Email=data['Email']).first():
        return jsonify({'success': False, 'message': 'El correo ya está registrado'}), 400

    # 1. Crear usuario en iniciosesion
    nuevo_usuario = InicioSesion(
        Nom=data['Nom'],
        Apell=data['Apell'],
        Email=data['Email'],
        Contrasena=generate_password_hash(data['Contrasena']),
        NumTelf=data.get('NumTelf'),
        NumCel=data.get('NumCel'),
        Direccion=data.get('Direccion'),
        Rol='usuario'
    )
    db.session.add(nuevo_usuario)
    db.session.flush()  # obtiene el IdInicioSesion antes de commit

    # 2. Crear perfil en perfildueño enlazado
    nuevo_perfil = PerfilDueño(
        NomDueño=data['Nom'],
        Apell=data['Apell'],
        Email=data['Email'],
        NumTelf=data.get('NumTelf'),
        NumCel=data.get('NumCel'),
        Direccion=data.get('Direccion'),
        IdInicioSesion=nuevo_usuario.IdInicioSesion
    )
    db.session.add(nuevo_perfil)

    db.session.commit()

    return jsonify({
        'success': True,
        'message': 'Usuario registrado correctamente',
        'id': nuevo_usuario.IdInicioSesion,
        'email': nuevo_usuario.Email
    }), 201


# Login
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    contrasena = data.get('contrasena')

    user = InicioSesion.query.filter_by(Email=email).first()

    if not user:
        return jsonify({'success': False, 'message': 'Correo no registrado'}), 401

    if not check_password_hash(user.Contrasena, contrasena):  # verificación segura
        return jsonify({'success': False, 'message': 'Contraseña incorrecta'}), 401

    perfil = user.perfil  # gracias a la relación en models.py

    return jsonify({
        'success': True,
        'message': 'Inicio de sesión exitoso',
        'id': user.IdInicioSesion,
        'email': user.Email,
        'perfil': {
            'idPerfil': perfil.IdPerfilDueño,
            'nom': perfil.NomDueño,
            'apell': perfil.Apell,
            'direccion': perfil.Direccion,
            'numTelf': perfil.NumTelf,
            'numCel': perfil.NumCel
        } if perfil else None
    })
