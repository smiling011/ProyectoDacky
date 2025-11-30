from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from app.utils.config import Config
from flask_mail import Mail
import os

db = SQLAlchemy()
mail = Mail()  # 🆕 Declarar mail aquí

def create_app():
    app = Flask(__name__)

    # Cargar configuración desde Config (usa variables de entorno)
    app.config.from_object(Config)

    # Inicializar base de datos
    db.init_app(app)

    # 🆕 Configuración de correo con variables de entorno
    app.config['MAIL_SERVER'] = 'smtp.gmail.com'
    app.config['MAIL_PORT'] = 587
    app.config['MAIL_USE_TLS'] = True
    app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME')  # 🔒 Desde .env
    app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD')  # 🔒 Desde .env
    app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_USERNAME')

    # Inicializar Mail
    mail.init_app(app)

    # Registrar Blueprints
    from app.routes.auth import auth_bp
    from app.routes.perfil import perfil_bp
    from app.routes.pet import pet_bp 
    from app.routes.vacunas import vacunas_bp

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(perfil_bp, url_prefix="/perfil")
    app.register_blueprint(pet_bp, url_prefix="/pet")
    app.register_blueprint(vacunas_bp, url_prefix="/vacunas")

    return app

# from flask import Flask
# from flask_sqlalchemy import SQLAlchemy
# from app.utils.config import Config

# db = SQLAlchemy()

# def create_app():
#     app = Flask(__name__)
#     app.config.from_object(Config)

#     db.init_app(app)

#     # Importar y registrar Blueprints
#     from app.routes.auth import auth_bp
#     from app.routes.perfil import perfil_bp
#     from app.routes.pet import pet_bp 
#     from app.routes.vacunas import vacunas_bp

#     app.register_blueprint(auth_bp, url_prefix="/auth")
#     app.register_blueprint(perfil_bp, url_prefix="/perfil")
#     app.register_blueprint(pet_bp, url_prefix="/pet")
#     app.register_blueprint(vacunas_bp, url_prefix="/vacunas")  

#     return app
 