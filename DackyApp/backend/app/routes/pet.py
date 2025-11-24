from flask import Blueprint, request, jsonify, send_file
from app import db
from app.utils.models import PerfilDueño, PerfilMascota, Mascota, Raza, RazaMascota
import os
from werkzeug.utils import secure_filename
from datetime import datetime

pet_bp = Blueprint("pet", __name__)

# Carpeta donde se guardarán las imágenes
UPLOAD_FOLDER = "uploads/mascotas"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

# Aseguramos que la carpeta exista
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


#  Obtener todas las mascotas de un dueño
@pet_bp.route('/<int:id_perfil>', methods=['GET'])
def obtener_mascotas(id_perfil):
    mascotas = Mascota.query.filter_by(PerfilDueño_IdPerfilDueño=id_perfil).all()

    if not mascotas:
        return jsonify([]), 200

    resultado = []
    for m in mascotas:
        perfil_mascota = PerfilMascota.query.get(m.PerfilMascota_IdPerfilMascota)
        
        # 🔹 MEJORADO: Incluir información de imagen
        tiene_imagen = perfil_mascota.imagen is not None and perfil_mascota.imagen != ""
        
        resultado.append({
            'IdMascota': m.IdMascota,
            'NomMascota': perfil_mascota.NomMascota,
            'Raza': perfil_mascota.Raza,
            'Edad': perfil_mascota.Edad,
            'Peso': str(perfil_mascota.Peso),
            'Altura': str(perfil_mascota.Altura),
            'Descripcion': perfil_mascota.Descripcion,
            'tieneImagen': tiene_imagen  
        })

    return jsonify(resultado), 200


#  Crear una nueva mascota (con imagen opcional)
@pet_bp.route('/<int:id_perfil>', methods=['POST'])
def crear_mascota(id_perfil):
    # 🔹 Aceptar multipart/form-data para imágenes
    if request.content_type and request.content_type.startswith("multipart/form-data"):
        data = request.form
    else:
        data = request.get_json() or {}

    if not all(k in data for k in ('NomMascota', 'Raza', 'Edad', 'Peso', 'Altura', 'Descripcion')):
        return jsonify({'mensaje': 'Faltan campos obligatorios'}), 400

    # Crear perfil de mascota
    perfil_mascota = PerfilMascota(
        NomMascota=data['NomMascota'],
        Raza=data['Raza'],
        Edad=int(data['Edad']),
        Peso=int(data['Peso']),
        Altura=int(data['Altura']),
        Descripcion=data['Descripcion'],
        PerfilDueño_IdPerfilDueño=id_perfil
    )

    # 🔹 NUEVO: Manejar imagen si se envió
    if 'imagen' in request.files:
        file = request.files['imagen']
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            # Agregar timestamp para evitar sobrescribir
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            name, ext = os.path.splitext(filename)
            filename = f"{name}_{timestamp}{ext}"
            path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(path)
            perfil_mascota.imagen = path

    db.session.add(perfil_mascota)
    db.session.flush()  # Para obtener el IdPerfilMascota

    # Calcular el número de mascota por dueño
    ultimo_numero = Mascota.query.filter_by(PerfilDueño_IdPerfilDueño=id_perfil).count()

    # Crear relación con Mascota
    mascota = Mascota(
        NumMascota=ultimo_numero + 1,
        PerfilDueño_IdPerfilDueño=id_perfil,
        PerfilMascota_IdPerfilMascota=perfil_mascota.IdPerfilMascota
    )
    db.session.add(mascota)
    db.session.commit()

    return jsonify({'mensaje': 'Mascota registrada correctamente'}), 201


#  Obtener detalles de una mascota
@pet_bp.route('/detalle/<int:id_mascota>', methods=['GET'])
def obtener_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({'mensaje': 'Mascota no encontrada'}), 404

    perfil_mascota = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)

    # 🔹 MEJORADO: Incluir información de imagen
    tiene_imagen = perfil_mascota.imagen is not None and perfil_mascota.imagen != ""

    return jsonify({
        'IdMascota': mascota.IdMascota,
        'NomMascota': perfil_mascota.NomMascota,
        'Raza': perfil_mascota.Raza,
        'Edad': perfil_mascota.Edad,
        'Peso': str(perfil_mascota.Peso),
        'Altura': str(perfil_mascota.Altura),
        'Descripcion': perfil_mascota.Descripcion,
        'tieneImagen': tiene_imagen  # 🆕 Campo nuevo
    }), 200


