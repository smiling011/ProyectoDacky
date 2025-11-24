from flask import Blueprint, request, jsonify, send_file
from app.utils.models import db, PerfilDueño
import os
from werkzeug.utils import secure_filename
from datetime import datetime

perfil_bp = Blueprint("perfil", __name__)

# Carpeta donde se guardarán las imágenes de perfil
UPLOAD_FOLDER = "uploads/usuarios"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

# Aseguramos que la carpeta exista
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


# 🟢 Obtener perfil de un usuario por ID
@perfil_bp.route('/<int:id_usuario>', methods=['GET'])
def perfil_usuario(id_usuario):
    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()

    if not perfil:
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404

    # 🔹 MEJORADO: Incluir información de imagen
    tiene_imagen = perfil.imagen is not None and perfil.imagen != ""

    return jsonify({
        'IdPerfilDueño': perfil.IdPerfilDueño,
        'NomDueño': perfil.NomDueño or '',
        'Apell': perfil.Apell or '',
        'Email': perfil.Email or '',
        'NumTelf': str(perfil.NumTelf) if perfil.NumTelf else '',
        'NumCel': str(perfil.NumCel) if perfil.NumCel else '',
        'Direccion': perfil.Direccion or '',
        'tieneImagen': tiene_imagen  # 🆕 Campo nuevo
    })


# 🟢 Actualizar perfil (con imagen opcional)
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

    # 🔹 NUEVO: Manejar imagen si se envió
    if 'imagen' in request.files:
        file = request.files['imagen']
        if file and allowed_file(file.filename):
            # Eliminar imagen anterior si existe
            if perfil.imagen and os.path.exists(perfil.imagen):
                try:
                    os.remove(perfil.imagen)
                except:
                    pass
            
            filename = secure_filename(file.filename)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            name, ext = os.path.splitext(filename)
            filename = f"user_{id_usuario}_{timestamp}{ext}"
            path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(path)
            perfil.imagen = path

    db.session.commit()

    return jsonify({'success': True, 'message': 'Perfil actualizado correctamente'})


# 🆕 NUEVO: Obtener imagen de perfil de usuario
@perfil_bp.route('/<int:id_usuario>/imagen', methods=['GET'])
def obtener_imagen_usuario(id_usuario):
    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()
    
    if not perfil:
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404
    
    if not perfil.imagen:
        return jsonify({'mensaje': 'No hay imagen asociada'}), 404
    
    # Normalizar la ruta del archivo
    imagen_path = perfil.imagen.replace('/', os.sep).replace('\\', os.sep)
    
    # Si la ruta no es absoluta, convertirla a absoluta
    if not os.path.isabs(imagen_path):
        imagen_path = os.path.join(os.getcwd(), imagen_path)
    
    if not os.path.exists(imagen_path):
        return jsonify({
            'mensaje': 'Imagen no encontrada en el servidor',
            'ruta_guardada': perfil.imagen,
            'ruta_buscada': imagen_path
        }), 404
    
    try:
        return send_file(imagen_path, as_attachment=False)
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
    
    # Eliminar archivo físico
    if os.path.exists(perfil.imagen):
        try:
            os.remove(perfil.imagen)
        except Exception as e:
            return jsonify({'mensaje': f'Error al eliminar imagen: {str(e)}'}), 500
    
    # Limpiar campo en BD
    perfil.imagen = None
    db.session.commit()
    
    return jsonify({'mensaje': 'Imagen eliminada correctamente'}), 200