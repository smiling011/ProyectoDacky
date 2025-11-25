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


# 🟢 Registrar vacuna a una mascota (CORREGIDO)
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

    # 🔹 CAMBIO: Ahora recibimos IdVacunas en lugar de NomVacuna
    if not all(k in data for k in ("IdVacunas", "Edad", "NumDosis")):
        return jsonify({"mensaje": "Faltan campos obligatorios (IdVacunas, Edad, NumDosis)"}), 400

    # Verificar que la vacuna existe
    id_vacuna = int(data["IdVacunas"])
    vacuna = Vacunas.query.get(id_vacuna)
    if not vacuna:
        return jsonify({"mensaje": "Vacuna no encontrada en el catálogo"}), 404

    # Parseo de fechas
    fecha_vac = None
    if data.get("FechaVac"):
        try:
            fecha_vac = datetime.strptime(data["FechaVac"], "%Y-%m-%d").date()
        except ValueError:
            return jsonify({"mensaje": "Formato de fecha inválido (usar YYYY-MM-DD)"}), 400

    fecha_ven = None
    if data.get("FechaVenVac"):
        try:
            fecha_ven = datetime.strptime(data["FechaVenVac"], "%Y-%m-%d").date()
        except ValueError:
            return jsonify({"mensaje": "Formato de fecha de vencimiento inválido"}), 400

    # Crear registro de vacuna aplicada
    vacuna_mascota = VacunasMascota(
        Mascota_IdMascota=id_mascota,
        Vacunas_IdVacunas=id_vacuna,
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


# 🟢 Editar vacuna aplicada (CORREGIDO)
@vacunas_bp.route("/detalle/<int:id_vacuna_mascota>", methods=["PUT"])
def editar_vacuna(id_vacuna_mascota):
    vacuna_mascota = VacunasMascota.query.get(id_vacuna_mascota)
    if not vacuna_mascota:
        return jsonify({"mensaje": "Vacuna no encontrada"}), 404

    # 🔹 Aceptar JSON o multipart
    if request.content_type and request.content_type.startswith("multipart/form-data"):
        data = request.form
    else:
        data = request.get_json() or {}

    # 🔹 CAMBIO: Actualizar con IdVacunas
    if "IdVacunas" in data:
        id_vacuna = int(data["IdVacunas"])
        vacuna = Vacunas.query.get(id_vacuna)
        if not vacuna:
            return jsonify({"mensaje": "Vacuna no encontrada en el catálogo"}), 404
        vacuna_mascota.Vacunas_IdVacunas = id_vacuna

    # Parseo de fechas
    if data.get("FechaVac"):
        try:
            vacuna_mascota.FechaVac = datetime.strptime(data["FechaVac"], "%Y-%m-%d").date()
        except ValueError:
            pass

    if data.get("FechaVenVac"):
        try:
            vacuna_mascota.FechaVenVac = datetime.strptime(data["FechaVenVac"], "%Y-%m-%d").date()
        except ValueError:
            pass

    if "Edad" in data:
        vacuna_mascota.Edad = int(data["Edad"])
    if "NumDosis" in data:
        vacuna_mascota.NumDosis = int(data["NumDosis"])
    if "Nota" in data:
        vacuna_mascota.Nota = data["Nota"]

    # Si hay archivo adjunto, reemplazar el anterior
    if "file" in request.files:
        file = request.files["file"]
        if file and allowed_file(file.filename):
            # Eliminar archivo anterior si existe
            if vacuna_mascota.archivo and os.path.exists(vacuna_mascota.archivo):
                try:
                    os.remove(vacuna_mascota.archivo)
                except:
                    pass
            
            filename = secure_filename(file.filename)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            name, ext = os.path.splitext(filename)
            filename = f"{name}_{timestamp}{ext}"
            path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(path)
            vacuna_mascota.archivo = path

    db.session.commit()
    
    return jsonify({
        "mensaje": "Vacuna actualizada correctamente",
        "vacuna": {
            "IdVacunasMascota": vacuna_mascota.IdVacunasMascota,
            "NomVacuna": vacuna_mascota.vacuna.NomVacuna if vacuna_mascota.vacuna else "Desconocida",
            "FechaVac": vacuna_mascota.FechaVac.isoformat() if vacuna_mascota.FechaVac else None,
            "Edad": vacuna_mascota.Edad,
            "FechaVenVac": vacuna_mascota.FechaVenVac.isoformat() if vacuna_mascota.FechaVenVac else None,
            "NumDosis": vacuna_mascota.NumDosis,
            "Nota": vacuna_mascota.Nota
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
    try:
        from app.utils.pdf_generator import generar_pdf_vacunas
        from app.utils.models import PerfilMascota
        
        print(f"Buscando mascota con ID: {id_mascota}")
        mascota = Mascota.query.get(id_mascota)
        if not mascota:
            print("Mascota no encontrada")
            return jsonify({"mensaje": "Mascota no encontrada"}), 404
        
        print(f"Mascota encontrada: {mascota.IdMascota}")
        
        # Obtener perfil de la mascota
        perfil = PerfilMascota.query.get(mascota.PerfilMascota_IdPerfilMascota)
        print(f"Perfil encontrado: {perfil.NomMascota if perfil else 'No hay perfil'}")
        
        # Obtener vacunas
        vacunas = VacunasMascota.query.filter_by(Mascota_IdMascota=id_mascota).all()
        print(f"Vacunas encontradas: {len(vacunas)}")
        
        # Preparar datos
        datos_mascota = {
            'NomMascota': perfil.NomMascota if perfil else 'Mascota sin nombre',
            'Raza': perfil.Raza if perfil else 'N/A',
            'Edad': perfil.Edad if perfil else 0,
            'Peso': float(perfil.Peso) if perfil and perfil.Peso else 0,
            'Altura': float(perfil.Altura) if perfil and perfil.Altura else 0,
        }
        
        print(f"Datos mascota: {datos_mascota}")
        
        lista_vacunas = []
        for v in vacunas:
            vacuna_data = {
                'NomVacuna': v.vacuna.NomVacuna if v.vacuna else 'Desconocida',
                'FechaVac': v.FechaVac.strftime('%d/%m/%Y') if v.FechaVac else 'N/A',
                'Edad': v.Edad,
                'NumDosis': v.NumDosis,
                'FechaVenVac': v.FechaVenVac.strftime('%d/%m/%Y') if v.FechaVenVac else 'N/A',
                'Nota': v.Nota if v.Nota else ''
            }
            lista_vacunas.append(vacuna_data)
            print(f"Vacuna agregada: {vacuna_data['NomVacuna']}")
        
        # 🔹 CORRECCIÓN: Generar PDF con ruta absoluta
        pdf_folder = os.path.join(os.getcwd(), "uploads", "pdfs")
        if not os.path.exists(pdf_folder):
            os.makedirs(pdf_folder)
            print(f"Carpeta creada: {pdf_folder}")
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        nombre_mascota = datos_mascota['NomMascota'].replace(' ', '_')
        pdf_filename = f"vacunas_{nombre_mascota}_{timestamp}.pdf"
        pdf_path = os.path.join(pdf_folder, pdf_filename)
        
        print(f"Generando PDF en: {pdf_path}")
        
        generar_pdf_vacunas(datos_mascota, lista_vacunas, pdf_path)
        
        # 🔹 VERIFICAR que el archivo existe antes de enviarlo
        if not os.path.exists(pdf_path):
            print(f"ERROR: El PDF no se generó en {pdf_path}")
            return jsonify({"mensaje": "Error: PDF no se generó correctamente"}), 500
        
        print(f"PDF generado exitosamente en: {pdf_path}")
        print(f"Tamaño del archivo: {os.path.getsize(pdf_path)} bytes")
        
        return send_file(pdf_path, as_attachment=True, download_name=pdf_filename)
        
    except Exception as e:
        import traceback
        error_detail = traceback.format_exc()
        print("=" * 80)
        print("ERROR AL GENERAR PDF:")
        print(error_detail)
        print("=" * 80)
        return jsonify({
            "mensaje": f"Error al generar PDF: {str(e)}",
            "tipo_error": type(e).__name__
        }), 500
        

# 🆕 NUEVO: Obtener catálogo completo de vacunas
@vacunas_bp.route("/catalogo", methods=["GET"])
def obtener_catalogo_vacunas():
    """Retorna todas las vacunas disponibles en el catálogo"""
    vacunas = Vacunas.query.order_by(Vacunas.NomVacuna).all()
    resultado = [
        {
            "IdVacunas": v.IdVacunas,
            "NomVacuna": v.NomVacuna
        }
        for v in vacunas
    ]
    return jsonify(resultado), 200