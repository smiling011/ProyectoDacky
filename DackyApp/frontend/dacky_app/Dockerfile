# Usa una imagen de Flutter
FROM cirrusci/flutter:stable AS build

# Establece el directorio de trabajo
WORKDIR /app

# Copia el código del frontend
COPY . .

# Instala las dependencias
RUN flutter pub get

# Construye la aplicación para web
RUN flutter build web

# Usa un servidor web ligero para servir la app
FROM nginx:alpine

# Copia los archivos generados en la carpeta web
COPY --from=build /app/build/web /usr/share/nginx/html

# Expone el puerto 80
EXPOSE 80

# Inicia Nginx
CMD ["nginx", "-g", "daemon off;"]
