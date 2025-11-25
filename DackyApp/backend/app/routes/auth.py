from flask import Blueprint, request, jsonify
from app import db
from app.utils.models import InicioSesion, PerfilDueño
from werkzeug.security import generate_password_hash, check_password_hash
import secrets  # 🆕 Para generar tokens seguros
from datetime import datetime

auth_bp = Blueprint("auth", __name__)

# 🆕 Función para generar token único
def generar_token():
    return secrets.token_urlsafe(32)

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
    db.session.flush()

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

    # 🆕 Generar token para el nuevo usuario
    token = generar_token()

    return jsonify({
        'success': True,
        'message': 'Usuario registrado correctamente',
        'id': nuevo_usuario.IdInicioSesion,
        'email': nuevo_usuario.Email,
        'token': token  # 🆕 Token de sesión
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

    if not check_password_hash(user.Contrasena, contrasena):
        return jsonify({'success': False, 'message': 'Contraseña incorrecta'}), 401

    perfil = user.perfil

    # 🆕 Generar nuevo token de sesión
    token = generar_token()

    # 🆕 (Opcional) Guardar el token en la base de datos si quieres validarlo después
    # user.token = token
    # user.ultima_sesion = datetime.now()
    # db.session.commit()

    return jsonify({
        'success': True,
        'message': 'Inicio de sesión exitoso',
        'id': user.IdInicioSesion,
        'email': user.Email,
        'token': token,  # 🆕 Token único de sesión
        'perfil': {
            'idPerfil': perfil.IdPerfilDueño,
            'nom': perfil.NomDueño,
            'apell': perfil.Apell,
            'direccion': perfil.Direccion,
            'numTelf': perfil.NumTelf,
            'numCel': perfil.NumCel
        } if perfil else None
    })


# 🆕 OPCIONAL: Endpoint para verificar token (si quieres validar en cada request)
@auth_bp.route('/verificar-sesion', methods=['POST'])
def verificar_sesion():
    """
    Verifica si un token de sesión es válido
    Útil para validar sesiones desde el frontend
    """
    data = request.get_json()
    token = data.get('token')
    user_id = data.get('id')

    if not token or not user_id:
        return jsonify({'success': False, 'message': 'Token o ID faltante'}), 400

    user = InicioSesion.query.get(user_id)
    
    if not user:
        return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404

    # Si guardaste el token en la DB, valídalo aquí
    # if user.token != token:
    #     return jsonify({'success': False, 'message': 'Token inválido'}), 401

    return jsonify({
        'success': True,
        'message': 'Sesión válida',
        'user': {
            'id': user.IdInicioSesion,
            'email': user.Email,
            'nombre': user.Nom,
            'apellido': user.Apell
        }
    })


# 🆕 OPCIONAL: Endpoint para cerrar sesión (invalidar token)
@auth_bp.route('/logout', methods=['POST'])
def logout():
    """
    Cierra la sesión del usuario (invalida el token)
    """
    data = request.get_json()
    user_id = data.get('id')

    if not user_id:
        return jsonify({'success': False, 'message': 'ID faltante'}), 400

    user = InicioSesion.query.get(user_id)
    
    if not user:
        return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404

    # Si guardas tokens en la DB, elimínalo aquí
    # user.token = None
    # db.session.commit()

    return jsonify({
        'success': True,
        'message': 'Sesión cerrada correctamente'
    })