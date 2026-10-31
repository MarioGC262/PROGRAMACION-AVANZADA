:- encoding(utf8).
% =========================================================================
% ARCHIVO: asignaciones_d.pl
% Almacenamiento dinamico de asignaciones y capacitaciones tomadas
% =========================================================================

:- dynamic asignacion_academia/2.     % asignacion_academia(NumEmpleado, IdAcademia)
:- dynamic asignacion_ca/2.           % asignacion_ca(NumEmpleado, IdCA)
:- dynamic asignacion_proyecto/2.     % asignacion_proyecto(NumEmpleado, IdProyecto)
:- dynamic asignacion_comision/2.     % asignacion_comision(NumEmpleado, IdComision)
:- dynamic asignacion_curso/2.        % asignacion_curso(NumEmpleado, IdCurso)
:- dynamic asignacion_capacitacion/2. % asignacion_capacitacion(NumEmpleado, IdCap)
:- dynamic cap_tomada/2.              % cap_tomada(NumEmpleado, IdCap)