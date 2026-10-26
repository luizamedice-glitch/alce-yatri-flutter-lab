# Mock Ride API v0.2

Public base URL: `https://54-94-146-177.sslip.io`. Node listens only on `127.0.0.1:8080`.

Caddy authenticates individual HTTP Basic accounts and **overwrites** `X-Alce-User` with `{http.auth.user.id}`. The backend maps that trusted identity to `passenger` or `driver` using `ALCE_USERS_FILE`. Unknown identities receive 401, including on `/health`. Never accept a role supplied by the app. A direct connection to the Node listener can impersonate users; keep it private to the trusted local proxy.

| Method | Path | Rule |
| --- | --- | --- |
| GET | `/health` | Authenticated user; returns `{ok:true,role}` |
| GET | `/rides/current` | Passenger sees own active/latest ride. Driver sees own active ride, otherwise oldest unclaimed request, otherwise own latest ride. |
| POST | `/rides` | Passenger only; at most one active ride per passenger |
| POST | `/rides/:id/status` | JSON `{ "status": "accepted" }`; enforced ownership and transitions |

Ride fields: `id`, `passengerId`, `driverId` (null before acceptance), `status`, `createdAt`, and `updatedAt` after a transition. Identity and ownership come from the server, never from POST fields.

## State and permission rules

- A driver accepts a `requested` ride, becoming its assigned driver. Each driver has at most one active ride.
- Only the assigned driver advances `accepted → driver_arrived → in_progress → completed`.
- Only the owning passenger cancels, from `requested`, `accepted`, or `driver_arrived`.
- Completed and cancelled rides are terminal. A new request is then allowed.
- Another passenger's ride or a ride assigned to another driver returns 404.
- Concurrent acceptance is checked against current state immediately before the synchronous update. Only one driver wins within this single process.

Errors: 401 unauthenticated/unmapped identity, 403 wrong role, 404 unavailable resource, 409 active ride or invalid transition, 400 invalid JSON/status, 413 status payload over 2048 bytes.

## Limits

This remains a single-process in-memory laboratory backend. Restarting clears all rides. There is no database, retention policy, rate limiting, location tracking, payment processing or real-world dispatch. Native Android clients use HTTPS Basic authentication; browser CORS access is not enabled. Do not run multiple backend workers or use for real rides without a transactional persistent data store and production authentication.
