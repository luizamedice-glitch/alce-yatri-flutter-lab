# Análise inicial: Te Levo Mobile — Motorista 25.10

Fonte: exportação local do aplicativo instalado, pacote `br.com.televomobilearaxa.taxi.drivermachine`. **Não publicar APKs nem recursos proprietários.**

## Inventário
- `base.apk`: 44.051.928 bytes, SHA-256 `642c3c1b312d16561a36637491a7a6e2cdbed6116070b26526a3761cc6b194d5`
- `split_config.xhdpi.apk`: 435.225 bytes, SHA-256 `35d16edd259a3614ef36b28ebcbd4f0d2343c2f93821e49e1bcfe6383de6851d`
- `manifest.json`: versão 25.10, versionCode 5145
- `base.apk`: 3.594 entradas ZIP, quatro DEX.
- Sem `flutter_assets` ou bibliotecas Flutter na exportação recebida.
- Referências a AndroidX, Kotlin, OkHttp e Firebase; não confirmam quais funções estão ativas.
- Hipótese: Android predominantemente nativo, pendente de inspeção de classes.

## Decisão de arquitetura do laboratório
- Passageiro: Flutter (`apps/passenger/`).
- Motorista: **Android nativo Kotlin** (`apps/driver/`), com Jetpack Compose para a interface nova.
- Backend e contratos de API próprios e compartilhados.
- A escolha de Kotlin é uma **decisão do nosso projeto**, não prova de que o aplicativo de referência usa Kotlin em todas as telas.

## Próximas análises com REA
1. Analisar AndroidManifest.xml e componentes exportados.
2. Examinar quatro DEX via JADX para identificar Activities, Services e bibliotecas.
3. Verificar localização em primeiro e segundo plano, notificações e gestão de bateria.
4. Documentar estados de disponibilidade, solicitação, aceite, chegada, início e encerramento de corrida.
5. Testar integração entre passageiro Flutter e motorista Kotlin com dados fictícios.

Não inferir protocolos de backend ou algoritmos de despacho sem evidências.
