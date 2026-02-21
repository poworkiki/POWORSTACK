# CLAUDE.md

## Projet

**POWORSTACK** — Stack d'outils IA et d'automatisation. Espace centralisé regroupant configurations, skills, workflows et outils pour travailler efficacement avec Claude Code, n8n, et d'autres services d'IA/automatisation.

**Langue** : fr — tout code, commentaires, et documentation en français.
**Plateforme** : Windows 11 (shell bash via Git Bash)

## Stack technique

Pas de stack fixe — projet multi-outils :
- **Claude Code** : Agent IA principal (CLI)
- **n8n** : Orchestration de workflows et automatisations
- **Supabase** : Base de données PostgreSQL, Auth, Edge Functions (si besoin)
- **Playwright** : Tests navigateur et scraping
- **Context7** : Documentation à jour des librairies

## Commandes essentielles

```bash
# Vérifier l'état du projet
git status

# Lancer Claude Code
claude

# Vérifier les MCP servers
claude mcp list
```

## Architecture

```
POWORSTACK/
├── CLAUDE.md                    # Ce fichier — instructions projet
├── GUIDE_CONFIG.md              # Guide de configuration Claude Code
├── .claude/
│   ├── settings.json            # Permissions partagées (équipe)
│   ├── settings.local.json      # Permissions locales (gitignore)
│   ├── skills/                  # Skills custom
│   └── commands/                # Slash commands custom
├── .mcp.json                    # Configuration MCP servers
└── .gitignore                   # Fichiers ignorés par git
```

## Contraintes importantes

- Toujours utiliser les outils MCP Context7 (`resolve-library-id` puis `query-docs`) pour tout code utilisant une librairie externe
- Code et commentaires en français
- Préfixer `PYTHONIOENCODING=utf-8` pour les commandes Python/specify sur Windows
- Ne jamais commiter `.claude/settings.local.json` ni les fichiers `.env`

## Conventions

- Commits en français, style descriptif
- Un skill = un fichier `.md` dans `.claude/skills/`
- Une commande = un fichier `.md` dans `.claude/commands/<groupe>/`
