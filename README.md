# HammerTempo

Jogo de ritmo em que você é um ferreiro forjando armas ao som de músicas medievais.
As notas acompanham a percussão da música e são acertadas com as setas do teclado, com
WASD ou com o direcional de um controle.

Desenvolvido pela **Panela Games** em uma Game Jam de 5 dias
(Beatrice Fischer, Gabriele Maria Freiberger, Gustavo Hreczuck, Lucas de Carvalho Ziele,
Raul Schmitz) e em refinamento para apresentação na feira de profissões.

---

## Como abrir

1. Instale o **GameMaker Studio 2** (o projeto foi feito na IDE `2024.13.1`).
2. Abra o arquivo `HammerTempo.yyp`.
3. `F5` para rodar.

> O projeto se chamava `Jorge's Smith 2.0.yyp` até a Sprint 2. Se o GameMaker abrir a
> versão antiga pelos "projetos recentes", feche e abra `HammerTempo.yyp`.

## Controles

| Ação | Teclado | Controle |
|---|---|---|
| Notas / navegação | `↑ ↓ ← →` ou `W A S D` | direcional ou analógico esquerdo |
| Confirmar | `Enter` ou `Espaço` | botão 1 / Start |
| Voltar | `Esc` | botão 2 / Select |
| Overlay de diagnóstico | `F3` | — |

Teclado e controle funcionam ao mesmo tempo; o jogo detecta sozinho qual foi usado por
último. O remapeamento de botões entra na Sprint 3.5.

## Estrutura do projeto

```
scripts/     funções compartilhadas (enums, input, UI, save, ritmo, debug)
objects/     objetos do jogo — toda a lógica de gameplay vive em eventos
rooms/       rm_splash -> rm_menu -> rm_forja / rm_opcoes / rm_creditos
sprites/     pixel art
sounds/      músicas (streaming) e efeitos
docs/        documentação técnica e planejamento
```

## Documentação

| Arquivo | Conteúdo |
|---|---|
| [docs/00-DECISOES.md](docs/00-DECISOES.md) | Registro das decisões tomadas em cada sprint |
| [docs/01-ARQUITETURA.md](docs/01-ARQUITETURA.md) | Como o jogo funciona por dentro |
| [docs/02-AUDITORIA.md](docs/02-AUDITORIA.md) | Achados técnicos, com severidade e reprodução |
| [docs/03-ROADMAP-SPRINTS.md](docs/03-ROADMAP-SPRINTS.md) | Plano de trabalho por frente |
| [docs/04-ARCADE.md](docs/04-ARCADE.md) | Preparação para o gabinete da feira |

## Save

O jogo grava opções (e, a partir da Sprint 4, o leaderboard) em
`hammertempo_save.json`, na pasta de save do GameMaker
(`%LOCALAPPDATA%\HammerTempo\`). Apagar o arquivo restaura os padrões.

## Créditos e licenças de assets

A lista completa de assets de terceiros, com autor, link e termos de uso, está na tela de
**Créditos** dentro do jogo (`objects/o_creditos/Create_0.gml`). As músicas das fases são
melodias de domínio público (séculos X–XIV), com arranjo e gravação de Maiko Thomé de Araujo.
