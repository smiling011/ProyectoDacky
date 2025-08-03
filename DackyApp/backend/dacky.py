from flask import request, jsonify
from models import InicioSesion

@app.route('/registro', methods=['POST'])
def registro():
    data = request.get_json()

    # Validación simple
    if not all(k in data for k in ('Nom', 'Apell', 'Email', 'Contrasena')):
        return jsonify({'mensaje': 'Faltan campos obligatorios'}), 400

    nuevo_usuario = InicioSesion(
        Nom=data['Nom'],
        Apell=data['Apell'],
        Email=data['Email'],
        Contrasena=data['Contrasena'],
        NumTelf=None,         # Se pueden completar luego
        NumCel=None,
        Direccion=None,
        PerfilDueño_IdPerfilDueño=None,
        Rol='usuario'
    )

    db.session.add(nuevo_usuario)
    db.session.commit()

    return jsonify({'mensaje': 'Usuario registrado correctamente'})
