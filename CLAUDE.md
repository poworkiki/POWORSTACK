# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projet

**POWORSTACK** — Stack d'outils IA et d'automatisation dont l'objectif est d'**entretenir et améliorer le stack** déployé sur les infrastructures de l'utilisateur : maintenance des configurations, amélioration continue des automatisations, fiabilisation des services existants.

**Langue** : fr — tout code, commentaires, et documentation en français.
**Plateforme** : Windows 11 (shell bash via Git Bash)

## Stack technique

Projet multi-outils, pas de stack applicative fixe :
- **Claude Code** : Agent IA principal (CLI)
- **n8n** : Orchestration de workflows et automatisations
- **Supabase** : Base de données PostgreSQL, Auth, Edge Functions
- **Playwright** : Tests navigateur et scraping
- **Context7** : Documentation à jour des librairies

## MCP Servers configurés (`.mcp.json`)

| Serveur | Usage |
|---------|-------|
| `context7` | Docs à jour de librairies (`resolve-library-id` → `query-docs`) |
| `playwright` | Tests navigateur, screenshots, interactions web |
| `supabase` | Gestion Supabase (SQL, migrations, edge functions) |

## Commandes

```bash
# État du projet
git status

# MCP servers
claude mcp list

# Mode YOLO (bypass permissions) — commandes custom
/yolo-on    # Active bypassPermissions dans .claude/settings.json
/yolo-off   # Désactive bypassPermissions

# Python sur Windows (encodage obligatoire)
PYTHONIOENCODING=utf-8 python mon_script.py
```

## Architecture

```
POWORSTACK/
├── CLAUDE.md              # Instructions projet (ce fichier)
├── context.md             # Contexte et objectifs du projet
├── GUIDE_CONFIG.md        # Guide complet de configuration Claude Code
├── .claude/
│   ├── settings.json      # Permissions partagées (commitées)
│   ├── settings.local.json # Permissions locales (gitignorées)
│   ├── skills/            # Skills custom (.md)
│   └── commands/          # Slash commands custom (.md)
├── .mcp.json              # Configuration MCP servers
└── .env                   # Variables d'environnement (gitignorées)
```

`GUIDE_CONFIG.md` est la référence complète pour configurer Claude Code (settings, permissions, MCP, plugins, skills, commands, hooks, Specify).

## Contraintes importantes

- Toujours utiliser les outils MCP Context7 (`resolve-library-id` puis `query-docs`) pour tout code utilisant une librairie externe
- Préfixer `PYTHONIOENCODING=utf-8` pour toute commande Python sur Windows
- Ne jamais commiter `.claude/settings.local.json` ni les fichiers `.env`

## Conventions

- Commits en français, style descriptif
- Un skill = un fichier `.md` dans `.claude/skills/`
- Une commande = un fichier `.md` dans `.claude/commands/<groupe>/`
