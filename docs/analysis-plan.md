# Plano de análise REA — passageiro 28.9 e motorista 25.10

1. Inventariar e validar hashes dos split APKs localmente.
2. Examinar manifesto, permissões, componentes, DEX, dependências e recursos com REA/JADX/Apktool.
3. No passageiro, documentar metadados Flutter, bibliotecas ELF e limites de recuperação de Dart.
4. No motorista, documentar Activities, Services, permissões de localização, notificações e gerenciamento do ciclo de vida Android.
5. Modelar estados da corrida em `contracts/`, sem depender da linguagem dos clientes.
6. Implementar passageiro Flutter em `apps/passenger/`.
7. Implementar motorista **Android nativo Kotlin** em `apps/driver/`, com Jetpack Compose e APIs oficiais do Android.
8. Integrar ambos a backend simulado, depois validar GPS em segundo plano, notificações, bateria e fluxo completo.
9. Comparar resultados com PureScript/PrestoDom sem modificar o projeto original.

Classificar achados como confirmados, observados, inferidos ou desconhecidos. Não publicar material proprietário extraído.
