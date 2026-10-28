-- =====================================================================
--  TrazaMar by NotFound - ORACLE
--  Archivo 02: datos de demostración (ficticios, según el caso)
--  Contraseña de todos los usuarios demo: 1234  (hash SHA-256 en hex,
--  el mismo formato que genera hashPassword() en AuthRepository.kt)
-- =====================================================================

-- Roles
INSERT INTO roles VALUES ('operador',   'Operador de muestreo',  'Registra muestras, fotos, conteo y observaciones');
INSERT INTO roles VALUES ('supervisor', 'Supervisor técnico',    'Revisa, valida o solicita correcciones');
INSERT INTO roles VALUES ('analista',   'Analista de reportes',  'Consulta históricos validados y prepara resúmenes');
INSERT INTO roles VALUES ('cliente',    'Revisor externo',       'Solo lectura de resultados autorizados');
INSERT INTO roles VALUES ('admin',      'Administrador',         'Gestiona usuarios y catálogos');

-- Estados del flujo de revisión
INSERT INTO estados_muestra VALUES ('borrador',  'Borrador',  1, 'Creada por el operador, aún editable');
INSERT INTO estados_muestra VALUES ('pendiente', 'Pendiente', 2, 'Enviada a revisión');
INSERT INTO estados_muestra VALUES ('observada', 'Observada', 3, 'El supervisor solicitó correcciones');
INSERT INTO estados_muestra VALUES ('corregida', 'Corregida', 4, 'El operador corrigió y reenvió');
INSERT INTO estados_muestra VALUES ('validada',  'Validada',  5, 'Aprobada por el supervisor');

-- Usuarios (mismos que siembra la app)
INSERT INTO usuarios (username, nombre_completo, rol, password_hash)
  VALUES ('ADMIN-01', 'Administrador Uno', 'admin',      '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4');
INSERT INTO usuarios (username, nombre_completo, rol, password_hash)
  VALUES ('OP-01',    'Operador Uno',      'operador',   '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4');
INSERT INTO usuarios (username, nombre_completo, rol, password_hash)
  VALUES ('OP-02',    'Operador Dos',      'operador',   '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4');
