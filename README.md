# Alce Yatri — Laboratório Android

Repositório de prototipagem independente, com **passageiro Flutter** e **motorista Android nativo (Kotlin)**. Os dois clientes compartilham contratos de API, não código de interface.

## Isolamento e uso responsável
- Não modificar `luizamedice-glitch/namma-yatri-br.` (PureScript/PrestoDom).
- APKs de terceiros são apenas referências de análise local. Não publicar APKs, código descompilado, recursos proprietários ou segredos.
- Nenhum acesso a APIs privadas de terceiros; backend próprio ou simulado.

## Organização
```
apps/passenger/       # Flutter, Android
apps/driver/          # Android nativo, Kotlin (Jetpack Compose)
contracts/            # Esquemas e estados de corrida, independentes de linguagem
backend/mock/         # Backend de testes a implementar
docs/                 # Inventários e resultados da análise REA
scripts/              # Preparação do ambiente
```

## Preparação
`bash scripts/setup.sh` cria o esqueleto Flutter do passageiro, se o Flutter estiver instalado, e prepara a análise REA com Node.js compatível. O motorista é um projeto Gradle/Kotlin próprio: não execute `flutter create` em `apps/driver`.

## Compilação
- Passageiro: `cd apps/passenger && flutter pub get && flutter build apk --debug`.
- Motorista: `cd apps/driver && ./gradlew assembleDebug` **após criar e versionar o projeto Android/Gradle**.

A estrutura inicial não contém ainda os projetos completos nem gera APKs. O workflow CI separa as compilações e informa quando cada projeto ainda não existe.

## Documentação
- `docs/analysis-plan.md`
- `docs/driver-apk-25.10.md`
- `docs/android-driver-architecture.md`
