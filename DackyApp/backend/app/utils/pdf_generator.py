from reportlab.lib import colors
from reportlab.lib.pagesizes import letter, A4
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from datetime import datetime
import os

def generar_pdf_vacunas(mascota, vacunas, output_path):
    """
    Genera un PDF con la tarjeta de vacunas de una mascota
    
    Args:
        mascota: Objeto con datos de la mascota (NomMascota, Raza, Edad, etc.)
        vacunas: Lista de diccionarios con datos de vacunas
        output_path: Ruta donde guardar el PDF
    """
    
    # Crear documento PDF
    doc = SimpleDocTemplate(
        output_path,
        pagesize=letter,
        rightMargin=30,
        leftMargin=30,
        topMargin=30,
        bottomMargin=18,
    )
    
    # Contenedor de elementos
    elementos = []
    
    # Estilos
    estilos = getSampleStyleSheet()
    estilo_titulo = ParagraphStyle(
        'CustomTitle',
        parent=estilos['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#11120D'),
        spaceAfter=30,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    estilo_subtitulo = ParagraphStyle(
        'CustomSubtitle',
        parent=estilos['Heading2'],
        fontSize=14,
        textColor=colors.HexColor('#11120D'),
        spaceAfter=12,
        fontName='Helvetica-Bold'
    )
    
    estilo_normal = ParagraphStyle(
        'CustomNormal',
        parent=estilos['Normal'],
        fontSize=10,
        textColor=colors.HexColor('#11120D'),
        spaceAfter=6,
    )
    
    # 🔹 ENCABEZADO
    titulo = Paragraph("<b>TARJETA DE VACUNAS</b>", estilo_titulo)
    elementos.append(titulo)
    elementos.append(Spacer(1, 0.2*inch))
    
    # 🔹 INFORMACIÓN DE LA MASCOTA
    info_mascota = Paragraph("<b>Información de la Mascota</b>", estilo_subtitulo)
    elementos.append(info_mascota)
    
    datos_mascota = [
        ['Nombre:', mascota.get('NomMascota', 'N/A')],
        ['Raza:', mascota.get('Raza', 'N/A')],
        ['Edad:', f"{mascota.get('Edad', 'N/A')} años"],
        ['Peso:', f"{mascota.get('Peso', 'N/A')} kg"],
        ['Altura:', f"{mascota.get('Altura', 'N/A')} cm"],
    ]
    
    tabla_mascota = Table(datos_mascota, colWidths=[2*inch, 4*inch])
    tabla_mascota.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#D8CFBC')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#11120D')),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
    ]))
    
    elementos.append(tabla_mascota)
    elementos.append(Spacer(1, 0.3*inch))
    
    # 🔹 REGISTRO DE VACUNAS
    registro_vacunas = Paragraph("<b>Registro de Vacunas</b>", estilo_subtitulo)
    elementos.append(registro_vacunas)
    elementos.append(Spacer(1, 0.1*inch))
    
    if not vacunas or len(vacunas) == 0:
        sin_vacunas = Paragraph("No hay vacunas registradas.", estilo_normal)
        elementos.append(sin_vacunas)
    else:
        # Encabezados de la tabla
        datos_tabla = [['Vacuna', 'Fecha Aplicación', 'Edad', 'Dosis', 'Vencimiento', 'Nota']]
        
        # Agregar datos de cada vacuna
        for v in vacunas:
            nombre = v.get('NomVacuna', 'N/A')
            fecha_vac = v.get('FechaVac', 'N/A')
            edad = str(v.get('Edad', 'N/A'))
            dosis = f"{v.get('NumDosis', 0)}/5"
            fecha_ven = v.get('FechaVenVac', 'N/A') if v.get('FechaVenVac') else 'N/A'
            nota = v.get('Nota', '')[:30] + '...' if v.get('Nota') and len(v.get('Nota', '')) > 30 else v.get('Nota', '-')
            
            datos_tabla.append([nombre, fecha_vac, edad, dosis, fecha_ven, nota])
        
        # Crear tabla
        tabla_vacunas = Table(datos_tabla, colWidths=[1.3*inch, 1.1*inch, 0.6*inch, 0.6*inch, 1.1*inch, 1.8*inch])
        
        # Estilo de la tabla
        tabla_vacunas.setStyle(TableStyle([
            # Encabezado
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#11120D')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 9),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 10),
            ('TOPPADDING', (0, 0), (-1, 0), 10),
            
            # Contenido
            ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor('#FEF9F2')),
            ('TEXTCOLOR', (0, 1), (-1, -1), colors.HexColor('#11120D')),
            ('ALIGN', (0, 1), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 1), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 1), (-1, -1), 6),
            ('TOPPADDING', (0, 1), (-1, -1), 6),
            
            # Bordes
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            
            # Alternar colores de filas
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#FEF9F2')]),
        ]))
        
        elementos.append(tabla_vacunas)
    
    # 🔹 PIE DE PÁGINA
    elementos.append(Spacer(1, 0.5*inch))
    fecha_generacion = datetime.now().strftime("%d/%m/%Y %H:%M")
    pie = Paragraph(
        f"<i>Documento generado el {fecha_generacion} por DackyApp</i>",
        ParagraphStyle('Pie', parent=estilos['Normal'], fontSize=8, textColor=colors.grey, alignment=TA_CENTER)
    )
    elementos.append(pie)
    
    # Construir PDF
    doc.build(elementos)
    
    return output_path