# Motorista Android nativo — decisão arquitetural

## Diretriz
Desenvolver o cliente motorista como aplicativo Android nativo em Kotlin, sem Flutter, usando Jetpack Compose para a interface original do laboratório. O APK Te Levo Motorista 25.10 é apenas referência de comportamento; não copiar código, interfaces protegidas, chaves ou recursos proprietários.

## Camadas
- UI: Jetpack Compose + ViewModel + StateFlow.
- Domínio: estados de corrida e regras de transição validadas.
- Dados: repositórios, REST/WebSocket próprios, persistência local quando necessário.
- Plataforma: Location Services, Foreground Service de localização quando permitido, notificações e ciclo de vida.
- Testes: unitários de estados, instrumentados de permissões, integração ponta a ponta com passageiro.

## Requisitos operacionais a validar
1. Permissões de localização em primeiro/segundo plano e notificações nas versões Android suportadas.
2. Foreground Service com tipo de serviço apropriado e notificação visível, respeitando restrições de inicialização.
3. Reentrada após processo morto, perda de rede, GPS desativado e mudanças de permissão.
4. Idempotência de aceite de corrida e atualização de estado no backend.
5. Medições reais de bateria, latência e confiabilidade em dispositivos físicos.

## Limites
Nativo não contorna restrições de bateria e background do Android; permite implementar diretamente as APIs oficiais. Não assumir que o app de referência usa Compose nem Kotlin em todas as camadas.

## Contratos
Ver `contracts/ride-states.md`. Comunicação com backend por protocolo neutro, sem dependência de Flutter.
