from flask import Blueprint, request, jsonify
from app import db
from app.utils.models import Mascota, Vacunas, VacunasMascota
from datetime import datetime
import os
from werkzeug.utils import secure_filename

vacunas_bp = Blueprint("vacunas", __name__)

# Carpeta donde se guardarán los archivos subidos
UPLOAD_FOLDER = "uploads/vacunas"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "pdf"}

# Aseguramos que la carpeta exista
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


# 🟢 Obtener todas las vacunas de una mascota
@vacunas_bp.route("/<int:id_mascota>", methods=["GET"])
def obtener_vacunas_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({"mensaje": "Mascota no encontrada"}), 404

    vacunas = VacunasMascota.query.filter_by(Mascota_IdMascota=id_mascota).all()
    resultado = []

    for v in vacunas:
        resultado.append({
            "IdVacunasMascota": v.IdVacunasMascota,
            "IdVacuna": v.Vacunas_IdVacunas,
            "NomVacuna": v.vacuna.NomVacuna if v.vacuna else "Desconocida",
            "FechaVac": v.FechaVac.isoformat() if v.FechaVac else None,
            "Edad": v.Edad,
            "FechaVenVac": v.FechaVenVac.isoformat() if v.FechaVenVac else None,
            "NumDosis": v.NumDosis,
            "Nota": v.Nota
        })

    return jsonify(resultado), 200


# 🟢 Registrar vacuna a una mascota
@vacunas_bp.route("/<int:id_mascota>", methods=["POST"])
def agregar_vacuna_mascota(id_mascota):
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({"mensaje": "Mascota no encontrada"}), 404

    # 🔹 Aceptar JSON o multipart
    if request.content_type and request.content_type.startswith("multipart/form-data"):
        data = request.form
    else:
        data = request.get_json() or {}

    if not all(k in data for k in ("NomVacuna", "Edad", "NumDosis")):
        return jsonify({"mensaje": "Faltan campos obligatorios"}), 400

    # Parseo de fechas
    fecha_vac = None
    if data.get("FechaVac"):
        fecha_vac = datetime.strptime(data["FechaVac"], "%Y-%m-%d").date()

    fecha_ven = None
    if data.get("FechaVenVac"):
        fecha_ven = datetime.strptime(data["FechaVenVac"], "%Y-%m-%d").date()

    # Verificar si la vacuna ya existe en el catálogo
    vacuna = Vacunas.query.filter_by(NomVacuna=data["NomVacuna"]).first()
    if not vacuna:
        vacuna = Vacunas(NomVacuna=data["NomVacuna"])
        db.session.add(vacuna)
        db.session.flush()

    # Crear registro de vacuna aplicada
    vacuna_mascota = VacunasMascota(
        Mascota_IdMascota=id_mascota,
        Vacunas_IdVacunas=vacuna.IdVacunas,
        FechaVac=fecha_vac,
        Edad=int(data["Edad"]),
        FechaVenVac=fecha_ven,
        NumDosis=int(data["NumDosis"]),
        Nota=data.get("Nota")
    )

    # Si hay archivo adjunto
    if "file" in request.files:
        file = request.files["file"]
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(path)
            vacuna_mascota.archivo = path

    db.session.add(vacuna_mascota)
    db.session.commit()

    return jsonify({
        "mensaje": "Vacuna registrada correctamente",
        "vacuna": {
            "IdVacunasMascota": vacuna_mascota.IdVacunasMascota,
            "NomVacuna": vacuna.NomVacuna,
            "FechaVac": vacuna_mascota.FechaVac.isoformat() if vacuna_mascota.FechaVac else None,
            "Edad": vacuna_mascota.Edad,
            "FechaVenVac": vacuna_mascota.FechaVenVac.isoformat() if vacuna_mascota.FechaVenVac else None,
            "NumDosis": vacuna_mascota.NumDosis,
            "Nota": vacuna_mascota.Nota
        }
    }), 201


# 🟢 Obtener detalle de una vacuna aplicada
@vacunas_bp.route("/detalle/<int:id_vacuna_mascota>", methods=["GET"])
def obtener_vacuna_detalle(id_vacuna_mascota):
    vacuna = VacunasMascota.query.get(id_vacuna_mascota)
    if not vacuna:
        return jsonify({"mensaje": "Vacuna no encontrada"}), 404

    return jsonify({
        "IdVacunasMascota": vacuna.IdVacunasMascota,
        "NomVacuna": vacuna.vacuna.NomVacuna if vacuna.vacuna else "Desconocida",
        "FechaVac": vacuna.FechaVac.isoformat() if vacuna.FechaVac else None,
        "Edad": vacuna.Edad,
        "FechaVenVac": vacuna.FechaVenVac.isoformat() if vacuna.FechaVenVac else None,
        "NumDosis": vacuna.NumDosis,
        "Nota": vacuna.Nota
    }), 200


