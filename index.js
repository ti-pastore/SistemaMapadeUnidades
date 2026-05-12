const express = require('express');
const fetch = require('node-fetch');
const app = express();

const FEEGOW_BASE = 'https://api.feegow.com.br/api';
const PORT = process.env.PORT || 3000;

// ✅ CORS aberto para qualquer origem
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Max-Age', '86400');
  if (req.method === 'OPTIONS') return res.status(204).send('');
  next();
});

// Health check — usar para testar se está funcionando
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    token: process.env.FEEGOW_TOKEN ? 'configurado ✅' : 'FALTANDO ❌',
    timestamp: new Date().toISOString()
  });
});

// Proxy → Feegow
app.use('/', async (req, res) => {
  const token = process.env.FEEGOW_TOKEN;
  if (!token) {
    return res.status(500).json({ error: 'FEEGOW_TOKEN não configurado no Railway' });
  }

  const qs = req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : '';
  const feegowUrl = `${FEEGOW_BASE}${req.path}${qs}`;
  console.log(`→ Chamando Feegow: ${feegowUrl}`);

  try {
    const resp = await fetch(feegowUrl, {
      method: req.method,
      headers: {
        'x-access-token': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    });

    const text = await resp.text();
    try {
      res.status(resp.status).json(JSON.parse(text));
    } catch {
      res.status(resp.status).send(text);
    }

  } catch (err) {
    console.error('Erro proxy:', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Proxy rodando na porta ${PORT}`);
  console.log(`Token: ${process.env.FEEGOW_TOKEN ? '✅ configurado' : '❌ FALTANDO'}`);
});
