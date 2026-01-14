# FC26 MultiPC Tools

**Herramientas para jugar EA SPORTS FC 26 en múltiples PCs con una misma cuenta/sesión**

---

## 🎯 ¿Para qué sirve?

Este repositorio contiene herramientas esenciales para:

- **Jugar FC26 en varios PCs simultáneamente** con la misma cuenta de EA
- **Gestionar backups automáticos** de partidas y modos carrera
- **Evitar conflictos de guardado** entre diferentes computadoras
- **Bloquear la conexión a internet** para evitar sincronización de la nube
- **Mantener el progreso seguro** sin perder partidas por sobreescritura

Diseñado para funcionar con **mods** como **LTA MOD** y otros mods de FIFA Mod Manager.

---

## 📁 Estructura del Repositorio

```
FC26 MultiPC Tools/
├── Bloquear Internet FC26/    # Herramientas para bloquear internet
│   ├── Bloquear_Internet_FC26.bat
│   ├── Desbloquear_Internet_FC26.bat
│   └── INSTRUCCIONES.txt
│
├── Gestor Backups/            # Sistema de backup automático
│   ├── Iniciar.bat            # ← ARCHIVO PRINCIPAL
│   ├── Gestor_Guardados_FC26.ps1
│   └── INSTRUCCIONES.txt
│
├── .gitignore
└── README.md
```

---

## 🔧 Herramientas Incluidas

### 1. Bloquear Internet FC26

Bloquea la conexión a internet **solo para FC26** usando el Firewall de Windows.

**¿Por qué es útil?**
- Evita que EA sincronice partidas con la nube
- Permite jugar en modo offline sin interferencias
- Ideal para usar mods sin problemas de conexión
- Permite que múltiples PCs usen la misma cuenta sin conflictos

**Uso:**
```
1. Ejecutar como Administrador: Bloquear_Internet_FC26.bat
2. Para desbloquear: Desbloquear_Internet_FC26.bat
```

### 2. Gestor de Backups Automático

Sistema de monitoreo que **crea backups automáticamente** cada vez que FC26 guarda una partida.

**Características:**
- ✅ Monitoreo en tiempo real de la carpeta de guardados
- ✅ Backups organizados por PC, fecha y hora
- ✅ Limpieza automática de cache pre-juego
- ✅ Compatible con modos carrera, settings y squads
- ✅ Cada PC tiene su propia carpeta de backups

**Archivos que respalda:**
| Archivo | Descripción |
|---------|-------------|
| `CmMgrC*` | Partidas de Modo Carrera |
| `Settings*` | Configuraciones de perfil |
| `Squads*` | Personajes creados |
| `overrideAutodetect.lua` | Configuración del juego |

**Uso:**
```
1. Ejecutar: Gestor Backups/Iniciar.bat
2. Primera vez: Opciones [1] y [2] para configurar
3. Uso diario: Opción [3] INICIO COMPLETO
4. Jugar FC26 normalmente
5. Los backups se crean automáticamente
```

---

## 🚀 Guía de Inicio Rápido

### Primera vez (configuración)

1. **Bloquear internet** (opcional pero recomendado):
   ```
   Ejecutar como Admin: Bloquear Internet FC26/Bloquear_Internet_FC26.bat
   ```

2. **Configurar el gestor de backups**:
   ```
   Ejecutar: Gestor Backups/Iniciar.bat
   Seleccionar: [1] Configurar rutas
   Seleccionar: [2] Crear carpeta de backups
   ```

### Uso diario

1. Ejecutar `Gestor Backups/Iniciar.bat`
2. Seleccionar `[3] INICIO COMPLETO`
3. Jugar FC26
4. Al terminar: `Ctrl+C` → Responder `N`

---

## 💻 Para Múltiples PCs

Si tienes **2 o más PCs** con FC26:

1. **Instala estas herramientas en TODOS los PCs**

2. **Bloquea internet en TODOS** antes de jugar

3. **Los backups se guardan separados por PC:**
   ```
   Backups Guardados/
   ├── PC-GAMING/        # Backups del PC 1
   │   └── 2026-01-14/
   │       └── 15-30-00/
   ├── LAPTOP-WORK/      # Backups del PC 2
   │   └── 2026-01-14/
   │       └── 18-45-00/
   ```

4. **Para transferir una partida entre PCs:**
   - Copia desde: `Backups Guardados/[PC-Origen]/[Fecha]/[Hora]/`
   - Pega en: `AppData\Local\EA SPORTS FC 26\settings\`

---

## 📍 Ubicaciones Importantes

| Carpeta | Ubicación |
|---------|-----------|
| **Partidas del juego** | `%LOCALAPPDATA%\EA SPORTS FC 26\settings` |
| **Backups** | `LTA MOD 26 V1\Backups Guardados\` |
| **Cache dinámico** | `%LOCALAPPDATA%\Temp\EA SPORTS FC 26\cache0\data\loc` |

---

## 🔮 Evoluciones Futuras

- [ ] Detección automática del slot de modo carrera
- [ ] Identificación de la fecha de la partida
- [ ] Sistema de limpieza de backups antiguos
- [ ] Interfaz gráfica (GUI)
- [ ] Sincronización entre PCs vía red local

---

## ⚠️ Notas Importantes

- **Ejecutar como Administrador** el bloqueador de internet
- El gestor de backups **no requiere** permisos de administrador
- Funciona con **LTA MOD** y otros mods de FIFA Mod Manager
- Los backups son **locales** (no se sincronizan con la nube)
- Siempre **bloquea internet** antes de jugar para evitar conflictos

---

## 📝 Licencia

Este proyecto está bajo la **licencia MIT (Non-Commercial)**.

### ⚖️ Términos de Uso

- ✅ **Uso personal y educativo**: Libre y gratuito
- ✅ **Modificación**: Puedes modificar el código para tus necesidades
- ✅ **Distribución**: Puedes compartir estas herramientas con otros
- ✅ **Atribución**: Se agradece mencionar el autor original
- ❌ **Uso comercial PROHIBIDO**: No se permite vender, comercializar o usar en productos comerciales

### ❤️ Hecho con amor para la comunidad

Estas herramientas fueron desarrolladas **con amor y dedicación** para la comunidad de mods de FC26. Son completamente **gratuitas y de código abierto** para ayudar a todos los jugadores a disfrutar del juego en múltiples PCs sin perder su progreso.

**No es un producto comercial** - Es un regalo para la comunidad que disfruta de mods como **LTA MOD** y otros mods de FIFA Mod Manager.

---

## 🤝 Créditos

Desarrollado **con amor** para mejorar la experiencia de juego con **LTA MOD** y facilitar el uso de FC26 en múltiples dispositivos.

**Para la comunidad, por la comunidad.** ❤️

---

*FC26 MultiPC Tools - Juega en todos tus PCs sin perder el progreso* 🎮
