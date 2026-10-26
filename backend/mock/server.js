const http = require('node:http');
const { randomUUID } = require('node:crypto');
const fs = require('node:fs');

// Caddy authenticates each account and overwrites X-Alce-User. Keep this
// listener on loopback: this header is not authentication on a public port.
function createServer({ users = {} } = {}) {
  if (!users || typeof users !== 'object' || Array.isArray(users) ||
      Object.values(users).some(role => !['passenger', 'driver'].includes(role))) {
    throw new Error('Invalid user role configuration');
  }
  const roles = new Map(Object.entries(users));
  const rides = new Map();
  const active = ride => !['completed', 'cancelled'].includes(ride.status);
  const transitions = {
    requested: ['accepted', 'cancelled'],
    accepted: ['driver_arrived', 'cancelled'],
    driver_arrived: ['in_progress', 'cancelled'],
    in_progress: ['completed'], completed: [], cancelled: [],
  };
  const respond = (res, status, data) => {
    res.writeHead(status, {'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store'});
    res.end(JSON.stringify(data));
  };
  return http.createServer(async (req, res) => {
    const user = req.headers['x-alce-user'];
    const role = roles.get(user);
    if (!role) return respond(res, 401, {error: 'unauthorized'});
    const url = new URL(req.url, 'http://localhost');
    if (url.pathname === '/health' && req.method === 'GET') return respond(res, 200, {ok: true, role});
    if (url.pathname === '/rides/current' && req.method === 'GET') {
      const all = [...rides.values()];
      const own = all.filter(r => role === 'passenger' ? r.passengerId === user : r.driverId === user);
      const ride = own.find(active) || (role === 'driver' && all.find(r => r.status === 'requested')) || own.at(-1) || null;
      return respond(res, 200, {ride});
    }
    if (url.pathname === '/rides' && req.method === 'POST') {
      if (role !== 'passenger') return respond(res, 403, {error: 'passenger_required'});
      if ([...rides.values()].some(r => r.passengerId === user && active(r))) return respond(res, 409, {error: 'active_ride_exists'});
      const ride = {id: randomUUID(), passengerId: user, driverId: null, status: 'requested', createdAt: new Date().toISOString()};
      rides.set(ride.id, ride);
      return respond(res, 201, {ride});
    }
    const match = url.pathname.match(/^\/rides\/([^/]+)\/status$/);
    if (match && req.method === 'POST') {
      let raw = '';
      let body;
      try {
        for await (const chunk of req) {
          raw += chunk;
          if (Buffer.byteLength(raw) > 2048) return respond(res, 413, {error: 'body_too_large'});
        }
        body = JSON.parse(raw);
      } catch { return respond(res, 400, {error: 'invalid_json'}); }
      if (!body || typeof body !== 'object' || Array.isArray(body) || typeof body.status !== 'string') return respond(res, 400, {error: 'invalid_status'});
      // Read and validate AFTER awaiting the body, then commit synchronously.
      // Two drivers cannot claim the same ride with concurrent requests.
      const ride = rides.get(match[1]);
      if (!ride || (role === 'passenger' && ride.passengerId !== user) ||
          (role === 'driver' && ride.driverId !== user && ride.status !== 'requested')) return respond(res, 404, {error: 'ride_not_found'});
      const next = body.status;
      if (role === 'passenger' && next !== 'cancelled') return respond(res, 403, {error: 'driver_required'});
      if (role === 'driver' && next === 'cancelled') return respond(res, 403, {error: 'passenger_required'});
      if (!transitions[ride.status].includes(next)) return respond(res, 409, {error: 'invalid_transition', current: ride.status});
      if (next === 'accepted' && [...rides.values()].some(r => r.driverId === user && active(r))) return respond(res, 409, {error: 'active_ride_exists'});
      const updated = {...ride, status: next, updatedAt: new Date().toISOString(), ...(next === 'accepted' ? {driverId: user} : {})};
      rides.set(ride.id, updated);
      return respond(res, 200, {ride: updated});
    }
    return respond(res, 404, {error: 'not_found'});
  });
}
if (require.main === module) {
  if (!process.env.ALCE_USERS_FILE) throw new Error('Set ALCE_USERS_FILE to the user role JSON file');
  const users = JSON.parse(fs.readFileSync(process.env.ALCE_USERS_FILE, 'utf8'));
  if (!Object.keys(users).length) throw new Error('Configure at least one user');
  createServer({users}).listen(Number(process.env.PORT || 8080), '127.0.0.1', () => console.log('Mock API listening'));
}
module.exports = {createServer};
