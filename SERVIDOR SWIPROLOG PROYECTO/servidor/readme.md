# Sistema de Asignación Docente — FCI UNACAR

# Integrantes del Equipo de Desarrollo
   - **David del Jesus Solano Herrera**

   - **Yanet del Carmen Miranda Xeque**

   - **Mario Garcia Castillo.**

## 1. Descripción del proyecto

Sistema desarrollado en **SWI-Prolog** para la Facultad de Ciencias de la Información (**UNACAR**), diseñado para gestionar entidades académicas (profesores, cuerpos académicos, academias, proyectos, cursos, capacitaciones y comisiones) y realizar asignaciones docentes basadas en el perfil de estudios, especialidad y nivel de dominio de los profesores.

El sistema cuenta con un servidor web integrado que ofrece una interfaz gráfica web para registrar datos, ejecutar validaciones lógicas en tiempo real y consultar expedientes completos de los profesores.

## 2. Tecnologías utilizadas

- **SWI-Prolog:** Lenguaje de programación lógica, motor de reglas y persistencia dinámica.
- **HTTP Server de SWI-Prolog (`library(http/http_server)`):** Servidor web modular integrado.
- **HTML5 & CSS3:** Interfaz de usuario integrada con diseño responsive y menú lateral navegable.
- **Visual Studio Code / Terminal (PowerShell):** Entorno de ejecución y administración del servidor.

## 3. Estructura del proyecto

El proyecto se encuentra alojado dentro de la carpeta `servidor/` y se compone de los siguientes archivos principales:

```text
servidor/
│
├── server.pl          # Servidor HTTP, enrutamiento HTML/POST y plantillas visuales.
├── datos.pl           # Hechos dinámicos de las entidades (profesores, cursos, etc.).
├── reglas.pl          # Reglas lógicas y algoritmos de validación de asignaciones.
├── asignaciones.pl    # Control de altas, registro de operaciones y guardado en disco.
└── asignaciones_d.pl  # Persistencia dinámica de asignaciones y capacitaciones tomadas.
```

### Función de cada archivo

| Archivo | Descripción |
|---|---|
| `server.pl` | Inicia el servidor web en el puerto `8080`, gestiona las vistas HTML del menú lateral y procesa los formularios `POST`. |
| `datos.pl` | Declara los predicados dinámicos (`dynamic`) para almacenar la información de profesores, academias, cuerpos académicos, proyectos, cursos y capacitaciones. |
| `reglas.pl` | Contiene los algoritmos lógicos para validar si un profesor es apto para una asignación, así como el cálculo de aptitud para determinar el **mejor profesor para un curso**. |
| `asignaciones.pl` | Realiza las operaciones de lectura/escritura (`assertz`, `retractall`), convierte entradas de formularios y reescribe los cambios en `datos.pl` y `asignaciones_d.pl`. |
| `asignaciones_d.pl` | Almacena y persiste en disco las asignaciones registradas entre sesiones. |

---

## 4. Requisitos previos

Antes de ejecutar el sistema, asegúrate de cumplir con los siguientes requisitos:

1. Tener instalado **SWI-Prolog** (64-bit) en el equipo (por defecto en `C:\Program Files\swipl\bin\swipl.exe`).
2. Contar con la carpeta del proyecto (`servidor`) disponible en tu equipo.
3. Disponer del puerto `8080` libre para el servidor web local.

---

## 5. Cómo ejecutar el sistema

### Paso 1: Abrir la terminal o PowerShell
Abre Windows PowerShell o la terminal de tu elección.

### Paso 2: Navegar a la carpeta del servidor
Accede a la ruta del directorio donde se encuentran los archivos del proyecto usando el comando `cd`:

```powershell
cd C:\Users\layto\OneDrive\Desktop\servidor
```
*(Ajusta la ruta según la ubicación real de la carpeta `servidor` en tu equipo).*

### Paso 3: Iniciar el servidor con SWI-Prolog
Ejecuta el siguiente comando llamando al ejecutable de SWI-Prolog e indicando la carga de `server.pl`:

