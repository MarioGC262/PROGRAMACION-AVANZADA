:- encoding(utf8).
% =========================================================================
% ARCHIVO: server.pl
% Servidor Web Modular por Apartados - FCI UNACAR
% Ejecutar: swipl -s server.pl
% Abrir en navegador: http://localhost:8080/home
% =========================================================================

:- use_module(library(http/http_server)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/html_write)).

:- ensure_loaded('datos.pl').
:- ensure_loaded('asignaciones_d.pl').
:- ensure_loaded('reglas.pl').
:- ensure_loaded('asignaciones.pl').

:- initialization http_server([port(8080)]).

% --- RUTAS DE NAVEGACION: APARTADO 1 (ENTIDADES DEL PUNTO 2) ---
:- http_handler(root(.), vista_inicio, []).
:- http_handler(root(home), vista_inicio, []).
:- http_handler(root(entidad/profesor), vista_entidad_profesor, []).
:- http_handler(root(entidad/cuerpo_academico), vista_entidad_ca, []).
:- http_handler(root(entidad/academia), vista_entidad_academia, []).
:- http_handler(root(entidad/proyecto), vista_entidad_proyecto, []).
:- http_handler(root(entidad/curso), vista_entidad_curso, []).
:- http_handler(root(entidad/capacitacion), vista_entidad_capacitacion, []).
:- http_handler(root(entidad/comision), vista_entidad_comision, []).

% --- RUTAS DE NAVEGACION: APARTADO 2 (LAS 6 OPCIONES DEL USUARIO) ---
:- http_handler(root(opcion/op1_academia), vista_op1_academia, []).
:- http_handler(root(opcion/op2_ca), vista_op2_ca, []).
:- http_handler(root(opcion/op3_proyecto), vista_op3_proyecto, []).
:- http_handler(root(opcion/op4_curso), vista_op4_curso, []).
:- http_handler(root(opcion/op5_capacitacion), vista_op5_capacitacion, []).
:- http_handler(root(opcion/op6_buscar), vista_op6_buscar, []).
:- http_handler(root(opcion/extra_comision), vista_op_comision, []).

% --- RUTAS POST PARA GUARDAR ENTIDADES ---
:- http_handler(root(guardar/profesor), handle_alta_profesor, []).
:- http_handler(root(guardar/ca), handle_alta_ca, []).
:- http_handler(root(guardar/academia), handle_alta_academia, []).
:- http_handler(root(guardar/proyecto), handle_alta_proyecto, []).
:- http_handler(root(guardar/curso), handle_alta_curso, []).
:- http_handler(root(guardar/capacitacion), handle_alta_capacitacion, []).

% --- RUTAS POST PARA EJECUTAR ASIGNACIONES ---
:- http_handler(root(operacion/asignar_academia), handle_op_academia, []).
:- http_handler(root(operacion/asignar_ca), handle_op_ca, []).
:- http_handler(root(operacion/asignar_proyecto), handle_op_proyecto, []).
:- http_handler(root(operacion/asignar_curso), handle_op_curso, []).
:- http_handler(root(operacion/mejor_profesor), handle_op_mejor_profesor, []).
:- http_handler(root(operacion/asignar_capacitacion), handle_op_capacitacion, []).
:- http_handler(root(operacion/asignar_comision), handle_op_comision, []).


