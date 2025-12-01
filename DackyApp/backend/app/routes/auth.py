from flask import Blueprint, request, jsonify
from flask_mail import Message
from app import db, mail
from app.utils.models import InicioSesion, PerfilDueño
from werkzeug.security import generate_password_hash, check_password_hash
import secrets
from datetime import datetime

auth_bp = Blueprint("auth", __name__)

# Función para generar token único
def generar_token():
    return secrets.token_urlsafe(32)

# Registro
@auth_bp.route('/registro', methods=['POST'])
def registro():
    data = request.get_json()
    
    print(f"📥 Datos recibidos: {data}")

    if not all(k in data for k in ('Nom', 'Apell', 'Email', 'Contrasena')):
        return jsonify({'success': False, 'message': 'Faltan campos obligatorios'}), 400

    if InicioSesion.query.filter_by(Email=data['Email']).first():
        return jsonify({'success': False, 'message': 'El correo ya está registrado'}), 400

    # Validar y convertir campos numéricos
    num_telf = data.get('NumTelf')
    num_cel = data.get('NumCel')
    
    if num_telf == '' or num_telf is None:
        num_telf = 0
    else:
        try:
            num_telf = int(num_telf)
        except (ValueError, TypeError):
            num_telf = 0
    
    if num_cel == '' or num_cel is None:
        num_cel = 0
    else:
        try:
            num_cel = int(num_cel)
        except (ValueError, TypeError):
            num_cel = 0

    direccion = data.get('Direccion', '') or ''

    try:
        # 1️⃣ Crear PerfilDueño PRIMERO
        nuevo_perfil = PerfilDueño(
            NomDueño=data['Nom'],
            Apell=data['Apell'],
            Email=data['Email'],
            NumTelf=num_telf,
            NumCel=num_cel,
            Direccion=direccion
        )
        db.session.add(nuevo_perfil)
        db.session.flush()
        
        print(f"✅ Perfil creado con ID: {nuevo_perfil.IdPerfilDueño}")

        # 2️⃣ Crear InicioSesion usando SQL directo
        from sqlalchemy import text
        
        sql = text("""
            INSERT INTO iniciosesion 
            ("Nom", "Apell", "Email", "Contrasena", "NumTelf", "NumCel", "Direccion", "Rol", "PerfilDueño_IdPerfilDueño")
            VALUES (:nom, :apell, :email, :contrasena, :numtelf, :numcel, :direccion, :rol, :perfil_id)
            RETURNING "IdInicioSesion"
        """)
        
        result = db.session.execute(sql, {
            'nom': data['Nom'],
            'apell': data['Apell'],
            'email': data['Email'],
            'contrasena': generate_password_hash(data['Contrasena']),
            'numtelf': num_telf,
            'numcel': num_cel,
            'direccion': direccion,
            'rol': 'usuario',
            'perfil_id': nuevo_perfil.IdPerfilDueño
        })
        
        id_inicio_sesion = result.fetchone()[0]
        
        print(f"✅ Usuario creado con ID: {id_inicio_sesion}")

        # 3️⃣ Actualizar PerfilDueño con IdInicioSesion
        nuevo_perfil.IdInicioSesion = id_inicio_sesion

        db.session.commit()
        
        print("✅ Registro completado exitosamente")

        token = generar_token()

        return jsonify({
            'success': True,
            'message': 'Usuario registrado correctamente',
            'id': id_inicio_sesion,
            'email': data['Email'],
            'token': token
        }), 201
        
    except Exception as e:
        db.session.rollback()
        import traceback
        error_completo = traceback.format_exc()
        print(f"❌ Error completo:\n{error_completo}")
        return jsonify({'success': False, 'message': f'Error al registrar: {str(e)}'}), 500


