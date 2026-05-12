@echo off

chcp 65001 >nul

echo ============================================

echo  Deploy Feegow Proxy - Centro Medico Pastore

echo ============================================

echo.
 
echo [1/5] Verificando Node.js...

node --version >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (

    echo ERRO: Node.js nao encontrado!

    echo Baixe em: https://nodejs.org e instale antes de continuar.

    pause

    exit /b 1

)

echo OK - Node.js encontrado

echo.
 
echo [2/5] Instalando Railway CLI...

call npm install -g @railway/cli

echo OK

echo.
 
echo [3/5] Criando arquivos do projeto...

IF NOT EXIST "feegow-proxy" mkdir feegow-proxy
 
REM Salvar index.js via node para evitar problemas de escape no bat

node -e "const fs=require('fs');fs.writeFileSync('feegow-proxy/index.js',`const express = require('express');\nconst fetch = require('node-fetch');\nconst app = express();\nconst FEEGOW_BASE = 'https://www.api.feegow.com.br/api';\nconst PORT = process.env.PORT || 3000;\napp.use((req, res, next) => {\n  res.header('Access-Control-Allow-Origin', '*');\n  res.header('Access-Control-Allow-Headers', '*');\n  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');\n  res.header('Access-Control-Max-Age', '86400');\n  if (req.method === 'OPTIONS') return res.status(204).send('');\n  next();\n});\napp.get('/health', (req, res) => {\n  res.json({ status: 'ok', token: process.env.FEEGOW_TOKEN ? 'configurado' : 'FALTANDO', ts: new Date().toISOString() });\n});\napp.use('/', async (req, res) => {\n  const token = process.env.FEEGOW_TOKEN;\n  if (!token) return res.status(500).json({ error: 'FEEGOW_TOKEN nao configurado' });\n  const qs = req.url.includes('?') ? req.url.substring(req.url.indexOf('?')) : '';\n  const url = FEEGOW_BASE + req.path + qs;\n  console.log('->', url);\n  try {\n    const r = await fetch(url, { method: req.method, headers: { 'x-access-token': token, 'Content-Type': 'application/json', 'Accept': 'application/json' } });\n    const text = await r.text();\n    try { res.status(r.status).json(JSON.parse(text)); } catch(e) { res.status(r.status).send(text); }\n  } catch (err) { res.status(500).json({ error: err.message }); }\n});\napp.listen(PORT, () => console.log('Proxy rodando na porta ' + PORT));\n`);"
 
REM Salvar package.json

node -e "const fs=require('fs');fs.writeFileSync('feegow-proxy/package.json',JSON.stringify({name:'feegow-proxy',version:'1.0.0',main:'index.js',scripts:{start:'node index.js'},dependencies:{express:'^4.18.2','node-fetch':'^2.7.0'},engines:{node:'>=18'}},null,2));"
 
echo OK - Arquivos criados

echo.
 
echo [4/5] Instalando dependencias...

cd feegow-proxy

call npm install

echo OK

echo.
 
echo [5/5] Login e deploy no Railway...

echo Uma janela do navegador vai abrir para autenticar.

echo.

call railway login

call railway init

call railway up --detach

cd ..
 
echo.

echo ============================================

echo  Deploy concluido!

echo ============================================

echo.

echo PROXIMO PASSO OBRIGATORIO:

echo 1. Acesse https://railway.app

echo 2. Abra o projeto feegow-proxy

echo 3. Va em Variables e adicione:

echo    FEEGOW_TOKEN = seu token do Feegow

echo.

echo Depois teste em:

echo https://feegow-proxy.up.railway.app/health

echo.

pause

Node.js — Run JavaScript Everywhere
Node.js® is a free, open-source, cross-platform JavaScript runtime environment that lets developers create servers, web apps, command line tools and scripts.
 