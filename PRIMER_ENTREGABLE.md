**1. Diagrama Entidad Relacion**
![Diagrama de entidad relacion](IMAGEN_ER.png)

**2.Esquema en Tercera Forma Normal (3NF)**

1.	Clientes 
    - (id_cliente, nombre, correo_electronico, direccion, numero_telefono)
    - Clave Primaria: id_cliente
2.	Categorías 
    - (id_categoria, nombre, descripcion)
    - Clave Primaria: id_categoria
3.	Productos 
    - (id_producto, nombre, descripcion, precio, stock, id_categoria)
    - Clave Primaria: id_producto
    - Clave Foránea: id_categoria → Categorías
4.	Pedidos 
    - (id_pedido, id_cliente, fecha_estado, fecha_pedido)
    - Clave Primaria: id_pedido
    - Clave Foránea: id_cliente → Clientes
5.	Detalles_Pedido 
    - (id_detalle, id_pedido, id_producto, cantidad)
    - Clave Primaria: id_detalle
    - Claves Foráneas: id_pedido → Pedidos, id_producto → Productos
6.	Reseñas 
    - (id_resena, id_cliente, id_producto, calificacion, comentario)
    - Clave Primaria: id_resena
    - Claves Foráneas: id_cliente → Clientes, id_producto → Productos

**3. Justificación de la Normalización**

1.	Primera Forma Normal (1NF): 
    - Todas las tablas tienen atributos atómicos, sin listas ni datos repetidos. Por ejemplo, en Detalles_Pedido.
    - Se eliminan dependencias parciales y transitivas en los siguientes pasos.
2.	Segunda Forma Normal (2NF): 
    - Todas las tablas están en 1NF.
    - No hay dependencias parciales de claves primarias compuestas porque las claves primarias son simples, por ejemplo: id_detalle, id_resena.
    - Atributos como precio en la tabla de Productos dependen completamente de la clave primaria.
3.	Tercera Forma Normal (3NF): 
    - No existen dependencias transitivas. Por ejemplo, en Productos, id_categoria no se determina otros atributos no clave como precio, solo lo relaciona con Categorías.
    - Se asegura que cada no clave dependa solo de la clave primaria, cumpliendo con las restricciones como stock no negativo y máximo 5 pedidos pendientes por cliente, que se manejan a nivel de lógica en la base de datos.

**4. Claves Primarias (PK)**

id_cat, id_prod, id_cli, id_ped, id_det, id_res

**5. Claves Foráneas (FK)**

    - PRODUCTOS.id_cat → CATEGORÍAS.id_cat
    - PEDIDOS.id_cli → CLIENTES.id_cli
    - DET_PEDIDO.id_ped → PEDIDOS.id_ped
    - DET_PEDIDO.id_prod → PRODUCTOS.id_prod
    - RESEÑAS.id_prod → PRODUCTOS.id_prod
    - RESEÑAS.id_cli → CLIENTES.id_cli

**6.	Claves Candidatas:**

    - CLIENTES.email (podría ser clave alternativa)
    - PRODUCTOS.nombre + id_cat (combinación única)
