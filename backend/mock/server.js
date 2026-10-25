const http = require('node:http');
const { randomUUID } = require('node:crypto');

function createServer() {
  let ride = null;
  const transitions = {
    requested: ['accepted', 'cancelled'],
    accepted: ['driver_arrived', 'cancelled'],
    driver_arrived: ['in_progress', 'cancelled'],
    in_progress: ['completed'],
    completed: [],
    cancelled: [],
  };
  const respond = (res, status, data) => {
    res.writeHead(status, {'content-type':'application/json; charset=utf-8','access-control-allow-origin':'*'});
    res.end(JSON.stringify(data));
  };
  return http.createServer(async (req, res) => {
    if (req.method === 'OPTIONS') {
      res.writeHead(204, {'access-control-allow-origin':'*','access-control-allow-methods':'GET, POST, OPTIONS','access-control-allow-headers':'content-type'}); return res.end();
    }
    const url = new URL(req.url, 'http://localhost');
    if (url.pathname === '/health' && req.method === 'GET') return respond(res,200,{ok:true});
    if (url.pathname === '/rides/current' && req.method === 'GET') return respond(res,200,{ride});
    if (url.pathname === '/rides' && req.method === 'POST') {
      if (ride && !['completed','cancelled'].includes(ride.status)) return respond(res,409,{error:'active_ride_exists'});
      ride = {id:randomUUID(),status:'requested',createdAt:new Date().toISOString()};
      return respond(res,201,{ride});
    }
    const match = url.pathname.match(/^\/rides\/([^/]+)\/status$/);
    if (match && req.method === 'POST') {
      if (!ride || match[1] !== ride.id) return respond(res,404,{error:'ride_not_found'});
      let raw = '';
      try {
        for await (const chunk of req) { raw += chunk; if (raw.length > 2048) return respond(res,413,{error:'body_too_large'}); }
        const next = JSON.parse(raw).status;
        if (!transitions[ride.status].includes(next)) return respond(res,409,{error:'invalid_transition',current:ride.status});
        ride = {...ride,status:next,updatedAt:new Date().toISOString()};
        return respond(res,200,{ride});
      } catch { return respond(res,400,{error:'invalid_json'}); }
    }
    return respond(res,404,{error:'not_found'});
  });
}
if (require.main === module) createServer().listen(Number(process.env.PORT || 8080),'0.0.0.0',()=>console.log('Mock API listening'));
module.exports = {createServer};
