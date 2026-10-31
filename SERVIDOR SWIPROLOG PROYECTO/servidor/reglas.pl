:- encoding(utf8).
% =========================================================================
% ARCHIVO: reglas.pl
% Reglas de validacion para las 6 opciones del usuario
% =========================================================================

:- use_module(library(lists)).
:- ensure_loaded('datos.pl').
:- ensure_loaded('asignaciones_d.pl').

% Auxiliar: Verifica si dos textos/atomos tienen coincidencia (insensible a mayusculas)
texto_afin(TextoBase, PalabraClave) :-
    downcase_atom(TextoBase, B),
    downcase_atom(PalabraClave, P),
    sub_atom(B, _, _, _, P), !.

% -------------------------------------------------------------------------
% OPCION 1: Asignar profesores a academias de acuerdo a su perfil de estudios y capacitacion
% Valida: Que el profesor domine al menos una de las MateriasAsignadas de la academia,
%         o tenga la misma especialidad que el Lider de la academia,
%         o su especialidad aparezca en el nombre de la academia.
% -------------------------------------------------------------------------
validar_asignacion_academia(NumEmp, IdAcad, Mensaje) :-
    profesor(NumEmp, Nombre, _, EspProf, CursosProf),
    academia(IdAcad, NomAcad, MateriasAcad, LiderAcad),
    \+ asignacion_academia(NumEmp, IdAcad),
    (   (member(Curso, CursosProf), member(Curso, MateriasAcad))
    ;   (profesor(LiderAcad, _, _, EspLider, _), EspProf == EspLider)
    ;   texto_afin(NomAcad, EspProf)
    ), !,
    format(atom(Mensaje), 'Exito: ~w fue asignado a la academia "~w" de acuerdo a su perfil y materias que domina.', [Nombre, NomAcad]).

motivo_rechazo_academia(NumEmp, _, 'Error: El profesor no existe.') :- \+ profesor(NumEmp, _, _, _, _), !.
motivo_rechazo_academia(_, IdAcad, 'Error: La academia no existe.') :- \+ academia(IdAcad, _, _, _), !.
motivo_rechazo_academia(NumEmp, IdAcad, 'Aviso: El profesor ya pertenece a esta academia.') :- asignacion_academia(NumEmp, IdAcad), !.
motivo_rechazo_academia(NumEmp, IdAcad, Msg) :-
    profesor(NumEmp, Nombre, _, Esp, Cursos),
    academia(IdAcad, NomAcad, Materias, _),
    format(atom(Msg), 'Rechazado: ~w (Especialidad: ~w | Domina: ~w) no domina ninguna de las materias (~w) ni tiene perfil afin a la academia "~w".', [Nombre, Esp, Cursos, Materias, NomAcad]).

% -------------------------------------------------------------------------
% OPCION 2: Asignar profesores a cuerpos academicos de acuerdo a su perfil de estudios y capacitacion
% Valida: Grado de Maestria o Doctorado + Especialidad o estudios/capacitaciones afines a la Linea de Investigacion.
% -------------------------------------------------------------------------
validar_asignacion_ca(NumEmp, IdCA, Mensaje) :-
    profesor(NumEmp, Nombre, Grado, EspProf, _),
    cuerpo_academico(IdCA, NomCA, LineaInv, LiderCA, _),
    \+ asignacion_ca(NumEmp, IdCA),
    member(Grado, [maestria, doctorado]),
    (   EspProf == LineaInv
    ;   texto_afin(LineaInv, EspProf)
    ;   texto_afin(EspProf, LineaInv)
    ;   (profesor(LiderCA, _, _, EspLider, _), EspProf == EspLider)
    ), !,
    format(atom(Mensaje), 'Exito: ~w (Grado: ~w) fue asignado al Cuerpo Academico "~w" (Linea: ~w).', [Nombre, Grado, NomCA, LineaInv]).

