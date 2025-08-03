-- 1. Listar productos disponibles por categoría, ordenados por precio.
-- Se filtran productos con stock > 0, se unen con su categoría y se ordenan por categoría y precio.
SELECT c.nombre AS categoria, p.nombre, p.precio
FROM Productos p
INNER JOIN Categorias c ON p.id_categoria = c.id_categoria
WHERE p.stock > 0
ORDER BY c.nombre, p.precio ASC;

-- 2. Mostrar clientes con pedidos pendientes y total de compras.
-- Se consideran solo pedidos con estado 'pendiente', se agrupan por cliente y se calcula el total gastado.
SELECT cl.id_cliente, cl.nombre, COUNT(p.id_pedido) AS pedidos_pendientes, 
       SUM(pd.precio * dp.cantidad) AS total_compras
FROM Clientes cl
INNER JOIN Pedidos p ON cl.id_cliente = p.id_cliente
INNER JOIN Detalles_Pedido dp ON p.id_pedido = dp.id_pedido
INNER JOIN Productos pd ON dp.id_producto = pd.id_producto
WHERE p.estado = 'pendiente'
GROUP BY cl.id_cliente, cl.nombre;

-- 3. Reporte de los 5 productos con mejor calificación promedio en reseñas.
-- Se calculan los promedios de calificaciones por producto(si tienen reseñas) y se seleccionan los 5 más altos.
SELECT p.id_producto, p.nombre, AVG(r.calificacion) AS promedio
FROM Productos p
INNER JOIN Resenas r ON p.id_producto = r.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY promedio DESC
LIMIT 5;


--PROCEDIMIENTOS ALMACENADOS

-- 1. Registrar un nuevo pedido verificando el límite de 5 pedidos pendientes y stock suficiente.
DELIMITER $$
CREATE PROCEDURE RegistrarPedido (
    IN p_id_cli INT,       -- ID del cliente que realiza el pedido
    IN p_id_prod INT,      -- ID del producto solicitado
    IN p_cantidad INT      -- Cantidad deseada del producto
)
BEGIN
    -- Se hace un analisis de pedidos pendientes, verifica que el cliente no tenga más de 5 pedidos pendientes asi se evita la acumulación excesiva de pedidos sin procesar
    IF (SELECT COUNT(*) FROM Pedidos WHERE id_cliente = p_id_cli AND estado = 'pendiente') >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Máximo 5 pedidos pendientes permitidos';
    END IF;

    -- Disponibilidad de stock: Comprueba que haya suficiente inventario para satisfacer el pedido
    IF (SELECT stock FROM Productos WHERE id_producto = p_id_prod) < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;

    /*
    Creación del pedido
    Inserta un nuevo registro en la tabla Pedidos con:
    - ID del cliente
    - Estado inicial 'pendiente'
    - Fecha actual automática
    */
    INSERT INTO Pedidos(id_cliente, estado, fecha_pedido) 
    VALUES (p_id_cli, 'pendiente', NOW());
    
    /*
    Detalle del pedido
    Inserta en Detalles_Pedido la información específica:
    - ID del pedido recién creado (LAST_INSERT_ID())
    - ID del producto solicitado
    - Cantidad requerida
    */
    INSERT INTO Detalles_Pedido(id_pedido, id_producto, cantidad)
    VALUES (LAST_INSERT_ID(), p_id_prod, p_cantidad);
    
    /*
    Reduce el stock disponible del producto según la cantidad pedida
    */
    UPDATE Productos SET stock = stock - p_cantidad WHERE id_producto = p_id_prod;
    
    -- Mensaje de confirmación de éxito
    SELECT 'Pedido registrado correctamente' AS Mensaje;
END $$
DELIMITER ;