% =========================================================================
% PLANTILLA VISUAL MAESTRA (MENU LATERAL + CONTENIDO)
% =========================================================================
layout_sistema(TituloPagina, ContenidoHTML) :-
    reply_html_page(
        title(TituloPagina),
        [
            style('
                * { box-sizing: border-box; font-family: "Segoe UI", Arial, sans-serif; }
                body { margin: 0; display: flex; min-height: 100vh; background-color: #f0f2f5; color: #1c1e21; }
                .sidebar { width: 310px; background: #002855; color: white; display: flex; flex-direction: column; flex-shrink: 0; }
                .sidebar-header { padding: 18px; background: #001a38; border-bottom: 2px solid #eaaa00; }
                .sidebar-header h2 { margin: 0; font-size: 18px; color: #eaaa00; }
                .sidebar-header p { margin: 4px 0 0; font-size: 12px; color: #cfd8dc; }
                .nav-section { padding: 12px 16px 4px; font-size: 11px; text-transform: uppercase; letter-spacing: 1px; color: #90a4ae; font-weight: bold; }
                .nav-link { display: block; padding: 10px 20px; color: #eceff1; text-decoration: none; font-size: 13.5px; border-left: 4px solid transparent; }
                .nav-link:hover { background: #003c7e; border-left-color: #eaaa00; }
                .main { flex: 1; padding: 28px; overflow-y: auto; }
                .header-title { margin-top: 0; color: #002855; border-bottom: 2px solid #dce1e7; padding-bottom: 10px; }
                .card { background: white; padding: 22px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.08); margin-bottom: 22px; }
                .card h3 { margin-top: 0; color: #002855; }
                .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
                .form-group { margin-bottom: 12px; }
                label { display: block; font-weight: 600; font-size: 13px; margin-bottom: 5px; color: #333; }
                input, select { width: 100%; padding: 9px; border: 1px solid #ccd0d5; border-radius: 5px; font-size: 14px; }
                button { background: #002855; color: white; border: none; padding: 10px 18px; border-radius: 5px; font-size: 14px; font-weight: bold; cursor: pointer; margin-top: 8px; }
                button:hover { background: #004085; }
                table { width: 100%; border-collapse: collapse; margin-top: 10px; background: white; font-size: 13.5px; }
                th, td { border: 1px solid #dee2e6; padding: 10px; text-align: left; }
                th { background: #002855; color: white; }
                tr:nth-child(even) { background: #f8f9fa; }
                .badge { display: inline-block; padding: 3px 8px; background: #e3f2fd; color: #0d47a1; border-radius: 12px; font-size: 12px; font-weight: bold; }
                .alert-ok { background: #d4edda; color: #155724; border-left: 5px solid #28a745; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
                .alert-err { background: #f8d7da; color: #721c24; border-left: 5px solid #dc3545; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
            '),
            div(class(sidebar), [
                div(class('sidebar-header'), [
                    h2('FCI - UNACAR'),
                    p('Sistema de Asignacion Docente')
                ]),
                a([class('nav-link'), href('/home')], 'Inicio / Resumen General'),

                div(class('nav-section'), 'Datos de las Entidades'),
                a([class('nav-link'), href('/entidad/profesor')], '- Profesor y Estudios'),
                a([class('nav-link'), href('/entidad/cuerpo_academico')], '- Cuerpo Academico'),
                a([class('nav-link'), href('/entidad/academia')], '- Academia'),
                a([class('nav-link'), href('/entidad/proyecto')], '- Proyecto'),
                a([class('nav-link'), href('/entidad/curso')], '- Curso'),
                a([class('nav-link'), href('/entidad/capacitacion')], '- Cursos Capacitacion'),
                a([class('nav-link'), href('/entidad/comision')], '- Comisiones'),

                div(class('nav-section'), 'Opciones del Sistema'),
                a([class('nav-link'), href('/opcion/op1_academia')], '1. Asignar a Academias'),
                a([class('nav-link'), href('/opcion/op2_ca')], '2. Asignar a Cuerpos Academicos'),
                a([class('nav-link'), href('/opcion/op3_proyecto')], '3. Asignar a Proyectos'),
                a([class('nav-link'), href('/opcion/op4_curso')], '4. Asignar Mejor Prof. a Curso'),
                a([class('nav-link'), href('/opcion/op5_capacitacion')], '5. Asignar a Cursos Capacitacion'),
                a([class('nav-link'), href('/opcion/op6_buscar')], '6. Buscar Profesor y Asignaciones'),
                a([class('nav-link'), href('/opcion/extra_comision')], '+ Asignar a Comisiones')
            ]),
            div(class(main), [
                h1(class('header-title'), TituloPagina),
                div(ContenidoHTML)
            ])
        ]
    ).

% =========================================================================
% PANTALLA DE INICIO
% =========================================================================
vista_inicio(_Req) :-
    findall(E, profesor(E,_,_,_,_), LProf), length(LProf, NProf),
    findall(C, cuerpo_academico(C,_,_,_,_), LCA), length(LCA, NCA),
    findall(A, academia(A,_,_,_), LAcad), length(LAcad, NAcad),
    findall(P, proyecto(P,_,_,_,_,_,_,_), LProy), length(LProy, NProy),
    findall(Cu, curso(Cu,_,_,_,_), LCur), length(LCur, NCur),
    findall(Ca, curso_capacitacion(Ca,_,_,_,_,_), LCap), length(LCap, NCap),
    layout_sistema('Facultad de Ciencias de la Informacion - UNACAR', [
        div(class(card), [
            h3('Resumen de Entidades Registradas'),
            table([
                tr([th('Entidad'), th('Atributos del Sistema'), th('Total'), th('Accion')]),
                tr([td('Profesor'), td('#empleado, nombre, grado, especialidad, cursos que domina + estudios/acred.'), td(NProf), td(a([href('/entidad/profesor')], 'Capturar >>'))]),
                tr([td('Cuerpo Academico'), td('id, nombre, linea de investigacion, lider, estatus'), td(NCA), td(a([href('/entidad/cuerpo_academico')], 'Capturar >>'))]),
                tr([td('Academia'), td('id, nombre, materias asignadas, lider'), td(NAcad), td(a([href('/entidad/academia')], 'Capturar >>'))]),
                tr([td('Proyecto'), td('id, nombre, objetivo, entregables, lider, integrantes, fecha inicio, fecha entrega'), td(NProy), td(a([href('/entidad/proyecto')], 'Capturar >>'))]),
                tr([td('Curso'), td('id, creditos, nombre, objetivo, academia'), td(NCur), td(a([href('/entidad/curso')], 'Capturar >>'))]),
                tr([td('Cursos Capacitacion'), td('id, nombre, objetivo, numero de horas, fecha inicio, fecha conclusion'), td(NCap), td(a([href('/entidad/capacitacion')], 'Capturar >>'))])
            ])
        ])
    ]).


% =========================================================================
% APARTADO 1: VISTAS DE ENTIDADES (ATRIBUTOS EXACTOS DEL PUNTO 2)
% =========================================================================

% --- 1. PROFESOR ---
vista_entidad_profesor(_Req) :-
    findall(prof(E, N, G, Esp, C), profesor(E, N, G, Esp, C), Lista),
    layout_sistema('Entidad: Profesor y Control de Estudios', [
        div(class(card), [
            h3('Registrar Profesor (#empleado, nombre, grado, especialidad, cursos que domina y control de estudios)'),
            form([action('/guardar/profesor'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('# Empleado:'), input([name(empleado), type(number), required(required)])]),
                    div(class('form-group'), [label('Nombre:'), input([name(nombre), type(text), required(required)])]),
                    div(class('form-group'), [
                        label('Grado Academico:'),
                        select([name(grado)], [
                            option([value(licenciatura)], 'Licenciatura'),
                            option([value(maestria)], 'Maestria'),
                            option([value(doctorado)], 'Doctorado')
                        ])
                    ]),
                    div(class('form-group'), [label('Especialidad (ej. programacion, interfaces, ia, redes):'), input([name(especialidad), type(text), required(required)])]),
                    div(class('form-group'), [label('Lista de cursos que domina de MAYOR a MENOR (IDs separados por coma):'), input([name(cursos), type(text), placeholder('prog_avanzada, est_datos, poo'), required(required)])]),
                    div(class('form-group'), [label('Estudios de Licenciatura:'), input([name(lic), type(text), required(required)])]),
                    div(class('form-group'), [label('Estudios de Maestria (o Ninguno):'), input([name(mae), type(text), value('Ninguno')])]),
                    div(class('form-group'), [label('Estudios de Doctorado (o Ninguno):'), input([name(doc), type(text), value('Ninguno')])]),
                    div(class('form-group'), [label('Acreditaciones (separadas por coma, ej. prodep, sni_1):'), input([name(acreditaciones), type(text), placeholder('prodep')])]),
                    div(class('form-group'), [label('Cursos de capacitacion tomados (IDs separados por coma):'), input([name(cap_tomadas), type(text), placeholder('cap_1')])])
                ]),
                button([type(submit)], 'Guardar Profesor')
            ])
        ]),
        div(class(card), [
            h3('Profesores Registrados'),
            table([
                tr([th('# Empleado'), th('Nombre'), th('Grado'), th('Especialidad'), th('Cursos que Domina (Mayor > Menor)'), th('Lic / Mae / Doc'), th('Acreditaciones'), th('Cap. Tomadas')]),
                \filas_entidad_profesor(Lista)
            ])
        ])
    ]).

filas_entidad_profesor([]) --> [].
filas_entidad_profesor([prof(E, N, G, Esp, C)|R]) -->
    {
        atomic_list_concat(C, ' > ', SC),
        (estudios_profesor(E, Lic, Mae, Doc) -> true ; (Lic='-', Mae='-', Doc='-')),
        format(atom(EstStr), '~w / ~w / ~w', [Lic, Mae, Doc]),
        (acreditaciones_profesor(E, Ac) -> atomic_list_concat(Ac, ', ', SAc) ; SAc = '-'),
        findall(Cap, cap_tomada(E, Cap), LCap), atomic_list_concat(LCap, ', ', SCap)
    },
    html(tr([td(E), td(N), td(G), td(Esp), td(SC), td(EstStr), td(SAc), td(SCap)])),
    filas_entidad_profesor(R).

% --- 2. CUERPO ACADEMICO: id, nombre, linea de investigacion, lider, estatus ---
vista_entidad_ca(_Req) :-
    findall(ca(Id, Nom, Lin, Lid, Est), cuerpo_academico(Id, Nom, Lin, Lid, Est), Lista),
    layout_sistema('Entidad: Cuerpo Academico', [
        div(class(card), [
            h3('Registrar Cuerpo Academico (id, nombre, linea de investigacion, lider, estatus)'),
            form([action('/guardar/ca'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('ID:'), input([name(id), type(text), required(required)])]),
                    div(class('form-group'), [label('Nombre:'), input([name(nombre), type(text), required(required)])]),
                    div(class('form-group'), [label('Linea de Investigacion:'), input([name(linea), type(text), required(required)])]),
                    div(class('form-group'), [label('Lider (# Empleado):'), input([name(lider), type(number), required(required)])]),
                    div(class('form-group'), [
                        label('Estatus:'),
                        select([name(estatus)], [
                            option([value(en_formacion)], 'En Formacion'),
                            option([value(en_consolidacion)], 'En Consolidacion'),
                            option([value(consolidado)], 'Consolidado')
                        ])
                    ])
                ]),
                button([type(submit)], 'Guardar Cuerpo Academico')
            ])
        ]),
        div(class(card), [
            h3('Cuerpos Academicos Registrados'),
            table([
                tr([th('ID'), th('Nombre'), th('Linea de Investigacion'), th('Lider'), th('Estatus')]),
                \filas_entidad_ca(Lista)
            ])
        ])
    ]).

filas_entidad_ca([]) --> [].
filas_entidad_ca([ca(Id, Nom, Lin, Lid, Est)|R]) -->
    html(tr([td(Id), td(Nom), td(Lin), td(Lid), td(Est)])),
    filas_entidad_ca(R).

% --- 3. ACADEMIA: id, nombre, materias asignadas, lider ---
vista_entidad_academia(_Req) :-
    findall(ac(Id, Nom, Mat, Lid), academia(Id, Nom, Mat, Lid), Lista),
    layout_sistema('Entidad: Academia', [
        div(class(card), [
            h3('Registrar Academia (id, nombre, materias asignadas, lider)'),
            form([action('/guardar/academia'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('ID:'), input([name(id), type(text), required(required)])]),
                    div(class('form-group'), [label('Nombre:'), input([name(nombre), type(text), required(required)])]),
                    div(class('form-group'), [label('Materias Asignadas (IDs separados por coma):'), input([name(materias), type(text), placeholder('prog_avanzada, poo'), required(required)])]),
                    div(class('form-group'), [label('Lider (# Empleado):'), input([name(lider), type(number), required(required)])])
                ]),
                button([type(submit)], 'Guardar Academia')
            ])
        ]),
        div(class(card), [
            h3('Academias Registradas'),
            table([
                tr([th('ID'), th('Nombre'), th('Materias Asignadas'), th('Lider')]),
                \filas_entidad_academia(Lista)
            ])
        ])
    ]).

filas_entidad_academia([]) --> [].
filas_entidad_academia([ac(Id, Nom, Mat, Lid)|R]) -->
    { atomic_list_concat(Mat, ', ', SMat) },
    html(tr([td(Id), td(Nom), td(SMat), td(Lid)])),
    filas_entidad_academia(R).

% --- 4. PROYECTO: id, nombre, objetivo, entregables, lider, integrantes, fecha de inicio, fecha de entrega ---
vista_entidad_proyecto(_Req) :-
    findall(pr(Id, Nom, Obj, Ent, Lid, Int, FIn, FEn), proyecto(Id, Nom, Obj, Ent, Lid, Int, FIn, FEn), Lista),
    layout_sistema('Entidad: Proyecto', [
        div(class(card), [
            h3('Registrar Proyecto (id, nombre, objetivo, entregables, lider, integrantes, fecha inicio, fecha entrega)'),
            form([action('/guardar/proyecto'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('ID:'), input([name(id), type(text), required(required)])]),
                    div(class('form-group'), [label('Nombre:'), input([name(nombre), type(text), required(required)])]),
                    div(class('form-group'), [label('Objetivo:'), input([name(objetivo), type(text), required(required)])]),
                    div(class('form-group'), [label('Entregables (separados por coma):'), input([name(entregables), type(text), required(required)])]),
                    div(class('form-group'), [label('Lider (# Empleado):'), input([name(lider), type(number), required(required)])]),
                    div(class('form-group'), [label('Integrantes (# Empleados separados por coma):'), input([name(integrantes), type(text), required(required)])]),
                    div(class('form-group'), [label('Fecha de Inicio:'), input([name(inicio), type(date), required(required)])]),
                    div(class('form-group'), [label('Fecha de Entrega:'), input([name(entrega), type(date), required(required)])])
                ]),
                button([type(submit)], 'Guardar Proyecto')
            ])
        ]),
        div(class(card), [
            h3('Proyectos Registrados'),
            table([
                tr([th('ID'), th('Nombre'), th('Objetivo'), th('Entregables'), th('Lider'), th('Integrantes'), th('Fecha Inicio'), th('Fecha Entrega')]),
                \filas_entidad_proyecto(Lista)
            ])
        ])
    ]).

filas_entidad_proyecto([]) --> [].
filas_entidad_proyecto([pr(Id, Nom, Obj, Ent, Lid, Int, FIn, FEn)|R]) -->
    { atomic_list_concat(Ent, ', ', SEnt), atomic_list_concat(Int, ', ', SInt) },
    html(tr([td(Id), td(Nom), td(Obj), td(SEnt), td(Lid), td(SInt), td(FIn), td(FEn)])),
    filas_entidad_proyecto(R).

% --- 5. CURSO: id, creditos, nombre, objetivo, academia ---
vista_entidad_curso(_Req) :-
    findall(cu(Id, Cr, Nom, Obj, Ac), curso(Id, Cr, Nom, Obj, Ac), Lista),
    layout_sistema('Entidad: Curso', [
        div(class(card), [
            h3('Registrar Curso (id, creditos, nombre, objetivo, academia)'),
            form([action('/guardar/curso'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('ID:'), input([name(id), type(text), required(required)])]),
                    div(class('form-group'), [label('Creditos:'), input([name(creditos), type(number), required(required)])]),
                    div(class('form-group'), [label('Nombre:'), input([name(nombre), type(text), required(required)])]),
                    div(class('form-group'), [label('Objetivo:'), input([name(objetivo), type(text), required(required)])]),
                    div(class('form-group'), [label('Academia (ID):'), input([name(academia), type(text), required(required)])])
                ]),
                button([type(submit)], 'Guardar Curso')
            ])
        ]),
        div(class(card), [
            h3('Cursos Registrados'),
            table([
                tr([th('ID'), th('Creditos'), th('Nombre'), th('Objetivo'), th('Academia')]),
                \filas_entidad_curso(Lista)
            ])
        ])
    ]).

filas_entidad_curso([]) --> [].
filas_entidad_curso([cu(Id, Cr, Nom, Obj, Ac)|R]) -->
    html(tr([td(Id), td(Cr), td(Nom), td(Obj), td(Ac)])),
    filas_entidad_curso(R).

% --- 6. CURSOS CAPACITACION: id, nombre, objetivo, numero de horas, fecha de inicio, fecha de conclusion ---
vista_entidad_capacitacion(_Req) :-
    findall(cap(Id, Nom, Obj, H, FI, FC), curso_capacitacion(Id, Nom, Obj, H, FI, FC), Lista),
    layout_sistema('Entidad: Cursos Capacitacion', [
        div(class(card), [
            h3('Registrar Curso de Capacitacion (id, nombre, objetivo, numero de horas, fecha inicio, fecha conclusion)'),
            form([action('/guardar/capacitacion'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('ID:'), input([name(id), type(text), required(required)])]),
                    div(class('form-group'), [label('Nombre:'), input([name(nombre), type(text), required(required)])]),
                    div(class('form-group'), [label('Objetivo:'), input([name(objetivo), type(text), required(required)])]),
                    div(class('form-group'), [label('Numero de Horas:'), input([name(horas), type(number), required(required)])]),
                    div(class('form-group'), [label('Fecha de Inicio:'), input([name(inicio), type(date), required(required)])]),
                    div(class('form-group'), [label('Fecha de Conclusion:'), input([name(fin), type(date), required(required)])])
                ]),
                button([type(submit)], 'Guardar Curso de Capacitacion')
            ])
        ]),
        div(class(card), [
            h3('Cursos de Capacitacion Registrados'),
            table([
                tr([th('ID'), th('Nombre'), th('Objetivo'), th('Numero de Horas'), th('Fecha Inicio'), th('Fecha Conclusion')]),
                \filas_entidad_cap(Lista)
            ])
        ])
    ]).

filas_entidad_cap([]) --> [].
filas_entidad_cap([cap(Id, Nom, Obj, H, FI, FC)|R]) -->
    html(tr([td(Id), td(Nom), td(Obj), td(H), td(FI), td(FC)])),
    filas_entidad_cap(R).

% --- 7. COMISIONES (Precargadas) ---
vista_entidad_comision(_Req) :-
    findall(com(Id, Nom, Obj, Req, Est), comision(Id, Nom, Obj, Req, Est), Lista),
    layout_sistema('Comisiones Academicas (Precargadas)', [
        div(class(card), [
            h3('Catalogo de Comisiones'),
            table([
                tr([th('ID'), th('Nombre'), th('Objetivo'), th('Requisito de Perfil'), th('Estatus')]),
                \filas_entidad_comision(Lista)
            ])
        ])
    ]).

filas_entidad_comision([]) --> [].
filas_entidad_comision([com(Id, Nom, Obj, Req, Est)|R]) -->
    html(tr([td(Id), td(Nom), td(Obj), td(span(class(badge), Req)), td(Est)])),
    filas_entidad_comision(R).


% =========================================================================
% APARTADO 2: LAS 6 OPCIONES DEL USUARIO
% =========================================================================

opciones_profesores([]) --> [].
opciones_profesores([prof(E, N, G, Esp)|R]) -->
    { format(atom(Label), '#~w - ~w (~w | Esp: ~w)', [E, N, G, Esp]) },
    html(option([value(E)], Label)),
    opciones_profesores(R).

opciones_items([]) --> [].
opciones_items([item(Id, Desc)|R]) -->
    { format(atom(Label), '~w - ~w', [Id, Desc]) },
    html(option([value(Id)], Label)),
    opciones_items(R).

% --- OPCION 1 ---
vista_op1_academia(_Req) :-
    findall(prof(E, N, G, Esp), profesor(E, N, G, Esp, _), LProf),
    findall(item(Id, Nom), academia(Id, Nom, _, _), LAcad),
    findall(asig(E, A), asignacion_academia(E, A), LAsig),
    layout_sistema('1. Asignar profesores a academias de acuerdo a su perfil de estudios y capacitacion', [
        div(class(card), [
            h3('Formulario de Asignacion a Academia'),
            form([action('/operacion/asignar_academia'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('Profesor:'), select([name(empleado), required(required)], \opciones_profesores(LProf))]),
                    div(class('form-group'), [label('Academia:'), select([name(academia), required(required)], \opciones_items(LAcad))])
                ]),
                button([type(submit)], 'Asignar Profesor a Academia')
            ])
        ]),
        div(class(card), [
            h3('Asignaciones Registradas en Academias'),
            table([
                tr([th('# Empleado'), th('Profesor'), th('ID Academia'), th('Nombre de Academia')]),
                \filas_asig_academia(LAsig)
            ])
        ])
    ]).

