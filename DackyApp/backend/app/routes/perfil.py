from flask import Blueprint, request, jsonify, send_file
from app.utils.models import db, PerfilDueño
from io import BytesIO

perfil_bp = Blueprint("perfil", __name__)

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


# 🟢 Obtener perfil de un usuario por ID
@perfil_bp.route('/<int:id_usuario>', methods=['GET'])
def perfil_usuario(id_usuario):
    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()

    if not perfil:
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404

    # 🔹 MEJORADO: Verificar si hay imagen en la BD (bytea)
    tiene_imagen = perfil.imagen is not None and len(perfil.imagen) > 0

    return jsonify({
        'IdPerfilDueño': perfil.IdPerfilDueño,
        'NomDueño': perfil.NomDueño or '',
        'Apell': perfil.Apell or '',
        'Email': perfil.Email or '',
        'NumTelf': str(perfil.NumTelf) if perfil.NumTelf else '',
        'NumCel': str(perfil.NumCel) if perfil.NumCel else '',
        'Direccion': perfil.Direccion or '',
        'tieneImagen': tiene_imagen
    })


# 🟢 Actualizar perfil (con imagen en BD como BYTEA)
@perfil_bp.route('/<int:id_usuario>', methods=['PUT'])
def actualizar_perfil(id_usuario):
    # 🔹 Aceptar multipart/form-data para imágenes
    if request.content_type and request.content_type.startswith("multipart/form-data"):
        data = request.form
    else:
        data = request.get_json() or {}

    if not data:
        return jsonify({'success': False, 'message': 'No se enviaron datos'}), 400

    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()

    if not perfil:
        return jsonify({'success': False, 'message': 'Perfil no encontrado'}), 404

    # Actualizar campos editables
    perfil.NomDueño = data.get('NomDueño', perfil.NomDueño)
    perfil.Apell = data.get('Apell', perfil.Apell)
    perfil.Email = data.get('Email', perfil.Email)
    perfil.NumTelf = data.get('NumTelf', perfil.NumTelf) or 0
    perfil.NumCel = data.get('NumCel', perfil.NumCel) or 0
    perfil.Direccion = data.get('Direccion', perfil.Direccion)

    # 🔹 NUEVO: Guardar imagen directamente en la BD como BYTEA
    if 'imagen' in request.files:
        file = request.files['imagen']
        if file and allowed_file(file.filename):
            # Leer el archivo como bytes
            imagen_bytes = file.read()
            # Guardar directamente en la BD
            perfil.imagen = imagen_bytes
            print(f"✅ Imagen guardada en BD: {len(imagen_bytes)} bytes")

    db.session.commit()

    return jsonify({'success': True, 'message': 'Perfil actualizado correctamente'})


# 🆕 NUEVO: Obtener imagen de perfil desde la BD
@perfil_bp.route('/<int:id_usuario>/imagen', methods=['GET'])
def obtener_imagen_usuario(id_usuario):
    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()
    
    if not perfil:
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404
    
    if not perfil.imagen or len(perfil.imagen) == 0:
        return jsonify({'mensaje': 'No hay imagen asociada'}), 404
    
    try:
        # Enviar la imagen desde la BD
        return send_file(
            BytesIO(perfil.imagen),
            mimetype='image/jpeg',
            as_attachment=False
        )
    except Exception as e:
        return jsonify({'mensaje': f'Error al enviar imagen: {str(e)}'}), 500


# 🆕 NUEVO: Eliminar solo la imagen de perfil
@perfil_bp.route('/<int:id_usuario>/imagen', methods=['DELETE'])
def eliminar_imagen_usuario(id_usuario):
    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()
    
    if not perfil:
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404
    
    if not perfil.imagen:
        return jsonify({'mensaje': 'No hay imagen para eliminar'}), 404
    
    # Limpiar campo en BD
    perfil.imagen = None
    db.session.commit()
    
    return jsonify({'mensaje': 'Imagen eliminada correctamente'}), 200