motivo_rechazo_ca(NumEmp, _, 'Error: El profesor no existe.') :- \+ profesor(NumEmp, _, _, _, _), !.
motivo_rechazo_ca(_, IdCA, 'Error: El Cuerpo Academico no existe.') :- \+ cuerpo_academico(IdCA, _, _, _, _), !.
motivo_rechazo_ca(NumEmp, IdCA, 'Aviso: El profesor ya pertenece a este Cuerpo Academico.') :- asignacion_ca(NumEmp, IdCA), !.
motivo_rechazo_ca(NumEmp, _, Msg) :-
    profesor(NumEmp, Nombre, licenciatura, _, _), !,
    format(atom(Msg), 'Rechazado: ~w cuenta solo con Licenciatura. Para ingresar a un Cuerpo Academico se requiere Maestria o Doctorado.', [Nombre]).
motivo_rechazo_ca(NumEmp, IdCA, Msg) :-
    profesor(NumEmp, Nombre, _, Esp, _),
    cuerpo_academico(IdCA, NomCA, Linea, _, _),
    format(atom(Msg), 'Rechazado: La especialidad de ~w (~w) no es afin a la linea de investigacion (~w) del Cuerpo Academico "~w".', [Nombre, Esp, Linea, NomCA]).

% -------------------------------------------------------------------------
% OPCION 3: Asignar profesores a proyectos de acuerdo a su perfil de estudios y capacitacion
% Valida: Que su especialidad coincida con la del Lider del proyecto, o sea afin al Nombre/Objetivo del proyecto,
%         o pertenezca a la misma academia/CA que el lider del proyecto.
% -------------------------------------------------------------------------
validar_asignacion_proyecto(NumEmp, IdProy, Mensaje) :-
    profesor(NumEmp, Nombre, _, EspProf, _),
    proyecto(IdProy, NomProy, ObjProy, _, LiderProy, IntegrantesBase, _, _),
    \+ member(NumEmp, IntegrantesBase),
    \+ asignacion_proyecto(NumEmp, IdProy),
    (   (profesor(LiderProy, _, _, EspLider, _), EspProf == EspLider)
    ;   texto_afin(NomProy, EspProf)
    ;   texto_afin(ObjProy, EspProf)
    ;   (asignacion_academia(NumEmp, Ac), asignacion_academia(LiderProy, Ac))
    ), !,
    format(atom(Mensaje), 'Exito: ~w se integro al proyecto "~w" de acuerdo a su perfil.', [Nombre, NomProy]).

motivo_rechazo_proyecto(NumEmp, _, 'Error: El profesor no existe.') :- \+ profesor(NumEmp, _, _, _, _), !.
motivo_rechazo_proyecto(_, IdProy, 'Error: El proyecto no existe.') :- \+ proyecto(IdProy, _, _, _, _, _, _, _), !.
motivo_rechazo_proyecto(NumEmp, IdProy, 'Aviso: El profesor ya es integrante de este proyecto.') :-
    proyecto(IdProy, _, _, _, _, Base, _, _),
    (member(NumEmp, Base) ; asignacion_proyecto(NumEmp, IdProy)), !.
motivo_rechazo_proyecto(NumEmp, IdProy, Msg) :-
    profesor(NumEmp, Nombre, _, Esp, _),
    proyecto(IdProy, NomProy, ObjProy, _, _, _, _, _),
    format(atom(Msg), 'Rechazado: El perfil de ~w (Especialidad: ~w) no es compatible con el proyecto "~w" (Objetivo: ~w).', [Nombre, Esp, NomProy, ObjProy]).