filas_asig_academia([]) --> [].
filas_asig_academia([asig(E, A)|R]) -->
    { (profesor(E, NomP, _, _, _) -> true ; NomP = '-'), (academia(A, NomA, _, _) -> true ; NomA = '-') },
    html(tr([td(E), td(NomP), td(A), td(NomA)])),
    filas_asig_academia(R).

% --- OPCION 2 ---
vista_op2_ca(_Req) :-
    findall(prof(E, N, G, Esp), profesor(E, N, G, Esp, _), LProf),
    findall(item(Id, Nom), cuerpo_academico(Id, Nom, _, _, _), LCA),
    findall(asig(E, C), asignacion_ca(E, C), LAsig),
    layout_sistema('2. Asignar profesores a cuerpos academicos de acuerdo a su perfil de estudios y capacitacion', [
        div(class(card), [
            h3('Formulario de Asignacion a Cuerpo Academico'),
            form([action('/operacion/asignar_ca'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('Profesor:'), select([name(empleado), required(required)], \opciones_profesores(LProf))]),
                    div(class('form-group'), [label('Cuerpo Academico:'), select([name(ca), required(required)], \opciones_items(LCA))])
                ]),
                button([type(submit)], 'Asignar Profesor a Cuerpo Academico')
            ])
        ]),
        div(class(card), [
            h3('Asignaciones Registradas en Cuerpos Academicos'),
            table([
                tr([th('# Empleado'), th('Profesor'), th('ID Cuerpo Academico'), th('Nombre del CA')]),
                \filas_asig_ca(LAsig)
            ])
        ])
    ]).

