# Diagnóstico de la venta 46713

> **Revisión posterior:** el usuario precisó que se seleccionó Paguitos con un
> solo celular y sin agregar otro después. Las hipótesis de altas repetidas de
> este primer informe no explican ese recorrido. La conclusión vigente y las
> nuevas pruebas están en
> [la revisión de Paguitos y Tarifario](diagnostico_paguitos_tarifario_46713_2026-10-26.md).

Fecha: 26/10/2026. IMEI proporcionado: `350028031597294`.

**Se reprodujo una secuencia en el frontend que permite enviar una sola venta
con cantidad 2 y sin IMEI, aunque se haya capturado un solo IMEI.** Los
procedimientos de la copia de pruebas aceptan esos datos y descuentan dos
equipos. Esto demuestra un mecanismo posible; no demuestra que esa fuera la
secuencia histórica del folio 46713.

Se analizó el código local de `C:\Users\Jesus\IdeaProjects\velcel`, sobre el
commit `f8d0645` con las modificaciones que ya tenía el espacio de trabajo.
No se modificó código funcional ni se corrigieron registros o procedimientos.
Solo se agregaron este informe y dos archivos de diagnóstico.

## Límite de la evidencia histórica

Solo se utilizó la conexión **Velcel Prueba / velcelco_prueba2026**. No se abrió
una sesión en la conexión de producción.

La copia contiene 35,688 ventas, llega al folio **36652** y su fecha máxima es
**29/09/2026**. No contiene el folio **46713**. Tampoco se encontró el IMEI
proporcionado en `imeis` o `imeisventas` de esa copia. No hay aquí un registro
del contenido enviado por el frontend ni del orden de eventos del incidente.

Por eso no se puede afirmar si el registro real tiene una línea con cantidad
2, dos líneas con cantidad 1, o cuántos IMEI quedaron asociados. El análisis
distingue esos resultados sin consultar producción.

## Por qué pudo registrar dos celulares en el mismo folio

`SearchProductsWidget._addProduct` espera una consulta de stock sin bloquear
otra alta del mismo producto (`search_products_widget.dart:277`). Cada llamada
pendiente termina ejecutando `CartState.addProduct`; si el producto ya existe,
incrementa `quantity` (`cart_state.dart:172–201`).

La prueba con dos consultas pendientes devolviendo stock suficiente produjo:

```text
líneas del carrito = 1
producto = DIAG_PHONE
cantidad = 2
total = 2000, para precio unitario 1000
```

Las dos invocaciones pueden corresponder a una repetición de la acción de
agregar mientras aún se espera respuesta. La prueba no presupone dos equipos
físicos vendidos ni demuestra un doble toque del vendedor. **Una única llamada
normal no se duplicó**: la prueba de control envió cantidad 1.

Además, una segunda alta ya iniciada puede terminar después de validar el
primer IMEI. El método modifica el carrito antes de que el widget compruebe
si sigue montado. `purchase()` no exige que las altas pendientes hayan
terminado ni vuelve a comprobar cantidad contra IMEI.

Si lo observado fueran dos líneas del mismo producto, existe otra ruta
reproducible: el carrito compara el `ProductEntity` completo, cuyos atributos
de igualdad incluyen nombre visible, descripción, precio y otros campos
(`product_entity.dart:29`). Dos versiones del mismo código con metadatos
distintos se agregan como dos líneas; el request lleva el código repetido y
el procedimiento inserta ambas. Esto requiere dos altas y metadatos distintos;
no existe evidencia de ese cambio de catálogo para el incidente.

## Por qué el IMEI escrito puede no enviarse

El texto del campo y los IMEI de la venta se guardan en lugares diferentes.
`purchase()` envía `cart[].imeiList`, no el texto de los controladores
(`cart_state.dart:226–253`).

En `verifyImei()` (`cart_state.dart:140–168`):

1. Se vacía `imeiList`, incluso si el IMEI ya había sido validado.
2. Se consulta el repositorio.
3. Una respuesta positiva agrega el IMEI a la lista.
4. Si el repositorio devuelve `Left(ServerFailure)`, la rama `(l) {}` omite el
   error. No marca el campo como inválido ni interrumpe la operación.

El validador del campo comprueba texto, duplicados y el indicador `error`
(`input_imei_app.dart:28–44`). Un texto presente con `error == false` pasa
aunque la consulta haya fallado y `imeiList` esté vacía. La prueba con el
widget real `CartVerify` permitió avanzar hasta `CartStates.purchase` y
capturar un request sin IMEI.

Esto aplica a errores devueltos como `Left` por el repositorio. No demuestra
una caída de internet: excepciones que se propaguen sin convertirse en ese
resultado pueden detener el flujo.

