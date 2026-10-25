const test = require('node:test');
const assert = require('node:assert/strict');
const {createServer} = require('./server');
test('ride lifecycle and invalid transition', async () => {
  const server = createServer().listen(0);
  try {
    const base = 'http://127.0.0.1:' + server.address().port;
    const post = (path, body) => fetch(base + path,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(body)});
    const created = await post('/rides',{});
    assert.equal(created.status,201);
    const {ride} = await created.json();
    assert.equal(ride.status,'requested');
    assert.equal((await post('/rides/'+ride.id+'/status',{status:'completed'})).status,409);
    for (const status of ['accepted','driver_arrived','in_progress','completed']) {
      const response = await post('/rides/'+ride.id+'/status',{status});
      assert.equal(response.status,200);
    }
    const current = await (await fetch(base+'/rides/current')).json();
    assert.equal(current.ride.status,'completed');
  } finally {server.close();}
});
