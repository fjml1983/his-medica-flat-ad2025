# hismedica

Proyecto Flutter para HIS Medica.

## Guia Completa de Instalacion

Para una guia completa paso a paso (Windows, Docker, templates/arquetipos de EHRbase, Flutter y solucion de problemas), revisa:

- [docs/INSTALACION_COMPLETA.md](docs/INSTALACION_COMPLETA.md)

## Contenedores de backend requeridos

Esta aplicacion espera dos APIs de backend ejecutandose en local:

- EHRbase en `http://localhost:8081/ehrbase/rest/openehr/v1`
- HAPI FHIR en `http://localhost:8080/fhir`

Este repositorio incluye un stack de Docker Compose que inicia:

- `ehrbase` + `ehrdb` (PostgreSQL)
- `fhir` + `fhirdb` (PostgreSQL)

### 1) Iniciar contenedores

```bash
docker compose up -d
```

Opcional: copia `.env.example` a `.env` y ajusta credenciales o tags de imagen.

### 2) Verificar servicios

```bash
docker compose ps
```

Endpoints esperados:

- EHRbase responde en `http://localhost:8081/ehrbase`
- Capability statement de FHIR en `http://localhost:8080/fhir/metadata`

### 3) Ejecutar app Flutter

```bash
flutter pub get
flutter run -d emulator-5554
```

### Notas

- El emulador Android usa host mapping ya manejado en el codigo (`10.0.2.2`).
- Si la creacion de composiciones falla por errores de template, carga en EHRbase el template openEHR con ID `his_medica_itsur.historia_clinica_nom004.v1`.
- Subir arquetipos `.adl` es recomendado, pero la app sigue requiriendo el template anterior porque las claves del payload de composicion estan atadas a ese template ID.

### Cargar templates openEHR

Este proyecto incluye dos formas de subir archivos template (`.opt` o `.xml`) a EHRbase.

1. Copia tus templates en `docker/ehrbase-templates`.
2. Usa una de estas opciones:

Opcion A: script de PowerShell

```powershell
./scripts/upload-ehr-templates.ps1
```

Opcion B: perfil de carga con Docker Compose

```bash
docker compose --profile templates run --rm ehrbase-template-loader
```

Despues de cargar, verifica:

```bash
curl http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4
```

### Cargar arquetipos openEHR (.adl)

Usa esto cuando tengas una carpeta de arquetipos ADL publicados.

1. Copia tus arquetipos (`.adl`) en `docker/ehrbase-archetypes`.
2. Usa una de estas opciones:

Opcion A: script de PowerShell

```powershell
./scripts/upload-ehr-archetypes.ps1
```

Opcion B: perfil de carga con Docker Compose

```bash
docker compose --profile archetypes run --rm ehrbase-archetype-loader
```

Importante:

- Los arquetipos por si solos no reemplazan templates en esta app.
- Debes seguir subiendo templates (`.opt` o `.xml`) y asegurarte de que exista en EHRbase el template ID `his_medica_itsur.historia_clinica_nom004.v1`.
- Si el endpoint de carga de arquetipos devuelve 404, tu version de EHRbase no soporta esta ruta REST. Es esperable en muchos despliegues.

## Inicio rapido

Este proyecto es un punto de partida para una aplicacion Flutter.

Algunos recursos utiles si es tu primer proyecto Flutter:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Para comenzar con Flutter, revisa la
[documentacion oficial](https://docs.flutter.dev/), con tutoriales,
ejemplos, guias de desarrollo movil y referencia completa de API.
