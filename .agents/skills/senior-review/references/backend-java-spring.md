# Backend — Java e Spring Boot

Checklist de revisão sênior. Confirme versões (Java 17/21+, Spring Boot 2.x vs 3.x, `javax` vs `jakarta`) no `pom.xml`/`build.gradle` antes de sugerir algo dependente de versão.

## Arquitetura e camadas
- Controller fino: validação de entrada, mapeamento e delegação. Regra de negócio em service/domínio; acesso a dados em repository.
- **Entidade JPA exposta na API** (request/response) → vazamento de campos, lazy loading em serialização, acoplamento de contrato com schema. Use DTOs/`record`s e mapeamento explícito (MapStruct ou manual, conforme o projeto).
- Injeção por **construtor** (campos `final`), não `@Autowired` em campo. Dependências circulares indicam design a revisar.
- Configuração tipada com `@ConfigurationProperties` + validação, em vez de `@Value` espalhado.
- Consistência com a estrutura já usada (por camada ou por feature/módulo).

## Transações
- `@Transactional` em método **privado** ou chamado pelo próprio bean (self-invocation) **não** é aplicado pelo proxy.
- Escopo transacional amplo demais (chamada HTTP externa, envio de e-mail ou fila dentro da transação) → locks longos e inconsistência. Use eventos pós-commit (`@TransactionalEventListener(phase = AFTER_COMMIT)`) ou outbox.
- `readOnly = true` em leituras; rollback para checked exceptions (`rollbackFor`) quando aplicável.
- Operações que precisam ser atômicas espalhadas em várias transações.

## JPA / Hibernate e banco
- **N+1**: acesso a coleções lazy em loop, serialização de relacionamentos. Use `JOIN FETCH`, `@EntityGraph`, projeções/DTO queries.
- `FetchType.EAGER` (especialmente em `@ManyToOne`/`@OneToMany` padrão) carregando grafo inteiro.
- `spring.jpa.open-in-view` habilitado mascarando lazy loading na camada web.
- `equals/hashCode` de entidade baseado em todos os campos ou em ID gerado (quebra em `Set` antes do persist); Lombok `@Data` em entidade (toString recursivo, hashCode mutável).
- **Concorrência**: atualização de saldo/estoque/contador sem `@Version` (lock otimista) ou lock pessimista/`UPDATE ... WHERE` atômico → lost update.
- Queries nativas/JPQL concatenando strings → SQL injection. Use parâmetros nomeados.
- Paginação (`Pageable`) em listagens; `findAll()` sem limite.
- Migrations (Flyway/Liquibase): nunca editar migration já aplicada; mudanças compatíveis com a versão anterior da aplicação (expand/contract); índices para novas consultas; constraints (`NOT NULL`, `UNIQUE`, FK) refletindo as regras do domínio. `ddl-auto=update` fora de dev é risco.
- `BigDecimal` para dinheiro (nunca `double`), com escala e `RoundingMode` explícitos.

## Validação e erros
- Bean Validation (`@Valid`, `@NotNull`, `@Size`...) nos DTOs de entrada; validações de negócio no domínio.
- Tratamento centralizado com `@RestControllerAdvice`, formato de erro consistente (ex.: `ProblemDetail`/RFC 9457) e status HTTP corretos (400 vs 404 vs 409 vs 422).
- `catch (Exception e)` engolindo erro, `e.printStackTrace()`, retornar `null` em vez de `Optional`/exceção; `Optional.get()` sem verificação.
- Exceções de domínio significativas em vez de `RuntimeException` genérica.

## Segurança
- Toda rota nova coberta pela configuração do Spring Security (`SecurityFilterChain`); `permitAll` amplo demais.
- **Autorização por recurso (IDOR)**: verificar que o recurso pertence ao usuário/tenant, não só que está autenticado (`@PreAuthorize`, checagem no service, filtro por tenant na query).
- CSRF desabilitado sem motivo (ok para API stateless com token; não para sessão com cookie).
- Senhas com `BCrypt`/`Argon2`; JWT validado (assinatura, expiração, issuer/audience); segredos fora do código (`application.yml` sem credenciais reais).
- Logs sem PII, tokens ou senhas; mass assignment ao mapear request direto para entidade.
- Upload: validação de tipo/tamanho, path traversal ao salvar arquivos.

## Datas, tempo e concorrência
- `Instant`/`OffsetDateTime` para momentos; `LocalDate` para datas de calendário; `ZoneId` de negócio explícito; nunca `new Date()`/`Calendar` em código novo. Injetar `Clock` para testabilidade.
- Estado mutável em beans singleton (campos não-final em `@Service`) → race condition entre requisições.
- `@Async`/`CompletableFuture` sem executor configurado ou sem propagação de contexto (segurança, MDC, transação).
- Virtual threads (Java 21+): cuidado com `synchronized` prendendo carrier thread em I/O e com `ThreadLocal` pesado.
- Idempotência em endpoints de pagamento/criação acionados por retry (chave de idempotência, constraint única).

## Integrações e resiliência
- Cliente HTTP (`RestClient`/`WebClient`/Feign) sem timeout de conexão e leitura.
- Retries sem backoff ou em operação não idempotente; circuit breaker quando a dependência é instável.
- Consumidores de fila (Kafka/Rabbit/SQS): idempotência, tratamento de mensagem envenenada (DLQ), ordem e commit de offset.
- `@Scheduled` em várias instâncias executando em duplicidade (use ShedLock ou equivalente).

## Observabilidade
- Logs estruturados com SLF4J (placeholders `{}`, não concatenação), nível adequado, correlation id (MDC).
- Actuator/health checks e métricas (Micrometer) para fluxos críticos novos.

## Código idiomático
- `record` para DTOs imutáveis, `switch` com pattern matching, `Stream` só quando melhora a leitura (não para efeitos colaterais).
- `Optional` como retorno, não como campo/parâmetro.
- Lombok usado com moderação e consistente com o projeto.

## Testes
- Testes unitários do domínio/service sem subir contexto Spring.
- Slices: `@WebMvcTest` (controller + validação + segurança), `@DataJpaTest` (queries), preferencialmente com **Testcontainers** no banco real em vez de H2 quando há SQL específico.
- Teste de autorização (usuário A não acessa recurso de B) e de concorrência para regras críticas.
- Evitar `@SpringBootTest` para tudo (lento) e mocks excessivos que só testam o mock.
