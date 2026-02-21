# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

**POWORSTACK** — Entretien et amélioration du stack IA/automatisation déployé sur les infrastructures de l'utilisateur : maintenance des configurations, amélioration continue des automatisations, fiabilisation des services existants.

**Langue** : fr — tout code, commentaires et documentation en français.
**Plateforme** : Windows 11 (shell bash via Git Bash)

## Services et intégrations

Le stack repose sur plusieurs services interconnectés (voir `.env.example` pour les variables requises) :

| Service | Rôle |
|---------|------|
| **n8n** | Orchestration de workflows et automatisations (2 instances) |
| **Supabase** | Base de données PostgreSQL, Auth, Edge Functions |
| **OpenRouter** | Routeur LLM (Gemini, Mistral, OpenAI) — provider principal |
| **Qdrant** | Base vectorielle pour knowledge base |
| **Odoo** | ERP / gestion (HMA) |
| **Pennylane** | Comptabilité |
| **Coolify** | Déploiement et hébergement des services |
| **Firecrawl** | Scraping web |
| **Playwright** | Tests navigateur et scraping |
| **Context7** | Documentation à jour des librairies |

## MCP Servers (`.mcp.json`)

Trois serveurs MCP configurés : `context7`, `playwright`, `supabase`.

## Commandes

```bash
# Mode YOLO (bypass permissions) — commandes custom
/yolo-on    # Active bypassPermissions dans .claude/settings.json
/yolo-off   # Désactive bypassPermissions

# Python sur Windows (encodage obligatoire)
PYTHONIOENCODING=utf-8 python mon_script.py
```

## Posture pédagogique

L'utilisateur est débutant. Agir en senior dev pédagogue : expliquer brièvement la logique du code et les bonnes pratiques au fil des tâches, vulgariser les technologies utilisées, une ou deux notions à la fois.

## Contraintes

- Toujours utiliser les outils MCP Context7 (`resolve-library-id` puis `query-docs`) pour tout code utilisant une librairie externe
- Préfixer `PYTHONIOENCODING=utf-8` pour toute commande Python sur Windows
- Ne jamais commiter `.claude/settings.local.json` ni les fichiers `.env`

## Conventions

- Commits en français, style descriptif
- Un skill = un fichier `.md` dans `.claude/skills/`
- Une commande = un fichier `.md` dans `.claude/commands/<groupe>/`

## Fichiers de référence

- `context.md` — Objectifs du projet
- `GUIDE_CONFIG.md` — Guide complet de configuration Claude Code (settings, permissions, MCP, plugins, skills, commands, hooks, Specify)
- `.env.example` — Variables d'environnement requises (template)
