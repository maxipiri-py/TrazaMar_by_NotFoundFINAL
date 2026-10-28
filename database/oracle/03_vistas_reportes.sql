-- =====================================================================
--  TrazaMar by NotFound - ORACLE
--  Archivo 03: vistas para historial y reportes (ResumenReporteDto)
-- =====================================================================

-- Detalle de muestra con nombres (equivale a MuestraEntity de la caché)
CREATE OR REPLACE VIEW v_muestras_detalle AS
SELECT m.id,
       m.centro_id,  c.nombre  AS centro_nombre,
       m.tren_id,    t.nombre  AS tren_nombre,
       m.linea_id,   l.nombre  AS linea_nombre,
       m.fecha, m.hora, m.tramo_metros,
       m.operador_id, op.username AS operador_username, op.nombre_completo AS operador_nombre,
       m.conteo_individuos, m.densidad_ind_metro,
       m.observaciones, m.calibre_promedio, m.calibre_min, m.calibre_max, m.peso_muestra,
       m.foto_url, m.estado, m.comentario_supervisor,
       m.supervisor_id, sp.nombre_completo AS supervisor_nombre,
       m.fecha_revision, m.created_at, m.updated_at
FROM muestras m
JOIN centros  c  ON c.id  = m.centro_id
JOIN trenes   t  ON t.id  = m.tren_id
JOIN lineas   l  ON l.id  = m.linea_id
JOIN usuarios op ON op.id = m.operador_id
LEFT JOIN usuarios sp ON sp.id = m.supervisor_id;

-- Reporte: total por estado  (EstadoCantidadDto)
CREATE OR REPLACE VIEW v_reporte_por_estado AS
SELECT e.codigo AS estado, e.orden, COUNT(m.id) AS total
FROM estados_muestra e
LEFT JOIN muestras m ON m.estado = e.codigo
GROUP BY e.codigo, e.orden;

-- Reporte: total por centro  (CentroCantidadDto)
CREATE OR REPLACE VIEW v_reporte_por_centro AS
SELECT c.nombre AS centro, COUNT(m.id) AS total,
       ROUND(AVG(m.conteo_individuos), 1) AS promedio_conteo,
       ROUND(AVG(m.densidad_ind_metro), 1) AS promedio_densidad
FROM centros c
LEFT JOIN muestras m ON m.centro_id = c.id
GROUP BY c.nombre;

-- Reporte: serie temporal  (SeriePuntoDto)
CREATE OR REPLACE VIEW v_reporte_serie_temporal AS
SELECT TO_CHAR(m.fecha, 'YYYY-MM-DD') AS fecha,
       NVL(SUM(m.conteo_individuos), 0) AS total_individuos,
       COUNT(*) AS total_muestras
FROM muestras m
GROUP BY TO_CHAR(m.fecha, 'YYYY-MM-DD');

-- Historial de trazabilidad legible
CREATE OR REPLACE VIEW v_historial_revisiones AS
SELECT r.id, r.muestra_id, r.estado_anterior, r.estado_nuevo, r.comentario,
       u.username AS usuario, u.rol, r.fecha
FROM revisiones_muestra r
LEFT JOIN usuarios u ON u.id = r.usuario_id;

-- ---------------------------------------------------------------------
-- Consultas de verificación (ejecutar para la presentación)
-- ---------------------------------------------------------------------
-- SELECT * FROM v_muestras_detalle ORDER BY fecha DESC;
-- SELECT * FROM v_reporte_por_estado ORDER BY orden;
-- SELECT * FROM v_reporte_por_centro ORDER BY total DESC;
-- SELECT * FROM v_reporte_serie_temporal ORDER BY fecha;
-- SELECT * FROM v_historial_revisiones ORDER BY muestra_id, fecha;