-- 2. Registrar una reseña, verificando que el cliente haya comprado el producto.
DELIMITER $$
CREATE PROCEDURE RegistrarResena (
    IN p_id_cli INT,           -- ID del cliente que escribe la reseña
    IN p_id_prod INT,          -- ID del producto evaluado
    IN p_calificacion INT,     -- Puntuación dada (1-5)
    IN p_comentario VARCHAR(500) -- Texto de la reseña
)
BEGIN
    -- Asegura que la puntuación esté entre 1 y 5 estrellas
    IF p_calificacion < 1 OR p_calificacion > 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La calificación debe ser entre 1 y 5';
    END IF;

    /*
    Verifica que el cliente haya comprado efectivamente el producto
    Previene reseñas falsas o no verificadas
    */
    IF NOT EXISTS (
        SELECT 1 
        FROM Pedidos p
        INNER JOIN Detalles_Pedido dp ON p.id_pedido = dp.id_pedido
        WHERE p.id_cliente = p_id_cli AND dp.id_producto = p_id_prod
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El cliente no ha comprado el producto';
    END IF;
    -- Registra la evaluación con todos los datos proporcionados:
    INSERT INTO Resenas(id_cliente, id_producto, calificacion, comentario)
    VALUES (p_id_cli, p_id_prod, p_calificacion, p_comentario);

    -- Mensaje de confirmación
    SELECT 'Reseña registrada correctamente' AS Mensaje;
END $$
DELIMITER ;


-- 3. Actualizar el stock de un producto después de un pedido.
DELIMITER $$
CREATE PROCEDURE ActualizarStock (
    IN p_id_prod INT,      -- ID del producto a actualizar
    IN p_cantidad INT      -- Cantidad a reducir del stock
)
BEGIN
    -- Se compara la cantidad solicitada con el inventario actual
    IF (SELECT stock FROM Productos WHERE id_producto = p_id_prod) < p_cantidad THEN
        SELECT 'Error: No hay suficiente stock' AS Mensaje;
    ELSE
    -- Se hace la resta al stock solo si hay disponibilidad
        UPDATE Productos SET stock = stock - p_cantidad WHERE id_producto = p_id_prod;
        SELECT 'Stock actualizado correctamente' AS Mensaje;
    END IF;
END $$
DELIMITER ;

-- 4. Cambiar el estado de un pedido (por ejemplo, de pendiente a enviado). 
DELIMITER $$
CREATE PROCEDURE CambiarEstadoPedido (
    IN p_id_ped INT,               -- ID del pedido a modificar
    IN p_nuevo_estado VARCHAR(50)   -- Nuevo estado a asignar
)
BEGIN

    -- Se verifica que el pedido no tenga el estado que se quiere asignar asi se evitan actualizaciones innecesarias
    IF (SELECT estado FROM Pedidos WHERE id_pedido = p_id_ped) = p_nuevo_estado THEN
        SELECT CONCAT('Error: El pedido ya está en estado ', p_nuevo_estado) AS Mensaje;
    ELSE
        -- Modifica el estado del pedido al nuevo valor proporcionado
        UPDATE Pedidos SET estado = p_nuevo_estado WHERE id_pedido = p_id_ped;
        -- ROW_COUNT() retorna el número de filas afectadas, si es 0 significa que no se encontró el pedido.
        IF ROW_COUNT() = 0 THEN
            SELECT 'Error: No se encontró el pedido' AS Mensaje;
        ELSE
            SELECT CONCAT('Estado actualizado a: ', p_nuevo_estado) AS Mensaje;
        END IF;
    END IF;
END $$
DELIMITER ;

-- 5. Eliminar reseñas de un producto específico.
DELIMITER $$
CREATE PROCEDURE EliminarResenasProducto (
    IN p_id_prod INT   -- ID del producto cuyas reseñas se eliminarán
)
BEGIN
    -- Verifica que el producto exista en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Productos WHERE id_producto = p_id_prod) THEN
        SELECT 'Error: El producto no existe' AS Mensaje;
    -- Comprueba que el producto tenga reseñas antes de intentar borrar
    ELSEIF NOT EXISTS (SELECT 1 FROM Resenas WHERE id_producto = p_id_prod) THEN
        SELECT 'Advertencia: El producto no tiene reseñas' AS Mensaje;
    ELSE
        -- Borra todas las evaluaciones asociadas al producto
        DELETE FROM Resenas WHERE id_producto = p_id_prod;
        /*
        RESULTADO Y CALIFICACIÓN PROMEDIO
        Muestra:
        1. Cantidad de reseñas eliminadas
        2. Nuevo promedio (5 por defecto ya que no hay reseñas)
        */
        SELECT 
            CONCAT(ROW_COUNT(), ' reseña(s) eliminada(s)') AS Mensaje,
            IFNULL(
                (SELECT AVG(calificacion) 
                 FROM Resenas 
                 WHERE id_producto = p_id_prod),
                5
            ) AS 'Nueva calificación';
    END IF;
END $$
DELIMITER ;

