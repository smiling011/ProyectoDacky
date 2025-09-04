from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from app.utils.config import Config

db = SQLAlchemy()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)

    # Importar y registrar Blueprints
    from app.routes.auth import auth_bp
    from app.routes.perfil import perfil_bp
    from app.routes.pet import pet_bp 

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(perfil_bp, url_prefix="/perfil")
    app.register_blueprint(pet_bp, url_prefix="/pet")  

    return app
 