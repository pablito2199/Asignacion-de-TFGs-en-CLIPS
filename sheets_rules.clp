; PLANTILLAS
; Plantilla de Alumno
(deftemplate Alumno
    (field Id)                     ; DNI del alumno
    (multifield Nombre)            ; Nombre del alumno
    (field Expediente (default 0)) ; Nota media del alumno durante la carrera
    (field Entrevista (default 0)) ; Prioridad obtenida durante la entrevista
    (field Asignacion)             ; TFG que se le ha sido asignado
)

; Plantilla de TFG
(deftemplate TFG
    (field Id)                                                                                          ; Numero identificativo del TFG
    (field NumeroAsignaciones (default 1))                                                              ; Plazas disponibles para participar en el TFG
	(multifield Titulo)                                                                                 ; Titulo del TFG
    (multifield Tutoria)                                                                                ; Profesores encargados de dirigir el TFG
    (multifield Descripcion)                                                                            ; Breve descripcion del contenido del TFG
    (multifield Requisitos)                                                                             ; Requisitos para poder realizar el TFG
    (field Tipo (type SYMBOL) (allowed-symbols A B C) (default A))                                      ; Tipo del TFG: Puede ser A, B o C (por defecto A)
    (field MetodoAsignacion (type SYMBOL) (allowed-symbols Expediente Entrevista) (default Expediente)) ; Metodo de asignacion del TFG; Puede ser Expediente o Entrevista (por defecto Expediente)
    (field PlazasUsadas (default 0))                                                                    ; Plazas que han sido asignadas hasta el momento de este TFG
)

; REGLAS
; Asignacion de TFG pero el alumno tiene mas nota de expediente que otro (con opcion 1)
(defrule Asignacion_Opcion_1_Expediente
    (declare (salience 7))                                                                                    ; declaracion de prioridad 7 (mas alta)
    ?a <- (Alumno (Id ?dni) (Expediente ?exp) (Asignacion nil))                                               ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                                           ; comprobamos las propuestas
    ?t <- (TFG (Id ?op1) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas) (MetodoAsignacion Expediente))   ; cogemos el TFG correspondiente, comprobamos que asigne por expediente
    (test (eq ?plazas ?usadas))                                                                               ; comprobamos que esten todas sus plazas usadas
    ?asig <- (Asignacion ?otroAlumno ?opOtro)                                                                 ; cogemos una asignacion previa
    (test (eq ?opOtro ?op1))                                                                                  ; comprobamos que las opciones de la asignacion son la misma
    ?otro <- (Alumno (Id ?otroAlumno) (Expediente ?expOtroAlumno))                                            ; comprobamos los datos del otro alumno
    (test (> ?exp ?expOtroAlumno))                                                                            ; comprobamos que el expediente del alumno actual es mayor que el del otro
    =>                            
    (retract ?asig)                                                                                           ; eliminamos la antigua asignacion
    (assert (Asignacion ?dni ?op1))                                                                           ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op1))                                                                             ; asignamos el TFG al alumno
    (modify ?otro (Asignacion nil))                                                                           ; modificamos el otro alumno para indicar que vuelve a estar sin asignacion
	(printout t "(-) Retirado TFG " ?op1 " a " ?otroAlumno ". Motivo: Expediente de otro alumno mejor." crlf)
	(printout t "(+) Asignado TFG " ?op1 " a " ?dni ". Es su opcion 1." crlf crlf)
)