filas_asig_ca([]) --> [].
filas_asig_ca([asig(E, C)|R]) -->
    { (profesor(E, NomP, _, _, _) -> true ; NomP = '-'), (cuerpo_academico(C, NomC, _, _, _) -> true ; NomC = '-') },
    html(tr([td(E), td(NomP), td(C), td(NomC)])),
    filas_asig_ca(R).

% --- OPCION 3 ---
vista_op3_proyecto(_Req) :-
    findall(prof(E, N, G, Esp), profesor(E, N, G, Esp, _), LProf),
    findall(item(Id, Nom), proyecto(Id, Nom, _, _, _, _, _, _), LProy),
    findall(asig(E, P), asignacion_proyecto(E, P), LAsig),
    layout_sistema('3. Asignar profesores a proyectos de acuerdo a su perfil de estudios y capacitacion', [
        div(class(card), [
            h3('Formulario de Asignacion a Proyecto'),
            form([action('/operacion/asignar_proyecto'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('Profesor:'), select([name(empleado), required(required)], \opciones_profesores(LProf))]),
                    div(class('form-group'), [label('Proyecto:'), select([name(proyecto), required(required)], \opciones_items(LProy))])
                ]),
                button([type(submit)], 'Asignar Profesor a Proyecto')
            ])
        ]),
        div(class(card), [
            h3('Asignaciones Registradas en Proyectos'),
            table([
                tr([th('# Empleado'), th('Profesor'), th('ID Proyecto'), th('Nombre del Proyecto')]),
                \filas_asig_proy(LAsig)
            ])
        ])
    ]).

