Repositorio para una solución preliminar de un Software de Gestión Hospitalaria de tipo Hospital Information System (HIS), desarrollado en el Tecnológico Nacional de México (TecNM), campus Instituto Tecnológico Superior del Sur de Guanajuato (ITSUR) con el propósito de explorar el uso de las tecnologías EHRBase, HAPI FHIR y su posible integración.
Pasos para montar el proyecto
Preparación del entorno (Docker Desktop) Pasos:
Crea una carpeta raíz en tu equipo llamada hismedica-server.
Asegúrate de colocar dentro de esa carpeta los siguientes dos archivos (los cuales contienen la definición de la arquitectura):
docker-compose.yml (el orquestador de servicios). hapi.application.yaml(la configuración inyectada para habilitar el borrado físico).
Crea una carpeta raíz en tu equipo llamada ehrbase
Asegúrate de colocar dentro de esa carpeta el siguiente archivo
docker-compose.yml (el orquestador de servicios).
3.Ejecución del despliegue Para iniciar los servicios, sigue estos pasos operativos:
Abre una terminal (CMD, PowerShell o Terminal de Linux) y navega a la carpeta creada:
	cd hismedica-server
Ejecuta el comando de levantamiento:
    docker-compose up -d
Ahora navega a la carpeta ehrbase:
	cd erhbase
Ejecuta el comando de levantamiento:
 	docker-compose up -d
2.Flutter Nos dirigimos a la página oficial de Flutter 1.Precionamos Get Started y buscamos la opcion de windows 2.Nos pedira hacer intalacion de varias cosas las cuales son:
Instalamos Git for Windows. Instalamos Android Studio (puede ser cualquier versión, pero se recomienda la última). Instalamos Visual Studio Code
Configuración del entorno de Visual Studio Pasos:
Descargar Visual Studio Code para Windows. 1.Dentro de las extensiones de Visual Studio, buscamos la extensión llamada “Flutter Dark Code”(puede ser necesario reiniciar el equipo).
2.Dentro de las extensiones también descargaremos la extensión de Dart.
También es recomendable hacerlo manualmente: Explicación de instalación manual de Flutter
Nos dirigimos a la parte que dice “Install Flutter manually”.Descargamos el archivo flutter_windows_3.38.8-stable.zip.
Ahora vamos al disco local C: y creamos una carpeta con el nombre “development”, y descomprimimos el archivo dentro de esta carpeta.
Ahora abre una terminal (CMD, PowerShell o Terminal de Linux) y navega al archivo bin, el cual se encuentra dentro de la carpeta que descomprimiste.
    cd C:\development\flutter\bin
Ahora ejecuta el siguiente comando para actualizar y analizar qué es lo que nos hace falta para comenzar a trabajar con Flutter:
    flutter doctor
Ahora presiona la tecla de Windows y busca “Editar las variables de entorno”. Presionamos Variables de entorno y buscamos Path. Damos doble clic para entrar, luego le damos en Editar y agregamos una nueva.
Colocamos la ruta de la carpeta; en mi caso:
      C:\development\flutter_windows_3.38.7-stable\flutter\bin
Damos clic en Aceptar, nuevamente en Aceptar y otra vez en Aceptar.
Ahora cerramos la terminal y la abrimos nuevamente:
     Ejecutamos: flutter doctor
Configuracion Android studio Aceptamos todo hasta llegar a la pantalla de inicio. Buscamos Settings y vamos a Languages & Frameworks. Seleccionamos Android SDK.
	SDK Tools
Activamos la opción Android SDK Command-line Tools (latest) e instalamos. Volvemos a ejecutar flutter doctor; este nos arrojará un comando, el cual es: flutter doctor android-licenses, Aceptamos todo con y y presionamos Enter.
Configuración y Preparación de Docker EHR BASE 
Configuración inicial
Se revisó la configuración del proyecto para confirmar la conexión con EHRbase y el template requerido.
Se verificó que la aplicación depende del siguiente template:
his_medica_itsur.historia_clinica_nom004.v1
Se agregó soporte para carga de archetypes ADL mediante:
Scripts
Docker profile
Se copiaron los archetypes ADL a la carpeta correspondiente del proyecto.
Importante:
Se detectó que EHRbase no expone el endpoint REST de archetypes, por lo que se implementó un manejo seguro (aviso y salida controlada).
Carga de Template
Se copió el archivo .opt a la carpeta de templates del proyecto.
Se corrigió el script para detectar correctamente archivos .opt y .xml.
Se subió el template a EHRbase y se verificó su registro.
Se probaron los endpoints para confirmar funcionamiento correcto.
Ajustes en la Aplicación
Se ajustó una constante para alinear el código de contexto con el template.
Se mejoraron los mensajes de error para facilitar el diagnóstico en la creación de composiciones.
Documentación
Se documentó todo el proceso en una guía completa.
Se enlazó la documentación desde el archivo:
README.md
Manual de Uso e Implementación
Template y Archetypes Utilizados
El sistema utiliza un template clínico específico:
Template: his_medica_itsur.historia_clinica_nom004.v1.opt
Template ID: his_medica_itsur.historia_clinica_nom004.v1
Este template es obligatorio para el correcto funcionamiento del sistema.
Los archetypes corresponden a modelos clínicos en formato .adl.
Ubicación de Archivos
Los archivos deben colocarse en las siguientes carpetas:
Archetypes (.adl)
ehrbase-archetypes
Templates (.opt / .xml)
ehrbase-templates
Archivos del Proyecto
docker-compose.yml → Configuración de contenedores
upload-ehr-archetypes.ps1 → Script de carga de archetypes
upload-ehr-templates.ps1 → Script de carga de templates
ehr_service.dart → Conexión con EHRbase
constants.dart → Configuración interna
README.md → Documentación general
INSTALACION_COMPLETA.md → Guía completa
.gitkeep → Control de carpetas
Comandos Principales
1. Levantar contenedores
docker compose up -d
2. Verificar estado
docker compose ps
3. Permitir scripts en PowerShell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
4. Subir archetypes
upload-ehr-archetypes.ps1
5. Subir templates
upload-ehr-templates.ps1
6. Verificar templates
curl http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4
7. Probar template
curl http://localhost:8081/ehrbase/rest/openehr/v1/definition/template/adl1.4/his_medica_itsur.historia_clinica_nom004.v1/example

Funcionamiento del Sistema
Una vez completado el proceso:
EHRbase se ejecuta en Docker
El template queda cargado correctamente
La aplicación se comunica con EHRbase
Se pueden crear composiciones clínicas sin errores
Resultado Final
El sistema queda completamente funcional:
Template disponible en EHRbase
Scripts reutilizables
Documentación completa
Configuración estable y replicable
Recomendaciones
No modificar el Template ID
Mantener actualizados los archetypes
Verificar que Docker esté en ejecución
Revisar logs en caso de errores