; Asignacion de TFG pero el alumno tiene mas nota de entrevista que otro (con opcion 1)
(defrule Asignacion_Opcion_1_Entrevista
    (declare (salience 7))                                                                                    ; declaracion de prioridad 7 (mas alta)
    ?a <- (Alumno (Id ?dni) (Entrevista ?ent) (Asignacion nil))                                               ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                                           ; comprobamos las propuestas
    ?t <- (TFG (Id ?op1) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas) (MetodoAsignacion Entrevista))   ; cogemos el TFG correspondiente, comprobamos que asigne por entrevista
    (test (eq ?plazas ?usadas))                                                                               ; comprobamos que esten todas sus plazas usadas
    ?asig <- (Asignacion ?otroAlumno ?opOtro)                                                                 ; cogemos una asignacion previa
    (test (eq ?opOtro ?op1))                                                                                  ; comprobamos que las opciones de la asignacion son la misma
    ?otro <- (Alumno (Id ?otroAlumno) (Entrevista ?entOtroAlumno))                                            ; comprobamos los datos del otro alumno
    (test (> ?ent ?entOtroAlumno))                                                                            ; comprobamos que la nota de entrevista del alumno actual es mayor que el del otro
    =>                            
    (retract ?asig)                                                                                           ; eliminamos la antigua asignacion
    (assert (Asignacion ?dni ?op1))                                                                           ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op1))                                                                             ; asignamos el TFG al alumno
    (modify ?otro (Asignacion nil))                                                                           ; modificamos el otro alumno para indicar que vuelve a estar sin asignacion
	(printout t "(-) Retirado TFG " ?op1 " a " ?otroAlumno ". Motivo: Entrevista de otro alumno mejor." crlf)
	(printout t "(+) Asignado TFG " ?op1 " a " ?dni ". Es su opcion 1." crlf crlf)
)

; Asignacion de TFG opcion 1 al alumno sin tener en cuenta notas
(defrule Asignacion_Opcion_1_Sin_Criterio
    (declare (salience 6))                                                         ; declaracion de prioridad 6
    ?a <- (Alumno (Id ?dni) (Asignacion nil))                                      ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                ; comprobamos las propuestas
    ?t <- (TFG (Id ?op1) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas))      ; cogemos el TFG correspondiente
    (test (neq ?plazas ?usadas))                                                   ; comprobamos que no esten todas sus plazas usadas
    =>     
    (assert (Asignacion ?dni ?op1))                                                ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op1))                                                  ; asignamos el TFG al alumno
    (modify ?t (PlazasUsadas (+ ?usadas 1)))                                       ; aumentamos el numero de plazas usadas en el TFG
	(printout t "(+) Asignado TFG " ?op1 " a " ?dni ". Es su opcion 1." crlf crlf)
)

; Asignacion de TFG pero el alumno tiene mas nota de expediente que otro (con opcion 2)
(defrule Asignacion_Opcion_2_Expediente
    (declare (salience 5))                                                                                    ; declaracion de prioridad 5
    ?a <- (Alumno (Id ?dni) (Expediente ?exp) (Asignacion nil))                                               ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                                           ; comprobamos las propuestas
    ?t <- (TFG (Id ?op2) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas) (MetodoAsignacion Expediente))   ; cogemos el TFG correspondiente, comprobamos que asigne por expediente
    (test (eq ?plazas ?usadas))                                                                               ; comprobamos que esten todas sus plazas usadas
    ?asig <- (Asignacion ?otroAlumno ?opOtro)                                                                 ; cogemos una asignacion previa
    (test (eq ?opOtro ?op2))                                                                                  ; comprobamos que las opciones de la asignacion son la misma
    ?otro <- (Alumno (Id ?otroAlumno) (Expediente ?expOtroAlumno))                                            ; comprobamos los datos del otro alumno
    (test (> ?exp ?expOtroAlumno))                                                                            ; comprobamos que el expediente del alumno actual es mayor que el del otro
    =>                            
    (retract ?asig)                                                                                           ; eliminamos la antigua asignacion
    (assert (Asignacion ?dni ?op2))                                                                           ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op2))                                                                             ; asignamos el TFG al alumno
    (modify ?otro (Asignacion nil))                                                                           ; modificamos el otro alumno para indicar que vuelve a estar sin asignacion
	(printout t "(-) Retirado TFG " ?op2 " a " ?otroAlumno ". Motivo: Expediente de otro alumno mejor." crlf)
	(printout t "(+) Asignado TFG " ?op2 " a " ?dni ". Es su opcion 2." crlf crlf)
)

