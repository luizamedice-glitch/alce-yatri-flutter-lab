# Deploying role rules to the Lightsail laboratory

These changes are not live until both the Caddy configuration and Node process are updated. They replace the shared lab account with separate passenger/driver identities. The existing Android clients already send HTTP Basic credentials entered at runtime; enter the corresponding individual account in each app. The current UI has no cancellation button; cancellation is supported by the API only.

1. Back up the running application revision, `/etc/caddy/Caddyfile`, and existing service configuration. Identify how the Node process is supervised before restarting it. Do not print or commit credentials.
2. Copy `backend/mock/deploy/users.example.json` to `/etc/alce/users.json`. Adapt the usernames to match Caddy accounts exactly. Give the backend service user read access; restrict file writes to the administrator. This file contains usernames and roles, never passwords.
3. Generate a separate strong password for each account and run `caddy hash-password` interactively for each. Keep plaintext passwords private and enter them in the appropriate Android app. Replace the placeholders in `backend/mock/deploy/Caddyfile.example` with the generated hashes in the server-local Caddy configuration. Do not commit the resulting file. Preserve any unrelated sites/settings in the existing Caddyfile.
4. The `header_up X-Alce-User {http.auth.user.id}` line must be inside `reverse_proxy`, and `basic_auth` must cover every API route. It overwrites incoming identities, preventing clients from choosing another user. Retire the old shared account.
5. Configure the existing Node supervisor with `ALCE_USERS_FILE=/etc/alce/users.json`, deploy this backend revision and restart its service. Keep a single process bound to `127.0.0.1:8080`. Coordinate the restart and proxy change in a maintenance window: the old shared account is intentionally incompatible with the new rules.
6. Validate with `sudo caddy validate --config /etc/caddy/Caddyfile`, then reload Caddy using its existing service. Do not open port 8080 publicly.
7. Check `curl --user passageiro-teste https://54-94-146-177.sslip.io/health` and repeat with `motorista-teste`. Curl prompts for the password without putting it in shell history. Expect the appropriate role. A request without credentials must receive 401. Repeat the passenger check with `-H 'X-Alce-User: motorista-teste'`: the response must still report `passenger`.
8. In the apps, connect with separate accounts, request a ride as passenger, accept as driver, arrive, start and complete. Verify that a second driver cannot modify the assigned ride and that another passenger cannot see it.

Local validation: `node --test backend/mock/server.test.js` covers role and ownership enforcement, invalid transitions and payloads, per-user active ride limits, cancellation, and concurrent claims.

Rollback: restore the previous application revision, Caddyfile and service environment together, validate/reload Caddy and restart Node. In-memory rides are lost on any restart. Server deployment and authenticated HTTPS verification remain operator tasks until SSH access from the workspace is available.