filas_asig_proy([]) --> [].
filas_asig_proy([asig(E, P)|R]) -->
    { (profesor(E, NomP, _, _, _) -> true ; NomP = '-'), (proyecto(P, NomPr, _, _, _, _, _, _) -> true ; NomPr = '-') },
    html(tr([td(E), td(NomP), td(P), td(NomPr)])),
    filas_asig_proy(R).

% --- OPCION 4 ---
vista_op4_curso(_Req) :-
    findall(prof(E, N, G, Esp), profesor(E, N, G, Esp, _), LProf),
    findall(item(Id, Nom), curso(Id, _, Nom, _, _), LCur),
    findall(asig(E, C), asignacion_curso(E, C), LAsig),
    layout_sistema('4. Asignar al mejor profesor a un curso de acuerdo a su perfil de estudios y capacitacion', [
        div(class(card), [
            h3('Asignar Automaticamente al MEJOR Profesor para un Curso'),
            form([action('/operacion/mejor_profesor'), method('POST')], [
                div(class('form-group'), [
                    label('Curso:'),
                    select([name(curso), required(required)], \opciones_items(LCur))
                ]),
                button([type(submit)], 'Seleccionar y Asignar al Mejor Profesor')
            ])
        ]),
        div(class(card), [
            h3('Asignacion Manual con Validacion de Dominio (Ej. Rechazar si no domina el curso)'),
            form([action('/operacion/asignar_curso'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('Profesor:'), select([name(empleado), required(required)], \opciones_profesores(LProf))]),
                    div(class('form-group'), [label('Curso:'), select([name(curso), required(required)], \opciones_items(LCur))])
                ]),
                button([type(submit)], 'Validar y Asignar Curso')
            ])
        ]),
        div(class(card), [
            h3('Cursos Asignados'),
            table([
                tr([th('# Empleado'), th('Profesor'), th('ID Curso'), th('Nombre del Curso')]),
                \filas_asig_curso(LAsig)
            ])
        ])
    ]).

