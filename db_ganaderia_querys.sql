use db_ganaderia;

select*
from cria;

-- 1. TOP 10: VACAS MAS PROLIFERAS Y CON MAS CRIAS QUE HAN DEJADO EN LA FINCA
select 
	id_vaca,
    count(id_animal) as births 
from cria
group by id_vaca
order by 2 DESC
limit 10;

-- 1.1 CUAL ES EL TORO MAS UTILIZADO?
select 
	c.id_toro, 
    t.nombre,
    count(c.id_animal) as crias
from cria as c
join toros as t on c.id_toro=t.id_toro
group by t.id_toro
order by 3 DESC
limit 1;

-- 2. TASA DE EXITO DE INSEMINACION (TASA DE FERTILIDAD)
-- preñados/inseminados
-- OPCION 1
SELECT 
    EXTRACT(YEAR FROM i.fecha_servicio) AS anio,
    COUNT(*) AS total_inseminaciones,
    SUM(CASE WHEN i.resultado = 'preñado' THEN 1 ELSE 0 END) AS preñeces,
    ROUND(
        (SUM(CASE WHEN i.resultado = 'preñado' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS tasa_preñez
FROM 
    inseminacion i
GROUP BY 
    EXTRACT(YEAR FROM i.fecha_servicio);

-- OPCION 2
SELECT 
    YEAR (fecha_servicio) AS anio,
    ROUND((SUM(CASE
        WHEN resultado = 'preñado' THEN 1
        ELSE 0
    END) *100 / COUNT(*)),2) AS tasa_preñez
FROM inseminacion
GROUP BY YEAR(fecha_servicio);

-- OPCION 3
SELECT 
    year(fecha_servicio) AS anio,
    SUM(CASE WHEN resultado = 'preñado' THEN 1 ELSE 0 END) AS preñeces,
    COUNT(*) AS inseminaciones,
    round((SUM(CASE WHEN resultado = 'preñado' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS tasa_preeniez_porcentaje
FROM inseminacion
GROUP BY year(fecha_servicio)
order by 1;

-- OTRA OPCION
SELECT 
    year(fecha_servicio) AS anio,
    (SUM(CASE WHEN resultado = 'preñado' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS tasa_fertilidad
FROM inseminacion
GROUP BY year(fecha_servicio);

-- 3. INDICE DE PARTOS EXITOSOS
-- TASA DE NACIMIENTOS GENERAL
SELECT 
    round(COUNT(*) / 
    (SELECT 
        COUNT(*)
        FROM inseminacion
        WHERE resultado = 'preñado') * 100,2) AS tasa_nacimientos
FROM cria;

-- TASA DE NACIMIENTOS ANUAL 
-- PREÑEZ, INSEMINACIONES Y TASA
SELECT 
    year(fecha_servicio) AS anio,
    SUM(CASE WHEN resultado = 'preñado' THEN 1 ELSE 0 END) AS preñeces,
    COUNT(*) AS inseminaciones,
    round((SUM(CASE WHEN resultado = 'preñado' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS tasa_prenez_porcentaje
FROM inseminacion
GROUP BY year(fecha_servicio)
order by year(fecha_servicio);

-- 4. COSTO TOTAL POR ANIMAL
SELECT 
	id_animal, 
    SUM(monto) AS costo_total
FROM costos
GROUP BY id_animal
order by costo_total DESC;

-- 4.1 CUALES SON LOS COSTOS MAS SIGNIFICATIVOS?
select
	costos_id,
    tipo_costo,
    sum(monto) costo_total,
    round((sum(monto)*100)/ (select sum(monto) from costos),2) porcentaje_costo
from costos
group by tipo_costo
order by sum(monto) DESC;

-- 5. INDICE DE RECHAZO DE TOROS PARA INSEMINACION
SELECT 
    year(fecha_nacimiento) AS anio,
    sexo,
    round((SUM(CASE WHEN status = 'rechazado' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS indice_rechazo,
    round((SUM(CASE WHEN status = 'disponible' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS indice_disponible,
    round((SUM(CASE WHEN status = 'rechazado' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS indice_vendido
FROM cria
GROUP BY year(fecha_nacimiento), sexo ="M"
order by sexo, anio;

-- 6. PROMEDIO DE PARTOS POR VACA
SELECT 
	round(avg(numero_partos),2) as promedio_partos
FROM vientres;

-- 6.1 CUANTAS VACAS TENEMOS POR PARTO?
select	
	numero_partos,
	count(*) as num_vacas,
    round((count(*)*100.0)/(select count(*) from vientres), 2) porcentaje
from vientres
group by numero_partos
order by 3 DESC;

-- 7. PROMEDIO DE PESO AL NACER
select
	round(avg(peso_nacimiento),2) as prom_peso_nacimiento
from cria;

-- 8. TOP 10 DE VACAS QUE NOS DAN TERNEROS MAS GRANDES
SELECT
	c.id_vaca,
     v.numero_partos,
     round(AVG(PESO_NACIMIENTO),2) AS prom_peso_nacimiento
from CRIA c
join vientres v ON c.id_vaca=v.id_vaca
group by id_vaca, v.numero_partos
order by prom_peso_nacimiento DESC
LIMIT 10;

-- 8.1  TOP 10 DE VACAS QUE NOS DAN TERNEROS MAS PEQUEÑOS
SELECT
	c.id_vaca,
     v.numero_partos,
     round(AVG(PESO_NACIMIENTO),2) AS prom_peso_nacimiento
from CRIA c
join vientres v ON c.id_vaca=v.id_vaca
group by id_vaca, v.numero_partos
order by prom_peso_nacimiento
LIMIT 10;

-- 8.3 QUE TOROS NOS DAN TERNEROS MAS GRANDES?
SELECT
	t.id_toro,
    t.nombre as toro,
    round(AVG(PESO_NACIMIENTO),2) AS prom_peso_nacimiento
FROM CRIA c
join toros t on c.id_toro=t.id_toro
group by id_toro
order by prom_peso_nacimiento DESC;

-- 9. CANTIDAD DE ANIMALES POR SU ESTADO ACTUAL (VENDIDOS, DISPONIBLES, RECHAZADO)
select
	status as estado,
    sexo, 
	count(*) as num_animales
from cria
group by status, sexo
order by 1;

-- 10. TASA DE CRECIMIENTO DE REBAÑO 
-- animales final 
select
year(v.fecha_venta) as anio,
count(c.id_animal) as animales_inicial,
(count(c.id_animal) - (select count(c.id_animal) from cria where status = "vendidos")) as animales_final,
(count(c.id_animal))-(count(c.id_animal) - (select count(c.id_animal) from cria where status = "vendidos")) as diferencia
from cria c
join ventas v on c.id_animal = v.id_animal
group by year(fecha_venta)
order by 1;
---
select
year(c.fecha_nacimiento) as anio,
count(c.id_animal) as num_inicial
from cria c
group by year(c.fecha_nacimiento)
order by 1;
----
select
year(v.fecha_venta) as anio,
count(v.id_animal) as num_final 
from ventas	v
group by 1
order by 1;

-- LIMPIEZA DE TABLA VENTAS (ELIMINAR DUPLICADOS) --
select * 
from ventas;

-- queremos mantener el registro con el id_venta más bajo para cada id_animal
SELECT id_animal, MIN(id_venta) AS id_venta
FROM ventas
GROUP BY id_animal;

DROP TEMPORARY TABLE IF EXISTS temp_ventas;

-- Crea una tabla temporal con los registros que deseas mantener
CREATE TEMPORARY TABLE temp_ventas AS
SELECT id_venta
FROM ventas
WHERE (id_animal, id_venta) IN (
    SELECT id_animal, MIN(id_venta)
    FROM ventas
    GROUP BY id_animal
);

-- Elimina los registros que no están en la tabla temporal:
DELETE FROM ventas
WHERE id_venta NOT IN (
    SELECT id_venta
    FROM temp_ventas
);

select * 
from ventas;

-- 11. GANANCIA DE PESO DIARIO (GPD) *** EL CALCULO ESTÁ CORRECTO PERO LOS DATOS DE FECHA DE NACIMIENTO Y VENTA ESTAN INCORRECTOS, POR ESO SALEN NEGATIVOS
SELECT 
    c.id_animal,
    c.fecha_nacimiento,
    v.fecha_venta,
    DATEDIFF(v.fecha_venta, c.fecha_nacimiento) as periodo,
    (c.peso_final - peso_nacimiento) / DATEDIFF(v.fecha_venta, c.fecha_nacimiento) AS gpd
FROM cria c
join ventas v on c.id_animal=v.id_animal
order by 5 DESC;

-- 12. INGRESO TOTAL POR VENTAS
SELECT
	YEAR(fecha_venta) as anio,
    count(*) as numero_ventas,
    sum(precio_venta) as ingreso_total
FROM ventas
where year(fecha_venta) >1 
GROUP BY YEAR(fecha_venta)
order by 1;

 SELECT 
    nombre,
    REPLACE(nombre, '_', ' ') AS nombre_sin_guiones
FROM clientes;

-- 13 CUANTAS COMPRAS NOS HA HECHO CADA CLIENTE
-- ver tabla de clientes que tiene guiones. 
select * from clientes;

-- Primer paso, eliminar guiones
SELECT 
    nombre,
    REPLACE(nombre, '_', ' ') AS nombre_sin_guiones
FROM clientes;

SELECT 
	v.id_cliente, 
    c.nombre,
    c.ubicacion,
	COUNT(v.id_venta) AS num_compras
FROM ventas v
join clientes c on v.id_cliente=c.id_cliente
GROUP BY id_cliente
ORDER BY 4 DESC;

-- 13.1 TASA DE RETORNO DE CLIENTES
-- Calcula la tasa de retorno de clientes
SELECT 
    round((COUNT(DISTINCT CASE
            WHEN num_compras > 1 THEN id_cliente
        END) / COUNT(DISTINCT id_cliente)) * 100,2) AS tasa_retorno_clientes
FROM
    (SELECT 
        id_cliente, COUNT(id_venta) AS num_compras
    FROM
        ventas
    GROUP BY id_cliente) AS subconsulta;

-- 14. VALOR PROMEDIO POR VENTA
SELECT 
    round((SUM(precio_venta) / COUNT(*)),2) AS valor_promedio_por_venta
FROM ventas;

-- 15. QUE ZONA ME COMPRA MAS ANIMALES?
select
	c.ubicacion, 
    count(*) as num_ventas,
    round(avg(v.precio_venta),2) as prom_venta,
    sum(v.precio_venta) as total_ventas
from ventas v
join clientes c on v.id_cliente = c.id_cliente
group by c.ubicacion
order by 3 DESC;

-- 16. RENTABILIDAD POR ANIMAL
-- OPCION 1
select 
	v.id_animal, 
    c.sexo,
    c.id_vaca,
    t.nombre as Toro,
    coalesce(sum(cs.monto),0) as costo,
    v.precio_venta,
    coalesce(v.precio_venta,0) - coalesce(sum(cs.monto),0) as beneficio
from ventas as v
left Join costos as cs ON v.id_animal=cs.id_animal
left join cria as c  ON c.id_animal=v.id_animal
left join toros as t ON c.id_toro=t.id_toro
group by v.id_animal, c.sexo, c.id_vaca, t.nombre, v.precio_venta
order by beneficio DESC;

-- OPCION 2
-- Paso 1: Sumar los costos por animal
-- Si el monto puede ser NULL, usamos COALESCE para reemplazar NULL con 0.
SELECT id_animal,
       COALESCE(SUM(monto), 0) AS total_costos
FROM costos
GROUP BY id_animal;

-- Paso 2: Calcular la rentabilidad, teniendo en cuenta la suma de costos y precio de venta por animal
SELECT 
    c.id_animal,
    c.sexo AS sexo,
    COALESCE(SUM(cs.monto), 0) AS costo,
    v.precio_venta,
    v.precio_venta - COALESCE(SUM(cs.monto), 0) AS beneficio
FROM cria c
JOIN ventas v ON c.id_animal = v.id_animal
LEFT JOIN costos cs ON c.id_animal = cs.id_animal
GROUP BY c.id_animal
order by beneficio DESC;

-- 17. PROMEDIO DE PESO Y EDAD A LA VENTA
SELECT
	round(AVG(c.peso_final),2) as prom_peso_final,
    round(avg(ROUND(DATEDIFF(v.fecha_venta, c.fecha_nacimiento) /30)),2) AS edad_meses
FROM cria c
join ventas v on c.id_animal=v.id_animal;

-- 18. TOP 10 ANIMALES CON MAYOR PESO A LA VENTA
SELECT
	c.id_animal,
    -- Calcular la edad en meses. Se divide en 30 para pasar los dias a meses
    ROUND(DATEDIFF(v.fecha_venta, c.fecha_nacimiento) /30) AS edad_meses,
    c.peso_final
FROM cria c
join ventas v on c.id_animal=v.id_animal
where c.status = "vendida"
order by 3 DESC
limit 10;

-- 17.1 TOP 10 ANIMALES CON MENOR PESO A LA VENTA
SELECT
	 id_animal,
    -- Calcular la edad en meses. Se divide en 30 para pasar los dias a meses
    ROUND(DATEDIFF(CURDATE(), fecha_nacimiento) / 30) AS edad_meses,
    peso_final
FROM cria
order by 3
limit 10;

-- 18. QUE ANIMALES SE VENDEN MAS, HEMBRAS O MACHOS?
select
    sexo, 
	count(*) as num_animales_vendidos,
    round((count(*)*100.0 / (select count(*) from cria where status= 'vendida')),2) as porcentaje
from cria 
where status = "vendida" 
group by sexo
order by 1;

-- 18.1 QUE ANIMALES SE VENDEN MAS POR AÑO, HEMBRAS O MACHOS?
SELECT
    YEAR(fecha_venta) AS anio,
    c.sexo,
    COUNT(*) AS num_animales,
    ROUND((COUNT(*) * 100.0 / (
        SELECT COUNT(*)
        FROM cria c2
        join ventas v2 on c2.id_animal = v2.id_animal
        WHERE c2.status = 'vendida'
        AND YEAR(v2.fecha_venta) = YEAR(v.fecha_venta)
    )), 2) AS porcentaje
FROM cria c
JOIN ventas v on c.id_animal=v.id_animal
WHERE c.status = 'vendida'
AND YEAR(v.fecha_venta) BETWEEN 2020 AND 2024
GROUP BY YEAR(v.fecha_venta), c.sexo
ORDER BY YEAR(v.fecha_venta), num_animales DESC; 

