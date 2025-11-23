import os
from dotenv import load_dotenv

# Cargar .env desde backend/
load_dotenv()

class Config:
    # Construir la URI de PostgreSQL usando variables separadas
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = os.getenv("DB_PORT")
    DB_NAME = os.getenv("DB_NAME")

    SQLALCHEMY_DATABASE_URI = (
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Llave del backend
    SECRET_KEY = os.getenv("SECRET_KEY", "default-secret")

# import pymysql
# pymysql.install_as_MySQLdb()

# class Config:
#     SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:12345@localhost/dacky'
#     SQLALCHEMY_TRACK_MODIFICATIONS = False
#     SECRET_KEY = "supersecretkey"