filas_asig_curso([]) --> [].
filas_asig_curso([asig(E, C)|R]) -->
    { (profesor(E, NomP, _, _, _) -> true ; NomP = '-'), (curso(C, _, NomC, _, _) -> true ; NomC = '-') },
    html(tr([td(E), td(NomP), td(C), td(NomC)])),
    filas_asig_curso(R).

% --- OPCION 5 ---
vista_op5_capacitacion(_Req) :-
    findall(prof(E, N, G, Esp), profesor(E, N, G, Esp, _), LProf),
    findall(item(Id, Desc), (curso_capacitacion(Id, Nom, Obj, H, _, _), format(atom(Desc), '~w (~w hrs | Obj: ~w)', [Nom, H, Obj])), LCap),
    findall(asig(E, Cap), asignacion_capacitacion(E, Cap), LAsig),
    layout_sistema('5. Asignar profesores a cursos de capacitacion de acuerdo a su perfil de estudios y capacitacion', [
        div(class(card), [
            h3('Formulario de Asignacion a Curso de Capacitacion'),
            form([action('/operacion/asignar_capacitacion'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('Profesor:'), select([name(empleado), required(required)], \opciones_profesores(LProf))]),
                    div(class('form-group'), [label('Curso de Capacitacion:'), select([name(capacitacion), required(required)], \opciones_items(LCap))])
                ]),
                button([type(submit)], 'Asignar Profesor a Curso de Capacitacion')
            ])
        ]),
        div(class(card), [
            h3('Profesores Asignados a Cursos de Capacitacion'),
            table([
                tr([th('# Empleado'), th('Profesor'), th('ID Capacitacion'), th('Nombre de Capacitacion')]),
                \filas_asig_cap(LAsig)
            ])
        ])
    ]).

