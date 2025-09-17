#!/usr/bin/env bash
# ci.sh - Simple local CI for Node.js project (lint, test, docker build, compose)
# Author: Beshoy - explain steps in the README or commit message

set -euo pipefail
IFS=$'\n\t'

echo "=== CI: Starting ==="

# >>            check required CLIs 
if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node not found. Install node first." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm not found. Install npm first." >&2
  exit 1
fi

# >>>           install dependencies 
if [ -f package-lock.json ]; then
  echo "package-lock.json found , we will using npm ci"
  npm ci
else
  echo "No package-lock.json , We will  running npm install"
  npm install
fi

# >>>>          lint (if script exists) 
node -e "try{ if(require('./package.json').scripts && require('./package.json').scripts.lint) process.exit(0); else process.exit(1);}catch(e){process.exit(1)}"
LINT_STATUS=$?
if [ $LINT_STATUS -eq 0 ]; then
  echo "Running lint (npm run lint)..."
  npm run lint
else
  echo "No lint script found, skipping lint."
fi

# >>>>>        tests (if script exists and not the default stub) 
node -e "try{ const s=require('./package.json').scripts; if(!s||!s.test) process.exit(1); const t=s.test.trim(); if(t.startsWith('echo') && t.includes('Error')) process.exit(2); process.exit(0);}catch(e){process.exit(1)}"
TEST_STATUS=$?
if [ $TEST_STATUS -eq 0 ]; then
  echo "Running tests (npm test)"
  npm test
elif [ $TEST_STATUS -eq 2 ]; then
  echo "Default test script stub found >>> skipping tests."
else
  echo "No test script found >>> skipping tests"
fi

# >>>>>>       docker image build (if Dockerfile exists)
IMAGE_NAME=$(node -e "try{console.log(require('./package.json').name||'app')}catch(e){console.log('app')}")
TAG="ci-$(date +%Y%m%d%H%M%S)"
if [ -f Dockerfile ]; then
  if command -v docker >/dev/null 2>&1; then
    echo "Building Docker image ${IMAGE_NAME}:${TAG}"
    docker build -t "${IMAGE_NAME}:${TAG}" .
  else
    echo "Docker not found >>> skipping docker build."
  fi
else
  echo "No Dockerfile found >>> skipping docker build."
fi

# >>>>>>>     docker-compose up (if file exists) 
if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ]; then
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "Using 'docker compose' (v2) to bring services up..."
    docker compose up -d --build
  elif command -v docker-compose >/dev/null 2>&1; then
    echo "Using 'docker-compose' to bring services up..."
    docker-compose up -d --build
  else
    echo "docker-compose not installed >>> skipping compose step."
  fi
else
  echo "No docker-compose file >>> skipping compose step."
fi

echo "=== CI: Done ==="
