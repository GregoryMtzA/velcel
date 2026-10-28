# Diagnóstico de cortes — 26/10/2026

Se revisaron el código actual de `velcel` y la base `velcelco_prueba2026`.
No se abrió una sesión de consulta en la conexión de producción ni se ejecutaron
cambios en ella. No se modificó el código funcional de la aplicación.

El mensaje no especifica el síntoma, folio o fecha del incidente. Se investigó
el flujo de cortes de JIMÉNEZ porque ya existía el script
`tool/read_only_closure_probe.dart` dedicado a ese caso. Los hallazgos siguientes
no deben atribuirse a otro incidente sin identificarlo primero.

## Datos encontrados en la copia de pruebas

| Sucursal | Último corte cerrado | Situación observada |
| --- | ---: | --- |
| CELLSHOP JIMENEZ | 15583 | Venta de $560, gastos de $550 y neto de $10: coinciden con el corte. |
| VELCEL JIMENEZ | 15574 | Venta de $5,180, gastos de $3,023 y neto de $2,157: coinciden con el corte. |

CELLSHOP JIMENEZ también tiene el corte **15588 abierto desde el 28/05/2026**,
sin ventas asociadas. No se encontró un corte abierto para VELCEL JIMENEZ.
En ambas sucursales, las últimas ventas de esta copia son del **27/05/2026**.
Por tanto, esta copia no permite verificar un incidente posterior de JIMÉNEZ.

La comparación de todos los cortes cerrados de ambas sucursales con sus ventas
y gastos encontró una diferencia histórica:

- El corte **3029**, de CELLSHOP JIMENEZ, abrió el **17/09/2023 a las 08:34:24**
  y cerró ese día a las **19:03:00**.
- Contenía las ventas 2900 ($1,530) y 2901 ($499.80): $2,029.80 en efectivo.
  Restando $300 de gastos, su total guardado es $1,729.80.
- La venta **2918**, por **$2,220**, tiene fecha **18/09/2023** y está ligada
  a ese mismo corte cerrado.
- Al sumar ahora las tres ventas resultan $4,249.80 en efectivo y $3,949.80
  netos. La diferencia de $2,220 corresponde exactamente a la venta 2918.

Esto demuestra una asociación incompatible con las fechas guardadas. Sin logs
históricos no se puede establecer si se originó en una sesión con un folio
anterior, una modificación posterior de datos u otra operación.

## Fallos reproducidos con el código actual

Se ejecutaron los repositorios reales de Dart contra la base de pruebas.
Las lecturas de datos persistentes se hicieron dentro de transacciones de solo
lectura. Los escenarios de escritura utilizaron siete tablas temporales de
sesión, comprobadas con `SHOW CREATE TABLE`, después de revisar los cuerpos
de los procedimientos y sus llamadas anidadas. Las tablas temporales se
eliminan al cerrar cada conexión.

| Comprobación | Resultado |
| --- | --- |
| Consultar los cortes y totales reales de CELLSHOP JIMENEZ | Correcto: cerrado 15583, abierto 15588, neto $10. |
| Venta normal usando un corte cerrado | Aceptada: fallo reproducido. |
| Venta a crédito usando un corte cerrado | Aceptada: fallo reproducido. |
| Venta usando un corte inexistente | Aceptada: fallo reproducido. |
| Venta usando un corte de otra sucursal | Aceptada: fallo reproducido. |
| Apertura cuando ya existe un corte abierto para el mismo usuario y sucursal | Error SQL 1172: `Result consisted of more than one row`; la aplicación lo convierte en un error de soporte. |

Las seis pruebas pasaron porque comprueban el comportamiento actual, incluidos
los fallos reproducidos. No son pruebas que certifiquen una corrección.

## Explicación en el código y los procedimientos

`CartPageWidget` toma el identificador del corte que conserva
`CashRegisterProvider` en memoria y lo pasa a `CartState.purchase`.
`ProductsRepositoryImpl.generarVenta` transmite ese identificador a
`proCrearVenta` o `proCrearVentaPayjoi`, sin volver a consultar su estado.
Ambos procedimientos insertan `folioCorte` tal como lo reciben: no comprueban
que el corte exista, pertenezca a la sucursal y esté abierto. El esquema
inspeccionado tampoco declara una clave foránea para `folioCorte`.

Por ello, una sesión que conserve un corte anterior puede registrar ventas
contra él después de que otra sesión lo cierre. Este mecanismo se reprodujo
con tablas temporales y es compatible con la anomalía de 2023, pero no prueba
el origen histórico de aquella venta.

En la apertura, `proCorteInicio` inserta un nuevo corte y luego obtiene su
identificador con una consulta de todos los cortes abiertos del mismo usuario
y sucursal. Si ya hay uno, la consulta devuelve varias filas y provoca el
error 1172. No usa el identificador del registro recién insertado.

## Corrección a preparar una vez identificado el incidente

La venta debe validar el corte en la base dentro de la misma transacción que
la registra, coordinando el bloqueo de esa fila con el cierre del corte. Una
validación aislada en la interfaz no resuelve operaciones concurrentes.
La apertura debe impedir aperturas simultáneas para una sucursal y obtener
el identificador recién generado. También conviene que el cierre compruebe
sucursal y estado, y que la aplicación descarte el corte de la sesión al cerrar.

No se aplicaron estas correcciones ni se alteraron procedimientos.

## Validación y reproducción

Archivo: `tool/closure_diagnostic_test.dart`.

```powershell
flutter test tool/closure_diagnostic_test.dart --no-pub --reporter expanded
flutter analyze tool/closure_diagnostic_test.dart --no-pub
```

Resultado: **6 pruebas pasaron**; el análisis del archivo terminó **sin issues**.
El archivo requiere que `DB_TEST` sea exactamente `velcelco_prueba2026` y
comprueba `SELECT DATABASE()` antes de preparar cualquier escenario.
Los valores esperados corresponden a esta copia y pueden cambiar si se actualiza.
Antes de repetir las pruebas con procedimientos modificados, se debe volver a
revisar que sus tablas coincidan con las temporales que prepara el diagnóstico.

Los conteos y máximos de identificadores de las tablas persistentes consultadas
coincidieron antes y después de la ejecución completa:

| Tabla | Filas | Máximo identificador/folio |
| --- | ---: | ---: |
| reportesventas | 35,688 | 36,652 |
| cortes | 14,683 | 15,601 |
| salidasventas | 115,465 | 36,652 |
| gastos | 18,887 | 19,692 |

No se ejecutó la suite completa porque `test/widget_test.dart` contiene otra
conexión fija a `velcelco_prueba`, distinta de la base autorizada para este caso.