; Asignacion de TFG pero el alumno tiene mas nota de entrevista que otro (con opcion 2)
(defrule Asignacion_Opcion_2_Entrevista
    (declare (salience 5))                                                                                    ; declaracion de prioridad 5
    ?a <- (Alumno (Id ?dni) (Entrevista ?ent) (Asignacion nil))                                               ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                                           ; comprobamos las propuestas
    ?t <- (TFG (Id ?op2) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas) (MetodoAsignacion Entrevista))   ; cogemos el TFG correspondiente, comprobamos que asigne por entrevista
    (test (eq ?plazas ?usadas))                                                                               ; comprobamos que esten todas sus plazas usadas
    ?asig <- (Asignacion ?otroAlumno ?opOtro)                                                                 ; cogemos una asignacion previa
    (test (eq ?opOtro ?op2))                                                                                  ; comprobamos que las opciones de la asignacion son la misma
    ?otro <- (Alumno (Id ?otroAlumno) (Entrevista ?entOtroAlumno))                                            ; comprobamos los datos del otro alumno
    (test (> ?ent ?entOtroAlumno))                                                                            ; comprobamos que la nota de entrevista del alumno actual es mayor que el del otro
    =>                            
    (retract ?asig)                                                                                           ; eliminamos la antigua asignacion
    (assert (Asignacion ?dni ?op2))                                                                           ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op2))                                                                             ; asignamos el TFG al alumno
    (modify ?otro (Asignacion nil))                                                                           ; modificamos el otro alumno para indicar que vuelve a estar sin asignacion
	(printout t "(-) Retirado TFG " ?op2 " a " ?otroAlumno ". Motivo: Entrevista de otro alumno mejor." crlf)
	(printout t "(+) Asignado TFG " ?op2 " a " ?dni ". Es su opcion 2." crlf crlf)
)

; Asignacion de TFG opcion 2 al alumno sin tener en cuenta notas
(defrule Asignacion_Opcion_2_Sin_Criterio
    (declare (salience 4))                                                         ; declaracion de prioridad 4
    ?a <- (Alumno (Id ?dni) (Asignacion nil))                                      ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                ; comprobamos las propuestas
    ?t <- (TFG (Id ?op2) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas))      ; cogemos el TFG correspondiente
    (test (neq ?plazas ?usadas))                                                   ; comprobamos que no esten todas sus plazas usadas
    =>     
    (assert (Asignacion ?dni ?op2))                                                ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op2))                                                  ; asignamos el TFG al alumno
    (modify ?t (PlazasUsadas (+ ?usadas 1)))                                       ; aumentamos el numero de plazas usadas en el TFG
	(printout t "(+) Asignado TFG " ?op2 " a " ?dni ". Es su opcion 2." crlf crlf)
)

; Asignacion de TFG pero el alumno tiene mas nota de expediente que otro (con opcion 3)
(defrule Asignacion_Opcion_3_Expediente
    (declare (salience 3))                                                                                    ; declaracion de prioridad 3
    ?a <- (Alumno (Id ?dni) (Expediente ?exp) (Asignacion nil))                                               ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                                           ; comprobamos las propuestas
    ?t <- (TFG (Id ?op3) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas) (MetodoAsignacion Expediente))   ; cogemos el TFG correspondiente, comprobamos que asigne por expediente
    (test (eq ?plazas ?usadas))                                                                               ; comprobamos que esten todas sus plazas usadas
    ?asig <- (Asignacion ?otroAlumno ?opOtro)                                                                 ; cogemos una asignacion previa
    (test (eq ?opOtro ?op3))                                                                                  ; comprobamos que las opciones de la asignacion son la misma
    ?otro <- (Alumno (Id ?otroAlumno) (Expediente ?expOtroAlumno))                                            ; comprobamos los datos del otro alumno
    (test (> ?exp ?expOtroAlumno))                                                                            ; comprobamos que el expediente del alumno actual es mayor que el del otro
    =>                           
    (retract ?asig)                                                                                           ; eliminamos la antigua asignacion
    (assert (Asignacion ?dni ?op3))                                                                           ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op3))                                                                             ; asignamos el TFG al alumno
    (modify ?otro (Asignacion nil))                                                                           ; modificamos el otro alumno para indicar que vuelve a estar sin asignacion
	(printout t "(-) Retirado TFG " ?op3 " a " ?otroAlumno ". Motivo: Expediente de otro alumno mejor." crlf)
	(printout t "(+) Asignado TFG " ?op3 " a " ?dni ". Es su opcion 3." crlf crlf)
)

