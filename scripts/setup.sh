#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null || { echo 'Flutter SDK não encontrado'; exit 1; }
command -v java >/dev/null || { echo 'JDK não encontrado'; exit 1; }
command -v node >/dev/null || { echo 'Node.js não encontrado'; exit 1; }
command -v npm >/dev/null || { echo 'npm não encontrado'; exit 1; }
cd apps/passenger
flutter create --project-name alce_yatri_passenger --platforms android .
flutter pub get
cd ../..
echo 'REA: setup interativo (confirme versão de Node.js suportada na documentação upstream)'
npx rea-agents setup
echo 'Motorista Kotlin: cd apps/driver && gradle assembleDebug'
echo 'Passageiro Flutter: cd apps/passenger && flutter build apk --debug'