filas_asig_cap([]) --> [].
filas_asig_cap([asig(E, Cap)|R]) -->
    { (profesor(E, NomP, _, _, _) -> true ; NomP = '-'), (curso_capacitacion(Cap, NomC, _, _, _, _) -> true ; NomC = '-') },
    html(tr([td(E), td(NomP), td(Cap), td(NomC)])),
    filas_asig_cap(R).

% --- OPCION 6 ---
vista_op6_buscar(Req) :-
    findall(prof(E, N, G, Esp), profesor(E, N, G, Esp, _), LProf),
    http_parameters(Req, [empleado(EmpBuscado, [integer, default(0)])]),
    (   EmpBuscado > 0, obtener_expediente_profesor(EmpBuscado, Dict)
    ->  BloqueResultado = \render_expediente(Dict)
    ;   EmpBuscado > 0
    ->  BloqueResultado = div(class('alert-err'), 'Profesor no encontrado.')
    ;   BloqueResultado = p('Selecciona un profesor para consultar todas sus asignaciones y control de estudios.')
    ),
    layout_sistema('6. Buscar un profesor y sus asignaciones', [
        div(class(card), [
            h3('Buscar Profesor'),
            form([action('/opcion/op6_buscar'), method('GET')], [
                div(class('form-group'), [
                    label('Profesor:'),
                    select([name(empleado), required(required)], \opciones_profesores(LProf))
                ]),
                button([type(submit)], 'Buscar Profesor y sus Asignaciones')
            ])
        ]),
        BloqueResultado
    ]).

render_expediente(Dict) -->
    {
        atomic_list_concat(Dict.acreditaciones, ', ', SAc),
        atomic_list_concat(Dict.cursos_que_domina, ' > ', SCurDom),
        atomic_list_concat(Dict.asignaciones.academias, ', ', SAcad),
        atomic_list_concat(Dict.asignaciones.cuerpos_academicos, ', ', SCA),
        atomic_list_concat(Dict.asignaciones.proyectos, ', ', SProy),
        atomic_list_concat(Dict.asignaciones.cursos_a_impartir, ', ', SCurImp),
        atomic_list_concat(Dict.asignaciones.capacitaciones_tomadas, ', ', SCapTom),
        atomic_list_concat(Dict.asignaciones.capacitaciones_asignadas, ', ', SCapAsig),
        atomic_list_concat(Dict.asignaciones.comisiones, ', ', SCom)
    },
    html(div(class(card), [
        h3(['Expediente y Asignaciones de: ', Dict.nombre, ' (#', Dict.num_empleado, ')']),
        table([
            tr([th('Rubro'), th('Informacion Registrada')]),
            tr([td(b('Grado Academico')), td(Dict.grado_maximo)]),
            tr([td(b('Especialidad')), td(Dict.especialidad)]),
            tr([td(b('Estudios de Licenciatura')), td(Dict.estudios.licenciatura)]),
            tr([td(b('Estudios de Maestria')), td(Dict.estudios.maestria)]),
            tr([td(b('Estudios de Doctorado')), td(Dict.estudios.doctorado)]),
            tr([td(b('Acreditaciones')), td(SAc)]),
            tr([td(b('Cursos que Domina (Mayor a Menor)')), td(SCurDom)]),
            tr([td(b('Cursos de Capacitacion Tomados')), td(SCapTom)]),
            tr([td(b('Academias Asignadas')), td(SAcad)]),
            tr([td(b('Cuerpos Academicos Asignados')), td(SCA)]),
            tr([td(b('Proyectos Asignados')), td(SProy)]),
            tr([td(b('Comisiones Asignadas')), td(SCom)]),
            tr([td(b('Cursos a Impartir Asignados')), td(SCurImp)]),
            tr([td(b('Cursos de Capacitacion Asignados')), td(SCapAsig)])
        ])
    ])).

% --- OPCION EXTRA: COMISIONES ---
vista_op_comision(_Req) :-
    findall(prof(E, N, G, Esp), profesor(E, N, G, Esp, _), LProf),
    findall(item(Id, Desc), (comision(Id, Nom, _, Req, _), format(atom(Desc), '~w (Req: ~w)', [Nom, Req])), LCom),
    findall(asig(E, Com), asignacion_comision(E, Com), LAsig),
    layout_sistema('Asignar Profesores a Comisiones', [
        div(class(card), [
            h3('Formulario de Asignacion a Comision'),
            form([action('/operacion/asignar_comision'), method('POST')], [
                div(class('form-grid'), [
                    div(class('form-group'), [label('Profesor:'), select([name(empleado), required(required)], \opciones_profesores(LProf))]),
                    div(class('form-group'), [label('Comision:'), select([name(comision), required(required)], \opciones_items(LCom))])
                ]),
                button([type(submit)], 'Asignar a Comision')
            ])
        ]),
        div(class(card), [
            h3('Comisiones Asignadas'),
            table([
                tr([th('# Empleado'), th('Profesor'), th('ID Comision')]),
                \filas_asig_com(LAsig)
            ])
        ])
    ]).

filas_asig_com([]) --> [].
filas_asig_com([asig(E, Com)|R]) -->
    { (profesor(E, NomP, _, _, _) -> true ; NomP = '-') },
    html(tr([td(E), td(NomP), td(Com)])),
    filas_asig_com(R).


