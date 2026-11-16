# Modelo do relatório — senior-review

Regras de apresentação:
- Markdown direto (nunca o relatório inteiro dentro de bloco de código; nunca recuo de 4 espaços no início das linhas).
- Blocos de código só para trechos, comandos e saídas.
- Referências no formato `caminho/arquivo.ext:linha`.
- Remova seções sem conteúdo em vez de preencher com placeholders.
- Seja proporcional: diff pequeno → relatório curto. Não infle o relatório.

---

~~~markdown
# Senior Review · <título curto do que foi feito>

**Escopo:** <branch> vs `<base>` (merge-base `<sha-curto>`) · <N> commits seus · <não commitado: sim/não>
**Arquivos:** <X> arquivos · +<adições> / -<remoções>
**Stack:** <ex.: Next.js 15 + TS / Spring Boot 3 + JPA / NestJS + Prisma>
**Validações:** <typecheck ✅ · lint ⚠️ 2 warnings · testes ✅ 48/48 · build não executado (motivo)>
**Veredito:** **<Pronto para seguir | Pronto com ressalvas | Precisa de ajustes>**

> <Uma frase objetiva justificando o veredito.>

## Resumo

<1–2 parágrafos: o que foi feito e os principais riscos/achados.>

| Severidade | Qtde |
|---|---:|
| Alta | X |
| Média | X |
| Baixa | X |
| Sugestão sênior | X |

## Pontos fortes

- <Ponto concreto, com arquivo quando fizer sentido.>

## Achados

### [Alta] <Título claro do problema>

**Onde:** `caminho/arquivo.ext:linha`
**Problema:** <O que está errado e em qual cenário acontece. Marque **Hipótese** se não confirmado.>
**Por que importa:** <Impacto real: usuário, dados, segurança, operação, manutenção. Explique o raciocínio sênior.>
**Como corrigir:**

```<linguagem>
// trecho sugerido, curto e no padrão do projeto
```

**Como validar:** <Teste a escrever ou comando/cenário para confirmar a correção.>

---

### [Média] ...

### [Baixa] ...

### [Sugestão sênior] ...

<details>
<summary><strong>🧪 Validações executadas</strong></summary>

| Comando | Resultado |
|---|---|
| `<comando>` | ✅ / ❌ / ⚠️ <resumo> |

</details>

<details>
<summary><strong>📦 Dívida preexistente (fora do seu escopo)</strong></summary>

- <Somente itens relevantes que encostam no que foi alterado; máximo 5.>

</details>

## Próximos passos

1. <Ação priorizada e objetiva.>
2. ...

> Quer que eu aplique as correções? Diga quais itens (ex.: "corrige as Altas" ou "itens 1 e 3").
~~~