-- 6. Agregar un nuevo producto, verificando que no exista un duplicado (mismo nombre y categoría).
DELIMITER $$
CREATE PROCEDURE AgregarProducto (
    IN p_nombre VARCHAR(100),   -- Nombre del nuevo producto
    IN p_id_cat INT,            -- ID de la categoría del producto
    IN p_desc VARCHAR(500),     -- Descripción detallada
    IN p_precio DECIMAL(10,2),  -- Precio unitario
    IN p_stock INT              -- Cantidad inicial en inventario
)
BEGIN
    -- Verifica que no exista otro producto con el mismo nombre en la misma categoría
    IF EXISTS (SELECT 1 FROM Productos WHERE nombre = p_nombre AND id_categoria = p_id_cat) THEN
        SELECT 'Error: Producto duplicado (mismo nombre y categoría)' AS Mensaje;
    -- Confirma que la categoría especificada exista en la base de datos 
    ELSEIF NOT EXISTS (SELECT 1 FROM Categorias WHERE id_categoria = p_id_cat) THEN
        SELECT 'Error: La categoría no existe' AS Mensaje;
    -- Asegura que el precio sea un valor positivo
    ELSEIF p_precio <= 0 THEN
        SELECT 'Error: El precio debe ser positivo' AS Mensaje;
    -- Verifica que el stock inicial no sea negativo
    ELSEIF p_stock < 0 THEN
        SELECT 'Error: El stock no puede ser negativo' AS Mensaje;
    
    ELSE
        /*
        SE INSERTA EL PRODUCTO
        Si pasó todas las validaciones, crea el nuevo registro con:
        - Nombre
        - Categoría
        - Descripción
        - Precio
        - Stock inicial
        */
        INSERT INTO Productos(nombre, id_categoria, descripcion, precio, stock)
        VALUES (p_nombre, p_id_cat, p_desc, p_precio, p_stock);
        
        -- Mensaje de confirmación
        SELECT 'Producto agregado correctamente' AS Mensaje;
    END IF;
END $$
DELIMITER ;

-- 7. Actualizar la información de un cliente (por ejemplo, dirección o teléfono).
DELIMITER $$
CREATE PROCEDURE ActualizarCliente (
    IN p_id_cli INT,            -- ID del cliente a actualizar
    IN p_direccion VARCHAR(200), -- Nueva dirección
    IN p_telefono VARCHAR(30)    -- Nuevo teléfono
)
BEGIN
    -- Verifica que el cliente exista antes de actualizar
    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE id_cliente = p_id_cli) THEN
        SELECT 'Error: El cliente no existe' AS Mensaje;
    ELSE
        /*
        Modifica solo los campos proporcionados:
        - Dirección
        - Teléfono
        */
        UPDATE Clientes
        SET direccion = p_direccion,
            numero_telefono = p_telefono
        WHERE id_cliente = p_id_cli;
        -- ROW_COUNT() indica si hubo modificaciones
        IF ROW_COUNT() > 0 THEN
            SELECT 'Datos del cliente actualizados correctamente' AS Mensaje;
        ELSE
            -- Si no hubo cambios, informa que los datos eran iguales
            SELECT 'Advertencia: No se realizaron cambios (los datos son iguales)' AS Mensaje;
        END IF;
    END IF;
END $$
DELIMITER ;

-- 8. Generar un reporte de productos con stock bajo (menos de 5 unidades).
DELIMITER $$
CREATE PROCEDURE ReporteStockBajo ()
BEGIN
    -- Comprueba si existen productos con menos de 5 unidades
    IF EXISTS (SELECT 1 FROM Productos WHERE stock < 5) THEN
        /*
        Lista todos los productos con stock bajo
        - ID del producto
        - Nombre
        - Cantidad actual
        Ordenados de menor a mayor stock
        */
        SELECT id_producto, nombre, stock
        FROM Productos
        WHERE stock < 5
        ORDER BY stock ASC;
        -- Muestra el conteo total de productos con stock bajo
        SELECT CONCAT('Se encontraron ', COUNT(*), ' productos con stock bajo') AS Resumen 
        FROM Productos WHERE stock < 5;
    ELSE
        -- Mensaje informativo cuando no hay stock bajo
        SELECT 'No hay productos con stock bajo (menos de 5 unidades)' AS Mensaje;
    END IF;
END $$
DELIMITER ;