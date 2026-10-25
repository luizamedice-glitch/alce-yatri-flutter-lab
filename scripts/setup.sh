#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v node >/dev/null || { echo 'Node.js não encontrado'; exit 1; }
command -v npm >/dev/null || { echo 'npm não encontrado'; exit 1; }
command -v flutter >/dev/null || { echo 'Flutter SDK não encontrado'; exit 1; }
node -e 'const [maj,min,patch]=process.versions.node.split(".").map(Number); if (!((maj===22&&(min>23||(min===23&&patch>=4)))||(maj===24&&(min>22||(min===22&&patch>=1)))||(maj===26&&(min>12||(min===12&&patch>=1)))||maj>26)) {console.error("Node.js incompatível com REA: "+process.version);process.exit(1)}'
if [ ! -d app ]; then flutter create --project-name alce_yatri_flutter_lab --platforms android app; fi
echo 'Configurando REA (interativo). Revise alterações e permissões.'
npx rea-agents setup
echo 'Prepare o Android SDK e execute: cd app && flutter build apk --debug'
