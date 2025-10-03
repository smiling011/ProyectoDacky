from flask import Blueprint, request, jsonify
from app import db
from app.utils.models import PerfilDueño, PerfilMascota, Mascota, Raza, RazaMascota

pet_bp = Blueprint("pet", __name__)

#  Obtener todas las mascotas de un dueño
@pet_bp.route('/<int:id_perfil>', methods=['GET'])
def obtener_mascotas(id_perfil):
    mascotas = Mascota.query.filter_by(PerfilDueño_IdPerfilDueño=id_perfil).all()

    if not mascotas:
        return jsonify([]), 200

    resultado = []
    for m in mascotas:
        perfil_mascota = PerfilMascota.query.get(m.PerfilMascota_IdPerfilMascota)
        resultado.append({
            'IdMascota': m.IdMascota,
            'NomMascota': perfil_mascota.NomMascota,
            'Raza': perfil_mascota.Raza,
            'Edad': perfil_mascota.Edad,
            'Peso': str(perfil_mascota.Peso),
            'Altura': str(perfil_mascota.Altura),
            'Descripcion': perfil_mascota.Descripcion
        })

    return jsonify(resultado), 200


# Crear una nueva mascota
@pet_bp.route('/<int:id_perfil>', methods=['POST'])
def crear_mascota(id_perfil):
    data = request.get_json()

    if not all(k in data for k in ('NomMascota', 'Raza', 'Edad', 'Peso', 'Altura', 'Descripcion')):
        return jsonify({'mensaje': 'Faltan campos obligatorios'}), 400

    # Crear perfil de mascota
    perfil_mascota = PerfilMascota(
        NomMascota=data['NomMascota'],
        Raza=data['Raza'],
        Edad=data['Edad'],
        Peso=data['Peso'],
        Altura=data['Altura'],
        Descripcion=data['Descripcion'],
        PerfilDueño_IdPerfilDueño=id_perfil
    )
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

    return jsonify({
        'IdMascota': mascota.IdMascota,
        'NomMascota': perfil_mascota.NomMascota,
        'Raza': perfil_mascota.Raza,
        'Edad': perfil_mascota.Edad,
        'Peso': str(perfil_mascota.Peso),
        'Altura': str(perfil_mascota.Altura),
        'Descripcion': perfil_mascota.Descripcion
    }), 200


# ✅ Editar mascota
@pet_bp.route('/detalle/<int:id_mascota>', methods=['PUT'])
def editar_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({'mensaje': 'Mascota no encontrada'}), 404

    perfil_mascota = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)
    data = request.get_json()

    perfil_mascota.NomMascota = data.get('NomMascota', perfil_mascota.NomMascota)
    perfil_mascota.Raza = data.get('Raza', perfil_mascota.Raza)
    perfil_mascota.Edad = data.get('Edad', perfil_mascota.Edad)
    perfil_mascota.Peso = data.get('Peso', perfil_mascota.Peso)
    perfil_mascota.Altura = data.get('Altura', perfil_mascota.Altura)
    perfil_mascota.Descripcion = data.get('Descripcion', perfil_mascota.Descripcion)

    db.session.commit()

    return jsonify({'mensaje': 'Mascota actualizada correctamente'}), 200


# ✅ Eliminar mascota
@pet_bp.route('/detalle/<int:id_mascota>', methods=['DELETE'])
def eliminar_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({'mensaje': 'Mascota no encontrada'}), 404

    perfil_mascota = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)

    # Borramos ambos registros
    db.session.delete(mascota)
    if perfil_mascota:
        db.session.delete(perfil_mascota)

    db.session.commit()
    return jsonify({'mensaje': 'Mascota eliminada correctamente'}), 200
