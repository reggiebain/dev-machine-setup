# Dev Machine Setup Checklist

Complete checklist for setting up a new MacBook Pro for HBP ML work.

## Pre-Setup

- [ ] Receive laptop from HBP IT
- [ ] Complete initial macOS setup
- [ ] Connect to WiFi / VPN (if required)
- [ ] Sign in to HBP accounts (Okta, Slack, etc.)

---

## Phase 1: Run Automated Setup (30-45 min)

```bash
# Clone this repository
git clone git@github.com:reginald-bain-hbp/dev-machine-setup.git
cd dev-machine-setup

# Make executable and run
chmod +x setup.sh
./setup.sh
```

- [ ] Script completes without critical errors
- [ ] Restart terminal after script completes

---

## Phase 2: SSH Keys for GitHub (5 min)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "reginald.bain@harvardbusiness.org"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

- [ ] Go to GitHub → Settings → SSH Keys → New SSH Key
- [ ] Paste the key and save
- [ ] Test connection:
  ```bash
  ssh -T git@github.com
  # Should say "Hi reginald-bain-hbp! You've successfully authenticated..."
  ```

---

## Phase 3: Cursor Setup (10 min)

### Install Extensions

Open Cursor → `Cmd+Shift+X` → Install:

- [ ] **Continue** - Local AI coding assistant
- [ ] **Python** - Python language support
- [ ] **Jupyter** - Notebook support
- [ ] **Snowflake** - Snowflake SQL support

### Configure Continue.dev

- [ ] Verify config copied: `ls ~/.continue/config.ts`
- [ ] Restart Cursor
- [ ] Press `Cmd+L` to open Continue chat
- [ ] Select "DeepSeek Coder (Local - HBP Safe)" from dropdown
- [ ] Test: Ask "Write a Python function to reverse a string"
- [ ] Verify it uses Ollama (no external API calls)

### Configure Settings Sync (Optional)

- [ ] Sign in with HBP email (if you want settings sync)
- [ ] Or skip sign-in for privacy

---

## Phase 4: VS Code Setup (Backup Editor) (5 min)

- [ ] Open VS Code
- [ ] Install same extensions as Cursor
- [ ] Configure for Python development

---

## Phase 5: Test Ollama (5 min)

```bash
# Check Ollama is running
ollama list

# Should show:
# deepseek-coder:6.7b
# qwen2.5-coder:7b

# Test a model
ollama run deepseek-coder:6.7b "Write a FastAPI hello world endpoint"

# Quick test from shell (using alias)
ask "What is MLflow?"
```

- [ ] Models are downloaded and working
- [ ] Generation is reasonably fast (few seconds)

---

## Phase 6: Python & uv Setup (10 min)

### Verify uv Installation

```bash
uv --version
uv python list
# Should show Python 3.12
```

### Create Test Project

```bash
cd ~/dev
mkdir test-project && cd test-project

# Initialize with uv
uv init

# Add ML packages
uv add pandas numpy scikit-learn jupyter ipykernel

# Test imports
uv run python -c "import pandas, numpy, sklearn; print('✅ ML stack works!')"
```

- [ ] uv creates virtual environment
- [ ] Packages install successfully
- [ ] Imports work

### Register Jupyter Kernel

```bash
# Activate venv
source .venv/bin/activate

# Register kernel
jupyter_register "Test Project" "test-project"

# List kernels
jupyter kernelspec list
```

- [ ] Kernel appears in list

---

## Phase 7: Test Full Workflow (10 min)

### Create HBP-style Project