# 🟢 Editar vacuna aplicada (aquí está la mejora)
@vacunas_bp.route("/detalle/<int:id_vacuna_mascota>", methods=["PUT"])
def editar_vacuna(id_vacuna_mascota):
    vacuna = VacunasMascota.query.get(id_vacuna_mascota)
    if not vacuna:
        return jsonify({"mensaje": "Vacuna no encontrada"}), 404

    # 🔹 Aceptar JSON o multipart
    if request.content_type and request.content_type.startswith("multipart/form-data"):
        data = request.form
    else:
        data = request.get_json() or {}

    # Si envían un nombre de vacuna diferente
    if "NomVacuna" in data:
        vacuna_catalogo = Vacunas.query.filter_by(NomVacuna=data["NomVacuna"]).first()
        if not vacuna_catalogo:
            vacuna_catalogo = Vacunas(NomVacuna=data["NomVacuna"])
            db.session.add(vacuna_catalogo)
            db.session.flush()
        vacuna.Vacunas_IdVacunas = vacuna_catalogo.IdVacunas

    # Parseo de fechas
    if data.get("FechaVac"):
        vacuna.FechaVac = datetime.strptime(data["FechaVac"], "%Y-%m-%d").date()
    if data.get("FechaVenVac"):
        vacuna.FechaVenVac = datetime.strptime(data["FechaVenVac"], "%Y-%m-%d").date()

    vacuna.Edad = int(data.get("Edad", vacuna.Edad))
    vacuna.NumDosis = int(data.get("NumDosis", vacuna.NumDosis))
    vacuna.Nota = data.get("Nota", vacuna.Nota)

    # Si hay archivo adjunto (solo si se envía multipart)
    if "file" in request.files:
        file = request.files["file"]
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(path)
            vacuna.archivo = path

    db.session.commit()
    return jsonify({
        "mensaje": "Vacuna actualizada correctamente",
        "vacuna": {
            "IdVacunasMascota": vacuna.IdVacunasMascota,
            "NomVacuna": vacuna.vacuna.NomVacuna if vacuna.vacuna else "Desconocida",
            "FechaVac": vacuna.FechaVac.isoformat() if vacuna.FechaVac else None,
            "Edad": vacuna.Edad,
            "FechaVenVac": vacuna.FechaVenVac.isoformat() if vacuna.FechaVenVac else None,
            "NumDosis": vacuna.NumDosis,
            "Nota": vacuna.Nota
        }
    }), 200


# 🟢 Eliminar vacuna aplicada
@vacunas_bp.route("/detalle/<int:id_vacuna_mascota>", methods=["DELETE"])
def eliminar_vacuna(id_vacuna_mascota):
    vacuna = VacunasMascota.query.get(id_vacuna_mascota)
    if not vacuna:
        return jsonify({"mensaje": "Vacuna no encontrada"}), 404

    db.session.delete(vacuna)
    db.session.commit()

    return jsonify({"mensaje": "Vacuna eliminada correctamente"}), 200


# 🟢 Subir imagen o documento a una vacuna específica
@vacunas_bp.route("/detalle/<int:id_vacuna_mascota>/upload", methods=["POST"])
def subir_archivo_vacuna(id_vacuna_mascota):
    vacuna = VacunasMascota.query.get(id_vacuna_mascota)
    if not vacuna:
        return jsonify({"mensaje": "Vacuna no encontrada"}), 404

    if "file" not in request.files:
        return jsonify({"mensaje": "No se encontró archivo"}), 400

    file = request.files["file"]

    if file.filename == "":
        return jsonify({"mensaje": "No se seleccionó ningún archivo"}), 400

    if not allowed_file(file.filename):
        return jsonify({"mensaje": "Formato de archivo no permitido (solo jpg, png, pdf)"}), 400

    filename = secure_filename(file.filename)
    path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(path)

    # Guardamos la ruta en la base de datos
    vacuna.archivo = path
    db.session.commit()

    return jsonify({
        "mensaje": "Archivo subido correctamente",
        "archivo": path
    }), 200
