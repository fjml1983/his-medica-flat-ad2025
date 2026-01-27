# HIS Medica (versión: experimental AD2025)
Repositorio para una solución preliminar de un Software de Gestión Hospitalaria de tipo Hospital Information System (HIS), desarrollado en el Tecnológico Nacional de México (TecNM), campus Instituto Tecnológico Superior del Sur de Guanajuato (ITSUR) con el propósito de explorar el uso de las tecnologías EHRBase, HAPI FHIR y su posible integración.

Pasos para montar el proyecto

1. Preparación del entorno (Docker Desktop)
Pasos:
    1. Crea una carpeta raíz en tu equipo llamada hismedica-server.
    2. Asegúrate de colocar dentro de esa carpeta los siguientes dos archivos (los cuales contienen la definición de la arquitectura):

    docker-compose.yml (el orquestador de servicios).
    hapi.application.yaml (la configuración inyectada para habilitar el borrado físico).

    3.Ejecución del despliegue
    Para iniciar los servicios, sigue estos pasos operativos:
     1. Abre una terminal (CMD, PowerShell o Terminal de Linux) y navega a la carpeta creada:
        cd hismedica-server

     2. Ejecuta el comando de levantamiento:
        docker-compose up -d

    3. Ahora navega a la carpeta ehrbase:
        cd erhbase

    4. Ejecuta el comando de levantamiento:
        docker-compose up -d

2.Flutter
    1.Nos dirijimos a la pagina ofcila de flutter.dev 
        1.Precionamos Get Started y buscamos la opcion de windows
        2.Nos pedira hacer intalacion de varias cosas las cuales son:
            - Git for Windows.
            - Android studio (puede ser cualquier version pero es recomendable la ultima)
            - Visual Studio Code

2. Configuración del entorno de Visual Studio
    Pasos:
        1.Descargar Visual Studio Code para Windows.
        2.Dentro de las extensiones de Visual Studio, buscamos la extensión llamada “Flutter Dark Code” (puede ser necesario reiniciar el equipo).
        3.Dentro de las extensiones también descargaremos la extensión de Dart.

    También es recomendable hacerlo manualmente:
         Explicación de instalación manual de Flutter
         - Nos dirigimos a la parte que dice “Install Flutter manually”.
         - Descargamos el archivo Flutter_windows_3.38.8-stable.zip.
         - Ahora vamos al disco local C: y creamos una carpeta con el nombre “development”, y descomprimimos el archivo dentro de esta carpeta.
         -Ahora abre una terminal (CMD, PowerShell o Terminal de Linux) y navega al archivo bin, el cual se encuentra dentro de la carpeta que descomprimiste.

    cd C:\development\flutter\bin

    -Ahora ejecuta el siguiente comando para actualizar y analizar qué es lo que nos hace falta para comenzar a trabajar con Flutter:

    flutter doctor 

    -Ahora presiona la tecla de Windows y busca “Editar las variables de entorno”.
    -Presionamos Variables de entorno y buscamos Path.
    Damos doble clic para entrar, luego le damos en Editar y agregamos una nueva.

    -Colocamos la ruta de la carpeta; en mi caso:
    C:\development\flutter_windows_3.38.7-stable\flutter\bin
    Damos clic en Aceptar, nuevamente en Aceptar y otra vez en Aceptar.

    -Ahora cerramos la terminal y la abrimos nuevamente 
    -Ejecutamos: flutter doctor

3. Configuracion Android studio
    1.Aceptamos todo hasta llegar a la pantalla de inicio.
    2.Buscamos Settings y vamos a Languages & Frameworks.
     -Seleccionamos Android SDK.
        -SDK Tools
        -Activamos la opción Android SDK Command-line Tools (latest) e instalamos.
        -Volvemos a ejecutar flutter doctor; este nos arrojará un comando, el cual es: flutter doctor --android-licenses, Aceptamos todo con y y presionamos Enter.

    Esto sería todo, ya estás listo para abrir el proyecto en Visual Studio
      