; Asignacion de TFG pero el alumno tiene mas nota de entrevista que otro (con opcion 3)
(defrule Asignacion_Opcion_3_Entrevista
    (declare (salience 3))                                                                                    ; declaracion de prioridad 3
    ?a <- (Alumno (Id ?dni) (Entrevista ?ent) (Asignacion nil))                                               ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                                           ; comprobamos las propuestas
    ?t <- (TFG (Id ?op3) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas) (MetodoAsignacion Entrevista))   ; cogemos el TFG correspondiente, comprobamos que asigne por entrevista
    (test (eq ?plazas ?usadas))                                                                               ; comprobamos que esten todas sus plazas usadas
    ?asig <- (Asignacion ?otroAlumno ?opOtro)                                                                 ; cogemos una asignacion previa
    (test (eq ?opOtro ?op3))                                                                                  ; comprobamos que las opciones de la asignacion son la misma
    ?otro <- (Alumno (Id ?otroAlumno) (Entrevista ?entOtroAlumno))                                            ; comprobamos los datos del otro alumno
    (test (> ?ent ?entOtroAlumno))                                                                            ; comprobamos que la nota de entrevista del alumno actual es mayor que el del otro
    =>                               
    (retract ?asig)                                                                                           ; eliminamos la antigua asignacion
    (assert (Asignacion ?dni ?op3))                                                                           ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op3))                                                                             ; asignamos el TFG al alumno
    (modify ?otro (Asignacion nil))                                                                           ; modificamos el otro alumno para indicar que vuelve a estar sin asignacion
	(printout t "(-) Retirado TFG " ?op3 " a " ?otroAlumno ". Motivo: Entrevista de otro alumno mejor." crlf)
	(printout t "(+) Asignado TFG " ?op3 " a " ?dni ". Es su opcion 3." crlf crlf)
)

; Asignacion de TFG opcion 3 al alumno sin tener en cuenta notas
(defrule Asignacion_Opcion_3_Sin_Criterio
    (declare (salience 2))                                                         ; declaracion de prioridad 2
    ?a <- (Alumno (Id ?dni) (Asignacion nil))                                      ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    (Propuesta ?dni ?op1 ?op2 ?op3)                                                ; comprobamos las propuestas
    ?t <- (TFG (Id ?op3) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas))      ; cogemos el TFG correspondiente
    (test (neq ?plazas ?usadas))                                                   ; comprobamos que no esten todas sus plazas usadas
    =>     
    (assert (Asignacion ?dni ?op3))                                                ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op3))                                                  ; asignamos el TFG al alumno
    (modify ?t (PlazasUsadas (+ ?usadas 1)))                                       ; aumentamos el numero de plazas usadas en el TFG
	(printout t "(+) Asignado TFG " ?op3 " a " ?dni ". Es su opcion 3." crlf crlf)
)

; Asignacion de TFG a aquellos alumnos cuya propuesta no puede ser aceptada porque no cumplen suficiente nota de expediente o entrevista
; En este caso se asigna por orden de llegada de la propuesta (no se tienen en cuenta las notas)
(defrule Asignacion_Ninguna_Opcion_Disponible
    (declare (salience 1))                                                     ; declaracion de prioridad 1
    ?a <- (Alumno (Id ?dni) (Asignacion nil))                                  ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    ?t <- (TFG (Id ?op) (NumeroAsignaciones ?plazas) (PlazasUsadas ?usadas))   ; cogemos el TFG correspondiente
    (test (neq ?plazas ?usadas))                                               ; comprobamos que no esten todas sus plazas usadas
    => 
    (assert (Asignacion ?dni ?op))                                             ; insertamos una nueva asignacion
    (modify ?a (Asignacion ?op))                                               ; asignamos el TFG al alumno
    (modify ?t (PlazasUsadas (+ ?usadas 1)))                                   ; aumentamos el numero de plazas usadas en el TFG
	(printout t "(+) Asignado TFG " ?op " a " ?dni " por descarte." crlf crlf)
)

