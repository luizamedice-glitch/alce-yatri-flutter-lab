const test = require('node:test');
const assert = require('node:assert/strict');
const {createServer} = require('./server');

test('roles, ownership, lifecycle, concurrent claims and validation', async () => {
  const server = createServer({users: {p1: 'passenger', p2: 'passenger', d1: 'driver', d2: 'driver'}}).listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const base = 'http://127.0.0.1:' + server.address().port;
  const request = (user, path, body) => fetch(base + path, {
    method: body === undefined ? 'GET' : 'POST',
    headers: {'x-alce-user': user, 'content-type': 'application/json'},
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const change = (user, id, status) => request(user, `/rides/${id}/status`, {status});
  try {
    assert.equal((await request('unknown', '/health')).status, 401);
    assert.equal((await request('d1', '/rides', {})).status, 403);
    const {ride: a} = await (await request('p1', '/rides', {})).json();
    assert.equal((await request('p1', '/rides', {})).status, 409);
    assert.equal((await request('p2', '/rides/current')).status, 200);
    assert.equal((await (await request('p2', '/rides/current')).json()).ride, null);
    assert.equal((await change('p2', a.id, 'cancelled')).status, 404);
    assert.equal((await change('p1', a.id, 'accepted')).status, 403);
    assert.equal((await change('d1', a.id, 'completed')).status, 409);
    assert.equal((await change('d1', a.id, 'cancelled')).status, 403);
    assert.equal((await request('p1', `/rides/${a.id}/status`, null)).status, 400);
    assert.equal((await request('p1', `/rides/${a.id}/status`, {status: 'x'.repeat(2100)})).status, 413);
    const claims = await Promise.all(['d1', 'd2'].map(u => change(u, a.id, 'accepted')));
    assert.deepEqual(claims.map(r => r.status).sort(), [200, 404]);
    const winner = claims[0].status === 200 ? 'd1' : 'd2';
    const loser = winner === 'd1' ? 'd2' : 'd1';
    const {ride: b} = await (await request('p2', '/rides', {})).json();
    assert.equal((await change(winner, b.id, 'accepted')).status, 409);
    assert.equal((await change(loser, a.id, 'driver_arrived')).status, 404);
    for (const status of ['driver_arrived', 'in_progress']) assert.equal((await change(winner, a.id, status)).status, 200);
    assert.equal((await change('p1', a.id, 'cancelled')).status, 409);
    assert.equal((await change(winner, a.id, 'completed')).status, 200);
    assert.equal((await change(winner, a.id, 'in_progress')).status, 409);
    assert.equal((await change('p2', b.id, 'cancelled')).status, 200);
    assert.equal((await change(loser, b.id, 'accepted')).status, 404);
    assert.equal((await request('p1', '/rides', {})).status, 201);
  } finally { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
});

test('rejects invalid role configuration and denies access without configured users', async () => {
  assert.throws(() => createServer({users: {a: 'admin'}}));
  const server = createServer().listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  try {
    const res = await fetch(`http://127.0.0.1:${server.address().port}/health`, {headers: {'x-alce-user': 'p1'}});
    assert.equal(res.status, 401);
  } finally { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
});
