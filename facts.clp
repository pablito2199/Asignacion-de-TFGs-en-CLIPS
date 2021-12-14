; BASE DE HECHOS INICIAL
(deffacts Datos
    ; Alumnos
    (Alumno (Id 00000000A) (Nombre Pablo) (Expediente 6) (Entrevista 4))
    (Alumno (Id 00000000B) (Nombre Carlos) (Expediente 3) (Entrevista 8))
    (Alumno (Id 00000000C) (Nombre Laura) (Expediente 7) (Entrevista 4))
    (Alumno (Id 00000000D) (Nombre Carla) (Expediente 3) (Entrevista 4))
    (Alumno (Id 00000000E) (Nombre Pedro) (Expediente 3) (Entrevista 4))
    (Alumno (Id 00000000F) (Nombre Daniel) (Expediente 9) (Entrevista 10))
    (Alumno (Id 00000000G) (Nombre Celia) (Expediente 9) (Entrevista 4))
    (Alumno (Id 00000000H) (Nombre Valeria) (Expediente 9) (Entrevista 4))
    (Alumno (Id 00000000I) (Nombre Marcos) (Expediente 9) (Entrevista 10))
    (Alumno (Id 00000000L) (Nombre Natalia) (Expediente 9) (Entrevista 4))

    ; TFGs
    (TFG (Id 1) (NumeroAsignaciones 1))
    (TFG (Id 2) (NumeroAsignaciones 2))
    (TFG (Id 3) (NumeroAsignaciones 1))
    (TFG (Id 4) (NumeroAsignaciones 1))
    (TFG (Id 5) (NumeroAsignaciones 1) (MetodoAsignacion Entrevista))
    (TFG (Id 6) (NumeroAsignaciones 1) (MetodoAsignacion Entrevista))
    (TFG (Id 7) (NumeroAsignaciones 1) (MetodoAsignacion Entrevista))
    (TFG (Id 8) (NumeroAsignaciones 1) (MetodoAsignacion Entrevista))

    ; Propuestas
    (Propuesta 00000000A 1 2 3)
    (Propuesta 00000000B 8 1 3)
    (Propuesta 00000000C 1 2 3)
    (Propuesta 00000000D 1 2 3)
    (Propuesta 00000000E 8 2 3)
    (Propuesta 00000000F 8 2 3)
    (Propuesta 00000000G 5 6 1)
    (Propuesta 00000000H 8 4 6)
    (Propuesta 00000000I 5 6 4)
    (Propuesta 00000000L 1 2 3)
)