# Feegow Proxy — Centro Médico Pastore

Proxy que resolve o CORS para a API Feegow.

## Arquivos
- `index.js` — servidor proxy
- `package.json` — dependências

## Deploy no Railway

1. Faça upload dos 2 arquivos (index.js e package.json) no repositório GitHub
2. No Railway, conecte o repositório e faça deploy
3. Vá em **Variables** e adicione:
   - `FEEGOW_TOKEN` = seu token da API Feegow
4. Após deploy, teste acessando:
   `https://SUA-URL.up.railway.app/health`

## Testar
`https://SUA-URL.up.railway.app/appoints/search?date=12-05-2026&unidade_id=57`