# Login
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    contrasena = data.get('contrasena')

    user = InicioSesion.query.filter_by(Email=email).first()

    if not user:
        return jsonify({'success': False, 'message': 'Correo no registrado'}), 401

    if not check_password_hash(user.Contrasena, contrasena):
        return jsonify({'success': False, 'message': 'Contraseña incorrecta'}), 401

    perfil = user.perfil
    token = generar_token()

    return jsonify({
        'success': True,
        'message': 'Inicio de sesión exitoso',
        'id': user.IdInicioSesion,
        'email': user.Email,
        'token': token,
        'perfil': {
            'idPerfil': perfil.IdPerfilDueño,
            'nom': perfil.NomDueño,
            'apell': perfil.Apell,
            'direccion': perfil.Direccion,
            'numTelf': perfil.NumTelf,
            'numCel': perfil.NumCel
        } if perfil else None
    })


# Verificar sesión
@auth_bp.route('/verificar-sesion', methods=['POST'])
def verificar_sesion():
    data = request.get_json()
    token = data.get('token')
    user_id = data.get('id')

    if not token or not user_id:
        return jsonify({'success': False, 'message': 'Token o ID faltante'}), 400

    user = InicioSesion.query.get(user_id)
    
    if not user:
        return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404

    return jsonify({
        'success': True,
        'message': 'Sesión válida',
        'user': {
            'id': user.IdInicioSesion,
            'email': user.Email,
            'nombre': user.Nom,
            'apellido': user.Apell
        }
    })


# Cerrar sesión
@auth_bp.route('/logout', methods=['POST'])
def logout():
    data = request.get_json()
    user_id = data.get('id')

    if not user_id:
        return jsonify({'success': False, 'message': 'ID faltante'}), 400

    user = InicioSesion.query.get(user_id)
    
    if not user:
        return jsonify({'success': False, 'message': 'Usuario no encontrado'}), 404

    return jsonify({
        'success': True,
        'message': 'Sesión cerrada correctamente'
    })


# Registro/Login con Google
@auth_bp.route('/registro-google', methods=['POST'])
def registro_google():
    data = request.get_json()
    
    email = data.get('email')
    nombre = data.get('nombre', 'Usuario')
    apellido = data.get('apellido', '')
    uid = data.get('uid')

    if not email or not uid:
        return jsonify({'success': False, 'message': 'Email o UID faltante'}), 400

    # Verificar si el usuario ya existe
    user = InicioSesion.query.filter_by(Email=email).first()

    if user:
        perfil = user.perfil
        token = generar_token()

        return jsonify({
            'success': True,
            'message': 'Inicio de sesión exitoso con Google',
            'id': user.IdInicioSesion,
            'email': user.Email,
            'token': token,
            'perfil': {
                'idPerfil': perfil.IdPerfilDueño if perfil else None,
                'nom': perfil.NomDueño if perfil else nombre,
                'apell': perfil.Apell if perfil else apellido,
            } if perfil else None
        }), 200

    # Usuario nuevo - registrar con Google
    try:
        nuevo_perfil = PerfilDueño(
            NomDueño=nombre,
            Apell=apellido,
            Email=email,
            NumTelf=0,
            NumCel=0,
            Direccion=''
        )
        db.session.add(nuevo_perfil)
        db.session.flush()
        
        print(f"✅ Perfil Google creado con ID: {nuevo_perfil.IdPerfilDueño}")

        from sqlalchemy import text
        
        sql = text("""
            INSERT INTO iniciosesion 
            ("Nom", "Apell", "Email", "Contrasena", "NumTelf", "NumCel", "Direccion", "Rol", "PerfilDueño_IdPerfilDueño")
            VALUES (:nom, :apell, :email, :contrasena, :numtelf, :numcel, :direccion, :rol, :perfil_id)
            RETURNING "IdInicioSesion"
        """)
        
        result = db.session.execute(sql, {
            'nom': nombre,
            'apell': apellido,
            'email': email,
            'contrasena': generate_password_hash(uid),
            'numtelf': 0,
            'numcel': 0,
            'direccion': '',
            'rol': 'usuario',
            'perfil_id': nuevo_perfil.IdPerfilDueño
        })
        
        id_inicio_sesion = result.fetchone()[0]
        
        print(f"✅ Usuario Google creado con ID: {id_inicio_sesion}")

        nuevo_perfil.IdInicioSesion = id_inicio_sesion
        db.session.commit()
        
        print("✅ Registro Google completado exitosamente")

        token = generar_token()

        return jsonify({
            'success': True,
            'message': 'Usuario registrado con Google correctamente',
            'id': id_inicio_sesion,
            'email': email,
            'token': token
        }), 201
        
    except Exception as e:
        db.session.rollback()
        import traceback
        error_completo = traceback.format_exc()
        print(f"❌ Error en registro Google:\n{error_completo}")
        return jsonify({'success': False, 'message': f'Error al registrar con Google: {str(e)}'}), 500


