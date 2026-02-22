#!/usr/bin/env bash
# Sets up ~/.claude/ from this repo on a new machine.
# Run from the repo root: bash claude/setup.sh

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$CLAUDE_DIR/agents"

cp "$SCRIPT_DIR/CLAUDE.md"              "$CLAUDE_DIR/CLAUDE.md"
cp "$SCRIPT_DIR/settings.json"          "$CLAUDE_DIR/settings.json"
cp "$SCRIPT_DIR/gpu-kernel-config.json" "$CLAUDE_DIR/gpu-kernel-config.json"
cp "$SCRIPT_DIR/ck_test.sh"             "$CLAUDE_DIR/ck_test.sh"
chmod +x "$CLAUDE_DIR/ck_test.sh"
cp "$SCRIPT_DIR/agents/gpu-arch-runner.md"   "$CLAUDE_DIR/agents/gpu-arch-runner.md"
cp "$SCRIPT_DIR/agents/gpu-kernel-tester.md" "$CLAUDE_DIR/agents/gpu-kernel-tester.md"

echo "Claude config installed to $CLAUDE_DIR"
echo "Remember to:"
echo "  1. Copy ~/.my_docker_bashrc to each remote GPU machine."
echo "  2. Deploy ck_test.sh to each remote GPU machine:"
echo "     scp $CLAUDE_DIR/ck_test.sh USER@HOST:~/ && ssh USER@HOST chmod +x ~/ck_test.sh"