# Editar mascota (con imagen opcional)
@pet_bp.route('/detalle/<int:id_mascota>', methods=['PUT'])
def editar_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({'mensaje': 'Mascota no encontrada'}), 404

    perfil_mascota = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)
    
    # 🔹 Aceptar multipart/form-data para imágenes
    if request.content_type and request.content_type.startswith("multipart/form-data"):
        data = request.form
    else:
        data = request.get_json() or {}

    perfil_mascota.NomMascota = data.get('NomMascota', perfil_mascota.NomMascota)
    perfil_mascota.Raza = data.get('Raza', perfil_mascota.Raza)
    perfil_mascota.Edad = int(data.get('Edad', perfil_mascota.Edad))
    perfil_mascota.Peso = int(data.get('Peso', perfil_mascota.Peso))
    perfil_mascota.Altura = int(data.get('Altura', perfil_mascota.Altura))
    perfil_mascota.Descripcion = data.get('Descripcion', perfil_mascota.Descripcion)

    # 🔹 NUEVO: Manejar imagen si se envió
    if 'imagen' in request.files:
        file = request.files['imagen']
        if file and allowed_file(file.filename):
            # Eliminar imagen anterior si existe
            if perfil_mascota.imagen and os.path.exists(perfil_mascota.imagen):
                try:
                    os.remove(perfil_mascota.imagen)
                except:
                    pass
            
            filename = secure_filename(file.filename)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            name, ext = os.path.splitext(filename)
            filename = f"{name}_{timestamp}{ext}"
            path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(path)
            perfil_mascota.imagen = path

    db.session.commit()

    return jsonify({'mensaje': 'Mascota actualizada correctamente'}), 200


#  Eliminar mascota
@pet_bp.route('/detalle/<int:id_mascota>', methods=['DELETE'])
def eliminar_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({'mensaje': 'Mascota no encontrada'}), 404

    perfil_mascota = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)

    # 🔹 MEJORADO: Eliminar imagen asociada si existe
    if perfil_mascota and perfil_mascota.imagen:
        if os.path.exists(perfil_mascota.imagen):
            try:
                os.remove(perfil_mascota.imagen)
            except:
                pass

    # Borramos ambos registros
    db.session.delete(mascota)
    if perfil_mascota:
        db.session.delete(perfil_mascota)

    db.session.commit()
    return jsonify({'mensaje': 'Mascota eliminada correctamente'}), 200


#  NUEVO: Obtener imagen de una mascota
@pet_bp.route('/detalle/<int:id_mascota>/imagen', methods=['GET'])
def obtener_imagen_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({'mensaje': 'Mascota no encontrada'}), 404
    
    perfil_mascota = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)
    
    if not perfil_mascota.imagen:
        return jsonify({'mensaje': 'No hay imagen asociada'}), 404
    
    # Normalizar la ruta del archivo
    imagen_path = perfil_mascota.imagen.replace('/', os.sep).replace('\\', os.sep)
    
    # Si la ruta no es absoluta, convertirla a absoluta
    if not os.path.isabs(imagen_path):
        imagen_path = os.path.join(os.getcwd(), imagen_path)
    
    if not os.path.exists(imagen_path):
        return jsonify({
            'mensaje': 'Imagen no encontrada en el servidor',
            'ruta_guardada': perfil_mascota.imagen,
            'ruta_buscada': imagen_path
        }), 404
    
    try:
        return send_file(imagen_path, as_attachment=False)
    except Exception as e:
        return jsonify({'mensaje': f'Error al enviar imagen: {str(e)}'}), 500


#  NUEVO: Eliminar solo la imagen (sin eliminar la mascota)
@pet_bp.route('/detalle/<int:id_mascota>/imagen', methods=['DELETE'])
def eliminar_imagen_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({'mensaje': 'Mascota no encontrada'}), 404
    
    perfil_mascota = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)
    
    if not perfil_mascota.imagen:
        return jsonify({'mensaje': 'No hay imagen para eliminar'}), 404
    
    # Eliminar archivo físico
    if os.path.exists(perfil_mascota.imagen):
        try:
            os.remove(perfil_mascota.imagen)
        except Exception as e:
            return jsonify({'mensaje': f'Error al eliminar imagen: {str(e)}'}), 500
    
    # Limpiar campo en BD
    perfil_mascota.imagen = None
    db.session.commit()
    
    return jsonify({'mensaje': 'Imagen eliminada correctamente'}), 200