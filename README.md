# HIS Medica (versión: experimental AD2025)

Repositorio para una solución preliminar de un Software de Gestión Hospitalaria de tipo Hospital Information System (HIS), desarrollado en el Tecnológico Nacional de México (TecNM), campus Instituto Tecnológico Superior del Sur de Guanajuato (ITSUR) con el propósito de explorar el uso de las tecnologías EHRBase, HAPI FHIR y su posible integración.

## Pasos para montar el proyecto

1. Preparación del entorno (Docker Desktop) Pasos:

a. Crea una carpeta raíz en tu equipo llamada hismedica-server.

b. Asegúrate de colocar dentro de esa carpeta los siguientes dos archivos (los cuales contienen la definición de la arquitectura):

[docker-compose.yml](https://github.com/fjml1983/his-medica-flat-ad2025/blob/RodrigoAAG-patch-1/Docker/ehrbase) (el orquestador de servicios). [hapi.application.yaml](https://github.com/fjml1983/his-medica-flat-ad2025/blob/RodrigoAAG-patch-1/Docker/ehrbase) (la configuración inyectada para habilitar el borrado físico).

2. Crea una carpeta raíz en tu equipo llamada ehrbase

3. Asegúrate de colocar dentro de esa carpeta el siguiente archivo  
[docker-compose.yml](https://github.com/fjml1983/his-medica-flat-ad2025/blob/RodrigoAAG-patch-1/Docker/ehrbase) (el orquestador de servicios).

3. Ejecución del despliegue Para iniciar los servicios, sigue estos pasos operativos:

Abre una terminal (CMD, PowerShell o Terminal de Linux) y navega a la carpeta creada:

```
cd hismedica-server
```

Ejecuta el comando de levantamiento:

```
docker-compose up -d
```

Ahora navega a la carpeta ehrbase:

```
cd ehrbase
```

Ejecuta el comando de levantamiento:

```
docker-compose up -d
```

2. Flutter Nos dirigimos a la página oficial de Flutter  
[Flutter](https://flutter.dev/)

1. Presionamos Get Started y buscamos la opción de Windows  
2. Nos pedirá hacer instalación de varias cosas las cuales son:

Instalamos [Git for Windows](https://git-scm.com/install/windows).  
Instalamos Android Studio (puede ser cualquier versión, pero se recomienda la última).  
Instalamos [Visual Studio Code](https://code.visualstudio.com/)

## Configuración del entorno de Visual Studio

Pasos:

Descargar [Visual Studio Code](https://code.visualstudio.com/)

1. Dentro de las extensiones de Visual Studio, buscamos la extensión llamada “Flutter Dark Code” (puede ser necesario reiniciar el equipo).  
2. Dentro de las extensiones también descargaremos la extensión de Dart.

También es recomendable hacerlo manualmente:

Explicación de instalación manual de Flutter

Nos dirigimos a la parte que dice “Install Flutter manually”.

Descargamos el archivo:  
[flutter_windows_3.38.8-stable.zip](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.8-stable.zip)

Ahora vamos al disco local C: y creamos una carpeta con el nombre “development”, y descomprimimos el archivo dentro de esta carpeta.

Ahora abre una terminal (CMD, PowerShell o Terminal de Linux) y navega al archivo bin:

```
cd C:\development\flutter\bin
```

Ahora ejecuta:

```
flutter doctor
```

Ahora presiona la tecla de Windows y busca “Editar las variables de entorno”.

Presionamos Variables de entorno → Path → Editar → Nuevo:

```
C:\development\flutter_windows_3.38.7-stable\flutter\bin
```

Damos clic en Aceptar (todas las ventanas).

Cerramos la terminal y la abrimos nuevamente:

```
flutter doctor
```

## Configuración Android Studio

Aceptamos todo hasta llegar a la pantalla de inicio.

Buscamos Settings → Languages & Frameworks → Android SDK

SDK Tools:

Activamos la opción Android SDK Command-line Tools (latest)

Ejecutamos:

```
flutter doctor android-licenses
```

Aceptamos todo con `y`

---

## Configuración y Preparación de Docker EHR BASE

### Configuración inicial

Se revisó la configuración del proyecto para confirmar la conexión con EHRbase y el template requerido.

Template requerido:

```
his_medica_itsur.historia_clinica_nom004.v1
```

Se agregó soporte para:

- Scripts
- Docker profile

Importante:

Se detectó que EHRbase no expone el endpoint REST de archetypes.

---

## Carga de Template

- Copia archivo .opt  
- Corrección de scripts  
- Subida a EHRbase  
- Verificación con endpoints  

---

## Ajustes en la Aplicación

- Ajuste de constantes  
- Mejora de errores  

---

## Documentación

README.md

---

## Template y Archetypes Utilizados

Template:

```
his_medica_itsur.historia_clinica_nom004.v1.opt
```

Template ID:

```
his_medica_itsur.historia_clinica_nom004.v1
```

---

## Ubicación de Archivos

Archetypes → ehrbase-archetypes  
Templates → ehrbase-templates  

---

## Archivos del Proyecto

- docker-compose.yml  
- upload-ehr-archetypes.ps1  
- upload-ehr-templates.ps1  
- ehr_service.dart  
- constants.dart  
- README.md  
- INSTALACION_COMPLETA.md  
- .gitkeep  

---

## Comandos Principales

```
docker compose up -d
docker compose ps
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
upload-ehr-archetypes.ps1
upload-ehr-templates.ps1
curl http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4
curl http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4/his_medica_itsur.historia_clinica_nom004.v1/example
```

---

## Funcionamiento del Sistema

- EHRbase se ejecuta en Docker  
- Template cargado correctamente  
- Comunicación activa  
- Composiciones sin errores  

---

## Resultado Final

- Sistema funcional  
- Template disponible  
- Scripts reutilizables  
- Documentación completa  

---

## Recomendaciones

- No modificar el Template ID  
- Mantener archetypes actualizados  
- Verificar Docker activo  
- Revisar logs  
