# Frontend — React, Next.js e TypeScript

Checklist de revisão sênior. Aplique só o que for relevante ao diff; confirme a versão (React 18/19, Next Pages vs App Router) no `package.json` antes de apontar algo específico de versão.

## Corretude e estado
- **Estado derivado guardado em `useState`** (cópia de props/estado que poderia ser calculada no render) → dessincronização. Calcule no render ou use `useMemo` se for caro.
- **`useEffect` desnecessário**: sincronizar estado com estado, reagir a evento do usuário dentro de effect, buscar dados que poderiam vir do servidor. Pergunta: "isso é sincronização com sistema externo?" Se não, não é effect.
- **Dependências de hooks** incorretas ou suprimidas (`eslint-disable react-hooks/exhaustive-deps`) → closures obsoletas. Exija justificativa.
- **Race condition em fetch** dentro de effect sem `AbortController`/flag de cancelamento → resposta antiga sobrescreve a nova.
- **Cleanup ausente** em listeners, timers, subscriptions, `IntersectionObserver`, WebSocket.
- **`key` instável** (índice em lista reordenável, `Math.random()`) → perda de estado e bugs de input.
- **Mutação de estado** (push/splice/atribuição em objeto do state) → re-render não acontece ou acontece errado.
- Estados de **loading / erro / vazio** tratados? Botões que disparam requisição duplicada (sem `disabled`/idempotência)?
- Formulários: validação no cliente **e** no servidor; mensagens de erro acessíveis; schema compartilhado (ex.: zod) quando o projeto já usa.

## Next.js (App Router)
- Fronteira `'use client'` alta demais (página inteira virando client) → bundle maior e perda de RSC. Empurre o client para as folhas.
- **Segredos no cliente**: variáveis `NEXT_PUBLIC_*` com dado sensível; import de módulo server-only em client component (use `server-only`).
- **Server Actions e Route Handlers são endpoints públicos**: exigem autenticação, autorização e validação de entrada em cada um — não confie que só a UI chama.
- Semântica de cache/revalidação (`fetch` cache, `revalidate`, `revalidatePath/Tag`, `dynamic`, `cookies()`/`headers()` tornando rota dinâmica) coerente com a necessidade de dados frescos. Confirme o comportamento padrão da versão em uso.
- **Hydration mismatch**: `Date.now()`, `Math.random()`, `window`, locale/fuso diferente entre servidor e cliente.
- `loading.tsx`, `error.tsx`, `not-found.tsx` e `Suspense` nos lugares certos; `notFound()`/`redirect()` em vez de render condicional frágil.
- Middleware fazendo trabalho pesado ou sendo a **única** camada de autorização.
- Metadata/SEO (`generateMetadata`) quando a página é pública.
- Pages Router: `getServerSideProps` x `getStaticProps` adequados; não vazar props sensíveis para o cliente.

## Dados no cliente
- Uso consistente da lib do projeto (React Query/SWR/RTK Query): chaves de cache estáveis, invalidação após mutation, `staleTime` coerente, sem duplicar estado do servidor em store global.
- Paginação/infinite scroll e debounce em buscas.
- Tratamento de 401/403 (refresh de token, redirecionamento) centralizado.

## Performance
- Re-render em cascata: contexto com valor novo a cada render, objetos/funções inline passados a componentes memoizados. `useMemo/useCallback/memo` só quando há ganho mensurável ou contrato de referência — memo indiscriminado também é ruído. (Se o projeto usa React Compiler, não exija memo manual.)
- Listas grandes sem virtualização.
- Bundle: imports pesados (lodash inteiro, moment, ícones inteiros), falta de `next/dynamic`/lazy em componentes pesados abaixo da dobra.
- Imagens sem `next/image` (ou sem `width/height`/`sizes`) → CLS e LCP ruins; fontes sem `next/font`.
- Trabalho caro no render (sort/filter de listas grandes sem memo).

## Segurança
- `dangerouslySetInnerHTML` sem sanitização (DOMPurify); `href` montado com entrada do usuário (`javascript:`).
- Tokens em `localStorage` (exposto a XSS) quando cookie `HttpOnly` é viável.
- Dados sensíveis em logs do browser, query string ou analytics.
- Autorização feita só escondendo botão — o backend precisa validar.

## Acessibilidade (a11y)
- Elementos interativos semânticos (`button`, `a`, `label` associada a input) em vez de `div onClick`.
- Foco visível, ordem de tabulação, armadilha de foco em modais (ou `<dialog>`), `Esc` para fechar.
- `alt` em imagens, `aria-*` só quando o HTML semântico não resolve, contraste de cor, mensagens de erro anunciadas (`aria-live`/`aria-describedby`).

## TypeScript
- `any`, `as` forçado, `!` (non-null assertion) e `@ts-ignore` escondendo bug real. Prefira `unknown` + narrowing, type guards, `satisfies`.
- Uniões discriminadas para estados (`{ status: 'loading' } | { status: 'error', error } | { status: 'success', data }`) em vez de vários booleans.
- Tipos de API gerados/compartilhados (OpenAPI, tRPC, zod) em vez de duplicados à mão; validação em runtime nas fronteiras (resposta de API externa).
- `strict` desligado ou regras relaxadas no diff.

## Organização e manutenção
- Componente fazendo tudo (fetch + regra de negócio + layout) → extrair hooks/serviços.
- Lógica de negócio duplicada entre front e back sem fonte única.
- Estilos: seguir o sistema do projeto (Tailwind, CSS Modules, design system); valores mágicos em vez de tokens.
- i18n/formatação de datas, moedas e números com `Intl` e fuso correto.

## Testes
- Testing Library testando comportamento (`getByRole`, interações com `user-event`) e não detalhes de implementação.
- Mocks de rede (MSW) em vez de mockar hooks internos.
- Cobertura dos estados de erro/vazio/loading e de regras críticas; e2e (Playwright/Cypress) para fluxos de dinheiro/autenticação.
