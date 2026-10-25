# Alce Yatri Flutter Lab

Laboratório independente para análise técnica do Te Levo Mobile 28.9 e desenvolvimento de um protótipo Flutter comparativo.

## Escopo e isolamento
- O projeto PureScript/PrestoDom `namma-yatri-br.` não será modificado.
- APKs de terceiros, código descompilado, credenciais e recursos proprietários não serão publicados.
- Protótipo com dados fictícios e serviços próprios; nenhuma conexão a APIs privadas de terceiros.

## Ferramentas
- Flutter SDK e Android SDK para compilar o aplicativo.
- REA: https://github.com/morluto/rea
- JADX, JDK e Apktool conforme os objetivos da análise.

## Preparação (Linux)
Execute `bash scripts/setup.sh` após instalar Flutter/Android SDK e Node.js compatível com REA. O script cria o projeto Flutter local e executa o setup interativo do REA. Revise as mudanças antes de aprovar.

## APK de referência
Guarde o ZIP extraído localmente em `reference/te-levo-28.9.zip` (ignorado pelo Git).
Execute `python3 scripts/inventory.py reference/te-levo-28.9.zip`.

## Compilação
```bash
cd app
flutter pub get
flutter build apk --debug
```

A compilação exige que o diretório `app/` tenha sido criado e versionado. O workflow do GitHub Actions não compila até isso acontecer.

## Plano
Veja `docs/analysis-plan.md` para fases e critérios de evidência.
