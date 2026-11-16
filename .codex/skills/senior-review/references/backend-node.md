# Backend — Node.js (NestJS, Express, Fastify)

Checklist de revisão sênior. Confirme versões (Node LTS, Nest, ORM) e o tipo de módulo (ESM/CJS) no `package.json` antes de sugerir algo dependente de versão.

## Assincronia e event loop
- **Promises soltas** (sem `await`, sem `.catch`) → erros perdidos e `unhandledRejection`. Ative/respeite `@typescript-eslint/no-floating-promises`.
- `await` em loop quando as operações são independentes → use `Promise.all` (com limite de concorrência, ex. `p-limit`, para muitas chamadas). O inverso também: `Promise.all` sem limite em milhares de itens derruba o banco/API.
- `forEach` com callback `async` (não espera nada).
- **Bloqueio do event loop**: CPU pesada (crypto síncrono, `JSON.parse` de payload enorme, regex catastrófica, loops grandes), APIs `*Sync` em request. Use streams, worker threads ou fila.
- Express < 5: erro lançado em handler `async` não chega ao error middleware sem wrapper.

## Arquitetura
- **NestJS**: módulos coesos, providers injetados por construtor, regras no service, controllers finos; `Guards` para auth, `Pipes` (`ValidationPipe` com `whitelist` e `forbidNonWhitelisted`) para validação, `Interceptors`/`Filters` para transversais. Evite lógica em decorators customizados obscuros.
- **Express/Fastify**: ordem de middlewares (body parser, auth, rotas, 404, error handler por último); handlers sem regra de negócio; separação rota → controller → service → repositório conforme o padrão do projeto.
- Dependências acopladas via import direto de singletons dificultando testes.
- Config centralizada e **validada no boot** (zod/joi/`@nestjs/config` com schema); `process.env` espalhado pelo código é cheiro.

## Validação e contratos
- Toda entrada externa validada (body, params, query, headers, mensagens de fila) com zod/class-validator/TypeBox/schema do Fastify; tipos TS **não** validam em runtime.
- Mass assignment: passar `req.body` direto para o ORM (`create(req.body)`) permite setar `role`, `ownerId` etc.
- Respostas com DTO/serialização explícita (não devolver entidade com hash de senha, campos internos).
- Formato de erro consistente e status HTTP corretos; não vazar stack trace em produção.

## Dados (Prisma, TypeORM, Sequelize, Drizzle, Mongoose)
- N+1 (consultas em loop) → `include`/`relations`/joins ou batch (DataLoader em GraphQL).
- Transações para operações multi-etapa (`prisma.$transaction`, `queryRunner`), com cuidado de não fazer I/O externo dentro.
- Concorrência: incrementos/decrementos via update atômico (`increment`, `UPDATE ... SET x = x - 1 WHERE x > 0`) em vez de ler-modificar-gravar; constraints únicas para idempotência.
- `$queryRawUnsafe`/concatenação de SQL → injection. Use queries parametrizadas/tagged templates.
- Migrations versionadas e compatíveis com deploy gradual; índices para novas consultas; `select` só dos campos necessários.
- Pool de conexões dimensionado; em serverless, cuidado com explosão de conexões (pooler/`DIRECT_URL` vs `DATABASE_URL`).
- Mongo: validação de schema, índices, operadores vindos do usuário (`$where`, `$ne` → NoSQL injection).

## Segurança
- Autenticação: JWT verificado (algoritmo fixo, expiração, issuer/audience), segredo forte fora do código; refresh token rotacionado; cookies `HttpOnly`, `Secure`, `SameSite`.
- **Autorização por recurso (IDOR)** e por tenant em cada query, não só no guard.
- `helmet`, CORS restrito (não `origin: '*'` com credenciais), rate limiting em login/rotas sensíveis, limite de tamanho de body.
- Prototype pollution em merges profundos com entrada do usuário; path traversal em arquivos; SSRF em fetch de URL vinda do usuário.
- Segredos e PII fora dos logs; `npm audit`/dependências novas avaliadas (manutenção, licença, tamanho).

## Resiliência e operação
- `fetch`/axios sem **timeout** (`AbortSignal.timeout`) e sem retry com backoff para chamadas idempotentes.
- Graceful shutdown (`SIGTERM`: parar de aceitar requisições, drenar, fechar pool/filas); `enableShutdownHooks` no Nest.
- Jobs/filas (BullMQ etc.): idempotência, retries, DLQ, concorrência configurada; cron duplicado em múltiplas instâncias.
- Streams para arquivos grandes em vez de carregar em memória; backpressure respeitado.
- Health/readiness checks para recursos novos.

## Observabilidade
- Logger estruturado (pino/winston) com níveis e request id/correlation id (AsyncLocalStorage); nada de `console.log` esquecido.
- Erros logados uma vez, com contexto, no ponto certo (não logar e relançar em todas as camadas).

## TypeScript
- `strict` ligado; sem `any`/`as` escondendo formato real de dados externos; tipos derivados do schema (`z.infer`) ou do ORM.
- Uniões discriminadas para resultados/estados; `unknown` em `catch` com narrowing.

## Testes
- Unitários de service com dependências injetadas; integração de rotas com `supertest`/`app.inject` (Fastify) e banco real (Testcontainers ou banco de teste) quando há SQL relevante.
- Casos de autorização, validação de entrada inválida, erros de dependência externa (timeout) e concorrência para regras críticas.
- Mocks com moderação; nada de testes que dependem de ordem ou de horário real (use fake timers/clock injetado).
