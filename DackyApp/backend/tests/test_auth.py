import pytest
from app import create_app, db
from app.utils.models import InicioSesion

@pytest.fixture
def client():
    # Crear app de prueba
    app = create_app()
    app.config["TESTING"] = True
    app.config["SQLALCHEMY_DATABASE_URI"] = "mysql+pymysql://root:12345@mysql/dacky"

    with app.test_client() as client:
        with app.app_context():
            db.drop_all()
            db.create_all()
        yield client

def test_registro(client):
    response = client.post("/registro", json={
        "Nom": "Vicky",
        "Apell": "Vielma",
        "Email": "test@example.com",
        "Contrasena": "123456",
        "NumCel": "3000000000",
        "Direccion": "Calle 123"
    })
    assert response.status_code == 201
    data = response.get_json()
    assert data["success"] is True
    assert "Usuario registrado correctamente" in data["message"]

def test_login(client):
    # Registrar usuario primero
    client.post("/registro", json={
        "Nom": "Vicky",
        "Apell": "Vielma",
        "Email": "test@example.com",
        "Contrasena": "123456"
    })

    # Intentar login
    response = client.post("/login", json={
        "email": "test@example.com",
        "contrasena": "123456"
    })
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    assert data["email"] == "test@example.com"