% -------------------------------------------------------------------------
% OPCION 4: Asignar al mejor profesor a un curso (y validacion directa por perfil)
% -------------------------------------------------------------------------
% Validacion directa (Ej: Rechazar maestro de interfaces en curso de programacion)
validar_asignacion_curso(NumEmp, IdCurso, Mensaje) :-
    profesor(NumEmp, Nombre, _, _, CursosDomina),
    curso(IdCurso, _, NomCurso, _, _),
    \+ asignacion_curso(NumEmp, IdCurso),
    nth1(Pos, CursosDomina, IdCurso), !,
    format(atom(Mensaje), 'Exito: ~w asignado al curso "~w" (Prioridad #~w en su lista de cursos que domina).', [Nombre, NomCurso, Pos]).

motivo_rechazo_curso(NumEmp, _, 'Error: El profesor no existe.') :- \+ profesor(NumEmp, _, _, _, _), !.
motivo_rechazo_curso(_, IdCurso, 'Error: El curso no existe.') :- \+ curso(IdCurso, _, _, _, _), !.
motivo_rechazo_curso(NumEmp, IdCurso, 'Aviso: El profesor ya tiene asignado este curso.') :- asignacion_curso(NumEmp, IdCurso), !.
motivo_rechazo_curso(NumEmp, IdCurso, Msg) :-
    profesor(NumEmp, Nombre, _, EspProf, CursosDomina),
    curso(IdCurso, _, NomCurso, _, _),
    format(atom(Msg), 'Rechazado: No se puede asignar el curso "~w" al profesor ~w (Especialidad: ~w) porque no esta en la lista de cursos que domina (~w).', [NomCurso, Nombre, EspProf, CursosDomina]).

% Seleccion automatica del MEJOR profesor para un curso:
% Evalua: Posicion en la lista de cursos que domina (menor indice = mayor dominio) +
%         Grado academico + Acreditaciones + Cursos de capacitacion tomados.
calcular_aptitud_curso(IdCurso, PuntajeTotal, NumEmp, Nombre, PosicionDominio, Grado) :-
    profesor(NumEmp, Nombre, Grado, _, CursosDomina),
    nth1(PosicionDominio, CursosDomina, IdCurso),
    (peso_grado(Grado, PtsGrado) -> true ; PtsGrado = 10),
    PtsDominio is max(10, 60 - (PosicionDominio * 10)),
    (acreditaciones_profesor(NumEmp, Acreds), length(Acreds, NA) -> PtsAcred is NA * 5 ; PtsAcred = 0),
    findall(Cap, cap_tomada(NumEmp, Cap), Caps), length(Caps, NC), PtsCap is NC * 5,
    PuntajeTotal is PtsGrado + PtsDominio + PtsAcred + PtsCap.

mejor_profesor_para_curso(IdCurso, MejorEmp, MejorNombre, MejorPuntaje, Posicion, Grado) :-
    findall(
        Pts-Emp-Nom-Pos-Gr,
        calcular_aptitud_curso(IdCurso, Pts, Emp, Nom, Pos, Gr),
        Candidatos
    ),
    Candidatos \= [],
    keysort(Candidatos, OrdenadosAsc),
    reverse(OrdenadosAsc, [MejorPuntaje-MejorEmp-MejorNombre-Posicion-Grado | _]).

% -------------------------------------------------------------------------
% OPCION 5: Asignar profesores a cursos de capacitacion de acuerdo a su perfil de estudios y capacitacion
% Valida:
% 1. Que no lo haya tomado antes (cap_tomada) ni este ya inscrito (asignacion_capacitacion).
% 2. Que el Nombre u Objetivo de la capacitacion sea afin a su Especialidad, a sus estudios o sea docente/pedagogico,
%    o bien que la duracion/nivel corresponda a su preparacion (si supera 40 horas exige capacitacion previa o posgrado).
% -------------------------------------------------------------------------
validar_asignacion_capacitacion(NumEmp, IdCap, Mensaje) :-
    profesor(NumEmp, Nombre, Grado, EspProf, _),
    curso_capacitacion(IdCap, NomCap, ObjCap, Horas, _, _),
    \+ cap_tomada(NumEmp, IdCap),
    \+ asignacion_capacitacion(NumEmp, IdCap),
    (   texto_afin(NomCap, EspProf)
    ;   texto_afin(ObjCap, EspProf)
    ;   texto_afin(NomCap, docencia)
    ;   texto_afin(NomCap, pedagogia)
    ;   texto_afin(ObjCap, docente)
    ;   Horas =< 40
    ),
    (   Horas > 40
    ->  (member(Grado, [maestria, doctorado]) ; cap_tomada(NumEmp, _))
    ;   true
    ), !,
    format(atom(Mensaje), 'Exito: ~w inscrito en el curso de capacitacion "~w" (~w hrs) de acuerdo a su perfil.', [Nombre, NomCap, Horas]).

