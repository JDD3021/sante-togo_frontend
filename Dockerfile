# syntax=docker/dockerfile:1

# ---- Étape de build : compile l'app Flutter en app web statique ----
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# ---- Développement : serveur web Flutter avec hot-reload ----
# Le code source est monté en volume par docker-compose.yml.
# Pour du dev quotidien sur mobile (Android/iOS), utiliser `flutter run` en local reste
# préférable : un conteneur Linux ne peut pas lancer un simulateur iOS/Android.
FROM ghcr.io/cirruslabs/flutter:stable AS dev
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
EXPOSE 5000
CMD ["flutter", "run", "-d", "web-server", "--web-hostname=0.0.0.0", "--web-port=5000"]

# ---- Production : sert les fichiers statiques compilés avec Nginx ----
FROM nginx:1.27-alpine AS prod
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
