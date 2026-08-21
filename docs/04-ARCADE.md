# HammerTempo — Preparação para o gabinete arcade

> Documento de preparação, escrito quando o hardware da feira foi confirmado.
> Não é plano de sprint: é o levantamento do que muda por causa do gabinete, com as
> decisões que precisam ser tomadas **antes** de escrever código.

## 1. Hardware confirmado

| Item | Situação |
|---|---|
| Tela | 21 polegadas — **resolução nativa ainda não confirmada** |
| Controle | Joystick arcade tradicional: **alavanca + botões** |
| Quantidade de botões | Ainda não confirmada |
| Tipo de conexão | Ainda não confirmado (encoder que emula teclado, ou XInput/DirectInput) |

As três incógnitas acima mudam decisões concretas. Vale confirmar antes do dia.

---

## 2. A alavanca serve para as notas? Não.

Esta é a conclusão mais importante do documento, e ela vai contra a intuição de que
"o jogo usa setas, a alavanca faz setas, então funciona".

### 2.1 O problema físico

Uma alavanca produz **uma direção por vez** e precisa passar pelo neutro para trocar de
direção. O jogo pede até 4 lanes, com notas chegando a cada:

| Fase | BPM | Semínima | Colcheia |
|---|---|---|---|
| 1 — Adaga | 88 | 682 ms | 341 ms |
| 2 — Lança | 100 | 600 ms | 300 ms |
| 3 — Espada | 108 | 555 ms | 277 ms |

O deslocamento humano de uma alavanca entre direções **adjacentes** fica na casa de
80–120 ms; entre direções **opostas**, 150–250 ms. Comparando com a janela de acerto do
jogo (±133 ms para "bom"), duas notas seguidas em lanes opostas numa colcheia deixam
praticamente nenhuma margem. A fase 2, que é toda construída em colcheias, seria
injogável na alavanca.

### 2.2 O problema de leitura: diagonais

Pior que a lentidão. Num gate quadrado de 8 vias, ir de **cima** para **direita** passa
pela diagonal **cima+direita**. A camada de input leria as **duas lanes como
pressionadas**, e uma delas não teria nota correspondente — resultado: toque inválido,
−10 pontos e combo quebrado, sem o jogador ter feito nada de errado.

O retorno da alavanca ao centro também tem rebote de microswitch, que pode disparar a
direção oposta por alguns milissegundos.

### 2.3 A recomendação

**As 4 lanes vão para 4 botões. A alavanca fica só para navegação de menu.**

É também o que os arcades de ritmo fazem: Pop'n Music usa botões, Taiko usa superfícies
de bater, DDR usa painéis de piso. Nenhum usa alavanca para as notas — pela razão acima.

Como a ordem física dos botões vira ordem de lane precisa ser decidida olhando o painel:
o mapeamento natural é **da esquerda para a direita, na mesma ordem em que as lanes
aparecem na tela** (cima, esquerda, direita, baixo — de cima para baixo).

### 2.4 Se ainda assim for preciso usar a alavanca

Mitigação possível, para o caso de o gabinete ter poucos botões:

- **Filtro de direção dominante**: quando duas direções estão ativas, só a de maior
  deslocamento conta. Elimina a diagonal parasita.
- **Histerese**: depois de aceitar uma direção, ignorar a oposta por ~60 ms, matando o
  rebote do retorno ao centro.
- **Reduzir o jogo para 2 lanes** nas fases jogadas na cabine (o jogo já suporta:
  `tipos_seta_permitidos` na estrutura da fase). Duas lanes opostas na alavanca ainda
  sofre do problema de deslocamento; duas lanes **adjacentes** (cima e direita, por
  exemplo) seria jogável.

---

## 3. Configuração manual de botões

Já previsto como Sprint 3.5. O cenário do gabinete torna obrigatório:

- Tela de remapeamento com captura ao vivo ("pressione o botão para a nota de cima...").
- **Defaults seguros por tipo de dispositivo**, para o jogo ser jogável mesmo sem
  ninguém configurar nada:
  - **Teclado**: setas e WASD para as lanes, Enter/Espaço confirmar, Esc voltar — o que já existe.
  - **Gamepad genérico**: d-pad e analógico para menu; os 4 botões de face para as lanes.
  - **Encoder de arcade**: identificar o padrão do encoder no dia e gravar como default.
