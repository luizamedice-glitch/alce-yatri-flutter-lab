const test = require('node:test');
const assert = require('node:assert/strict');
const {createServer} = require('./server');
test('driver test profile is disabled by default', async () => {
  const server = createServer().listen(0);
  try {
    const base = 'http://127.0.0.1:' + server.address().port;
    assert.equal((await fetch(base+'/lab/driver')).status,404);
  } finally { server.close(); }
});
test('opt-in Giselo profile follows the accepted ride to both clients', async () => {
  const server = createServer({enableDriverTestProfile:true}).listen(0);
  try {
    const base = 'http://127.0.0.1:' + server.address().port;
    const profile = await (await fetch(base+'/lab/driver')).json();
    assert.equal(profile.driver.name,'Motorista Giselo');
    assert.deepEqual(profile.driver.vehicle,{make:'Volkswagen',model:'Virtus',color:'Branco',plate:'ITQ-5799'});
    const post = (path,body) => fetch(base+path,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(body)});
    const {ride} = await (await post('/rides',{})).json();
    assert.equal(ride.driver,undefined);
    assert.equal((await post('/rides/'+ride.id+'/status',{status:'completed'})).status,409);
    for (const status of ['accepted','driver_arrived','in_progress','completed']) {
      assert.equal((await post('/rides/'+ride.id+'/status',{status})).status,200);
      const current = await (await fetch(base+'/rides/current')).json();
      assert.deepEqual(current.ride.driver,profile.driver);
    }
  } finally { server.close(); }
});
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