```bash
cd ~/dev/hbp
mkdir personalization-test && cd personalization-test

# Initialize
uv init

# Add HBP stack packages
uv add pandas numpy scikit-learn xgboost
uv add fastapi uvicorn pydantic
uv add mlflow
uv add snowflake-connector-python snowflake-ml-python
uv add jupyter ipykernel

# Create simple test
cat > test_stack.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from fastapi import FastAPI
import mlflow

# Test ML
X = np.random.rand(100, 4)
y = np.random.randint(0, 2, 100)
model = RandomForestClassifier(n_estimators=10, random_state=42)
model.fit(X, y)
print(f"Model accuracy: {model.score(X, y):.2f}")

# Test FastAPI import
app = FastAPI()
print("FastAPI imported successfully")

# Test MLflow import
print(f"MLflow version: {mlflow.__version__}")

print("\n✅ HBP ML stack working!")
EOF

# Run test
uv run python test_stack.py
```

- [ ] All imports work
- [ ] Model trains successfully
- [ ] Ready for HBP development

---

## Phase 8: Warp Terminal Setup (5 min)

- [ ] Open Warp from Applications
- [ ] Complete initial setup (can skip sign-in)
- [ ] Set as default terminal (optional)
- [ ] Test shell configuration works

---

## Phase 9: DBeaver Setup (5 min)

- [ ] Open DBeaver
- [ ] Will configure Snowflake connection later (need credentials)
- [ ] Familiarize with interface

---

## Phase 10: Git Verification (2 min)

```bash
git config --list | grep user
# Should show:
# user.name=Reginald Bain
# user.email=reginald.bain@harvardbusiness.org
```

- [ ] Git identity configured correctly

---

## Post-Setup: When You Get HBP Access

### Snowflake Configuration

When Nathan provides Snowflake credentials:

```bash
# Create .env file for credentials (never commit this!)
cat > ~/.snowflake/.env << 'EOF'
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_user
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=HBP_PERSONALIZATION
SNOWFLAKE_SCHEMA=ML
SNOWFLAKE_ROLE=ML_ENGINEER
EOF
```

- [ ] Receive Snowflake credentials from Nathan
- [ ] Configure connection
- [ ] Test connection in DBeaver
- [ ] Test Python Snowflake connector

### Clone HBP Repositories

```bash
cd ~/dev/hbp
# Clone repos Nathan shares
# git clone git@github.com:hbp-org/repo-name.git
```

- [ ] Clone team repositories
- [ ] Set up development environments

---

## Troubleshooting

### Homebrew Installation Blocked

If IT blocks Homebrew:
1. Submit escalation request (see `docs/it-escalation.md`)
2. Explain it's essential for Python development
3. If still blocked, see `docs/two-laptop-workflow.md`

### Ollama Not Working

```bash
# Check if running
ps aux | grep ollama

# Restart
killall ollama
ollama serve &

# Re-test
ollama list
```

### Python/uv Issues

```bash
# Reinstall uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Reinstall Python
uv python install 3.12 --force

# Clear cache if needed
uv cache clean
```

### Continue.dev Not Using Local Models

1. Verify Ollama is running: `ollama list`
2. Check config exists: `cat ~/.continue/config.ts`
3. Restart Cursor completely
4. Select local model from dropdown in Continue chat

---

## Quick Reference

### Daily Workflow Commands

```bash
# Start Ollama (if not auto-started)
ollama serve &

# Navigate to HBP work
hbp  # alias for cd ~/dev/hbp

# Create new project
uvnew my-new-project

# Quick commit and push
gitquick

# Ask AI from terminal
ask "How do I do X in Python?"
```

### Useful Paths

| Path | Purpose |
|------|---------|
| `~/dev/hbp` | HBP work projects |
| `~/dev/experiments` | Quick experiments |
| `~/.continue/config.ts` | Continue.dev config |
| `~/.zshrc` | Shell configuration |
| `~/.ollama/models` | Downloaded AI models |

---

## Checklist Summary

- [ ] Automated setup script completed
- [ ] SSH keys configured for GitHub
- [ ] Cursor + extensions installed
- [ ] Continue.dev working with local models
- [ ] Ollama models downloaded and working
- [ ] Python/uv working
- [ ] Test project created successfully
- [ ] Git configured for HBP
- [ ] Ready for HBP onboarding!
