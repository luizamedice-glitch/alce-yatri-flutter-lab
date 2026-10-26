# APKs originais no laboratório Lightsail

## Servidor identificado

Endpoint documentado: `https://54-94-146-177.sslip.io`. A consulta HTTPS a
`/health` retornou 401 nesta inspeção, confirmando a exigência de autenticação
do laboratório. Esse resultado não confirma a versão do processo Node em execução.
O repositório fornece apenas o mock de `backend/mock/server.js` e os clientes
experimentais de `apps/`; esses clientes não são os APKs originais analisados.

O Caddy continua responsável pelo acesso HTTP Basic, com o backend em loopback.
Desativar o login nativo do Motorista no laboratório não significa remover essa
proteção do servidor. Não inserir a senha do Caddy em APKs ou no Git.

## Motorista Giselo

Fixture: `backend/mock/fixtures/driver-giselo.json`.

- Nome: Motorista Giselo.
- Veículo: Volkswagen Virtus, Branco, placa ITQ-5799.
- Identidade: `lab-driver-giselo`, exclusiva para testes.

Com `ENABLE_DRIVER_TEST_PROFILE=true`, `GET /lab/driver` disponibiliza o perfil
e a aceitação de uma corrida associa esse motorista à corrida. O perfil permanece
nas consultas compartilhadas de `/rides/current` durante os demais estados.
Sem a opção, a rota retorna 404 e o comportamento anterior é preservado.
O perfil é uma fixture; não é um cadastro criado em um banco de dados remoto.

Execução local para conferir a opção:

```sh
ENABLE_DRIVER_TEST_PROFILE=true node backend/mock/server.js
```

No Lightsail será necessário atualizar a implantação e habilitar a variável no
gerenciador do processo existente. Os caminhos e o nome desse serviço precisam
ser verificados via acesso autorizado ao servidor antes de executar comandos.

## Adaptação dos APKs: ainda pendente

O APK Motorista chama `taxista/login`. O bootstrap original também consome ID,
token, status, veículo, categorias, bandeira e configurações. A rota de fixture
acima não implementa esse contrato. Pular o formulário sem substituir o bootstrap
não entrega uma sessão funcional. A adaptação deverá ser exclusiva do servidor
de laboratório, com uma identidade de teste e credenciais próprias.

O Passageiro contém cadastro e login nativos na interface, mas o servidor atual
não implementa os contratos dessas telas. Manter o cadastro visual exige mapear
as requisições, validações e respostas correspondentes e implementar seu suporte
no nosso backend. Não encaminhar os dados cadastrais a serviços do aplicativo
original durante os testes de integração.

Além disso, os endpoints originais de solicitação/estimativa/cancelamento diferem
de `/rides`. Será necessário adaptar os contratos de corrida e a atualização dos
dois clientes, incluindo localização e reconexão. Os catálogos estáticos estão em
`integracao/` no repositório privado `alce-yatri-rea-analysis`, branch
`entregas/apks-referencia-visual`.

## Estado verificável

Os testes locais validam a opção desativada, o perfil/veículo solicitado, a
atribuição na aceitação e sua manutenção no ciclo de corrida. A mudança ainda
não foi implantada no Lightsail, e os APKs originais ainda não foram integrados.
Faltam acesso autorizado ao servidor e validação dos contratos/fluxos em aparelho.
