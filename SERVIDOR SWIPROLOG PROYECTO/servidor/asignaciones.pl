:- encoding(utf8).
% =========================================================================
% ARCHIVO: asignaciones.pl
% Gestor de Altas de Entidades, Asignaciones y Persistencia en Disco
% =========================================================================

:- ensure_loaded('datos.pl').
:- ensure_loaded('asignaciones_d.pl').
:- ensure_loaded('reglas.pl').

% Convierte cadena separada por comas "a, b, c" en lista de atomos [a, b, c]
cadena_a_lista_atomos('', []) :- !.
cadena_a_lista_atomos(Cadena, ListaLimpiada) :-
    split_string(Cadena, ",", " ", SubCadenas),
    exclude(=(""), SubCadenas, NoVacias),
    maplist(atom_string, ListaLimpiada, NoVacias).

% Convierte cadena de numeros "1001, 1002" en lista de enteros [1001, 1002]
cadena_a_lista_enteros('', []) :- !.
cadena_a_lista_enteros(Cadena, ListaNumeros) :-
    cadena_a_lista_atomos(Cadena, Atomos),
    findall(N, (member(A, Atomos), atom_number(A, N)), ListaNumeros).

% --- Guardar entidades en datos.pl ---
guardar_datos_disco :-
    tell('datos.pl'),
    writeln(':- encoding(utf8).'),
    writeln('% ========================================================================='),
    writeln('% ARCHIVO: datos.pl (Actualizado por el usuario)'),
    writeln('% ========================================================================='),
    nl,
    listing(profesor/5),
    listing(cuerpo_academico/5),
    listing(academia/4),
    listing(proyecto/8),
    listing(curso/5),
    listing(curso_capacitacion/6),
    listing(estudios_profesor/4),
    listing(acreditaciones_profesor/2),
    listing(comision/5),
    listing(peso_grado/2),
    told.

% --- Guardar asignaciones en asignaciones_d.pl ---
guardar_asignaciones_disco :-
    tell('asignaciones_d.pl'),
    writeln(':- encoding(utf8).'),
    writeln('% ========================================================================='),
    writeln('% ARCHIVO: asignaciones_d.pl (Actualizado automaticamente)'),
    writeln('% ========================================================================='),
    nl,
    listing(asignacion_academia/2),
    listing(asignacion_ca/2),
    listing(asignacion_proyecto/2),
    listing(asignacion_comision/2),
    listing(asignacion_curso/2),
    listing(asignacion_capacitacion/2),
    listing(cap_tomada/2),
    told.

% =========================================================================
% ALTAS DE LAS ENTIDADES DEL PUNTO 2 + CONTROL DE ESTUDIOS DEL PUNTO 1
% =========================================================================

% Profesor: #empleado, nombre, grado academico y especialidad, lista de cursos que domina de mayor a menor
% + Control de licenciatura, maestria, doctorado, acreditaciones y cursos de capacitacion tomados
alta_profesor(NumEmp, Nombre, Grado, Especialidad, CursosStr, Lic, Mae, Doc, AcredStr, CapTomadasStr, Msg) :-
    retractall(profesor(NumEmp, _, _, _, _)),
    retractall(estudios_profesor(NumEmp, _, _, _)),
    retractall(acreditaciones_profesor(NumEmp, _)),
    retractall(cap_tomada(NumEmp, _)),
    cadena_a_lista_atomos(CursosStr, ListaCursos),
    cadena_a_lista_atomos(AcredStr, ListaAcreds),
    cadena_a_lista_atomos(CapTomadasStr, ListaCaps),
    assertz(profesor(NumEmp, Nombre, Grado, Especialidad, ListaCursos)),
    assertz(estudios_profesor(NumEmp, Lic, Mae, Doc)),
    assertz(acreditaciones_profesor(NumEmp, ListaAcreds)),
    forall(member(Cap, ListaCaps), assertz(cap_tomada(NumEmp, Cap))),
    guardar_datos_disco,
    guardar_asignaciones_disco,
    format(atom(Msg), 'Profesor ~w (#~w) registrado correctamente.', [Nombre, NumEmp]).