# Enviar código de verificación por correo
# Enviar código de verificación por correo
@auth_bp.route('/enviar-codigo', methods=['POST'])
def enviar_codigo():
    data = request.get_json()
    
    email = data.get('email')
    codigo = data.get('codigo')
    nombre = data.get('nombre', 'Usuario')

    if not email or not codigo:
        return jsonify({'success': False, 'message': 'Email o código faltante'}), 400

    #  Responder inmediatamente ANTES de enviar el correo
    # El correo se enviará en segundo plano
    try:
        # Enviar el correo en un thread separado para no bloquear
        from threading import Thread
        
        def enviar_correo_async():
            try:
                msg = Message(
                    subject='Código de verificación - Dacky App',
                    recipients=[email]
                )
                
                msg.html = f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body {{
                            font-family: 'Arial', sans-serif;
                            background-color: #f4f4f4;
                            margin: 0;
                            padding: 0;
                        }}
                        .container {{
                            max-width: 600px;
                            margin: 50px auto;
                            background-color: #ffffff;
                            border-radius: 10px;
                            overflow: hidden;
                            box-shadow: 0 0 10px rgba(0,0,0,0.1);
                        }}
                        .header {{
                            background-color: #11120D;
                            color: #FFFBF4;
                            text-align: center;
                            padding: 30px;
                        }}
                        .content {{
                            padding: 40px 30px;
                            text-align: center;
                        }}
                        .codigo {{
                            font-size: 36px;
                            font-weight: bold;
                            letter-spacing: 10px;
                            color: #11120D;
                            background-color: #D8CFBC;
                            padding: 20px;
                            border-radius: 10px;
                            display: inline-block;
                            margin: 20px 0;
                        }}
                        .footer {{
                            background-color: #565449;
                            color: #FFFBF4;
                            text-align: center;
                            padding: 20px;
                            font-size: 12px;
                        }}
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1>🐾 DACKY</h1>
                            <p>Tu app GPS para mascotas</p>
                        </div>
                        <div class="content">
                            <h2>¡Hola {nombre}!</h2>
                            <p>Tu código de verificación es:</p>
                            <div class="codigo">{codigo}</div>
                            <p>Este código es válido por 10 minutos.</p>
                            <p>Si no solicitaste este código, ignora este correo.</p>
                        </div>
                        <div class="footer">
                            <p>© 2025 Dacky App. Todos los derechos reservados.</p>
                            <p>Este es un correo automático, por favor no respondas.</p>
                        </div>
                    </div>
                </body>
                </html>
                """
                
                mail.send(msg)
                print(f"✅ Código {codigo} enviado a {email}")
                
            except Exception as e:
                import traceback
                print(f"❌ Error al enviar correo:\n{traceback.format_exc()}")
        
        # Iniciar el envío en segundo plano
        thread = Thread(target=enviar_correo_async)
        thread.daemon = True
        thread.start()
        
        # Responder inmediatamente sin esperar
        return jsonify({
            'success': True,
            'message': 'Código enviado correctamente'
        }), 200
        
    except Exception as e:
        import traceback
        print(f"❌ Error:\n{traceback.format_exc()}")
        return jsonify({
            'success': False,
            'message': f'Error al enviar correo: {str(e)}'
        }), 500