INSERT INTO usuarios (username, nombre_completo, rol, password_hash)
  VALUES ('SUP-01',   'Supervisor Uno',    'supervisor', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4');
INSERT INTO usuarios (username, nombre_completo, rol, password_hash)
  VALUES ('AN-01',    'Analista Uno',      'analista',   '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4');
INSERT INTO usuarios (username, nombre_completo, rol, password_hash)
  VALUES ('CLI-01',   'Cliente Demo',      'cliente',    '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4');

-- Centros / trenes / líneas
INSERT INTO centros (nombre, codigo) VALUES ('Centro Demo',        'CD-001');
INSERT INTO centros (nombre, codigo) VALUES ('Centro Isla Tenglo', 'CIT-002');

INSERT INTO trenes (centro_id, nombre)
  SELECT id, 'Tren 1' FROM centros WHERE codigo = 'CD-001';
INSERT INTO trenes (centro_id, nombre)
  SELECT id, 'Tren 2' FROM centros WHERE codigo = 'CD-001';
INSERT INTO trenes (centro_id, nombre)
  SELECT id, 'Tren A' FROM centros WHERE codigo = 'CIT-002';

INSERT INTO lineas (tren_id, nombre)
  SELECT t.id, 'Línea 1' FROM trenes t JOIN centros c ON c.id = t.centro_id WHERE c.codigo = 'CD-001' AND t.nombre = 'Tren 1';
INSERT INTO lineas (tren_id, nombre)
  SELECT t.id, 'Línea 2' FROM trenes t JOIN centros c ON c.id = t.centro_id WHERE c.codigo = 'CD-001' AND t.nombre = 'Tren 1';
INSERT INTO lineas (tren_id, nombre)
  SELECT t.id, 'Línea 1' FROM trenes t JOIN centros c ON c.id = t.centro_id WHERE c.codigo = 'CD-001' AND t.nombre = 'Tren 2';
INSERT INTO lineas (tren_id, nombre)
  SELECT t.id, 'Línea A1' FROM trenes t JOIN centros c ON c.id = t.centro_id WHERE c.codigo = 'CIT-002' AND t.nombre = 'Tren A';

-- Muestras de ejemplo (una por cada estado, para demostrar el flujo)
INSERT INTO muestras (centro_id, tren_id, linea_id, fecha, hora, tramo_metros, operador_id,
                      conteo_individuos, observaciones, calibre_promedio, calibre_min, calibre_max, peso_muestra, estado)
SELECT c.id, t.id, l.id, DATE '2026-10-20', '09:15', 0.20,
       (SELECT id FROM usuarios WHERE username = 'OP-01'),
       142, 'Buena fijación, sin epibiontes', 38.5, 30.0, 46.0, 820.0, 'borrador'
FROM centros c JOIN trenes t ON t.centro_id = c.id JOIN lineas l ON l.tren_id = t.id
WHERE c.codigo = 'CD-001' AND t.nombre = 'Tren 1' AND l.nombre = 'Línea 1';

INSERT INTO muestras (centro_id, tren_id, linea_id, fecha, hora, tramo_metros, operador_id,
                      conteo_individuos, observaciones, calibre_promedio, calibre_min, calibre_max, peso_muestra, estado)
SELECT c.id, t.id, l.id, DATE '2026-10-21', '10:40', 0.20,
       (SELECT id FROM usuarios WHERE username = 'OP-01'),
       168, 'Densidad alta en tramo medio', 36.2, 28.0, 44.5, 910.0, 'pendiente'
FROM centros c JOIN trenes t ON t.centro_id = c.id JOIN lineas l ON l.tren_id = t.id
WHERE c.codigo = 'CD-001' AND t.nombre = 'Tren 1' AND l.nombre = 'Línea 2';

INSERT INTO muestras (centro_id, tren_id, linea_id, fecha, hora, tramo_metros, operador_id,
                      conteo_individuos, observaciones, calibre_promedio, calibre_min, calibre_max, peso_muestra, estado)
SELECT c.id, t.id, l.id, DATE '2026-10-22', '08:55', 0.25,
       (SELECT id FROM usuarios WHERE username = 'OP-02'),
       131, 'Foto con poca luz', 40.1, 33.0, 48.0, 870.0, 'pendiente'
FROM centros c JOIN trenes t ON t.centro_id = c.id JOIN lineas l ON l.tren_id = t.id
WHERE c.codigo = 'CD-001' AND t.nombre = 'Tren 2' AND l.nombre = 'Línea 1';

INSERT INTO muestras (centro_id, tren_id, linea_id, fecha, hora, tramo_metros, operador_id,
                      conteo_individuos, observaciones, calibre_promedio, calibre_min, calibre_max, peso_muestra, estado)
SELECT c.id, t.id, l.id, DATE '2026-10-23', '11:20', 0.20,
       (SELECT id FROM usuarios WHERE username = 'OP-02'),
       155, 'Muestra estándar', 41.3, 35.0, 49.0, 980.0, 'pendiente'
FROM centros c JOIN trenes t ON t.centro_id = c.id JOIN lineas l ON l.tren_id = t.id
WHERE c.codigo = 'CIT-002' AND t.nombre = 'Tren A' AND l.nombre = 'Línea A1';

-- Revisión del supervisor: una observada y una validada (genera historial por trigger)
UPDATE muestras
   SET estado = 'observada',
       comentario_supervisor = 'Repetir fotografía con mejor iluminación',
       supervisor_id = (SELECT id FROM usuarios WHERE username = 'SUP-01'),
       fecha_revision = SYSTIMESTAMP
 WHERE fecha = DATE '2026-10-22';

UPDATE muestras
   SET estado = 'validada',
       comentario_supervisor = 'Datos consistentes',
       supervisor_id = (SELECT id FROM usuarios WHERE username = 'SUP-01'),
       fecha_revision = SYSTIMESTAMP
 WHERE fecha = DATE '2026-10-23';

COMMIT;
