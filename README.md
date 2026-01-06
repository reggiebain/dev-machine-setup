# Dev Machine Setup

Quick setup for MacBook Pro @ Harvard Business Publishing (ML Scientist role).

## Quick Start

```bash
# 1. Clone this repository
git clone git@github.com:reginald-bain-hbp/dev-machine-setup.git
cd dev-machine-setup

# 2. Make setup script executable
chmod +x setup.sh

# 3. Run the automated setup
./setup.sh

# 4. Follow the post-install checklist (CHECKLIST.md)
```

## What Gets Installed

### Core Development Tools
| Tool | Purpose |
|------|---------|
| **Cursor** | AI-enhanced IDE (primary editor) |
| **VS Code** | Backup editor |
| **Warp** | Modern terminal with AI features |
| **Neovim + LazyVim** | Terminal-based editor |

### AI Coding Assistants (Privacy-Preserving)
| Tool | Purpose |
|------|---------|
| **Continue.dev** | LLM coding assistant in Cursor/VSCode |
| **Ollama** | Local LLM runtime |
| deepseek-coder:6.7b | Code generation (16K context) |
| qwen2.5-coder:7b | Multilingual code tasks |

### Python Development
| Tool | Purpose |
|------|---------|
| **uv** | Fast Python package/project manager |
| **Python 3.12** | Primary Python version |

### Database & ML Tools
| Tool | Purpose |
|------|---------|
| **DBeaver** | Database GUI for Snowflake |
| Snowflake connectors | Python packages for Snowflake |

### Utilities
| Tool | Purpose |
|------|---------|
| **Git** | Version control |
| **Homebrew** | Package manager |
| **ripgrep, fd, fzf** | Fast search tools |
| **bat, eza** | Better cat/ls alternatives |

## Repository Structure

```
dev-machine-setup/
├── README.md              # This file
├── CHECKLIST.md           # Step-by-step manual checklist
├── setup.sh               # Main automated setup script
├── Brewfile               # Homebrew packages
├── requirements.txt       # Core Python ML packages
├── configs/
│   ├── continue/
│   │   └── config.ts      # Continue.dev configuration
│   ├── git/
│   │   └── .gitconfig     # Git configuration template
│   └── shell/
│       └── .zshrc         # Shell configuration
└── docs/
    ├── ollama-setup.md    # Ollama usage guide
    ├── it-escalation.md   # Notes for IT approval requests
    └── two-laptop-workflow.md  # Contingency if tools blocked
```

## HBP-Specific Notes

### Git Configuration
```bash
git config --global user.name "Reginald Bain"
git config --global user.email "reginald.bain@harvardbusiness.org"
```

### Privacy-Preserving AI Workflow
- Use **local Ollama models** for any code touching real HBP data
- Cloud AI tools (Claude, Cursor AI) only for synthetic data or generic questions
- Continue.dev configured to use local models by default

### Tech Stack Alignment
This setup mirrors HBP's production stack:
| Local | Production |
|-------|------------|
| SQLite | Snowflake |
| Local Jupyter | Snowflake Notebooks |
| joblib .pkl | Snowflake Model Registry |
| FastAPI (local) | FastAPI (AWS) |

## Troubleshooting

### IT Approval Required
Some tools may require IT escalation. See `docs/it-escalation.md` for pre-written justifications.

### Tool Not Installing
If Homebrew or other tools are blocked, see `docs/two-laptop-workflow.md` for the contingency plan using personal laptop for sensitive development.

### Ollama Issues
See `docs/ollama-setup.md` for detailed Ollama troubleshooting.

---

**Last Updated:** January 2026  
**For:** HBP ML Scientist Role
