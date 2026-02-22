# Claude GPU Kernel Testing Workflow

Automated multi-architecture AMD GPU kernel testing using Claude Code sub-agents.

## What this does

- Tests a CK (Composable Kernel) build target across multiple AMD GPU machines in parallel
- Each machine gets its own Claude sub-agent that: clones the branch, runs cmake, builds with ninja, executes the binary, and reports results
- The orchestrator agent collects all results and presents a unified report with performance numbers

## Files

| File | Purpose |
|---|---|
| `settings.json` | Claude Code permission allow-list |
| `CLAUDE.md` | Global Claude Code instructions |
| `gpu-kernel-config.json` | Machine list, docker image, build target, timeouts |
| `ck_test.sh` | Build/run script deployed on each remote GPU machine |
| `agents/gpu-kernel-tester.md` | Orchestrator agent definition |
| `agents/gpu-arch-runner.md` | Per-machine worker agent definition |
| `setup.sh` | Installs all of the above to `~/.claude/` |

## Setup on a new machine

### 1. Install Claude Code

Follow the official Claude Code installation instructions.

### 2. Clone this repo and run setup

```bash
git clone https://github.com/AviralGoelAMD/scripts ~/scripts
cd ~/scripts
git checkout main
bash claude/setup.sh
```

This copies all config files to `~/.claude/`.

### 3. Update the machine list

Edit `~/.claude/gpu-kernel-config.json` to reflect your GPU machines:

```json
"machines": [
  {
    "arch": "gfx950",
    "host": "your-mi350-hostname",
    "user": "your-username",
    "work_dir": "/home/your-username/gpu-kernel-tests"
  },
  ...
]
```

### 4. Deploy ck_test.sh to each remote GPU machine

For each machine in your config:

```bash
scp ~/.claude/ck_test.sh USER@HOST:~/
ssh USER@HOST "chmod +x ~/ck_test.sh"
```

This only needs to be done once per machine. If `ck_test.sh` is missing on a machine, the agent will detect it and print the exact command to fix it.

### 5. Ensure .my_docker_bashrc exists on each remote machine

The `cmake` step sources `~/.my_docker_bashrc` inside the Docker container. This file must exist on each remote machine at `~/.my_docker_bashrc` and must define the `ninja_build` and `clone` functions used by the CK build system.

### 6. Run a test

From any directory, tell Claude:

```
test kernel on all archs
```

Or to target a specific arch:

```
test kernel on gfx942 only
```

## Updating ck_test.sh on remote machines

If you modify `ck_test.sh` locally, redeploy it:

```bash
scp ~/.claude/ck_test.sh USER@HOST:~/
```

Note: `scp` is not in the Claude permission allow-list (intentionally, since it writes files). Run it manually in your terminal.

## Permission model

`~/.claude/settings.json` allows these commands without prompting:

| Pattern | Used for |
|---|---|
| `Bash(ssh -o ConnectTimeout=30 -o BatchMode=yes*)` | All remote operations via agents |
| `Bash(git remote get-url*)` | Repo detection by orchestrator |
| `Bash(git branch --show-current*)` | Branch detection by orchestrator |
| `Bash(git status --short*)` | Dirty state check by orchestrator |
| `Bash(cat ~/.claude/*)` | Config file reads by orchestrator |

Everything else requires manual approval.