% Cuerpo academico: id, nombre, linea de investigacion, lider, estatus
alta_ca(Id, Nombre, Linea, Lider, Estatus, Msg) :-
    retractall(cuerpo_academico(Id, _, _, _, _)),
    assertz(cuerpo_academico(Id, Nombre, Linea, Lider, Estatus)),
    guardar_datos_disco,
    format(atom(Msg), 'Cuerpo Academico "~w" (~w) guardado correctamente.', [Nombre, Id]).

% Academia: id, nombre, materias asignadas, lider
alta_academia(Id, Nombre, MateriasStr, Lider, Msg) :-
    retractall(academia(Id, _, _, _)),
    cadena_a_lista_atomos(MateriasStr, ListaMaterias),
    assertz(academia(Id, Nombre, ListaMaterias, Lider)),
    guardar_datos_disco,
    format(atom(Msg), 'Academia "~w" (~w) guardada correctamente.', [Nombre, Id]).

% Proyecto: id, nombre, objetivo, entregables, lider, integrantes, fecha de inicio, fecha de entrega
alta_proyecto(Id, Nombre, Objetivo, EntregablesStr, Lider, IntegrantesStr, FInicio, FEntrega, Msg) :-
    retractall(proyecto(Id, _, _, _, _, _, _, _)),
    cadena_a_lista_atomos(EntregablesStr, ListaEntregables),
    cadena_a_lista_enteros(IntegrantesStr, ListaIntegrantes),
    assertz(proyecto(Id, Nombre, Objetivo, ListaEntregables, Lider, ListaIntegrantes, FInicio, FEntrega)),
    guardar_datos_disco,
    format(atom(Msg), 'Proyecto "~w" (~w) guardado correctamente.', [Nombre, Id]).

% Curso: id, creditos, nombre, objetivo, academia
alta_curso(Id, Creditos, Nombre, Objetivo, IdAcademia, Msg) :-
    retractall(curso(Id, _, _, _, _)),
    assertz(curso(Id, Creditos, Nombre, Objetivo, IdAcademia)),
    guardar_datos_disco,
    format(atom(Msg), 'Curso "~w" (~w) guardado correctamente.', [Nombre, Id]).

% Cursos capacitacion: id, nombre, objetivo, numero de horas, fecha de inicio, fecha de conclusion
alta_capacitacion(Id, Nombre, Objetivo, Horas, FInicio, FConclusion, Msg) :-
    retractall(curso_capacitacion(Id, _, _, _, _, _)),
    assertz(curso_capacitacion(Id, Nombre, Objetivo, Horas, FInicio, FConclusion)),
    guardar_datos_disco,
    format(atom(Msg), 'Curso de Capacitacion "~w" (~w) guardado correctamente.', [Nombre, Id]).

% =========================================================================
% REGISTRO DE LAS 6 OPCIONES DEL USUARIO
% =========================================================================

registrar_en_academia(NumEmp, IdAcad, exito, Mensaje) :-
    validar_asignacion_academia(NumEmp, IdAcad, Mensaje), !,
    assertz(asignacion_academia(NumEmp, IdAcad)),
    guardar_asignaciones_disco.
registrar_en_academia(NumEmp, IdAcad, error, MensajeError) :-
    motivo_rechazo_academia(NumEmp, IdAcad, MensajeError).

registrar_en_ca(NumEmp, IdCA, exito, Mensaje) :-
    validar_asignacion_ca(NumEmp, IdCA, Mensaje), !,
    assertz(asignacion_ca(NumEmp, IdCA)),
    guardar_asignaciones_disco.
registrar_en_ca(NumEmp, IdCA, error, MensajeError) :-
    motivo_rechazo_ca(NumEmp, IdCA, MensajeError).

registrar_en_proyecto(NumEmp, IdProy, exito, Mensaje) :-
    validar_asignacion_proyecto(NumEmp, IdProy, Mensaje), !,
    assertz(asignacion_proyecto(NumEmp, IdProy)),
    guardar_asignaciones_disco.
registrar_en_proyecto(NumEmp, IdProy, error, MensajeError) :-
    motivo_rechazo_proyecto(NumEmp, IdProy, MensajeError).

registrar_en_curso(NumEmp, IdCurso, exito, Mensaje) :-
    validar_asignacion_curso(NumEmp, IdCurso, Mensaje), !,
    assertz(asignacion_curso(NumEmp, IdCurso)),
    guardar_asignaciones_disco.
