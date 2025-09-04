from flask import Blueprint, request, jsonify
from app.utils.models import db, PerfilDueño

perfil_bp = Blueprint("perfil", __name__)

# Obtener perfil de un usuario por ID
@perfil_bp.route('/<int:id_usuario>', methods=['GET'])
def perfil_usuario(id_usuario):
    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()

    if not perfil:
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404

    return jsonify({
        'NomDueño': perfil.NomDueño or '',
        'Apell': perfil.Apell or '',
        'Email': perfil.Email or '',
        'NumTelf': str(perfil.NumTelf) if perfil.NumTelf else '',
        'NumCel': str(perfil.NumCel) if perfil.NumCel else '',
        'Direccion': perfil.Direccion or ''
    })


# Actualizar perfil
@perfil_bp.route('/<int:id_usuario>', methods=['PUT'])
def actualizar_perfil(id_usuario):
    data = request.get_json()

    if not data:
        return jsonify({'success': False, 'message': 'No se enviaron datos'}), 400

    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()

    if not perfil:
        return jsonify({'success': False, 'message': 'Perfil no encontrado'}), 404

    # Actualizar solo los campos editables
    perfil.NomDueño = data.get('NomDueño', perfil.NomDueño)
    perfil.Apell = data.get('Apell', perfil.Apell)
    perfil.Email = data.get('Email', perfil.Email)
    perfil.NumTelf = data.get('NumTelf', perfil.NumTelf) or 0
    perfil.NumCel = data.get('NumCel', perfil.NumCel) or 0
    perfil.Direccion = data.get('Direccion', perfil.Direccion)

    db.session.commit()

    return jsonify({'success': True, 'message': 'Perfil actualizado correctamente'})
