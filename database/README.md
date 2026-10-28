# Base de datos TrazaMar (caso AquaSample · ALDEMAR SpA)

Modelo relacional para el registro y trazabilidad de muestras de choritos, construido a partir de las entidades Room de la app (`UsuarioEntity`, `CentroEntity`, `TrenEntity`, `LineaEntity`, `MuestraEntity`), los DTOs (`MuestraDto`, `ResumenReporteDto`) y las reglas de `util/Reglas.kt`.

```
database/
├── oracle/
│   ├── 01_esquema.sql          tablas, restricciones, índices y triggers
│   ├── 02_datos_demo.sql       roles, estados, usuarios demo, catálogo y muestras
│   └── 03_vistas_reportes.sql  vistas de detalle, reportes e historial
└── supabase/
    ├── migrations/20261028000000_esquema_inicial.sql   mismo modelo en PostgreSQL + RLS + RPC + bucket de fotos
    └── seed.sql                                       mismos datos demo
```

## Modelo

| Tabla | Propósito |
|---|---|
| `roles` | operador, supervisor, analista, cliente, admin |
| `estados_muestra` | borrador → pendiente → observada → corregida → validada |
| `usuarios` | cuentas con `password_hash` SHA-256 hex (mismo formato que `hashPassword()` de la app) |
| `centros` → `trenes` → `lineas` | jerarquía de cultivo (1:N en cada nivel) |
| `muestras` | registro de terreno: conteo, tramo, calibres, peso, foto, estado y revisión |
| `revisiones_muestra` | historial automático de cada cambio de estado (trazabilidad) |

Reglas aplicadas en la base:

- La línea debe pertenecer al tren y el tren al centro (trigger).
- `densidad_ind_metro` = conteo / tramo, calculada por la base (igual que `Reglas.densidad`).
- Checks: hora `HH:MM`, tramo > 0, conteo y peso ≥ 0, `calibre_min ≤ promedio ≤ calibre_max`.
- Cada cambio de estado queda en `revisiones_muestra` con quién lo hizo.
- Usernames únicos sin distinguir mayúsculas (el login de la app es case-insensitive).

Vistas: `v_muestras_detalle`, `v_reporte_por_estado`, `v_reporte_por_centro`, `v_reporte_serie_temporal`, `v_historial_revisiones`.

## Usuarios demo

Contraseña de todos: `1234` → `ADMIN-01`, `OP-01`, `OP-02`, `SUP-01`, `AN-01`, `CLI-01`.

## 1) Oracle en VS Code

1. Instalar la extensión **Oracle SQL Developer Extension for VS Code** (Oracle).
2. Crear una conexión (por ejemplo Oracle XE local: host `localhost`, puerto `1521`, servicio `XEPDB1`, con tu usuario de esquema).
3. Abrir y ejecutar como script, en orden: `01_esquema.sql`, `02_datos_demo.sql`, `03_vistas_reportes.sql`.
4. Verificar con las consultas comentadas al final de `03_vistas_reportes.sql`.

`01_esquema.sql` borra las tablas existentes al comenzar, así que se puede volver a ejecutar desde cero.

## 2) Supabase

**Opción rápida (Dashboard):** SQL Editor → pegar `supabase/migrations/20261028000000_esquema_inicial.sql` → Run → pegar `supabase/seed.sql` → Run.

**Opción CLI:**

```bash
supabase login
supabase link --project-ref <REF_DEL_PROYECTO>
supabase db push          # aplica migrations/
# luego ejecutar seed.sql desde el SQL Editor
```

La migración se probó sobre PostgreSQL 16 simulando los roles `anon`/`authenticated` de Supabase.

### Cómo la usa la app

- **Login:** `POST /rest/v1/rpc/fn_login` con `{"p_username":"OP-01","p_password":"1234"}` → devuelve el usuario o una lista vacía.
- **Usuarios (admin):** `fn_listar_usuarios`, `fn_crear_usuario`, `fn_actualizar_usuario`. La tabla `usuarios` no es legible con la anon key, así el hash nunca sale de la base.
- **Catálogo:** `centros`, `trenes`, `lineas` por REST normal (`?activo=eq.true`).
- **Muestras:** insertar en `muestras` (siempre en `borrador`), leer desde `v_muestras_detalle`, cambiar estado con `PATCH`.
- **Reportes:** leer las vistas `v_reporte_*`.
- **Fotos:** subir al bucket `fotos-muestras` de Storage y guardar la URL pública en `muestras.foto_url`.

### Seguridad (límite conocido del MVP)

La app usa su propio login, no Supabase Auth, por eso las políticas RLS permiten operar con la anon key sobre catálogo y muestras. Es suficiente para la demo académica con datos ficticios; para producción conviene pasar a Supabase Auth y filtrar las políticas por usuario y rol, y reemplazar SHA-256 simple por un hash con sal.