; Si no hay suficientes propuestas, habrá alumnos que queden sin TFG asignado
(defrule Sin_TFG
    (declare (salience 0))                                                                                         ; declaracion de prioridad 0
    ?a <- (Alumno (Id ?dni) (Asignacion nil))                                                                      ; cogemos los datos del alumno, comprobamos que aun no tenga asignacion
    =>
	(printout t "## El alumno " ?dni " se ha quedado sin TFG por no existir suficientes propuestas. ##" crlf crlf)
)

; Cuando no existan mas alumnos a los que asignar TFGs, eliminamos los hechos auxiliares utilizados
(defrule Eliminar_Asignacion
    (declare (salience -1)) ; declaracion de prioridad -1 (mas baja)
    ?a <- (Asignacion ? ?)  ; cogemos cada asignacion
    =>
    (retract ?a)            ; eliminamos la asignacion de la base de hechos
)

; FUNCIONES
; Funcion que permite introducir un alumno a la vez que su preferencia de propuestas en la base de hechos
(deffunction alumno-propuesta ()
    ; Solicitud y almacenamiento de los datos en variables (lectura de teclado)
	(printout t "Introduzca el DNI del alumno: ")
	(bind ?id (read))
	(printout t "Introduzca el nombre del alumno: ")
	(bind ?nombre (read))
	(printout t "Introduzca el expediente del alumno: ")
	(bind ?expediente (read))
	(printout t "Introduzca la prioridad en entrevista del alumno: ")
	(bind ?entrevista (read))
	(printout t "Introduzca la primera opcion de propuesta del alumno: ")
	(bind ?op1 (read))
	(printout t "Introduzca la segunda opcion de propuesta del alumno: ")
	(bind ?op2 (read))
	(printout t "Introduzca la tercera opcion de propuesta del alumno: ")
	(bind ?op3 (read))
    
    ; Introduccion de los hechos en la base de hechos
    (assert (Alumno (Id ?id) (Nombre ?nombre) (Expediente ?expediente) (Entrevista ?entrevista)))
    (assert (Propuesta ?id ?op1 ?op2 ?op3))
	(return TRUE) ; Devuelve TRUE cuando se ha terminado de introducir al alumno y la propuesta
)                                                               

; Funcion que permite introducir nuevos TFGs en la base de hechos
(deffunction TFG ()
    ; Solicitud y almacenamiento de los datos en variables (lectura de teclado)
	(printout t "Introduzca el id del TFG: ")
	(bind ?id (read))
	(printout t "Introduzca el numero de plazas disponibles para el TFG: ")
	(bind ?numeroPlazas (read))
	(printout t "Introduzca el titulo del TFG: ")
	(bind ?titulo (read))
	(printout t "Introduzca la tutoria del TFG: ")
	(bind ?tutoria (read))
	(printout t "Introduzca la descripcion del TFG: ")
	(bind ?descripcion (read))
	(printout t "Introduzca los requisitos para poder realizar el TFG: ")
	(bind ?requisitos (read))
	(printout t "Introduzca el tipo de TFG (A, B, C): ")
	(bind ?tipo (read))
	(printout t "Introduzca el metodo de asignacion del TFG (Expediente, Entrevista): ")
	(bind ?metodoAsignacion (read))
    
    ; Introduccion del hecho en la base de hechos
    (assert 
        (TFG (Id ?id) (NumeroAsignaciones ?numeroPlazas) (Titulo ?titulo) (Tutoria ?tutoria) (Descripcion ?descripcion) 
            (Requisitos ?requisitos) (Tipo ?tipo) (MetodoAsignacion ?metodoAsignacion)
        )
    )
	(return TRUE) ; Devuelve TRUE cuando se ha terminado de introducir el TFG
)