registrar_en_curso(NumEmp, IdCurso, rechazado, MensajeError) :-
    motivo_rechazo_curso(NumEmp, IdCurso, MensajeError).

registrar_mejor_profesor_curso(IdCurso, exito, Mensaje) :-
    curso(IdCurso, _, NomCurso, _, _),
    mejor_profesor_para_curso(IdCurso, MejorEmp, MejorNombre, Puntaje, Posicion, Grado), !,
    (   \+ asignacion_curso(MejorEmp, IdCurso)
    ->  assertz(asignacion_curso(MejorEmp, IdCurso)),
        guardar_asignaciones_disco
    ;   true
    ),
    format(atom(Mensaje), 'Exito: El mejor profesor para el curso "~w" es ~w (#~w, Grado: ~w, Prioridad #~w en su lista, Puntaje: ~w pts) y ha sido asignado.', [NomCurso, MejorNombre, MejorEmp, Grado, Posicion, Puntaje]).
registrar_mejor_profesor_curso(IdCurso, error, 'Error: El curso seleccionado no existe.') :-
    \+ curso(IdCurso, _, _, _, _), !.
registrar_mejor_profesor_curso(IdCurso, error, Msg) :-
    curso(IdCurso, _, NomCurso, _, _),
    format(atom(Msg), 'Rechazado: Ningun profesor registrado tiene el curso "~w" (~w) dentro de su lista de cursos que domina.', [NomCurso, IdCurso]).

registrar_en_capacitacion(NumEmp, IdCap, exito, Mensaje) :-
    validar_asignacion_capacitacion(NumEmp, IdCap, Mensaje), !,
    assertz(asignacion_capacitacion(NumEmp, IdCap)),
    guardar_asignaciones_disco.
registrar_en_capacitacion(NumEmp, IdCap, error, MensajeError) :-
    motivo_rechazo_capacitacion(NumEmp, IdCap, MensajeError).

registrar_en_comision(NumEmp, IdCom, exito, Mensaje) :-
    validar_asignacion_comision(NumEmp, IdCom, Mensaje), !,
    assertz(asignacion_comision(NumEmp, IdCom)),
    guardar_asignaciones_disco.
registrar_en_comision(NumEmp, IdCom, error, MensajeError) :-
    motivo_rechazo_comision(NumEmp, IdCom, MensajeError).

obtener_expediente_profesor(NumEmp, ExpedienteDict) :-
    profesor(NumEmp, Nombre, GradoMax, Especialidad, CursosDomina),
    (estudios_profesor(NumEmp, Lic, Mae, Doc) -> true ; (Lic='', Mae='', Doc='')),
    (acreditaciones_profesor(NumEmp, Acreds) -> true ; Acreds = []),
    findall(Acad, asignacion_academia(NumEmp, Acad), Academias),
    findall(CA, asignacion_ca(NumEmp, CA), CuerposAcademicos),
    findall(P, (asignacion_proyecto(NumEmp, P) ; (proyecto(P,_,_,_,_,Base,_,_), member(NumEmp, Base))), ProysRaw),
    sort(ProysRaw, Proyectos),
    findall(C, asignacion_curso(NumEmp, C), CursosImpartir),
    findall(CapT, cap_tomada(NumEmp, CapT), CapsTomadas),
    findall(CapA, asignacion_capacitacion(NumEmp, CapA), CapsAsignadas),
    findall(Com, asignacion_comision(NumEmp, Com), Comisiones),
    ExpedienteDict = _{
        num_empleado: NumEmp,
        nombre: Nombre,
        grado_maximo: GradoMax,
        especialidad: Especialidad,
        estudios: _{licenciatura: Lic, maestria: Mae, doctorado: Doc},
        acreditaciones: Acreds,
        cursos_que_domina: CursosDomina,
        asignaciones: _{
            academias: Academias,
            cuerpos_academicos: CuerposAcademicos,
            proyectos: Proyectos,
            cursos_a_impartir: CursosImpartir,
            capacitaciones_tomadas: CapsTomadas,
            capacitaciones_asignadas: CapsAsignadas,
            comisiones: Comisiones
        }
    }.