# Análise inicial: Te Levo Mobile — Motorista 25.10

Fonte: exportação local do aplicativo instalado, pacote `br.com.televomobilearaxa.taxi.drivermachine`. **Não publicar os APKs nem recursos proprietários.**

## Inventário verificado
- `base.apk`: 44.051.928 bytes, SHA-256 `642c3c1b312d16561a36637491a7a6e2cdbed6116070b26526a3761cc6b194d5`
- `split_config.xhdpi.apk`: 435.225 bytes, SHA-256 `35d16edd259a3614ef36b28ebcbd4f0d2343c2f93821e49e1bcfe6383de6851d`
- `manifest.json`: versão 25.10, versionCode 5145
- `base.apk`: 3.594 entradas ZIP, quatro arquivos DEX.
- Não há recursos `flutter_assets` ou bibliotecas Flutter na exportação recebida.
- Há referências a bibliotecas AndroidX, Kotlin, OkHttp e Firebase. Isso **não confirma** quais funções estão ativas.
- Hipótese: implementação Android predominantemente nativa; ainda precisa ser confirmada por inspeção do manifesto e classes.

## Contraste com passageiro
O APK do passageiro 28.9 contém `assets/flutter_assets` e distribuição de biblioteca Flutter no split ARM64. Não presumir que ambos usem a mesma tecnologia.

## Próximas análises com REA
1. Analisar AndroidManifest.xml e componentes exportados.
2. Examinar quatro DEX via JADX para identificar Activities, Services e bibliotecas.
3. Documentar estados de disponibilidade, solicitação, aceite, chegada, início e encerramento de corrida.
4. Implementar dois apps Flutter **independentes** em `apps/passenger` e `apps/driver`, com `packages/ride_core` e backend simulado.
5. Executar testes integrados com usuários e dados fictícios, sem conectar a APIs privadas.

Nenhuma inferência sobre protocolo de backend, credenciais ou algoritmo de despacho deve ser apresentada como fato sem evidência.
