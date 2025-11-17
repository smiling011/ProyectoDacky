from flask import Blueprint, request, jsonify, send_file
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
        # 🔹 MEJORADO: Incluir información del archivo
        tiene_archivo = v.archivo is not None and v.archivo != ""
        nombre_archivo = None
        tipo_archivo = None
        
        if tiene_archivo:
            nombre_archivo = os.path.basename(v.archivo)
            extension = nombre_archivo.rsplit(".", 1)[1].lower() if "." in nombre_archivo else ""
            tipo_archivo = "pdf" if extension == "pdf" else "imagen"
        
        resultado.append({
            "IdVacunasMascota": v.IdVacunasMascota,
            "IdVacuna": v.Vacunas_IdVacunas,
            "NomVacuna": v.vacuna.NomVacuna if v.vacuna else "Desconocida",
            "FechaVac": v.FechaVac.isoformat() if v.FechaVac else None,
            "Edad": v.Edad,
            "FechaVenVac": v.FechaVenVac.isoformat() if v.FechaVenVac else None,
            "NumDosis": v.NumDosis,
            "Nota": v.Nota,
            "tieneArchivo": tiene_archivo,
            "nombreArchivo": nombre_archivo,
            "tipoArchivo": tipo_archivo
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
            # 🔹 MEJORADO: Agregar timestamp para evitar sobrescribir
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            name, ext = os.path.splitext(filename)
            filename = f"{name}_{timestamp}{ext}"
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

    # 🔹 MEJORADO: Incluir información del archivo
    tiene_archivo = vacuna.archivo is not None and vacuna.archivo != ""
    nombre_archivo = None
    tipo_archivo = None
    
    if tiene_archivo:
        nombre_archivo = os.path.basename(vacuna.archivo)
        extension = nombre_archivo.rsplit(".", 1)[1].lower() if "." in nombre_archivo else ""
        tipo_archivo = "pdf" if extension == "pdf" else "imagen"

    return jsonify({
        "IdVacunasMascota": vacuna.IdVacunasMascota,
        "NomVacuna": vacuna.vacuna.NomVacuna if vacuna.vacuna else "Desconocida",
        "FechaVac": vacuna.FechaVac.isoformat() if vacuna.FechaVac else None,
        "Edad": vacuna.Edad,
        "FechaVenVac": vacuna.FechaVenVac.isoformat() if vacuna.FechaVenVac else None,
        "NumDosis": vacuna.NumDosis,
        "Nota": vacuna.Nota,
        "tieneArchivo": tiene_archivo,
        "nombreArchivo": nombre_archivo,
        "tipoArchivo": tipo_archivo
    }), 200


# 🟢 Editar vacuna aplicada
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

    # 🔹 MEJORADO: Si hay archivo adjunto, reemplazar el anterior
    if "file" in request.files:
        file = request.files["file"]
        if file and allowed_file(file.filename):
            # Eliminar archivo anterior si existe
            if vacuna.archivo and os.path.exists(vacuna.archivo):
                try:
                    os.remove(vacuna.archivo)
                except:
                    pass
            
            filename = secure_filename(file.filename)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            name, ext = os.path.splitext(filename)
            filename = f"{name}_{timestamp}{ext}"
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

    # 🔹 MEJORADO: Eliminar archivo asociado si existe
    if vacuna.archivo and os.path.exists(vacuna.archivo):
        try:
            os.remove(vacuna.archivo)
        except:
            pass

    db.session.delete(vacuna)
    db.session.commit()

    return jsonify({"mensaje": "Vacuna eliminada correctamente"}), 200


# 🆕 NUEVO: Obtener/Descargar archivo de una vacuna
@vacunas_bp.route("/detalle/<int:id_vacuna_mascota>/archivo", methods=["GET"])
def obtener_archivo_vacuna(id_vacuna_mascota):
    vacuna = VacunasMascota.query.get(id_vacuna_mascota)
    if not vacuna:
        return jsonify({"mensaje": "Vacuna no encontrada"}), 404
    
    if not vacuna.archivo:
        return jsonify({"mensaje": "No hay archivo asociado"}), 404
    
    # Normalizar la ruta del archivo
    archivo_path = vacuna.archivo.replace('/', os.sep).replace('\\', os.sep)
    
    # Si la ruta no es absoluta, convertirla a absoluta desde el directorio del proyecto
    if not os.path.isabs(archivo_path):
        archivo_path = os.path.join(os.getcwd(), archivo_path)
    
    if not os.path.exists(archivo_path):
        return jsonify({
            "mensaje": "Archivo no encontrado en el servidor",
            "ruta_guardada": vacuna.archivo,
            "ruta_buscada": archivo_path
        }), 404
    
    try:
        return send_file(archivo_path, as_attachment=False)
    except Exception as e:
        return jsonify({"mensaje": f"Error al enviar archivo: {str(e)}"}), 500


# 🆕 NUEVO: Eliminar solo el archivo (sin eliminar la vacuna)
@vacunas_bp.route("/detalle/<int:id_vacuna_mascota>/archivo", methods=["DELETE"])
def eliminar_archivo_vacuna(id_vacuna_mascota):
    vacuna = VacunasMascota.query.get(id_vacuna_mascota)
    if not vacuna:
        return jsonify({"mensaje": "Vacuna no encontrada"}), 404
    
    if not vacuna.archivo:
        return jsonify({"mensaje": "No hay archivo para eliminar"}), 404
    
    # Eliminar archivo físico
    if os.path.exists(vacuna.archivo):
        try:
            os.remove(vacuna.archivo)
        except Exception as e:
            return jsonify({"mensaje": f"Error al eliminar archivo: {str(e)}"}), 500
    
    # Limpiar campo en BD
    vacuna.archivo = None
    db.session.commit()
    
    return jsonify({"mensaje": "Archivo eliminado correctamente"}), 200


# 🟢 Subir imagen o documento a una vacuna específica (MANTENER COMPATIBILIDAD)
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

    # Eliminar archivo anterior si existe
    if vacuna.archivo and os.path.exists(vacuna.archivo):
        try:
            os.remove(vacuna.archivo)
        except:
            pass

    filename = secure_filename(file.filename)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    name, ext = os.path.splitext(filename)
    filename = f"{name}_{timestamp}{ext}"
    path = os.path.join(UPLOAD_FOLDER, filename)
    file.save(path)

    # Guardamos la ruta en la base de datos
    vacuna.archivo = path
    db.session.commit()

    return jsonify({
        "mensaje": "Archivo subido correctamente",
        "archivo": path
    }), 200
    
    # 🆕 NUEVO: Exportar tarjeta de vacunas a PDF
@vacunas_bp.route("/<int:id_mascota>/exportar-pdf", methods=["GET"])
def exportar_pdf_vacunas(id_mascota):
    from app.utils.pdf_generator import generar_pdf_vacunas
    from app.utils.models import PerfilMascota
    
    mascota = Mascota.query.get(id_mascota)
    if not mascota:
        return jsonify({"mensaje": "Mascota no encontrada"}), 404
    
    # Obtener perfil de la mascota
    perfil = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)
    
    # Obtener vacunas
    vacunas = VacunasMascota.query.filter_by(Mascota_IdMascota=id_mascota).all()
    
    # Preparar datos
    datos_mascota = {
        'NomMascota': perfil.NomMascota if perfil else 'N/A',
        'Raza': perfil.Raza if perfil else 'N/A',
        'Edad': perfil.Edad if perfil else 'N/A',
        'Peso': perfil.Peso if perfil else 'N/A',
        'Altura': perfil.Altura if perfil else 'N/A',
    }
    
    lista_vacunas = []
    for v in vacunas:
        lista_vacunas.append({
            'NomVacuna': v.vacuna.NomVacuna if v.vacuna else 'Desconocida',
            'FechaVac': v.FechaVac.strftime('%d/%m/%Y') if v.FechaVac else 'N/A',
            'Edad': v.Edad,
            'NumDosis': v.NumDosis,
            'FechaVenVac': v.FechaVenVac.strftime('%d/%m/%Y') if v.FechaVenVac else None,
            'Nota': v.Nota
        })
    
    # Generar PDF
    pdf_folder = "uploads/pdfs"
    if not os.path.exists(pdf_folder):
        os.makedirs(pdf_folder)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nombre_mascota = datos_mascota['NomMascota'].replace(' ', '_')
    pdf_filename = f"vacunas_{nombre_mascota}_{timestamp}.pdf"
    pdf_path = os.path.join(pdf_folder, pdf_filename)
    
    try:
        generar_pdf_vacunas(datos_mascota, lista_vacunas, pdf_path)
        return send_file(pdf_path, as_attachment=True, download_name=pdf_filename)
    except Exception as e:
        return jsonify({"mensaje": f"Error al generar PDF: {str(e)}"}), 500