```powershell
& "C:\Program Files\swipl\bin\swipl.exe" -s server.pl
```

*(Nota: En caso de escribir `-s server.p` por error, la consola indicará que el archivo no existe. Asegúrate de incluir la extensión `.pl` completa).*

Al ejecutarse correctamente, el motor de Prolog compilará los módulos y mostrará el siguiente mensaje en la terminal:

```text
% Started server at http://localhost:8080/
Welcome to SWI-Prolog (threaded, 64 bits, version 10.0.2)
1 ?-
```

### Paso 4: Abrir la aplicación en el navegador
Una vez que aparezca `% Started server at http://localhost:8080/`, abre tu navegador web e ingresa a cualquiera de los siguientes enlaces:

- **Inicio / Resumen General:** [http://localhost:8080/home](http://localhost:8080/home)
- **Consulta y Expedientes:** [http://localhost:8080/opcion/op6_buscar](http://localhost:8080/opcion/op6_buscar)

> **Importante:** No cierres la terminal ni salgas de la sesión interactiva de Prolog (`1 ?-`) mientras estés utilizando el sistema web. Para detener el servidor, finaliza la sesión en la terminal ingresando `halt.` o presionando `Ctrl + C`.

---

## 6. Funcionalidades del sistema

El sistema web cuenta con un menú lateral organizado en dos secciones principales:

### Datos de las Entidades (Captura y Consulta)
 Permite dar de alta y visualizar la lista completa de registros para cada entidad:
- **Profesor y Estudios:** Registro de `#empleado`, nombre, grado académico, especialidad, cursos que domina (ordenados de mayor a menor preferencia), historial de estudios (licenciatura, maestría, doctorado), acreditaciones (ej. PRODEP) y capacitaciones tomadas.
- **Cuerpo Académico:** ID, nombre, línea de investigación, líder (#empleado) y estatus.
- **Academia:** ID, nombre, materias asignadas y líder.
- **Proyecto:** ID, nombre, objetivo, entregables, líder, integrantes y fechas de inicio/entrega.
- **Curso:** ID, créditos, nombre, objetivo y academia asociada.
- **Cursos Capacitación:** ID, nombre, objetivo, horas y periodo.
- **Comisiones:** Catálogo de comisiones académicas (Currículo, CONAIC, Posgrado, Tutorías).

### Opciones del Sistema (Asignaciones Inteligentes)
1. **1. Asignar a Academias:** Valida concordancia entre las materias que domina el docente o su perfil y el de la academia.
2. **2. Asignar a Cuerpos Académicos:** Requiere grado de Maestría/Doctorado y afinidad entre la especialidad del docente y la línea de investigación.
3. **3. Asignar a Proyectos:** Asigna docentes a proyectos según proyectos vigentes o coincidencia de perfil con el líder/objetivo.
4. **4. Asignar Mejor Prof. a Curso:** 
   - **Asignación Automática:** Algoritmo que calcula el puntaje de aptitud (basado en prioridad de dominio, grado académico, acreditaciones y capacitaciones) para seleccionar e inscribir al profesor con mayor puntaje.
   - **Asignación Manual:** Valida estricta coincidencia con la lista de cursos que domina el profesor.
5. **5. Asignar a Cursos Capacitación:** Controla prerrequisitos de horas (más de 40 hrs exige posgrado o capacitaciones previas) y áreas de docencia/especialidad.
6. **6. Buscar Profesor y Asignaciones:** Genera un **Expediente Completo** consolidando datos personales, grados, capacitaciones y todas sus asignaciones registradas.
7. **+ Asignar a Comisiones:** Asignación de docentes a comisiones institucionales según el requisito académico.

---

## 7. Persistencia de Datos

El sistema guarda la información automáticamente en disco al realizar cualquier alta o asignación:

- **`datos.pl`:** Guarda los hechos dynamic de las entidades capturadas.
- **`asignaciones_d.pl`:** Guarda el historial de asignaciones aceptadas y capacitaciones tomadas.

Esto garantiza que la información se mantenga guardada al reiniciar el servidor web o abrir una nueva sesión en SWI-Prolog.