También se verificó que cualquier alta o eliminación reconstruye todos los
controladores con texto vacío (`getCartsWithImeiApply`, `cart_state.dart:114`).
Los IMEI previamente validados pueden seguir en `imeiList`, dejando estados
distintos entre los campos visibles y lo que se enviará.

## Secuencia que reprodujo ambos síntomas

La prueba de interfaz realizó estas acciones sobre los métodos y widgets reales:

1. Agregar un celular y escribir `350028031597294`.
2. Mantener pendiente una segunda solicitud de agregar ese producto.
3. Iniciar la verificación del IMEI.
4. Completar la segunda consulta de stock: la cantidad cambia a 2 y se
   reconstruyen los campos IMEI.
5. Devolver un error SQL de verificación antes del siguiente frame de Flutter.
6. El formulario aún montado valida el texto anterior, sin error marcado,
   y permite avanzar. El request capturado contiene `cantidades: [2]` e
   `imeis: []`.

El orden de respuestas antes del siguiente frame es una condición específica
de esta reproducción. No se ha establecido que ocurriera en el folio 46713.
Una variante más simple, sin error SQL, envió cantidad 2 con un solo IMEI al
completar la segunda alta después de verificar el primero.

## Qué hacen los procedimientos con esos datos

Se inspeccionaron los cuerpos actuales de `proCrearVenta`,
`proCrearVentaPayjoi`, `proIterarCadenas` y `proIterarCadena` en la base de
pruebas. Se ejecutó `ProductsRepositoryImpl.generarVenta` contra esos
procedimientos utilizando exclusivamente tablas temporales de sesión.

| Entrada / escenario | Resultado comprobado |
| --- | --- |
| Un producto, cantidad 1, un IMEI | Un folio, una línea, cantidad 1, un IMEI; stock 5 → 4. |
| Un producto, cantidad 2, lista IMEI vacía | Un folio, una línea, cantidad 2, cero IMEI; stock 5 → 3. |
| Un producto, cantidad 2, un IMEI | Un folio, una línea, cantidad 2, un IMEI; stock 5 → 3. |
| Código repetido dos veces con cantidades 1 y 1 | Un folio, dos líneas, cantidad total 2. |
| Dos llamadas a generar venta, cada una con cantidad 1 | Dos folios diferentes. |
| Venta a crédito con cantidad 2 y sin IMEI | También aceptada. |

El repositorio convierte la lista IMEI vacía en SQL `NULL`
(`products_repository_impl.dart:120`). Los procedimientos omiten guardar IMEI
cuando reciben `NULL`; no rechazan la venta. Tampoco exigen que el número de
IMEI coincida con las unidades. `proIterarCadenas` registra y descuenta las
cantidades recibidas del frontend.

Por tanto, **repetir “Generar venta” por sí solo no explica dos unidades dentro
del mismo folio** en las pruebas: cada llamada creó un folio distinto. En el
código actual también existe un bloqueo del botón mientras se compra. Para
el síntoma descrito, los mecanismos del carrito y su validación encajan mejor.

## Pruebas y conservación de datos

```powershell
flutter test tool/sale_frontend_diagnostic_test.dart tool/sale_persistence_diagnostic_test.dart --no-pub --reporter expanded --concurrency=1
flutter analyze tool/sale_frontend_diagnostic_test.dart tool/sale_persistence_diagnostic_test.dart --no-pub
```

Resultado final: **16 pruebas pasaron** — 10 del frontend y 6 de persistencia.
Análisis estático: **sin issues**. Las pruebas documentan el comportamiento
defectuoso actual; no certifican una corrección.

Las pruebas del frontend capturan el request con un repositorio de prueba y
detienen el flujo antes de guardar o imprimir. Las de persistencia usan el
repositorio y los procedimientos reales de la copia de pruebas. Antes de
escribir comprueban `DB_TEST`, `SELECT DATABASE()`, las referencias de los
procedimientos y la creación de las siete tablas temporales. Los folios
36653 y 36654 mostrados durante esas pruebas existieron solo en esas sesiones.

Los conteos y máximos persistentes coincidieron antes y después:

| Tabla | Filas | Máximo identificador |
| --- | ---: | ---: |
| reportesventas | 35,688 | 36,652 |
| salidasventas | 115,465 | 115,477 |
| imeisventas | 33,421 | 33,424 |
| imeis | 1,606 | — |
| almacenaje | 6,105 | — |

No se ejecutó la suite general, que contiene otras conexiones de base de datos.

Para prevenir esta secuencia, las correcciones serían bloquear altas repetidas
mientras están pendientes, impedir cambios del carrito durante la validación,
rechazar errores de verificación y comprobar cantidad/IMEI inmediatamente
antes de guardar y también dentro de la operación de base de datos. No se
aplicó ninguna de esas correcciones.
