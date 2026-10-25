#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v node >/dev/null || { echo 'Node.js não encontrado'; exit 1; }
command -v npm >/dev/null || { echo 'npm não encontrado'; exit 1; }
command -v flutter >/dev/null || { echo 'Flutter SDK não encontrado (necessário apenas para passageiro)'; exit 1; }
node -e 'const [maj,min,patch]=process.versions.node.split(".").map(Number); if (!((maj===22&&(min>23||(min===23&&patch>=4)))||(maj===24&&(min>22||(min===22&&patch>=1)))||(maj===26&&(min>12||(min===12&&patch>=1)))||maj>26)) {console.error("Node.js incompatível com REA: "+process.version);process.exit(1)}'
if [ ! -f apps/passenger/pubspec.yaml ]; then
  mkdir -p apps
  flutter create --project-name alce_yatri_passenger --platforms android apps/passenger
fi
echo 'Preparando REA para análise (setup interativo)'
npx rea-agents setup
echo 'Motorista: criar projeto Android Kotlin/Gradle em apps/driver (não Flutter).'
echo 'Passageiro: cd apps/passenger && flutter build apk --debug'
