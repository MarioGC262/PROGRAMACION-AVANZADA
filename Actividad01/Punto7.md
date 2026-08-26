### Resumen: Ingeniería de Conocimiento

* El documento define la Ingeniería de Conocimiento (IC) como una disciplina de la Inteligencia Artificial que permite construir sistemas expertos mediante la adquisición, representación y procesamiento del conocimiento.
* El Ingeniero de Conocimiento es el especialista informático encargado de extraer el saber de un Experto Humano (o de otras fuentes) y plasmarlo adecuadamente en un sistema.
* El conocimiento tratado puede ser declarativo (hechos y atributos), procedural (reglas para solucionar problemas) o metaconocimiento (saber sobre el propio razonamiento del sistema).
* El desarrollo de estos sistemas se divide en tres pilares fundamentales:
  * **Adquisición del conocimiento:** Es la labor de extracción de información desde fuentes estáticas (textos, películas) o dinámicas (el experto humano). Se desarrolla en cinco etapas: identificación, entendimiento, formalización, implementación y pruebas. Para lograrlo, se emplean métodos manuales (como entrevistas estructuradas, no estructuradas y métodos de búsqueda), semiautomatizados y automatizados (como reglas de inducción y aprendizaje automático).
  * **Representación del conocimiento:** Consiste en estructurar el conocimiento extraído de manera inteligible para organizar el almacenamiento en el sistema. Se emplean diversos esquemas como reglas de lógica simbólica (lógica proposicional y de predicados), redes semánticas, gráficos conceptuales, árboles de decisiones, y marcos o *frames*.
  * **Base de conocimiento:** Es el elemento donde entra y se codifica la información, generalmente representada mediante reglas de producción estructuradas por causas y efectos.

***

### Resumen: Sistemas Expertos Basados en Reglas

* El texto aborda los sistemas basados en reglas, describiéndolos como una metodología sencilla y eficiente para resolver situaciones complejas y deterministas.
* Estos sistemas operan principalmente con dos elementos: los "hechos", que son dinámicos y se almacenan en la memoria de trabajo, y las "reglas", que son estáticas, se almacenan en la base de conocimiento y constan de una premisa y una conclusión.
* El "Motor de Inferencia" es el componente que utiliza esta base de conocimiento para deducir nuevas conclusiones aplicando reglas lógicas:
  * **Modus Ponens:** Realiza inferencias hacia adelante; si se sabe que la premisa es cierta, se concluye que la conclusión también lo es.
  * **Modus Tollens:** Realiza inferencias hacia atrás; al examinar una regla, si se determina que la conclusión es falsa, deduce que la premisa también debe ser falsa.
  * **Mecanismo de Resolución:** Se utiliza para deducir conclusiones compuestas mediante la sustitución y combinación de reglas en expresiones lógicas equivalentes.
* Para obtener conclusiones, el motor emplea estrategias como el "encadenamiento de reglas" (que genera nuevos hechos a partir de los datos iniciales conocidos) y el "encadenamiento orientado a un objetivo" (que parte de una meta y busca hacia atrás la información o hechos requeridos para validarla).
* El documento enfatiza la necesidad de un "Control de la Coherencia" constante para eliminar valores no factibles y evitar que ingresen contradicciones en la base de reglas o en los hechos proporcionados por el usuario.
* Finalmente, se destaca que estos sistemas poseen un mecanismo de explicación que permite justificar ante el usuario el "por qué" de las conclusiones obtenidas, enumerando las reglas específicas que se activaron durante el proceso.
