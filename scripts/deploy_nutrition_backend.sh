#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Missing .env in project root."
  exit 1
fi

set -a
source .env
set +a

PROJECT_REF="${SUPABASE_PROJECT_REF:-sibussbdttgdcizldbzb}"
MODEL="${NUTRITION_AI_MODEL:-gpt-4o-mini}"

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "OPENAI_API_KEY is missing in .env"
  exit 1
fi

npx supabase link --project-ref "$PROJECT_REF"
npx supabase secrets set OPENAI_API_KEY="$OPENAI_API_KEY" NUTRITION_AI_MODEL="$MODEL"
npx supabase functions deploy estimate-nutrition
