**Resultados de consultas ejecutadas con datos de prueba.**

1. Lista de productos con stock disponible agrupados por categoría y ordenados por precio.

![PRIMER CONSULTA](PRIMER_CONSULTA.png)


2. Clientes con pedidos pendientes

![SEGUNDA CONSULTA](SEGUNDA_CONSULTA.png)

3. Top 5 productos mejor calificados

Análisis de índices: Falta un índice en Resenas(id_producto).

![TERCER CONSULTA](TERCER_CONSULTA.png)

**Explicación de índices creados y su impacto (por ejemplo, usando EXPLAIN en
MySQL).**

Los índices creados en el script son:

    - idx_nombre ON Productos(nombre): Acelera búsquedas por nombre de producto.

    - idx_categoria ON Productos(id_categoria): Acelera búsquedas por categoría.

    - idx_cliente ON Pedidos(id_cliente): Acelera búsquedas por cliente.

EJEMPLO:

![EJEMPLO CON EXPLAN DE INDICE](INDICE.png)

Sin índice, MySQL buscaría por completo dentro de la tabla. Con el índice idx_nombre, el motor puede buscar directamente los registros que coincidan con el patrón y lo mismo sucede con los otros indices.

**Pruebas de procedimientos almacenados con diferentes escenarios (por ejemplo,
intento de reseña sin compra).**

1. RegistrarPedido

Caso exitoso:

![CASO EXITOSO REGISTRAR_PEDIDO](REGISTRAR_EXITOSO.png)

Stock insuficiente:

![STOCK INSUFICIENTE](REGISTRAR_FALLO.png)

2. RegistrarResena 

Caso Exitoso:

![CASO EXITOSO REGISTRAR_RESENA](RESENA_EXITO.png)

Calificación inválida:

![CASO FALLIDO REGISTRAR_RESENA](RESENA_FALLO.png)

3. ActualizarStock

Caso Exitoso:

El stock del producto es de 98, por lo que se reduce a 96

![CASO EXITOSO ACTUALIZAR_STOCK](STOCK_EXITO.png)

Caso Fallido:

![CASO FALLIDO ACTUALIZAR_STOCK](STOCK_FALLO.png)

4. CambiarEstadoPedido

Caso Exitoso:

![CASO EXITOSO CAMBIAR_ESTADO_PEDIDO](ESTADO_EXITO.png)

Caso Fallido:

![CASO FALLIDO CAMBIAR_ESTADO_PEDIDO](ESTADO_FALLO.png)

5. EliminarResenasProducto

Caso Exitoso:

![CASO EXITOSO ELIMINAR_RESENAS](EResenas_EXITO.png)

Caso Fallido:

![CASO FALLIDO ELIMINAR_RESENAS](EResena_Fallo.png)

6. AgregarProducto

Caso Exitoso:

![CASO EXITOSO AGREGAR_PRODUCTO](AGREGAR_EXITO.png)

Caso Fallido:

![CASO FALLIDO AGREGAR_PRODUCTO](AGREGAR_FALLO.png)

7. ActualizarCliente

Caso Exitoso:

![CASO EXITOSO ACTUALIZAR_CLIENTE](ACTUALIZAR_EXITOSO.png)

Caso Fallido:

![CASO FALLIDO ACTUALIZAR_CLIENTE](ACTUALIZAR_FALLO.png)

8. ReporteStockBajo

Caso Exitoso:

![CASO EXITOSO REPORTE_STOCK_BAJO](REPORTE_EXITO.png)

Caso Fallido:

![CASO FALLIDO REPORTE_STOCK_BAJO](REPORTE_FALLO.png)

**Propuestas de Mejoras**

    - Índices adicionales:

    CREATE INDEX idx_estado ON Pedidos(estado); - Para consultas por estado

    CREATE INDEX idx_precio ON Productos(precio); - Para consultas ordenadas por precio

    -   Se podria agregar el procedimiento para eliminar un producto de la tienda.

