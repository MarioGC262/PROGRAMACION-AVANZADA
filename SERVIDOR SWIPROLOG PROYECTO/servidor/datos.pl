:- encoding(utf8).
% =========================================================================
% ARCHIVO: datos.pl
% Entidades con los atributos exactos especificados en las indicaciones
% =========================================================================

% --- ENTIDADES DEL PUNTO 2 (Inician vacias para que las llene el usuario) ---
:- dynamic profesor/5.
% profesor(NumEmpleado, Nombre, GradoAcademico, Especialidad, ListaCursosDominaMayorAMenor)

:- dynamic cuerpo_academico/5.
% cuerpo_academico(Id, Nombre, LineaInvestigacion, Lider, Estatus)

:- dynamic academia/4.
% academia(Id, Nombre, MateriasAsignadas, Lider)

:- dynamic proyecto/8.
% proyecto(Id, Nombre, Objetivo, Entregables, Lider, Integrantes, FechaInicio, FechaEntrega)

:- dynamic curso/5.
% curso(Id, Creditos, Nombre, Objetivo, Academia)

:- dynamic curso_capacitacion/6.
% curso_capacitacion(Id, Nombre, Objetivo, NumeroHoras, FechaInicio, FechaConclusion)

% --- CONTROL DE ESTUDIOS Y ACREDITACIONES DEL PUNTO 1 ---
:- dynamic estudios_profesor/4.
% estudios_profesor(NumEmpleado, Licenciatura, Maestria, Doctorado)

:- dynamic acreditaciones_profesor/2.
% acreditaciones_profesor(NumEmpleado, ListaAcreditaciones)

% --- COMPLEMENTO DEL PUNTO 1 (No detallado en punto 2, precargado por el sistema) ---
:- dynamic comision/5.
% comision(Id, Nombre, Objetivo, RequisitoGradoOAcred, Estatus)
comision(com_curriculo, 'Comision de Rediseno Curricular FCI', 'Actualizar planes de estudio', maestria, activa).
comision(com_conaic, 'Comision de Acreditacion CONAIC', 'Coordinar evaluacion externa', prodep, activa).
comision(com_posgrado, 'Comision de Investigacion y Posgrado', 'Evaluar tesis y proyectos', doctorado, activa).
comision(com_tutorias, 'Comision Institucional de Tutorias', 'Seguimiento estudiantil', licenciatura, activa).

% Puntajes base por grado academico para evaluar al mejor profesor
peso_grado(licenciatura, 10).
peso_grado(maestria, 20).
peso_grado(doctorado, 30).