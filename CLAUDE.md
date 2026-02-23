# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

**POWORSTACK** — Entretien et amélioration du stack IA/automatisation déployé sur les infrastructures de l'utilisateur : maintenance des configurations, amélioration continue des automatisations, fiabilisation des services existants.

**Langue** : fr — tout code, commentaires et documentation en français.
**Plateforme** : Windows 11 (shell bash via Git Bash)

## Architecture

Projet de type **configuration-as-code** : pas de code source applicatif, mais la gestion centralisée d'un stack d'infrastructure IA/automatisation hébergé sur un serveur Coolify (IP `168.231.69.226`).

### Services Coolify (projet POWOR_BUSINESS)

| Service | Type | URL / Accès |
|---------|------|-------------|
| **poworbusiness_n8n** | n8n (principal) | `n8n.poworkiki.cloud` |
| **KIKIN8N** | n8n (secondaire) | `kikin8n.poworkiki.cloud` |
| **POWOR_SUPABASE** | Supabase self-hosted | via Kong (voir `.env`) |
| **POWOR_APPSMITH** | Appsmith (low-code) | via sslip.io (voir `.env`) |
| **odoo** | ERP (HMA) | `odoo.hmagestion.fr` |
| **qdrant** | Base vectorielle | via sslip.io (voir `.env`) |
| **powor-business-api** | Application | `api.poworkiki.cloud` |
| **powor-dashboard** | Application | `dashboard.poworkiki.cloud` |

### Services externes

| Service | Rôle |
|---------|------|
| **Supabase Cloud** | PostgreSQL, Auth, Edge Functions (instance cloud) |
| **OpenRouter** | Routeur LLM (Gemini, Mistral, OpenAI) — provider principal |
| **Pennylane** | Comptabilité |
| **Firecrawl** | Scraping web |

### API Coolify

- Base URL : `https://coolify.poworkiki.cloud/api/v1`
- Auth : `Authorization: Bearer <COOLIFY_API_TOKEN>`
- Endpoints utiles : `/resources`, `/services`, `/services/{uuid}`, `/services/{uuid}/start|stop|restart`, `/servers/{uuid}/domains`
- Les logs ne sont disponibles via l'API que pour les **applications** (`/applications/{uuid}/logs`), pas pour les services

## MCP Servers (`.mcp.json`)

Trois serveurs MCP configurés : `context7` (docs librairies), `playwright` (navigateur), `supabase` (gestion BDD cloud).

## Commandes

```bash
# Mode YOLO (bypass permissions) — commandes custom
/yolo-on    # Active bypassPermissions dans .claude/settings.json
/yolo-off   # Désactive bypassPermissions

# Python sur Windows (encodage obligatoire)
PYTHONIOENCODING=utf-8 python mon_script.py

# API Coolify — pattern récurrent
curl -s "https://coolify.poworkiki.cloud/api/v1/<endpoint>" \
  -H "Authorization: Bearer $COOLIFY_API_TOKEN"
```

## Posture pédagogique

L'utilisateur est débutant. Agir en senior dev pédagogue : expliquer brièvement la logique du code et les bonnes pratiques au fil des tâches, vulgariser les technologies utilisées, une ou deux notions à la fois.

## Contraintes

- Toujours utiliser les outils MCP Context7 (`resolve-library-id` puis `query-docs`) pour tout code utilisant une librairie externe
- Préfixer `PYTHONIOENCODING=utf-8` pour toute commande Python sur Windows
- Ne jamais commiter `.claude/settings.local.json` ni les fichiers `.env`
- Deux instances Supabase coexistent : **cloud** (`SUPABASE_*`) et **self-hosted** (`COOLIFY_SUPABASE_*`) — ne pas les confondre

## Conventions

- Commits en français, style descriptif
- Un skill = un fichier `.md` dans `.claude/skills/`
- Une commande = un fichier `.md` dans `.claude/commands/<groupe>/`

## Fichiers de référence

- `context.md` — Objectifs du projet et posture pédagogique
- `GUIDE_CONFIG.md` — Guide complet de configuration Claude Code
- `.env.example` — Variables d'environnement requises (template)
- `.env` — Variables réelles avec tokens et mots de passe (gitignored)
