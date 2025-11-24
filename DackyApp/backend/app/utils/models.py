from datetime import datetime
from .. import db   # Usamos la instancia de __init__.py


class InicioSesion(db.Model):
    __tablename__ = 'iniciosesion'
    IdInicioSesion = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Nom = db.Column(db.String(50), nullable=False)
    Apell = db.Column(db.String(50), nullable=False)
    Email = db.Column(db.String(100), unique=True, nullable=False)
    Contrasena = db.Column(db.String(255), nullable=False)
    NumTelf = db.Column(db.String(20), nullable=True)
    NumCel = db.Column(db.String(15))
    Direccion = db.Column(db.String(255))
    Rol = db.Column(db.String(20), default='usuario')

    # Relación con PerfilDueño
    perfil = db.relationship("PerfilDueño", back_populates="usuario", uselist=False)


class PerfilDueño(db.Model):
    __tablename__ = 'perfildueño'
    IdPerfilDueño = db.Column(db.Integer, primary_key=True, autoincrement=True)
    NomDueño = db.Column(db.String(50))
    Apell = db.Column(db.String(50))
    Email = db.Column(db.String(100))
    NumTelf = db.Column(db.String(15))
    NumCel = db.Column(db.String(15))
    Direccion = db.Column(db.String(255))
    imagen = db.Column(db.String(255), nullable=True)

    IdInicioSesion = db.Column(db.Integer, db.ForeignKey('iniciosesion.IdInicioSesion'))

    usuario = db.relationship("InicioSesion", back_populates="perfil")



class PerfilMascota(db.Model):
    __tablename__ = 'perfilmascota'

    IdPerfilMascota = db.Column(db.Integer, primary_key=True, autoincrement=True)
    NomMascota = db.Column(db.String(100), nullable=False)
    Raza = db.Column(db.String(100), nullable=False)
    Peso = db.Column(db.Numeric(10, 0), nullable=False)
    Altura = db.Column(db.Numeric(10, 0), nullable=False)
    Descripcion = db.Column(db.Text, nullable=False)
    Edad = db.Column(db.Integer, nullable=False)
    PerfilDueño_IdPerfilDueño = db.Column(db.Integer, db.ForeignKey('perfildueño.IdPerfilDueño'))
    imagen = db.Column(db.String(255), nullable=True)


class Mascota(db.Model):
    __tablename__ = 'mascota'

    IdMascota = db.Column(db.Integer, primary_key=True, autoincrement=True)
    NumMascota = db.Column(db.Integer, nullable=False)
    PerfilDueño_IdPerfilDueño = db.Column(db.Integer, db.ForeignKey('perfildueño.IdPerfilDueño'))
    PerfilMascota_IdPerfilMascota = db.Column(db.Integer, db.ForeignKey('perfilmascota.IdPerfilMascota'))

    def __repr__(self):
        return f"<Mascota {self.IdMascota} - NumMascota {self.NumMascota}>"


class MascotaEliminada(db.Model):
    __tablename__ = 'mascotaseliminadas'

    IdMascotaEliminada = db.Column(db.Integer, primary_key=True, autoincrement=True)
    IdMascota = db.Column(db.Integer)
    NomMascota = db.Column(db.String(100))
    Raza = db.Column(db.String(100))
    Edad = db.Column(db.Integer)
    Peso = db.Column(db.Numeric(10, 0))
    Altura = db.Column(db.Numeric(10, 0))
    Descripcion = db.Column(db.Text)
    FechaEliminacion = db.Column(db.DateTime, default=datetime.utcnow)
    IdPerfilDueño = db.Column(db.Integer)


class Raza(db.Model):
    __tablename__ = 'raza'
    IdRaza = db.Column(db.Integer, primary_key=True, autoincrement=True)
    NomRaza = db.Column(db.String(45), nullable=False)


class RazaMascota(db.Model):
    __tablename__ = 'razamascota'
    IdRazaMascota = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Mascota_IdMascota = db.Column(db.Integer, db.ForeignKey('mascota.IdMascota'))
    Raza_IdRaza = db.Column(db.Integer, db.ForeignKey('raza.IdRaza'))


class Vacunas(db.Model):
    __tablename__ = 'vacunas'
    IdVacunas = db.Column(db.Integer, primary_key=True, autoincrement=True)
    NomVacuna = db.Column(db.String(100), nullable=False)


class VacunasMascota(db.Model):
    __tablename__ = 'vacunasmascota'
    IdVacunasMascota = db.Column(db.Integer, primary_key=True, autoincrement=True)
    Mascota_IdMascota = db.Column(db.Integer, db.ForeignKey('mascota.IdMascota'))
    Vacunas_IdVacunas = db.Column(db.Integer, db.ForeignKey('vacunas.IdVacunas'))
    FechaVac = db.Column(db.Date)
    Edad = db.Column(db.Integer, nullable=False)
    FechaVenVac = db.Column(db.Date)
    NumDosis = db.Column(db.Integer, nullable=False)
    Nota = db.Column(db.Text)
    archivo = db.Column(db.String(255), nullable=True)

    vacuna = db.relationship('Vacunas', backref='vacunas_mascota', lazy=True)
    mascota = db.relationship('Mascota', backref='vacunas_mascota', lazy=True)
