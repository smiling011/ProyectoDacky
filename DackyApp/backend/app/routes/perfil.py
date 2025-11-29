from flask import Blueprint, request, jsonify, Response
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

    # 🔹 CORREGIDO: Manejar BYTEA correctamente
    tiene_imagen = False
    if perfil.imagen is not None:
        try:
            imagen_bytes = bytes(perfil.imagen) if isinstance(perfil.imagen, memoryview) else perfil.imagen
            tiene_imagen = len(imagen_bytes) > 0
            print(f"✅ Usuario {id_usuario} tiene imagen: {len(imagen_bytes)} bytes")
        except Exception as e:
            print(f"❌ Error verificando imagen: {e}")
            tiene_imagen = False

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

    # 🔹 NUEVO: Guardar imagen correctamente
    if 'imagen' in request.files:
        file = request.files['imagen']
        if file and allowed_file(file.filename):
            file.seek(0)  # Asegurar inicio del archivo
            imagen_bytes = file.read()
            
            print(f"📥 Actualizando imagen de usuario: {file.filename}")
            print(f"📊 Tamaño: {len(imagen_bytes)} bytes")
            
            if len(imagen_bytes) > 0:
                perfil.imagen = imagen_bytes
                print(f"✅ Imagen guardada en BD: {len(imagen_bytes)} bytes")
            else:
                print(f"⚠️ Archivo vacío, no se guardará")

    db.session.commit()

    return jsonify({'success': True, 'message': 'Perfil actualizado correctamente'})


# 🆕 NUEVO: Obtener imagen de perfil desde la BD
@perfil_bp.route('/<int:id_usuario>/imagen', methods=['GET'])
def obtener_imagen_usuario(id_usuario):
    print(f"📥 Solicitando imagen para usuario ID: {id_usuario}")
    
    perfil = PerfilDueño.query.filter_by(IdInicioSesion=id_usuario).first()
    
    if not perfil:
        print(f"❌ Usuario {id_usuario} no encontrado")
        return jsonify({'mensaje': 'Perfil no encontrado'}), 404
    
    if perfil.imagen is None:
        print(f"❌ No hay imagen para usuario {id_usuario}")
        return jsonify({'mensaje': 'No hay imagen asociada'}), 404
    
    try:
        # 🔹 CORREGIDO: Manejar correctamente los bytes de PostgreSQL
        if isinstance(perfil.imagen, memoryview):
            imagen_bytes = perfil.imagen.tobytes()
        elif isinstance(perfil.imagen, bytes):
            imagen_bytes = perfil.imagen
        else:
            imagen_bytes = bytes(perfil.imagen)
        
        if len(imagen_bytes) == 0:
            print(f"❌ Imagen vacía para usuario {id_usuario}")
            return jsonify({'mensaje': 'Imagen vacía'}), 404
        
        print(f"✅ Enviando imagen: {len(imagen_bytes)} bytes")
        print(f"🔍 Primeros bytes: {imagen_bytes[:20]}")
        
        # 🔹 Detectar el tipo de imagen automáticamente
        mimetype = 'image/jpeg'  # default
        if imagen_bytes.startswith(b'\x89PNG'):
            mimetype = 'image/png'
        elif imagen_bytes.startswith(b'\xff\xd8\xff'):
            mimetype = 'image/jpeg'
        
        print(f"📝 Mimetype detectado: {mimetype}")
        
        return Response(
            imagen_bytes,
            mimetype=mimetype,
            headers={
                'Content-Type': mimetype,
                'Content-Length': str(len(imagen_bytes)),
                'Cache-Control': 'no-cache'
            }
        )
    except Exception as e:
        print(f"❌ Error al enviar imagen: {str(e)}")
        import traceback
        traceback.print_exc()
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