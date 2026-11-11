import http from 'node:http';
import { readFile, writeFile, copyFile, rename } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { createHash, randomBytes } from 'node:crypto';
import { spawn } from 'node:child_process';
import { validateGalaxy } from '../../tgui/packages/tgui/interfaces/overmap/galaxyGeometry.mjs';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const target = path.join(root, 'config/overmap_galaxy.json');
const fallback = path.join(root, 'config/example/overmap_galaxy.json');
const token = randomBytes(24).toString('hex');
const hash = (data) => createHash('sha256').update(data).digest('hex');
const current = async () => { try { return await readFile(target); } catch (e) { if (e.code !== 'ENOENT') throw e; return readFile(fallback); } };
let saving = false;
const server = http.createServer(async (req, res) => {
  const send = (status, data) => { res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' }); res.end(JSON.stringify(data)); };
  try {
    const route = new URL(req.url, 'http://localhost').pathname;
    if (req.headers.host !== `127.0.0.1:${server.address().port}`) return send(403, {error: 'Invalid host'});
    if (route === '/api/chart' && req.method === 'GET') { const data = await current(); return send(200, { chart: JSON.parse(data), revision: hash(data), token }); }
    if (route === '/api/chart' && req.method === 'POST') {
      if (req.headers['x-editor-token'] !== token || !req.headers['content-type']?.startsWith('application/json')) return send(403, {error:'Invalid request'});
      if (saving) return send(409, {error:'Сохранение уже выполняется'});
      saving = true;
      try {
        const parts = []; let bytes = 0; for await (const part of req) { bytes += part.length; if (bytes > 8 * 1024 * 1024) return send(413, {error:'Файл больше 8 МиБ'}); parts.push(part); }
        const { chart, revision } = JSON.parse(Buffer.concat(parts).toString('utf8'));
        const errors = validateGalaxy(chart); if (errors.length) return send(400, {error: errors.join('\n')});
        const before = await current(); if (revision !== hash(before)) return send(409, {error:'Файл изменился на диске. Экспортируй черновик и перезагрузи редактор.'});
        try { await copyFile(target, `${target}.bak`); } catch (e) { if (e.code !== 'ENOENT') throw e; }
        const data = JSON.stringify(chart, null, 2) + '\n';
        await writeFile(`${target}.tmp`, data); await rename(`${target}.tmp`, target);
        return send(200, {revision: hash(data)});
      } finally { saving = false; }
    }
    if (req.method !== 'GET') return send(405, {error:'Method not allowed'});
    const files = { '/': ['index.html','text/html'], '/app.mjs':['app.mjs','text/javascript'], '/style.css':['style.css','text/css'], '/geometry.mjs':['../../tgui/packages/tgui/interfaces/overmap/galaxyGeometry.mjs','text/javascript'] };
    if (!files[route]) return send(404, {error:'Not found'});
    const [file, type] = files[route]; const body = await readFile(path.resolve(here,file));
    res.writeHead(200, {'Content-Type':`${type}; charset=utf-8`, 'Cache-Control':'no-store', 'X-Content-Type-Options':'nosniff'}); res.end(body);
  } catch (error) { send(500, {error:String(error.message)}); }
});
let port = 8787;
server.on('error', (e) => { if(e.code === 'EADDRINUSE' && port < 8800) server.listen(++port, '127.0.0.1'); else { console.error(e); process.exitCode=1; } });
server.on('listening', () => { const url=`http://127.0.0.1:${port}`; console.log(`Galaxy editor: ${url}\nCtrl+C stops the editor. Save writes config/overmap_galaxy.json.`); if(process.argv.includes('--open')) spawn('cmd.exe',['/c','start','',url],{windowsHide:true,stdio:'ignore'}).unref(); });
server.listen(port,'127.0.0.1');
