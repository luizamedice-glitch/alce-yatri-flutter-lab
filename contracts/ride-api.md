# Mock Ride API v0.1

Base URL: `http://<HOST>:8080` (development only).

| Method | Path | Result |
| --- | --- | --- |
| GET | `/health` | `{"ok":true}` |
| GET | `/rides/current` | `{"ride":null}` or ride |
| POST | `/rides` | Creates ride in `requested` |
| POST | `/rides/:id/status` | JSON `{"status":"accepted"}` |

State transitions: requested → accepted → driver_arrived → in_progress → completed; cancellation is supported before in_progress.

Errors: 404 unknown resource, 409 active ride or invalid state transition, 400 invalid JSON.

**Security:** No authentication, no persistent storage, no rate limiting and permissive CORS. Use only in a private development environment. Never expose this service publicly or use it for real rides.