- Persistência em disco: o remapeamento precisa sobreviver a reinício, senão alguém
  reconfigura a cada boot da cabine.
- **Detecção de dispositivo com fallback**: se o controle for desconectado no meio da
  feira, o teclado tem que continuar funcionando sem reiniciar o jogo.

---

## 4. Textos presos ao teclado

Todos os textos abaixo citam teclas específicas e precisam virar rótulo por dispositivo,
de preferência com ícone:

| Onde | Texto atual |
|---|---|
| Tela de resultado | "Pressione ENTER ou ESPAÇO para continuar" |
| Tutorial | "Pressione ENTER ou ESPAÇO para começar" |
| Tutorial | "Use as `<SETAS>` ou `<W A S D>` do teclado para acertar as notas" |
| Opções | "ESQUERDA e DIREITA ajustam - APLICAR salva - VOLTAR descarta" |

Já existe a base: `ui_texto_confirmar()` troca o texto quando o último dispositivo usado
foi um gamepad. Falta estender para todos os textos e trocar palavra por **ícone** —
numa feira, ninguém lê instrução, mas todo mundo entende um desenho de botão.

O pacote de assets já inclui uma folha de teclado (`Keyboard Pixel Art`, creditada em
`o_creditos`); faltaria o equivalente para botões de arcade.

---

## 5. Tela de 21 polegadas

O espaço de design é **1280x720**. O que acontece em cada resolução provável:

| Resolução da tela | Escala | Consequência |
|---|---|---|
| 1920x1080 | 1,5x | **Não inteira** — pixels de tamanhos diferentes (padrão 2:3) |
| 1600x900 | 1,25x | Não inteira, pior que 1,5x |
| 1366x768 | 1,067x | Não inteira, quase 1:1 — praticamente imperceptível |
| 2560x1440 | 2x | **Inteira**, pixel art perfeita |

Se a tela for 1080p, três saídas:

1. **Aceitar o 1,5x.** É o que a maioria dos jogos de pixel art faz. A 21 polegadas e à
   distância de um jogador em pé, provavelmente ninguém nota.
2. **Migrar o espaço de design para 960x540**, que dá 2x exato em 1080p. Custo alto: todo
   o posicionamento do HUD, das lanes e das telas foi calculado em 1280x720.
3. **Rodar em janela de 1280x720 centralizada**, com barras pretas em volta. Pixel
   perfeito, mas desperdiça metade da tela.

**Verificar a resolução nativa no dia** é o passo que decide isso. A recomendação, sem
mais informação, é a opção 1.

---

## 6. Operação da cabine

Itens já levantados na auditoria (AR-01) que o gabinete torna obrigatórios:

- **Tela cheia por padrão**, sem passar pelas opções.
- **Esconder "Sair do Jogo"** do menu: hoje qualquer visitante fecha o jogo.
- **Reset por inatividade**: voltar ao menu se a partida ficar parada.
- **Attract mode**: depois de ~60 s parado no menu, entrar em demonstração ou rodar o
  placar. É o que atrai gente para a cabine.
- **Bloquear Alt+F4 e Alt+Tab**, ou pelo menos não deixar o jogo perder o foco.
- **Teste de resistência**: deixar rodando 30 minutos e conferir FPS e memória.

---

## 7. Perguntas a responder antes de implementar

1. Qual a **resolução nativa** da tela de 21"?
2. **Quantos botões** o painel tem, e em que disposição física?
3. O painel é **encoder de teclado** ou **controle XInput/DirectInput**?
4. Vai ser **um jogador ou dois**? (muda o layout do painel e a leitura do input)
5. Dá para **testar no gabinete antes do dia**, ou a primeira vez vai ser na feira?

A resposta da 3 muda completamente o trabalho: encoder de teclado já funciona hoje com
remapeamento, enquanto XInput exige a camada de gamepad — que existe, mas nunca foi
testada com hardware real.
