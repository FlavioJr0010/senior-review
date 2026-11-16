# senior-review

Skill para **Claude Code** e **OpenAI Codex** (e agentes compatíveis com `.agents/skills`) que faz **revisão de código com padrão de engenheiro sênior**, no frontend e no backend, sobre **o que você fez**: alterações não commitadas, seus commits na branch atual ou arquivos/módulos que você indicar.

> Diferente da [`pr-auditor`](https://github.com/FlavioJr0010/pr-auditor), que audita um Pull Request contra template e CI, a `senior-review` foca na **qualidade de engenharia** do seu próprio trabalho, antes mesmo de abrir o PR.

## O que ela faz

- **Escopo automático do seu trabalho:** identifica seu autor no git, descobre a branch base e junta alterações não commitadas, staged, arquivos novos e seus commits na branch, ignorando commits de outras pessoas.
- **Lentes de um sênior:** corretude, segurança, dados e concorrência, contratos front ↔ back, arquitetura, performance, resiliência, observabilidade, testes e manutenibilidade.
- **Profundidade por stack:** referências carregadas sob demanda para:
  - React / Next.js + TypeScript
  - Java / Spring Boot (JPA, transações, Spring Security)
  - Node.js (NestJS, Express, Fastify, Prisma/TypeORM)
  - Transversal + heurísticas para qualquer outra stack (Python, Go, .NET, mobile)
- **Validação com evidência:** roda typecheck, lint, build e testes relacionados e diferencia falhas suas de dívida preexistente. Pode criar um teste temporário para provar um bug e o remove em seguida.
- **Severidade clara:** `[Alta]`, `[Média]`, `[Baixa]` e `[Sugestão sênior]`, cada achado com **Onde**, **Problema**, **Por que importa**, **Como corrigir** e **Como validar**.
- **Segura:** somente leitura por padrão e nunca usa `stash`/`reset`/`checkout` no seu worktree. Só corrige quando você pede, e não commita nem dá push sozinha.

## Estrutura

```text
senior-review/
├── SKILL.md                         # protocolo da revisão
└── references/
    ├── cross-cutting.md             # segurança, API, dados, concorrência, testes...
    ├── frontend-react-next.md
    ├── backend-java-spring.md
    ├── backend-node.md
    └── report-template.md           # formato do relatório
```

As pastas `.claude/`, `.codex/` e `.agents/` contêm cópias prontas para uso local no projeto.

---

## Instalação

### 1. Via `npx skills` (universal)

```bash
npx skills add FlavioJr0010/senior-review
```

### 2. Instalação global com o script

```bash
git clone https://github.com/FlavioJr0010/senior-review.git
cd senior-review
./scripts/install.sh            # copia para ~/.claude/skills, ~/.codex/skills e ~/.agents/skills
```

### 3. Instalação global manual

```bash
# Claude Code
mkdir -p ~/.claude/skills && cp -R senior-review ~/.claude/skills/

# OpenAI Codex
mkdir -p ~/.codex/skills && cp -R senior-review ~/.codex/skills/

# Agentes compatíveis com .agents
mkdir -p ~/.agents/skills && cp -R senior-review ~/.agents/skills/
```

### 4. Instalação por projeto

```bash
./scripts/install.sh /caminho/do/seu/projeto
```

Cria `.claude/skills/senior-review`, `.codex/skills/senior-review` e `.agents/skills/senior-review` no projeto.

---

## Como usar

**Claude Code:** `/senior-review` ou prompt direto. **Codex:** `$senior-review` ou prompt direto.

```text
/senior-review
```

```text
Use a skill senior-review para revisar o que eu fiz nesta branch contra a dev.
```

```text
Faça um senior review só do módulo src/modules/payments.
```

```text
Revise minhas alterações não commitadas como um sênior faria.
```

Depois do relatório, peça as correções que quiser:

```text
Corrige os achados de severidade Alta.
```

## Padrão do relatório

1. Escopo revisado, stack, validações e **veredito** (`Pronto para seguir`, `Pronto com ressalvas` ou `Precisa de ajustes`);
2. resumo e contagem por severidade;
3. pontos fortes;
4. achados com onde, problema, por que importa, como corrigir e como validar;
5. validações executadas, dívida preexistente fora do escopo e próximos passos.

## Contribuindo

Edite os arquivos em `senior-review/` e rode `./scripts/install.sh --sync` para atualizar as cópias em `.claude/`, `.codex/` e `.agents/`.

---

by [@FlavioJr0010](https://github.com/FlavioJr0010)
