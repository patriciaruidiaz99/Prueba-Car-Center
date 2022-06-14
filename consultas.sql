-- Consulta d eclientes que han comprado un acumulado de 100000 en los ultimos 60 dias
SELECT cli.tipo_documento||'-'||cli.numero_documento DOCUMENTO,
      cli.primer_nombre||' '||cli.segundo_nombre||' '||
      cli.primer_apellido||' '||cli.segundo_apellido NOMBRE,
      fac.valor_total, fac.fecha
   FROM factura fac JOIN cliente cli ON cli.id_cliente = fac.id_cliente
WHERE valor_total = 100000
AND fecha > (SYSDATE -60);

-- Consulta de los 100 productos mas vendidos en los ultimos 30 dias
SELECT idProducto, SUM(unidades) Cantidad, pro.descripcion  FROM 
               (SELECT com.id_productos idProducto, com.cantidad unidades FROM factura fac 
                  JOIN compra com ON com.id_mantenimiento = fac.id_mantenimiento
                  WHERE fecha > (SYSDATE -30))
JOIN productos pro ON pro.id_productos = idProducto
WHERE pro.tipo_producto = 'REPUESTO'
AND ROWNUM <= 100
GROUP BY idProducto, pro.descripcion
ORDER BY Cantidad DESC;

-- Consulta de todos los clientes que han tenido más de un(1) mantenimiento en los últimos 30 días.
SELECT cli.tipo_documento||'-'||cli.numero_documento DOCUMENTO,
      cli.primer_nombre||' '||cli.segundo_nombre||' '||
      cli.primer_apellido||' '||cli.segundo_apellido NOMBRE,
      veces
FROM (SELECT id_cliente ID, COUNT(id_cliente) veces FROM mantenimiento
               GROUP BY id_cliente)
JOIN cliente cli ON cli.id_cliente = ID
WHERE veces >= 2;
   