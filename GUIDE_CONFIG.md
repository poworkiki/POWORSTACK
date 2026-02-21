# Guide de Configuration Rapide — Claude Code

Guide pour configurer rapidement Claude Code sur un nouveau projet. Couvre : settings, permissions, MCP servers, plugins, skills, Specify (spec-kit), CLAUDE.md, et memory.

---

## Table des matieres

1. [Structure des fichiers](#1-structure-des-fichiers)
2. [Settings globaux](#2-settings-globaux)
3. [Settings projet](#3-settings-projet)
4. [Permissions](#4-permissions)
5. [MCP Servers](#5-mcp-servers)
6. [Plugins](#6-plugins)
7. [Skills personnalisees](#7-skills-personnalisees)
8. [CLAUDE.md (instructions projet)](#8-claudemd)
9. [Memory (memoire persistante)](#9-memory)
10. [Commands personnalisees](#10-commands-personnalisees)
11. [Hooks](#11-hooks)
12. [Specify / Spec-Kit (spec-driven dev)](#12-specify--spec-kit)
13. [Checklist demarrage rapide](#13-checklist-demarrage-rapide)

---

## 1. Structure des fichiers

```
~/.claude/                          # Config GLOBALE (tous projets)
  settings.json                     # Settings globaux (env, plugins, channel)
  plugins/                          # Plugins installes
  projects/<hash-projet>/
    memory/MEMORY.md                # Memoire persistante par projet

<projet>/                           # Config PROJET
  CLAUDE.md                         # Instructions projet (commit dans git)
  .claude/
    settings.json                   # Permissions PARTAGEES (commit dans git)
    settings.local.json             # Permissions LOCALES (gitignore)
    skills/                         # Skills custom du projet
      mon-skill.md                  # Skill simple (fichier .md)
      mon-skill-avance/             # Skill avance (dossier)
        SKILL.md                    # Entrypoint du skill
        data/                       # Ressources du skill
    commands/                       # Slash commands custom
      mon-groupe/
        ma-commande.md              # Commande /mon-groupe:ma-commande
```

---

## 2. Settings globaux

**Fichier** : `~/.claude/settings.json`

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "enabledPlugins": {
    "example-skills@anthropic-agent-skills": true
  },
  "autoUpdatesChannel": "latest"
}
```

### Variables d'environnement utiles

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Active le mode equipes multi-agents |
| `ANTHROPIC_API_KEY` | Cle API Anthropic (si pas de Max/Pro) |
| `CLAUDE_CODE_MAX_TURNS` | Limite de tours par conversation |

---

## 3. Settings projet

### Permissions partagees (`.claude/settings.json`)

Commite dans git, partage avec l'equipe :

```json
{
  "permissions": {
    "allow": [
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(pytest:*)",
      "Bash(python:*)",
      "Bash(npm install:*)",
      "Bash(npm run:*)",
      "Skill(*)",
      "WebSearch"
    ],
    "deny": []
  }
}
```

### Permissions locales (`.claude/settings.local.json`)

Gitignore, specifique a ta machine :

```json
{
  "permissions": {
    "allow": [
      "Bash(git push:*)",
      "Bash(ssh:*)",
      "Bash(curl:*)",
      "Bash(docker:*)",
      "Bash(powershell:*)",
      "mcp__playwright__browser_navigate",
      "mcp__playwright__browser_take_screenshot",
      "mcp__playwright__browser_click",
      "mcp__playwright__browser_snapshot",
      "mcp__context7__resolve-library-id",
      "mcp__context7__query-docs",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:*)"
    ],
    "deny": []
  }
}
```

### Syntaxe des permissions

```
"Read(*)"                           # Toutes les lectures
"Bash(git:*)"                       # Toute commande commencant par "git"
"Bash(npm run dev:*)"               # Commande specifique
"mcp__<server>__<tool>"             # Outil MCP specifique
"WebFetch(domain:example.com)"      # Fetch sur un domaine specifique
"WebSearch"                         # Recherche web
"Skill(*)"                          # Tous les skills
```

---

## 4. Permissions

### Mode interactif (par defaut)

Claude demande confirmation pour chaque outil non autorise.

### Mode bypass / YOLO (`--dangerously-skip-permissions`)

Tout est autorise sans confirmation. **Utiliser uniquement en dev local.**

```bash
# Au lancement
claude --dangerously-skip-permissions
```

#### Commandes slash pour activer/desactiver en session

Deux commandes custom dans `.claude/commands/` permettent de basculer le mode YOLO sans relancer Claude Code :

| Commande | Effet |
|----------|-------|
| `/yolo-on` | Ajoute `"defaultMode": "bypassPermissions"` dans `.claude/settings.json` |
| `/yolo-off` | Retire `"defaultMode": "bypassPermissions"` de `.claude/settings.json` |

> **Note** : Le changement prend effet au prochain lancement de Claude Code.

#### Configuration manuelle equivalente

Dans `.claude/settings.json` :

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
```

Valeurs possibles pour `defaultMode` :

| Mode | Comportement |
|------|-------------|
| `default` | Demande confirmation (defaut) |
| `acceptEdits` | Auto-accepte les editions de fichiers |
| `plan` | Analyse sans modifier ni executer |
| `dontAsk` | Refuse tout sauf outils pre-approuves |
| `bypassPermissions` | Aucune verification (mode YOLO) |

### Bonnes pratiques

- **Commiter** `.claude/settings.json` (permissions equipe)
- **Gitignore** `.claude/settings.local.json` (permissions personnelles)
- **Autoriser** les outils frequents pour eviter le spam de confirmations
- **Denier** les commandes destructives (`rm -rf`, `git push --force`, etc.)

---

## 5. MCP Servers

Les MCP servers ajoutent des outils externes a Claude Code (bases de donnees, APIs, navigateur, etc.).

### Ajout via CLI

```bash
# Serveur stdio (npx)
claude mcp add context7 npx -y @upstash/context7-mcp

# Serveur stdio (node)
claude mcp add mon-serveur node /chemin/vers/server.js

# Serveur HTTP/SSE
claude mcp add supabase --transport http https://mcp.supabase.com/mcp

# Serveur avec variables d'env
claude mcp add mon-db npx -y @mcp/postgres-server -- --connection-string "$DATABASE_URL"

# Scope : user (global), project (projet actuel)
claude mcp add --scope user context7 npx -y @upstash/context7-mcp
claude mcp add --scope project mon-serveur npx ./my-server.js
```

### Ajout via fichier `.mcp.json` (racine du projet)

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp"
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb"
      }
    }
  }
}
```

### Serveurs MCP les plus utiles

| Serveur | Package | Usage |
|---------|---------|-------|
| **Context7** | `@upstash/context7-mcp` | Docs a jour de n'importe quelle librairie |
| **Playwright** | `@playwright/mcp@latest` | Tests navigateur, screenshots, interactions web |
| **Supabase** | HTTP `mcp.supabase.com/mcp` | Gestion Supabase (SQL, migrations, edge functions) |
| **Postgres** | `@modelcontextprotocol/server-postgres` | Acces direct PostgreSQL |
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | Acces fichiers (sandbox) |
| **GitHub** | `@modelcontextprotocol/server-github` | Issues, PRs, repos |
| **Notion** | HTTP (via plugin) | Pages, databases Notion |
| **Slack** | Via plugin | Messages, channels Slack |
| **n8n** | Via plugin Claude.ai | Workflows n8n |

### Gestion MCP

```bash
claude mcp list                     # Lister les serveurs
claude mcp remove context7          # Supprimer un serveur
claude mcp get context7             # Details d'un serveur
```

---

## 6. Plugins

Les plugins ajoutent des skills, MCP servers, et hooks pre-configures.

### Activer un plugin

Dans `~/.claude/settings.json` :

```json
{
  "enabledPlugins": {
    "example-skills@anthropic-agent-skills": true
  }
}
```

### Plugins officiels Anthropic

**Skills (via `example-skills@anthropic-agent-skills`)** :
- `xlsx` — Lecture/ecriture Excel
- `docx` — Documents Word
- `pptx` — Presentations PowerPoint
- `pdf` — Manipulation PDF
- `algorithmic-art` — Art generatif p5.js
- `frontend-design` — Design frontend production-grade
- `canvas-design` — Art visuel PNG/PDF
- `webapp-testing` — Tests web avec Playwright
- `mcp-builder` — Creation serveurs MCP
- `skill-creator` — Creation de skills
- `web-artifacts-builder` — Artifacts web React/shadcn
- `doc-coauthoring` — Co-ecriture documentaire
- `theme-factory` — Theming d'artifacts
- `slack-gif-creator` — GIFs animes pour Slack
- `brand-guidelines` — Charte graphique Anthropic
- `internal-comms` — Communications internes

**Plugins integres (marketplace officiel)** :
- `code-review` — Review de code multi-agents
- `commit-commands` — Commandes git
- `feature-dev` — Dev de features
- `security-guidance` — Guidance securite
- `frontend-design` — Design frontend
- `claude-md-management` — Gestion CLAUDE.md
- `hookify` — Creation de hooks
- `ralph-loop` — Boucle d'iteration

**External plugins (MCP integres)** :
- `context7` — Documentation librairies (Context7)
- `playwright` — Tests navigateur
- `supabase` — Gestion Supabase
- `firebase` — Firebase
- `github` — GitHub
- `gitlab` — GitLab
- `linear` — Linear (gestion projet)
- `slack` — Slack
- `stripe` — Stripe
- `asana` — Asana
- `greptile` — Recherche code semantique
- `serena` — LSP assistant

### Installer un plugin (CLI)

```bash
# Lister les plugins disponibles
claude plugin list

# Installer un plugin
claude plugin install example-skills@anthropic-agent-skills

# Desinstaller
claude plugin uninstall example-skills@anthropic-agent-skills
```

---

## 7. Skills personnalisees

Les skills sont des fichiers `.md` dans `.claude/skills/` qui donnent a Claude des connaissances et workflows specialises.

### Skill simple (fichier unique)

**`.claude/skills/mon-skill.md`** :

```markdown
# Nom du skill

Description de ce que fait ce skill et quand l'utiliser.

## Quand utiliser

Utiliser pour : [cas d'usage 1], [cas d'usage 2], [cas d'usage 3].

---

## Instructions

1. Etape 1...
2. Etape 2...

## Exemples

### Exemple 1

...code ou instructions...
```

### Skill avance (dossier avec SKILL.md)

**`.claude/skills/mon-skill-avance/SKILL.md`** :

```markdown
---
name: mon-skill-avance
description: Description du skill pour le trigger automatique.
license: MIT
metadata:
  author: Mon nom
  version: "1.0"
---

Instructions detaillees du skill...

Peut referencer des fichiers dans le meme dossier :
- Voir `./data/templates.json`
- Voir `./examples/example1.md`
```

### Exemples de skills utiles par domaine

**Comptabilite francaise** :
```markdown
# Comptabilite francaise

Expertise comptable : PCG, normes ANC, fiscalite, ecritures types, ratios d'analyse.

## Quand utiliser
Toute question de comptabilite francaise, ecritures comptables, fiscalite IS/TVA, analyse financiere.

## Regles
- Plan Comptable General (PCG) : comptes 1-7
- Ecritures : toujours equilibrees (debit = credit)
- Exercice fiscal : 12 mois, cloture 31/12 par defaut
...
```

**Integration n8n** :
```markdown
# n8n Workflow Patterns

Patterns d'integration n8n pour automatisations.

## Quand utiliser
Conception ou debug de workflows n8n, configuration de noeuds, expressions.

## Patterns
- Webhook -> traitement -> reponse
- Schedule -> fetch data -> transform -> store
...
```

---

## 8. CLAUDE.md

Le fichier `CLAUDE.md` a la racine du projet est le plus important. Claude le lit **automatiquement** a chaque conversation.

### Template minimal

```markdown
# CLAUDE.md

## Projet
[Nom et description en 2-3 lignes]

## Stack technique
- Backend : [Python/Node/Go/...] + [framework]
- Frontend : [React/Vue/...] + [framework CSS]
- Base de donnees : [PostgreSQL/MySQL/...]
- Deploiement : [Docker/Vercel/Coolify/...]

## Commandes essentielles

### Developpement
\`\`\`bash
# Installer les deps
[commande]

# Lancer le serveur dev
[commande]

# Lancer les tests
[commande]

# Linter / formatter
[commande]
\`\`\`

### Deploiement
\`\`\`bash
[commandes de deploy]
\`\`\`

## Architecture
[Description des couches principales, entrypoints, patterns utilises]

## Contraintes importantes
- [Contrainte 1 : ex. "Pas de TVA en Guyane"]
- [Contrainte 2 : ex. "Toujours utiliser async/await"]
- [Contrainte 3 : ex. "Code et commentaires en francais"]

## Conventions
- [Convention 1 : style de commit, nommage, etc.]
- [Convention 2 : patterns de code obligatoires]
```

### Template complet (projet complexe)

```markdown
# CLAUDE.md

## Project Overview
[Description, contexte metier, utilisateurs cibles]

**Langue** : [fr/en] — tout code, commentaires, UI en [langue].
**Plateforme** : [OS/infra specifique]

## Build & Development Commands

### Backend
\`\`\`bash
pip install -e ".[dev]"
pytest
ruff check src/ tests/
\`\`\`

### Frontend
\`\`\`bash
cd frontend && npm install && npm run dev
\`\`\`

### Deploiement
\`\`\`bash
[commandes deploy]
\`\`\`

## Architecture

### Couches systeme
\`\`\`
[Schema ASCII de l'architecture]
\`\`\`

### Structure du code
| Dossier | Contenu |
|---------|---------|
| `src/api/` | Routes FastAPI |
| `src/services/` | Logique metier |
| `src/db/` | Modeles et sessions DB |

### Entrypoints
- API : `src/api/main.py`
- Frontend : `frontend/src/app/`

## Contraintes critiques
1. [Regle 1]
2. [Regle 2]
3. [Regle 3]

## Configuration
- **Env** : `.env` charge par [pydantic-settings/dotenv/...]
- **Tests** : [config pytest/jest/...]
- **Linter** : [config ruff/eslint/...]

## Documentation
| Fichier | Contenu |
|---------|---------|
| `.claude/ARCHITECTURE.md` | Architecture technique detaillee |
| `.claude/SPEC.md` | Specification fonctionnelle |

## Utilisation obligatoire de Context7
[Si vous voulez forcer l'usage de docs a jour pour les libs]

Toujours utiliser les outils MCP Context7 (`resolve-library-id` puis `query-docs`)
automatiquement pour tout code utilisant une librairie externe.
```

---

## 9. Memory

La memoire persistante permet a Claude de se souvenir entre les conversations.

**Emplacement** : `~/.claude/projects/<hash-projet>/memory/MEMORY.md`

### Ce qu'il faut y mettre

- Patterns et conventions confirmes
- Decisions architecturales
- Chemins de fichiers importants
- Preferences de workflow
- Solutions a des problemes recurrents
- Infos de deploiement (UUIDs, URLs, credentials de dev)

### Ce qu'il ne faut PAS y mettre

- Contexte de session en cours
- Informations non verifiees
- Doublons du CLAUDE.md

### Demander a Claude de memoriser

Dire directement :
- "Retiens que j'utilise toujours bun au lieu de npm"
- "N'oublie pas : le deploy se fait via Coolify"
- "Memorise cette URL de staging : ..."

---

## 10. Commands personnalisees

Creez des slash commands custom dans `.claude/commands/`.

**`.claude/commands/mon-groupe/ma-commande.md`** :

```markdown
Analyse le code du fichier $ARGUMENTS et genere un rapport de qualite incluant :
1. Complexite cyclomatique
2. Couverture de tests manquante
3. Violations de principes SOLID
4. Suggestions d'amelioration

Formate le resultat en tableau markdown.
```

**Usage** : `/mon-groupe:ma-commande src/api/main.py`

### Variables disponibles dans les commands

- `$ARGUMENTS` — Texte apres la commande
- Les commands sont des templates de prompt (pas du code)

---

## 11. Hooks

Les hooks executent des commandes shell en reponse a des evenements Claude Code.

**`.claude/hooks.json`** ou via settings :

```json
{
  "hooks": {
    "pre-tool-use": [
      {
        "tool": "Write",
        "command": "echo 'Ecriture fichier: $TOOL_INPUT_FILE_PATH'"
      }
    ],
    "post-tool-use": [
      {
        "tool": "Bash",
        "command": "echo 'Commande executee'"
      }
    ],
    "on-notification": [
      {
        "command": "notify-send 'Claude Code' '$NOTIFICATION_MESSAGE'"
      }
    ]
  }
}
```

### Evenements disponibles

| Evenement | Quand |
|-----------|-------|
| `pre-tool-use` | Avant l'execution d'un outil |
| `post-tool-use` | Apres l'execution d'un outil |
| `on-notification` | Quand Claude envoie une notification |

---

## 12. Specify / Spec-Kit (spec-driven dev)

GitHub Spec-Kit est un toolkit de "spec-driven development" qui structure le travail avec des agents IA via des specs, plans, et taches.

### Installation

```bash
# Installer specify-cli via uv (recommande)
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Verifier l'installation (Windows : prefixer PYTHONIOENCODING=utf-8)
PYTHONIOENCODING=utf-8 specify version
PYTHONIOENCODING=utf-8 specify check
```

> **Windows** : `specify` utilise Rich qui crash en CP1252. Toujours prefixer avec `PYTHONIOENCODING=utf-8`.

### Initialiser un projet

```bash
# Nouveau dossier
PYTHONIOENCODING=utf-8 specify init mon-projet --ai claude --ai-skills

# Dans le dossier courant (existant)
PYTHONIOENCODING=utf-8 specify init --here --ai claude --ai-skills --force

# Sans initialiser git (si deja un repo)
PYTHONIOENCODING=utf-8 specify init --here --ai claude --ai-skills --no-git --force
```

Options `--ai` disponibles : `claude`, `gemini`, `copilot`, `cursor-agent`, `codex`, `windsurf`, `kilocode`, `auggie`, `qwen`, `opencode`, `generic`.

### Fichiers crees

```
.claude/commands/                    # Slash commands speckit
  speckit.analyze.md                 # /speckit:analyze — Analyse qualite
  speckit.checklist.md               # /speckit:checklist — Checklist custom
  speckit.clarify.md                 # /speckit:clarify — Clarifier les specs
  speckit.constitution.md            # /speckit:constitution — Constitution projet
  speckit.implement.md               # /speckit:implement — Implementer les taches
  speckit.plan.md                    # /speckit:plan — Planifier l'implementation
  speckit.specify.md                 # /speckit:specify — Creer/MAJ une spec
  speckit.tasks.md                   # /speckit:tasks — Generer les taches
  speckit.taskstoissues.md           # /speckit:taskstoissues — Taches -> GitHub Issues

.specify/                            # Configuration et templates
  scripts/bash/                      # Scripts utilitaires
    common.sh
    update-agent-context.sh
    create-new-feature.sh
    setup-plan.sh
    check-prerequisites.sh
  templates/                         # Templates de documents
    spec-template.md
    plan-template.md
    tasks-template.md
    checklist-template.md
    constitution-template.md
    agent-file-template.md
```

### Workflow typique Specify

```
1. /speckit:constitution         # Definir les principes du projet (une seule fois)
2. /speckit:specify <feature>    # Ecrire la spec d'une feature
3. /speckit:clarify              # Clarifier les zones floues (5 questions)
4. /speckit:plan                 # Generer le plan d'implementation
5. /speckit:tasks                # Generer les taches ordonnees
6. /speckit:analyze              # Verifier la coherence spec/plan/taches
7. /speckit:checklist            # Generer une checklist de validation
8. /speckit:implement            # Executer les taches une par une
9. /speckit:taskstoissues        # (Optionnel) Convertir en GitHub Issues
```

### Telecharger manuellement le template (si `specify init` bloque)

```bash
# Lister les assets de la derniere release
gh api repos/github/spec-kit/releases/latest --jq '.assets[].browser_download_url'

# Telecharger le template Claude (sh = bash, ps = powershell)
gh release download v0.1.5 --repo github/spec-kit \
  --pattern "spec-kit-template-claude-sh-v0.1.5.zip" --dir /tmp

# Extraire dans le projet
python -c "
import zipfile
with zipfile.ZipFile('/tmp/spec-kit-template-claude-sh-v0.1.5.zip', 'r') as z:
    z.extractall('.')
"
```

---

## 13. Checklist demarrage rapide

### Nouveau projet — Setup en 5 minutes

```bash
# 1. Creer la structure
mkdir -p .claude/skills .claude/commands

# 2. Creer CLAUDE.md (le plus important !)
# → Decrire le projet, la stack, les commandes, l'architecture

# 3. Configurer les permissions partagees
# → .claude/settings.json avec les outils autorises

# 4. Ajouter les MCP servers essentiels
claude mcp add context7 npx -y @upstash/context7-mcp
claude mcp add playwright npx @playwright/mcp@latest

# 5. Activer les plugins utiles (settings globaux)
# → ~/.claude/settings.json → enabledPlugins

# 6. Ajouter des skills custom si necessaire
# → .claude/skills/mon-skill.md

# 7. (Optionnel) Initialiser Specify pour le spec-driven dev
PYTHONIOENCODING=utf-8 specify init --here --ai claude --ai-skills --no-git --force

# 8. Gitignore les fichiers locaux
echo ".claude/settings.local.json" >> .gitignore
```

### Config minimale recommandee

| Fichier | Obligatoire | Commit |
|---------|:-----------:|:------:|
| `CLAUDE.md` | **Oui** | Oui |
| `.claude/settings.json` | Recommande | Oui |
| `.claude/settings.local.json` | Optionnel | Non |
| `.claude/skills/*.md` | Optionnel | Oui |
| `.claude/commands/**/*.md` | Optionnel | Oui |
| `.mcp.json` | Optionnel | Oui |
| `.specify/` | Optionnel | Oui |

### Copier la config d'un projet existant

```bash
# Depuis le projet source
cp CLAUDE.md /chemin/nouveau-projet/

# Copier les skills (adapter au nouveau projet)
cp -r .claude/skills/ /chemin/nouveau-projet/.claude/skills/

# Copier les permissions (adapter)
cp .claude/settings.json /chemin/nouveau-projet/.claude/settings.json

# Copier la config MCP (adapter)
cp .mcp.json /chemin/nouveau-projet/.mcp.json
```

---

## Ressources

- **Documentation officielle** : `claude --help`, `/help` dans Claude Code
- **Issues / feedback** : https://github.com/anthropics/claude-code/issues
- **Plugins marketplace** : `claude plugin list`
- **Skills exemples** : `~/.claude/plugins/cache/anthropic-agent-skills/`