motivo_rechazo_capacitacion(NumEmp, _, 'Error: El profesor no existe.') :- \+ profesor(NumEmp, _, _, _, _), !.
motivo_rechazo_capacitacion(_, IdCap, 'Error: El curso de capacitacion no existe.') :- \+ curso_capacitacion(IdCap, _, _, _, _, _), !.
motivo_rechazo_capacitacion(NumEmp, IdCap, 'Aviso: El profesor ya tomo o ya tiene asignado este curso de capacitacion.') :-
    (cap_tomada(NumEmp, IdCap) ; asignacion_capacitacion(NumEmp, IdCap)), !.
motivo_rechazo_capacitacion(NumEmp, IdCap, Msg) :-
    profesor(NumEmp, Nombre, licenciatura, _, _),
    curso_capacitacion(IdCap, NomCap, _, Horas, _, _),
    Horas > 40,
    \+ cap_tomada(NumEmp, _), !,
    format(atom(Msg), 'Rechazado: La capacitacion intensiva "~w" (~w hrs) requiere contar con al menos una capacitacion previa tomada o grado de posgrado (~w tiene Licenciatura sin capacitaciones previas).', [NomCap, Horas, Nombre]).
motivo_rechazo_capacitacion(NumEmp, IdCap, Msg) :-
    profesor(NumEmp, Nombre, _, Esp, _),
    curso_capacitacion(IdCap, NomCap, ObjCap, _, _, _),
    format(atom(Msg), 'Rechazado: El curso de capacitacion "~w" (Objetivo: ~w) no corresponde a la especialidad (~w) del profesor ~w.', [NomCap, ObjCap, Esp, Nombre]).

% -------------------------------------------------------------------------
% COMPLEMENTO PUNTO 1: Asignar profesores a comisiones
% -------------------------------------------------------------------------
validar_asignacion_comision(NumEmp, IdCom, Mensaje) :-
    profesor(NumEmp, Nombre, Grado, _, _),
    comision(IdCom, NomCom, _, Requisito, _),
    \+ asignacion_comision(NumEmp, IdCom),
    (   Grado == Requisito
    ;   (Grado == doctorado, Requisito == maestria)
    ;   Requisito == licenciatura
    ;   (acreditaciones_profesor(NumEmp, Acreds), member(Requisito, Acreds))
    ), !,
    format(atom(Mensaje), 'Exito: ~w asignado a la "~w".', [Nombre, NomCom]).

motivo_rechazo_comision(NumEmp, _, 'Error: El profesor no existe.') :- \+ profesor(NumEmp, _, _, _, _), !.
motivo_rechazo_comision(_, IdCom, 'Error: La comision no existe.') :- \+ comision(IdCom, _, _, _, _), !.
motivo_rechazo_comision(NumEmp, IdCom, 'Aviso: El profesor ya pertenece a esta comision.') :- asignacion_comision(NumEmp, IdCom), !.
motivo_rechazo_comision(NumEmp, IdCom, Msg) :-
    profesor(NumEmp, Nombre, Grado, _, _),
    comision(IdCom, NomCom, _, Req, _),
    format(atom(Msg), 'Rechazado: ~w (Grado: ~w) no cumple con el perfil o acreditacion requerida (~w) para la "~w".', [Nombre, Grado, Req, NomCom]).