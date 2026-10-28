# Prompt para continuar en Claude Code

Abre Claude Code en la raíz del repositorio `TrazaMar_by_NotFound` (con la carpeta `database/` ya copiada) y pega el bloque de abajo. Reemplaza `<SUPABASE_URL>` y `<SUPABASE_ANON_KEY>` por los de tu proyecto (Supabase → Project Settings → API).

---

```text
Contexto: este repo es TrazaMar, una app Android en Kotlin + Jetpack Compose (paquete cl.aldemar.trazamar) para el caso académico AquaSample (registro y trazabilidad de muestras de choritos). Hoy funciona 100% local con Room (data/local) y repositorios en data/repository que devuelven ResultadoApi.

Ya existe la carpeta database/ con:
- database/oracle/*.sql  (modelo en Oracle, para la entrega)
- database/supabase/migrations/20261028000000_esquema_inicial.sql y database/supabase/seed.sql (mismo modelo en PostgreSQL, con RLS, vistas y funciones RPC)
- database/README.md (explica tablas, vistas, RPC y cómo la usa la app)

Lee primero database/README.md y la migración de Supabase.

Tareas, en este orden:

1. Git: crea la rama feature/base-de-datos, agrega database/ y haz commit "Agrega base de datos Oracle y migración Supabase". No hagas push todavía.

2. Supabase CLI: si no existe supabase/config.toml en la raíz, ejecuta `supabase init` y mueve/copia database/supabase/migrations/* a supabase/migrations/ y database/supabase/seed.sql a supabase/seed.sql. Luego dime qué comandos debo correr yo (supabase login, supabase link --project-ref, supabase db push) en vez de correrlos tú si necesitan mis credenciales.

3. Conectar la app con Supabase SIN romper el modo offline:
   - Agrega supabase-kt (postgrest-kt, storage-kt) y Ktor client para Android en app/build.gradle.kts, con las versiones estables actuales (verifícalas).
   - Guarda SUPABASE_URL y SUPABASE_ANON_KEY en local.properties y exponlos vía BuildConfig (no los subas al repo; confirma que local.properties está en .gitignore).
     SUPABASE_URL=<SUPABASE_URL>
     SUPABASE_ANON_KEY=<SUPABASE_ANON_KEY>
   - Crea data/remote/SupabaseProvider.kt con el cliente singleton.
   - Mapea columnas snake_case <-> camelCase con @SerialName en DTOs remotos (no cambies los DTOs actuales si no es necesario).
   - AuthRepository.login: llamar rpc("fn_login", p_username, p_password); si hay respuesta guardar sesión como hoy; si falla la red, usar el login local con Room como respaldo.
   - UsuarioRepository: usar fn_listar_usuarios, fn_crear_usuario, fn_actualizar_usuario.
   - CatalogoRepository: leer/crear centros, trenes, lineas en Supabase y refrescar la caché Room (centros_cache, trenes_cache, lineas_cache).
   - MuestraRepository: insertar en "muestras" (estado borrador), leer desde la vista "v_muestras_detalle", revisar/enviar con update del estado; guardar en muestras_cache. Las muestras creadas sin conexión (id negativo, sincronizada=false) deben subirse cuando vuelva la red.
   - Fotos: subir al bucket "fotos-muestras" y guardar la URL pública en foto_url.
   - Reportes (ResumenScreen): leer v_reporte_por_estado, v_reporte_por_centro, v_reporte_serie_temporal.
   - Mantén las reglas de util/Reglas.kt y que ReglasTest siga pasando.

4. Compila (./gradlew assembleDebug) y corre los tests (./gradlew test). Corrige errores.

5. Actualiza README_LOCAL.md (o crea README.md) explicando la configuración de Supabase.

6. Muéstrame un resumen de los cambios y espera mi confirmación antes de hacer push y abrir el PR.

Trabaja paso a paso y explícame brevemente cada cambio, porque debo presentarlo en la universidad.
```
