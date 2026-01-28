# HIS Medica (versión: experimental AD2025)
Repositorio para una solución preliminar de un Software de Gestión Hospitalaria de tipo Hospital Information System (HIS), desarrollado en el Tecnológico Nacional de México (TecNM), campus Instituto Tecnológico Superior del Sur de Guanajuato (ITSUR) con el propósito de explorar el uso de las tecnologías EHRBase, HAPI FHIR y su posible integración.

Pasos para montar el proyecto

1. Preparación del entorno (Docker Desktop)
Pasos:
    1. Crea una carpeta raíz en tu equipo llamada hismedica-server.
    2. Asegúrate de colocar dentro de esa carpeta los siguientes dos archivos (los cuales contienen la definición de la arquitectura):

	[docker-compose.yml ](Src/Docker/ehrbase)(el orquestador de servicios).
[hapi.application.yaml](Src/Docker/ehrbase)(la configuración inyectada para habilitar el borrado físico).

 1. Crea una carpeta raíz en tu equipo llamada ehrbase
 2. Asegúrate de colocar dentro de esa carpeta el siguiente archivo

	[docker-compose.yml ](Src/Docker/hapifhir)(el orquestador de servicios).

   3.Ejecución del despliegue
    Para iniciar los servicios, sigue estos pasos operativos:
     
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
	cd erhbase
```
  Ejecuta el comando de levantamiento:
```
 	docker-compose up -d
```

2.Flutter
    Nos dirigimos a la página oficial de [Flutter](https://flutter.dev)
		1.Precionamos Get Started y buscamos la opcion de windows
        2.Nos pedira hacer intalacion de varias cosas las cuales son:

   Instalamos [Git for Windows. ](https://git-scm.com/install/windows)
   Instalamos [Android Studio](https://developer.android.com/studio)  (puede ser cualquier versión, pero se recomienda la última).
Instalamos [Visual Studio Code](https://code.visualstudio.com)


2. Configuración del entorno de Visual Studio
    Pasos:

2. [Descargar](https://code.visualstudio.com) Visual Studio Code para Windows.
1.Dentro de las extensiones de Visual Studio, buscamos la extensión llamada “Flutter Dark Code”(puede ser necesario reiniciar el equipo).

      2.Dentro de las extensiones también descargaremos la extensión de Dart.

    También es recomendable hacerlo manualmente:
      Explicación de instalación manual de Flutter

      1. Nos dirigimos a la parte que dice “Install Flutter manually”.
      Descargamos el archivo Flutter_windows_3.38.8-stable.zip.

      2. Ahora vamos al disco local C: y creamos una carpeta con el nombre “development”, y descomprimimos el archivo dentro de esta carpeta.
      3. Ahora abre una terminal (CMD, PowerShell o Terminal de Linux) y navega al archivo bin, el cual se encuentra dentro de la carpeta que descomprimiste.

```
    cd C:\development\flutter\bin
```

Ahora ejecuta el siguiente comando para actualizar y analizar qué es lo que nos hace falta para comenzar a trabajar con Flutter:
```
    flutter doctor
```

Ahora presiona la tecla de Windows y busca “Editar las variables de entorno”.
  Presionamos Variables de entorno y buscamos Path.
    Damos doble clic para entrar, luego le damos en Editar y agregamos una nueva.

   Colocamos la ruta de la carpeta; en mi caso:
```
      C:\development\flutter_windows_3.38.7-stable\flutter\bin
```

   Damos clic en Aceptar, nuevamente en Aceptar y otra vez en Aceptar.

   Ahora cerramos la terminal y la abrimos nuevamente:
```
     Ejecutamos: flutter doctor
```

3. Configuracion Android studio
    Aceptamos todo hasta llegar a la pantalla de inicio.
   Buscamos Settings y vamos a Languages & Frameworks.
     Seleccionamos Android SDK.
```
           SDK Tools
```
 Activamos la opción Android SDK Command-line Tools (latest) e instalamos.
  Volvemos a ejecutar flutter doctor; este nos arrojará un comando, el cual es: flutter doctor android-licenses, Aceptamos todo con y y presionamos Enter.

  Esto sería todo, ya estás listo para abrir el proyecto en Visual Studio
 
