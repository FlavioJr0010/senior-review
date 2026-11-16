# Transversal — vale para qualquer stack

Carregue sempre. Também serve de base para stacks sem referência própria (Python, Go, C#, PHP, mobile...): aplique os princípios e adapte ao idioma da linguagem.

## Segurança (baseado no OWASP Top 10)
- **Controle de acesso**: cada operação verifica *quem* pode fazer *o quê* em *qual* recurso/tenant. IDOR é o bug mais comum em código novo.
- **Injeção**: SQL/NoSQL/comando/LDAP/template — sempre parametrizar; nunca montar comando de shell com entrada do usuário.
- **Dados sensíveis**: segredos fora do repositório (`.env` no `.gitignore`, nada de chaves em testes/fixtures reais); PII mínima, mascarada em logs; HTTPS; hash de senha adequado.
- **Validação nas fronteiras**: tudo que vem de fora (HTTP, fila, arquivo, webhook, API de terceiro) é não confiável. Webhooks com verificação de assinatura.
- **Dependências novas**: necessárias? mantidas? licença compatível? vulnerabilidades conhecidas? peso no bundle?
- SSRF, path traversal, upload sem validação, redirecionamento aberto, CORS permissivo, ausência de rate limit em autenticação.

## Design de API e contratos
- Verbos e status HTTP corretos; recursos com nomes consistentes; paginação, filtros e ordenação previsíveis.
- Formato de erro único e útil para quem consome (código, mensagem, detalhes de campo).
- **Compatibilidade**: remover/renomear campo, mudar tipo ou semântica quebra clientes (front, mobile, integrações). Prefira adicionar, depreciar e só depois remover.
- Idempotência em POST/PUT sujeitos a retry (pagamentos, criação de pedidos).
- Contrato front ↔ back alinhado: se o diff mexe nos dois lados, verifique tipos, nomes de campos, nullability, formatos de data/moeda/medidas e enums.

## Dados
- Migrations: reversíveis ou com plano de rollback; compatíveis com a versão anterior durante o deploy (expand → migrate → contract); backfill em lotes; sem lock longo em tabela grande.
- Integridade no banco (constraints, FKs, unique) e não só na aplicação.
- Índices para novas consultas/filtros; evitar `SELECT *` e varreduras em tabelas grandes.
- Datas em UTC no armazenamento e fuso de negócio explícito na apresentação/regra; dinheiro em tipo decimal/inteiro de centavos; unidades explícitas (cm, kg, ms).
- Soft delete, auditoria e LGPD quando o domínio exigir (retenção, anonimização, consentimento).

## Concorrência e consistência
- Ler-modificar-gravar sem lock/versão → lost update.
- Check-then-act (verifica se existe e depois cria) sem constraint única → duplicidade.
- Cache: invalidação, stampede, dados de um usuário servidos a outro (chave de cache sem tenant/usuário).
- Processos distribuídos: jobs duplicados entre instâncias, ordem de eventos, entrega "at-least-once" exigindo idempotência.

## Resiliência
- Timeouts em toda chamada de rede; retries só em operações idempotentes, com backoff e jitter; circuit breaker/fallback quando faz sentido.
- Falhas parciais: o que acontece se a etapa 2 de 3 falhar? Há compensação, outbox ou estado consistente?
- Limites: tamanho de payload, paginação máxima, quantidade de itens em lote.

## Observabilidade
- Logs estruturados, nível adequado, com correlation id, sem PII/segredos.
- Erros com contexto suficiente para debugar sem reproduzir; não engolir exceções.
- Métricas/alertas para fluxos críticos novos (taxa de erro, latência, filas).

## Performance
- Complexidade algorítmica adequada ao volume esperado (pense em 100x).
- I/O em loop (N+1 de banco ou de HTTP); trabalho síncrono pesado em caminho de requisição.
- Cache com estratégia de invalidação clara; payloads enxutos; compressão.
- Medir antes de otimizar: aponte otimização só com risco/impacto plausível, não micro-otimização.

## Testes
- O comportamento novo tem teste? Os casos de borda e de erro também?
- Pirâmide saudável: muitos unitários rápidos, integração nas fronteiras (banco, HTTP), poucos e2e nos fluxos críticos.
- Testes determinísticos (sem depender de hora real, ordem, rede externa, dados compartilhados).
- Teste de regressão para cada bug corrigido.
- Asserções significativas (não só "não lançou exceção"); nomes que descrevem o comportamento.

## Manutenibilidade
- Nomes que revelam intenção; funções pequenas com uma responsabilidade; níveis de abstração consistentes.
- Duplicação de regra de negócio (DRY para conhecimento, não para coincidência de código).
- Abstração prematura (interfaces com uma implementação sem motivo, generalizações especulativas — YAGNI) **e** abstração ausente (mesmo `if` em 5 lugares).
- Código morto, TODOs sem dono, flags/config não usados, comentários que repetem o código (comente o *porquê*).
- Tratamento de erro explícito; nada de "magic numbers"/strings soltas.
- Consistência com o padrão existente vale mais que o "jeito ideal" isolado — se sugerir mudar o padrão, trate como **Sugestão sênior** e justifique.

## Higiene de entrega
- Commits coesos e mensagens claras (o projeto usa Conventional Commits?); mudanças não relacionadas misturadas no mesmo commit.
- Arquivos que não deveriam estar no diff: `.env`, builds, logs, dumps, arquivos de IDE, `console.log`/`System.out` de debug, código comentado.
- Documentação (README, docs, OpenAPI, ADR) atualizada quando o comportamento ou contrato mudou.
- Feature flags/rollout gradual para mudanças arriscadas; plano de rollback.

## Heurísticas para stacks sem referência dedicada
- **Python**: type hints + mypy/pyright, exceções específicas, `with` para recursos, sem argumentos default mutáveis, `async` sem chamadas bloqueantes, Pydantic nas fronteiras, ORM (Django/SQLAlchemy) com cuidado de N+1 (`select_related`/`selectinload`).
- **Go**: erros sempre tratados e enriquecidos (`%w`), `context.Context` propagado com timeout, goroutines com ciclo de vida e sem vazamento, data races (`-race`), `defer` para fechar recursos.
- **C#/.NET**: `async` até o fim (sem `.Result`/`.Wait()`), `CancellationToken`, EF Core N+1 (`Include`), `IDisposable`, DI com lifetimes corretos (scoped em singleton).
- **Mobile (React Native/Flutter)**: estados offline, tamanho de bundle, permissões, armazenamento seguro de tokens, listas virtualizadas.
