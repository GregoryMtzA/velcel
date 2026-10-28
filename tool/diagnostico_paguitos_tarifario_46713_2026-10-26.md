# Revisión del folio 46713: Paguitos y Tarifario

26/10/2026. IMEI indicado: `350028031597294`.

**Con un solo celular, seleccionado correctamente en Paguitos o Tarifario,
no se reprodujo la duplicación dentro del mismo folio. Sí se reprodujo que
una venta de un celular quede sin IMEI.** No hay evidencia suficiente para
atribuir ambos síntomas a una misma causa en el folio 46713.

La hipótesis anterior de dos altas pendientes no se utiliza como explicación
de este caso. Las nuevas pruebas mantienen una sola alta durante todo el
recorrido válido. Las pruebas con cantidad 2 solo comprueban que la interfaz
rechaza seleccionar esos tipos de venta.

## Recorrido comprobado

La interfaz llama a `applyForPaguitos()` al seleccionar Paguitos o Tarifario.
Exige una sola línea, categoría `CELULARES` y cantidad 1. Se comprobó esa
restricción usando el widget real, incluyendo la selección del tipo de venta.

Después de seleccionar el tipo se llenaron los datos del crédito, enganche e
IMEI. Se probaron los métodos reales de `CartState`, el repositorio MySQL,
`proCrearVentaPayjoi` y la consulta del detalle mediante `VentasRepositoryImpl`.

| Escenario | Resultado |
| --- | --- |
| Paguitos, un celular, verificación correcta | Un folio, una línea, cantidad 1, el IMEI correcto y un registro de cliente. |
| Tarifario, un celular, verificación correcta | Mismo resultado: una sola unidad y su IMEI. |
| Error SQL durante la verificación, ambos tipos | El formulario permite continuar; se guarda cantidad 1 sin IMEI. |
| Reintentar guardar el mismo carrito, ambos tipos | Dos folios diferentes, cada uno con cantidad 1. |
| Error al insertar el IMEI después de guardar la salida | Quedan cabecera, cliente y salida de cantidad 1; falta el IMEI y la aplicación recibe error. |
| Serialización de lista IMEI vacía como en el commit HEAD | Se inserta una fila de IMEI con texto vacío; cantidad sigue en 1. |

En el recorrido correcto, el stock pasó de 5 a 4. En el reintento pasó de 5
a 3, pero con dos folios diferentes. El detalle tampoco duplicó el producto:
devolvió una línea de cantidad 1.

## Fallo comprobado que permite perder el IMEI capturado

`CartState.verifyImei()` vacía primero `cart[].imeiList`. Si el repositorio
devuelve un error, su rama `(l) {}` lo ignora y deja el indicador `error` en
falso. El campo conserva el texto escrito.

El formulario comprueba ese texto y el indicador de error, por lo que puede
validar aun cuando `imeiList` haya quedado vacía. `purchase()` arma el request
usando `imeiList`; no vuelve a verificar el IMEI antes de guardar.

Esto se reprodujo para Paguitos y Tarifario en la interfaz. También se inyectó
un error SQL real contra una columna inexistente de la tabla temporal, para
ejecutar el manejo de errores del repositorio real. **El resultado fue una
unidad sin IMEI, nunca dos unidades.** La inyección prueba el mecanismo; no
demuestra qué error, si alguno, sucedió durante la venta 46713.

Hay una diferencia relevante entre versiones del código:

- El commit local `HEAD` (`f8d0645`) usa `vr.imeis?.join(',')`. Una lista vacía
  produce `''`, que el procedimiento registra como IMEI vacío.
- El código del espacio de trabajo ya tenía una modificación que convierte
  la lista vacía en `NULL`. El procedimiento omite entonces insertar el IMEI.

No se modificó esa lógica durante este análisis. Se probó la serialización de
HEAD con una adaptación exclusivamente en la conexión de diagnóstico.

## Segundo fallo: la venta puede quedar guardada parcialmente

`proCrearVentaPayjoi` inserta cabecera y cliente y llama a `proIterarCadenas`.
Ese procedimiento inserta la salida, descuenta stock y ejecuta `COMMIT`.
Después se intenta insertar el IMEI mediante `proIterarCadena`.

Si ese último paso falla, el `ROLLBACK` exterior no revierte los datos que ya
fueron confirmados. Se reprodujo una cabecera y salida de cantidad 1 sin IMEI,
aunque el request llevaba el IMEI correcto.

Para provocar el fallo se añadió una restricción única artificial únicamente
a la tabla temporal de IMEI y se preparó un conflicto. La tabla persistente
no tiene esa restricción: esta prueba demuestra la falta de atomicidad, no
una causa concreta del incidente. Tampoco produjo cantidad 2 en el mismo folio.

## Evidencia de la copia de pruebas

Solo se utilizó `velcelco_prueba2026`. La revisión de sus 6,664 ventas de
Paguitos y una venta de Tarifario encontró **cero ventas con más de una línea
o más de una unidad**, considerando todos los productos.

Cuatro ventas de Paguitos tienen un celular con cantidad 1 y una fila de IMEI
con texto vacío, no `NULL`:

| Folio | Fecha | Producto |
| --- | --- | --- |
| 21170 | 13/11/2025 | MOTO G05 128 GB |
| 21116 | 12/11/2025 | MOTO G15 256GB |
| 21045 | 11/11/2025 | REDMI A5 64GB |
| 21042 | 11/11/2025 | REDMI A5 64GB |

Estos registros son compatibles con recibir una cadena IMEI vacía, pero no
hay logs para atribuirlos al fallo de verificación. No son la venta 46713.

No se encontraron triggers en el esquema de pruebas. `productos.nombre`
tiene clave primaria; el JOIN del detalle no multiplicó el producto en las
pruebas. No hay códigos de celulares con comas en este catálogo que expliquen
dos iteraciones del separador de productos.

La copia sigue llegando al folio **36652**; no contiene el **46713** ni el IMEI
indicado. Eso impide comprobar la estructura exacta de la duplicación, los
parámetros recibidos y la versión del procedimiento usada en el incidente.

## Validación y alcance

```powershell
flutter test tool/sale_frontend_diagnostic_test.dart tool/sale_persistence_diagnostic_test.dart --no-pub --reporter expanded --concurrency=1 --plain-name 'Credito estricto'
flutter analyze tool/sale_frontend_diagnostic_test.dart tool/sale_persistence_diagnostic_test.dart --no-pub
```

**14 pruebas específicas pasaron: seis de interfaz y ocho de persistencia.
Análisis estático sin issues.** Son diagnósticos del comportamiento actual;
no se implementó ninguna corrección.

Todas las escrituras se hicieron en ocho tablas temporales de sesión. La
conexión exige `DB_TEST = velcelco_prueba2026`, comprueba `SELECT DATABASE()`,
revisa las referencias de los procedimientos y verifica que las tablas sean
temporales. El guardado real se detiene antes de generar PDF o imprimir.

Los conteos persistentes y máximos identificadores coincidieron antes y
después: `reportesventas` 35,688 / 36,652; `salidasventas` 115,465 / 115,477;
`imeisventas` 33,421 / 33,424; `registropayjoy` 6,929 / 6,929; `imeis` 1,606;
`almacenaje` 6,105. No se abrió una sesión en producción.

Para establecer la causa de la duplicación del 46713 hace falta que ese folio
esté disponible en una copia de pruebas y contrastar sus salidas e IMEI con
la versión del código o los parámetros enviados. Con la evidencia actual,
afirmar que el flujo válido convierte cantidad 1 en 2 sería injustificado.
