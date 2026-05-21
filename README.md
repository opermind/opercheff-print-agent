# OperChef Print Agent

Serviço Windows leve (~40-80 MB) que recebe jobs de impressão assinados (HMAC-SHA256) do backend OperChef e envia para impressoras térmicas locais (USB ou rede).

Substitui o **QZ Tray** (sem Java, sem popup, sem certificado autoassinado) e o "Modo Servidor" do app desktop legado.

## Arquitetura

```
PDV/Celular → Supabase Edge Function (print-agent-dispatch)
                          ↓ assina HMAC
              LAN http://192.168.x.x:8765/print
                          ↓ fallback
              https://*.trycloudflare.com/print
                          ↓
              OperChefPrintAgent.exe (serviço Windows)
                          ↓
              Impressora USB/Serial/IP
```

## Endpoints (porta 8765)

| Método | Path | Auth | Descrição |
|---|---|---|---|
| GET  | `/health`        | público | versão + status de pareamento |
| GET  | `/printers`      | público | lista impressoras Windows detectadas |
| POST | `/pair`          | token   | consome pair token do OperChef |
| POST | `/print`         | HMAC    | imprime job assinado |
| POST | `/test-printer`  | público | impressão de teste |

## Desenvolvimento

```bash
npm install
npm start          # roda em http://localhost:8765
npm run build      # gera dist/OperChefPrintAgent.exe (precisa rodar no Windows)
npm run installer  # gera dist/OperChefPrintAgentSetup.exe (requer NSIS instalado)
```

## Pareamento

1. No OperChef, abra **Configurações → Impressoras → OperChef Print Agent → Parear novo PC**.
2. Será gerado um QR / token de 10min.
3. No PC, abra `http://localhost:8765` ou rode `curl -X POST http://localhost:8765/pair -d '{"token":"..."}' -H "Content-Type: application/json"`.
4. O agente recebe `hmacSecret` e passa a aparecer **online** no painel.

## Release

Push de tag `agent-v0.1.0` dispara o workflow `.github/workflows/release.yml`, que compila o `.exe` com `pkg`, monta o instalador NSIS e publica em GitHub Releases. O botão **Baixar instalador** dentro do OperChef aponta para `https://github.com/SEU-USUARIO/opercheff-print-agent/releases/latest/download/OperChefPrintAgentSetup.exe`.

## Licença

MIT