% =========================================================================
% HANDLERS DE RESPUESTA
% =========================================================================
responder_operacion(Titulo, Estatus, Mensaje, RutaRetorno) :-
    (Estatus == exito -> ClaseAlerta = 'alert-ok' ; ClaseAlerta = 'alert-err'),
    layout_sistema(Titulo, [
        div(class(ClaseAlerta), [
            h3('Respuesta del Sistema:'),
            p(b(Mensaje))
        ]),
        a([href(RutaRetorno)], button([type(button)], '<< Regresar'))
    ]).

handle_alta_profesor(Req) :-
    http_parameters(Req, [
        empleado(Emp, [integer]), nombre(Nom, [atom]), grado(Grado, [atom]),
        especialidad(Esp, [atom]), cursos(CursosStr, [string]),
        lic(Lic, [atom]), mae(Mae, [atom]), doc(Doc, [atom]),
        acreditaciones(AcredStr, [string, default("")]),
        cap_tomadas(CapStr, [string, default("")])
    ]),
    alta_profesor(Emp, Nom, Grado, Esp, CursosStr, Lic, Mae, Doc, AcredStr, CapStr, Msg),
    responder_operacion('Registro de Profesor', exito, Msg, '/entidad/profesor').

handle_alta_ca(Req) :-
    http_parameters(Req, [
        id(Id, [atom]), nombre(Nom, [atom]), linea(Linea, [atom]),
        lider(Lider, [integer]), estatus(Est, [atom])
    ]),
    alta_ca(Id, Nom, Linea, Lider, Est, Msg),
    responder_operacion('Registro de Cuerpo Academico', exito, Msg, '/entidad/cuerpo_academico').

handle_alta_academia(Req) :-
    http_parameters(Req, [
        id(Id, [atom]), nombre(Nom, [atom]), materias(MatStr, [string]),
        lider(Lider, [integer])
    ]),
    alta_academia(Id, Nom, MatStr, Lider, Msg),
    responder_operacion('Registro de Academia', exito, Msg, '/entidad/academia').

handle_alta_proyecto(Req) :-
    http_parameters(Req, [
        id(Id, [atom]), nombre(Nom, [atom]), objetivo(Obj, [atom]),
        entregables(EntStr, [string]), lider(Lider, [integer]),
        integrantes(IntStr, [string]), inicio(FIni, [atom]),
        entrega(FEnt, [atom])
    ]),
    alta_proyecto(Id, Nom, Obj, EntStr, Lider, IntStr, FIni, FEnt, Msg),
    responder_operacion('Registro de Proyecto', exito, Msg, '/entidad/proyecto').

handle_alta_curso(Req) :-
    http_parameters(Req, [
        id(Id, [atom]), creditos(Cred, [integer]), nombre(Nom, [atom]),
        objetivo(Obj, [atom]), academia(Acad, [atom])
    ]),
    alta_curso(Id, Cred, Nom, Obj, Acad, Msg),
    responder_operacion('Registro de Curso', exito, Msg, '/entidad/curso').

handle_alta_capacitacion(Req) :-
    http_parameters(Req, [
        id(Id, [atom]), nombre(Nom, [atom]), objetivo(Obj, [atom]),
        horas(Horas, [integer]), inicio(FIni, [atom]), fin(FFin, [atom])
    ]),
    alta_capacitacion(Id, Nom, Obj, Horas, FIni, FFin, Msg),
    responder_operacion('Registro de Curso de Capacitacion', exito, Msg, '/entidad/capacitacion').

handle_op_academia(Req) :-
    http_parameters(Req, [empleado(Emp, [integer]), academia(Acad, [atom])]),
    registrar_en_academia(Emp, Acad, Estatus, Msg),
    responder_operacion('1. Asignacion a Academia', Estatus, Msg, '/opcion/op1_academia').

handle_op_ca(Req) :-
    http_parameters(Req, [empleado(Emp, [integer]), ca(CA, [atom])]),
    registrar_en_ca(Emp, CA, Estatus, Msg),
    responder_operacion('2. Asignacion a Cuerpo Academico', Estatus, Msg, '/opcion/op2_ca').

handle_op_proyecto(Req) :-
    http_parameters(Req, [empleado(Emp, [integer]), proyecto(Proy, [atom])]),
    registrar_en_proyecto(Emp, Proy, Estatus, Msg),
    responder_operacion('3. Asignacion a Proyecto', Estatus, Msg, '/opcion/op3_proyecto').

handle_op_curso(Req) :-
    http_parameters(Req, [empleado(Emp, [integer]), curso(Cur, [atom])]),
    registrar_en_curso(Emp, Cur, Estatus, Msg),
    responder_operacion('4. Asignacion a Curso', Estatus, Msg, '/opcion/op4_curso').

handle_op_mejor_profesor(Req) :-
    http_parameters(Req, [curso(Cur, [atom])]),
    registrar_mejor_profesor_curso(Cur, Estatus, Msg),
    responder_operacion('4. Mejor Profesor para Curso', Estatus, Msg, '/opcion/op4_curso').

handle_op_capacitacion(Req) :-
    http_parameters(Req, [empleado(Emp, [integer]), capacitacion(Cap, [atom])]),
    registrar_en_capacitacion(Emp, Cap, Estatus, Msg),
    responder_operacion('5. Asignacion a Curso de Capacitacion', Estatus, Msg, '/opcion/op5_capacitacion').

handle_op_comision(Req) :-
    http_parameters(Req, [empleado(Emp, [integer]), comision(Com, [atom])]),
    registrar_en_comision(Emp, Com, Estatus, Msg),
    responder_operacion('Asignacion a Comision', Estatus, Msg, '/opcion/extra_comision').