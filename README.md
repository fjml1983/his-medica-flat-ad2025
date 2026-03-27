# HIS Medica - Guia Completa de Instalacion y Puesta en Marcha

Esta guia esta pensada para publicarse en GitHub y para que cualquier usuario pueda levantar el proyecto sin conocimiento previo del entorno.

## 1. Objetivo de esta guia

Al terminar, podras:

1. Instalar todas las herramientas necesarias en Windows.
2. Clonar o descargar el proyecto.
3. Levantar backend con Docker (EHRbase + HAPI FHIR + PostgreSQL).
4. Cargar el template obligatorio en EHRbase.
5. (Opcional) Cargar arquetipos ADL.
6. Ejecutar la app Flutter y validar el flujo basico de uso.

## 1.1 Contexto de la guia anterior 

Tu guia original estaba planteada en dos despliegues separados:

1. Carpeta `hismedica-server` con su propio `docker-compose.yml` y `hapi.application.yaml`.
2. Carpeta `ehrbase` con otro `docker-compose.yml`.

En esta version del proyecto ya no hace falta mantener dos carpetas ni dos levantamientos separados.

Ahora todo se levanta desde una sola raiz del repositorio con un solo archivo de orquestacion:

1. `docker-compose.yml`

Esto simplifica la instalacion, reduce errores de configuracion y facilita que cualquier usuario nuevo pueda iniciar el sistema con menos pasos.

Si alguien viene del esquema anterior, la equivalencia es:

1. Antes: `cd hismedica-server` + `docker-compose up -d` y luego `cd ehrbase` + `docker-compose up -d`.
2. Ahora: una sola vez en la raiz del repo: `docker compose up -d`.

## 2. Arquitectura del proyecto

Este repositorio levanta estos servicios con Docker Compose:

1. `ehrdb` (PostgreSQL de EHRbase)
2. `ehrbase` (servidor openEHR)
3. `fhirdb` (PostgreSQL de HAPI FHIR)
4. `fhir` (servidor HAPI FHIR)

Archivo principal de orquestacion:

- `docker-compose.yml`

## 3. Requisitos previos

Sistema operativo recomendado:

- Windows 10 o Windows 11 (64-bit)

Software requerido:

1. Docker Desktop
2. Git for Windows
3. Flutter SDK (canal stable)
4. Android Studio
5. Visual Studio Code

Extensiones recomendadas de VS Code:

1. Flutter
2. Dart

## 4. Instalacion del entorno (paso a paso)

### 4.1 Docker Desktop

1. Instala Docker Desktop.
2. Habilita WSL2 si el instalador lo solicita.
3. Reinicia el equipo si es necesario.
4. Abre Docker Desktop y espera a que el motor quede en estado Running.

Validacion:

```powershell
docker --version
docker compose version
```

### 4.2 Git for Windows

1. Instala Git for Windows.
2. Reabre la terminal.

Validacion:

```powershell
git --version
```

### 4.3 Flutter SDK

1. Descarga Flutter stable para Windows.
2. Descomprime en `C:\development\flutter`.
3. Agrega `C:\development\flutter\bin` al PATH.
4. Cierra y abre terminal nueva.

Validacion:

```powershell
flutter --version
flutter doctor
```

### 4.4 Android Studio

1. Instala Android Studio.
2. Instala Android SDK y Command-line Tools.
3. Crea un emulador (AVD).
4. Acepta licencias:

```powershell
flutter doctor --android-licenses
```

## 5. Descargar el proyecto

### Opcion A: Git clone

```powershell
git clone URL_DEL_REPOSITORIO
cd hismedica
```

### Opcion B: ZIP

1. Descarga el ZIP desde GitHub.
2. Extrae el contenido.
3. Abre la carpeta en VS Code.

## 6. Verificacion rapida de estructura

Confirma que existan:

1. `docker-compose.yml`
2. `scripts/upload-ehr-templates.ps1`
3. `scripts/upload-ehr-archetypes.ps1`
4. `docker/ehrbase-templates`
5. `docker/ehrbase-archetypes`
6. `lib/main.dart`

## 7. Levantar backend con Docker

```powershell
docker compose up -d
docker compose ps
```

Servicios esperados:

1. `hismedica-ehrbase`
2. `hismedica-ehrdb`
3. `hismedica-fhir`
4. `hismedica-fhirdb`

## 8. Cargar template obligatorio en EHRbase

Template requerido:

```
his_medica_itsur.historia_clinica_nom004.v1
```

### 8.1 Copiar template

Colocar archivo en:

```
docker/ehrbase-templates
```

Ejemplo:

```
his_medica_itsur.historia_clinica_nom004.v1.opt
```

### 8.2 Ejecutar script

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
./scripts/upload-ehr-templates.ps1
```

### 8.3 Verificar template

```powershell
curl http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4
```

## 9. Cargar arquetipos ADL (opcional recomendado)

### 9.1 Copiar archivos

```
docker/ehrbase-archetypes
```

### 9.2 Ejecutar script

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
./scripts/upload-ehr-archetypes.ps1
```

Nota:

- Un error 404 puede ser normal dependiendo de la version de EHRbase.

## 10. Preparar Flutter y ejecutar app

### 10.1 Instalar dependencias

```powershell
flutter pub get
```

### 10.2 Ver dispositivos

```powershell
flutter devices
```

### 10.3 Ejecutar en emulador

```powershell
flutter run -d emulator-5554
```

### 10.4 Ejecutar en Chrome

```powershell
flutter run -d chrome
```

## 11. Validacion funcional minima

1. Crear paciente (EHR)
2. Crear composicion
3. Listar composiciones

## 12. Endpoints utiles

- `http://localhost:8081/ehrbase`
- `http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4`
- `http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4/his_medica_itsur.historia_clinica_nom004.v1/example`
- `http://localhost:8080/fhir/metadata`

## 13. Solucion de problemas frecuentes

### 13.1 Docker no disponible

- Abrir Docker Desktop
- Esperar estado Running
- Reintentar

### 13.2 Error PowerShell

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

### 13.3 Template no encontrado

1. Verificar carpeta templates
2. Ejecutar script
3. Validar endpoint

### 13.4 Error en composicion

- Actualizar repositorio
- Verificar template

## 14. Arranque rapido

```powershell
docker compose up -d
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
./scripts/upload-ehr-templates.ps1
flutter pub get
flutter run -d emulator-5554
```
