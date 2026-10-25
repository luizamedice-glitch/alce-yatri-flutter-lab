# Contrato inicial de corrida — proposta, não extraído do Te Levo

Estados: `requested`, `offered`, `accepted`, `driver_arriving`, `driver_arrived`, `in_progress`, `completed`, `cancelled`.

Transições típicas:
- requested → offered → accepted → driver_arriving → driver_arrived → in_progress → completed
- requested/offered/accepted/driver_arriving/driver_arrived → cancelled (segundo regras do backend)

O backend é a autoridade sobre transições e atribuição de motorista. Todos os eventos devem carregar `rideId`, `eventId`, `timestamp` e `actor`. Tratar eventos repetidos de forma idempotente. Autorização deve ser verificada no servidor.

Contrato provisório para simulações; será revisado após análise do REA e testes.
