from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class InicioSesion(db.Model):
    __tablename__ = 'iniciosesion'

    IdInicioSesion = db.Column(db.Integer, primary_key=True)
    Nom = db.Column(db.String(100), nullable=False)
    Apell = db.Column(db.String(100), nullable=False)
    Email = db.Column(db.String(200), nullable=False, unique=True)
    Contrasena = db.Column(db.String(100), nullable=False)
    NumTelf = db.Column(db.BigInteger, nullable=True)
    NumCel = db.Column(db.BigInteger, nullable=True)
    Direccion = db.Column(db.Text, nullable=True)
    PerfilDueño_IdPerfilDueño = db.Column(db.Integer, nullable=True)
    Rol = db.Column(db.Enum('admin', 'usuario'), default='usuario', nullable=False)
