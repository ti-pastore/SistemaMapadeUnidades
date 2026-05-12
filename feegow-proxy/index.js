const express = require('express');
const fetch = require('node-fetch');
const app = express();
const FEEGOW_BASE = 'https://www.api.feegow.com.br/api';
const PORT = process.env.PORT || 3000;
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Max-Age', '86400');
  if (req.method === 'OPTIONS') return res.status(204).send('');
  next();
});
app.get('/health', (req, res) => {
  res.json({ status: 'ok', token: process.env.FEEGOW_TOKEN ? 'configurado' : 'FALTANDO', ts: new Date().toISOString() });
});
app.use('/', async (req, res) => {
  const token = process.env.FEEGOW_TOKEN;
  if (!token) return res.status(500).json({ error: 'FEEGOW_TOKEN nao configurado' });
  const qs = req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : '';
  const url = FEEGOW_BASE + req.path + qs;
  console.log('->', url);
  try {
    const r = await fetch(url, { method: req.method, headers: { 'x-access-token': token, 'Content-Type': 'application/json', 'Accept': 'application/json' } });
    const text = await r.text();
    try { res.status(r.status).json(JSON.parse(text)); } catch(e) { res.status(r.status).send(text); }
  } catch (err) { res.status(500).json({ error: err.message }); }
});
app.listen(PORT, () => console.log('Proxy rodando na porta ' + PORT));
