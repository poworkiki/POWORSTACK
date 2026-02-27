# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

**POWORSTACK** — Entretien et amélioration du stack IA/automatisation déployé sur les infrastructures de l'utilisateur : maintenance des configurations, amélioration continue des automatisations, fiabilisation des services existants.

**Langue** : fr — tout code, commentaires et documentation en français.
**Plateforme** : Windows 11 (shell bash via Git Bash)

## Architecture

Projet de type **configuration-as-code** : pas de code source applicatif, mais la gestion centralisée d'un stack d'infrastructure IA/automatisation.

### VPS (Hetzner)

- **IP** : `168.231.69.226` — Ubuntu 24.04 LTS
- **Specs** : 4 vCPU AMD EPYC 9354P, 16 Go RAM, 193 Go disque
- **Coolify** : v4.0.0-beta.455 (Laravel/PHP) — PaaS self-hosted
- **SSH** : `ssh 168.231.69.226` (user `kiki`, clé `~/.ssh/id_ed25519`, groupes : sudo, docker)

### Services Coolify (projet POWOR_BUSINESS)

| Service | Type | URL | UUID |
|---------|------|-----|------|
| **poworbusiness_n8n** | n8n (principal) | `n8n.poworkiki.cloud` | `nwgkk4g84sswwogks0s4swoo` |
| **KIKIN8N** | n8n (secondaire) | `kikin8n.poworkiki.cloud` | `ms4k4ssss4k88woww4w8wgco` |
| **POWOR_SUPABASE** | Supabase self-hosted | via Kong | `jw84880scgs04sogssw8k888` |
| **POWOR_APPSMITH** | Appsmith (low-code) | via sslip.io | `b448o4k04kk404gcwowww0sk` |
| **odoo** | ERP (HMA) | `odoo.hmagestion.fr` | `b08gw8gow84wgoc00g8o48kw` |
| **qdrant** | Base vectorielle | via sslip.io | `pwcssg4cow44cgkwkkgo4wo0` |
| **powor-business-api** | Application FastAPI | `api.poworkiki.cloud` | `hc8cw8k8kgwcwkgkw4ckw40k` |
| **powor-dashboard** | Application Next.js | `dashboard.poworkiki.cloud` | `pk8kowg0804kksoc8owcws4w` |

### Services externes

| Service | Rôle |
|---------|------|
| **Supabase Cloud** | PostgreSQL, Auth, Edge Functions (instance cloud) |
| **OpenRouter** | Routeur LLM (Gemini, Mistral, OpenAI) — provider principal |
| **Pennylane** | Comptabilité |
| **Firecrawl** | Scraping web |

## Commandes

```bash
# Mode YOLO (bypass permissions) — commandes custom
/yolo-on    # Active bypassPermissions dans .claude/settings.json
/yolo-off   # Désactive bypassPermissions

# Python sur Windows (encodage obligatoire)
PYTHONIOENCODING=utf-8 python mon_script.py

# API Coolify — le token contient un pipe, utiliser des guillemets simples
curl -s 'https://coolify.poworkiki.cloud/api/v1/<endpoint>' \
  -H 'Authorization: Bearer 7|xxxxx'

# API Coolify — endpoints utiles
# GET /resources, /services, /applications
# GET /services/{uuid}, /applications/{uuid}
# POST /services/{uuid}/start|stop|restart
# POST /applications/{uuid}/start|stop|restart|execute
# GET /servers/{uuid}/domains, /servers/{uuid}/validate
# Note : les logs ne sont dispo via API que pour les applications, pas les services

# SSH vers le VPS
ssh 168.231.69.226          # user kiki, clé ed25519
# sudo demande un mot de passe (pas de NOPASSWD)
# docker est accessible sans sudo (kiki est dans le groupe docker)

# Diagnostic CPU spike (depuis ce repo)
ssh 168.231.69.226 'bash -s' < coolify/diag-cpu-spike.sh
```

## MCP Servers (`.mcp.json`)

Trois serveurs MCP configurés : `context7` (docs librairies), `playwright` (navigateur), `supabase` (gestion BDD cloud).

## Posture pédagogique

L'utilisateur est débutant. Agir en senior dev pédagogue : expliquer brièvement la logique du code et les bonnes pratiques au fil des tâches, vulgariser les technologies utilisées, une ou deux notions à la fois.

## Contraintes

- Toujours utiliser les outils MCP Context7 (`resolve-library-id` puis `query-docs`) pour tout code utilisant une librairie externe
- Préfixer `PYTHONIOENCODING=utf-8` pour toute commande Python sur Windows
- Ne jamais commiter `.claude/settings.local.json` ni les fichiers `.env`
- Deux instances Supabase coexistent : **cloud** (`SUPABASE_*`) et **self-hosted** (`COOLIFY_SUPABASE_*`) — ne pas les confondre
- Le token Coolify contient un `|` — toujours utiliser des guillemets simples en bash pour éviter l'interprétation pipe

## Conventions

- Commits en français, style descriptif
- Un skill = un fichier `.md` dans `.claude/skills/`
- Une commande = un fichier `.md` dans `.claude/commands/<groupe>/`
- Scripts serveur dans `coolify/`

## Fichiers de référence

- `context.md` — Objectifs du projet et posture pédagogique
- `GUIDE_CONFIG.md` — Guide complet de configuration Claude Code
- `.env.example` — Variables d'environnement requises (template)
- `.env` — Variables réelles avec tokens et mots de passe (gitignored)
- `coolify/diag-cpu-spike.sh` — Script de diagnostic CPU (mpstat, ps, docker stats, iostat)
