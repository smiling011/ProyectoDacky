# Usa una imagen de Python
FROM python:3.10

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos del backend
COPY . .

# Instala las dependencias
RUN pip install -r requirements.txt

# Expone el puerto 5000
EXPOSE 5000

# Ejecuta la aplicación Flask
CMD ["python", "dacky.py"]
