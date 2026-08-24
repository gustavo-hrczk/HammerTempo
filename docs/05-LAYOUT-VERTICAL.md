# Layout vertical — estudo de viabilidade

**Status: possibilidade resguardada. Não agendada, não iniciada.**
Registrado a pedido, para não se perder. Só entra depois que todos os pontos do plano
original estiverem fechados, e como experimento **paralelo** — nunca substituindo o que já
funciona. Ver D-79.

---

## 1. Por que existe esta ideia

Um gabinete de arcade tem uma fileira **deitada** de quatro botões. O jogo apresenta quatro
faixas **empilhadas**. A mão faz um gesto horizontal e o olho lê uma coluna vertical: o
cérebro traduz a cada nota.

Foi essa tradução que apareceu no teste com as faixas mapeadas em 1-2-3-4 — o input
funcionava, o "feeling" não. Não é problema de precisão nem de mapeamento; é desencontro
espacial. Um campo vertical, com as faixas lado a lado e as notas caindo, casa diretamente
com a fileira de botões. É por isso que os jogos de ritmo de arcade se apresentam assim.

Vale registrar o que **não** é motivo: a alavanca continua descartada para as faixas
(`04-ARCADE.md`), e o layout vertical não muda isso. O percurso de 150-250 ms entre direções
opostas segue maior que a janela de ±133 ms, independente de como a tela desenha.

---

## 2. O princípio: modo paralelo, não substituição

O layout horizontal está calibrado e aprovado. Um experimento não pode custar isso.

A forma de garantir é **não escrever um segundo jogo**, e sim extrair a geometria que hoje
está espalhada como número solto para um lugar só. O layout vertical vira então uma segunda
tabela de valores — não uma segunda base de código.

Esse movimento tem valor mesmo que o vertical nunca seja adotado: hoje a mesma informação
está repetida em cinco arquivos, e mudar a altura de uma faixa exige lembrar de todos.

### A geometria espalhada hoje

| Onde | O quê |
|---|---|
| `scr_ritmo.gml:12` | `RITMO_LINHA_X 98` — a zona de acerto |
| `scr_ritmo.gml:33` | `(_nota.x - RITMO_LINHA_X) / velocidade` — o julgamento lê o eixo X |
| `scr_ritmo.gml:50` | a mesma conta, repetida |
| `o_spawner_ritmo/Alarm_0.gml:17-20` | as quatro faixas, como `_pos_y` literal |
| `o_fundo_ui/Draw_0.gml:11` | as quatro faixas de novo, em `_lanes` |
| `o_fundo_ui/Draw_0.gml:16-17` | os trilhos, de `RITMO_LINHA_X` a `820` |
| `scr_hud.gml:8-9` | `HUD_CORREDOR_TOPO/BASE` — o corredor proibido |
| `rm_forja.yy` | os quatro `o_buttons_forja`, em `x:98` e `y:515/565/615/665` |
| `o_controlador_geral/Step_0.gml:119` | `_spawn_x = room_width + 120` |
| `o_nota_seta/Step_0.gml` | `x -= velocidade`, em três lugares |

### O que a extração criaria

Um `scr_pista` respondendo por toda a geometria de jogo:

```
pista_ponto_nascimento(_faixa)   -> {x, y}
pista_ponto_acerto(_faixa)       -> {x, y}
pista_avancar(_nota)             -> move a nota no eixo da pista
pista_erro_frames(_nota)         -> distância até a zona de acerto / velocidade
pista_corredor()                 -> o retângulo onde o HUD não pode desenhar
```

`pista_erro_frames()` é o ponto central: **as janelas de julgamento não mudam**. Elas são
medidas em tempo (±33 / ±75 / ±133 ms), e o que a função faz é converter distância em
frames. Trocar o eixo de X para Y não toca em nada do julgamento — é a maior garantia de que
o experimento não estraga o que está calibrado.

---

## 3. Geometria concreta proposta

**Campo à esquerda, 240 px de largura, x 16 a 256.**

A largura não é arbitrária: `s_fundo_ui` mede 1280x240. Uma fatia de 720x240 girada 90°
produz exatamente uma tira de 240 de largura por 720 de altura, **sem distorcer a textura** —
`draw_sprite_part_ext` com `rot = 90`. O pergaminho que já existe vira o fundo da pista.

A escolha do lado esquerdo é por ocupação: a casa fica em x 350-800, o ferreiro trabalha em
661 e passeia entre 501 e 716, a bigorna está em 619. Tudo à direita de 256. O que o campo
cobre é céu e mar — a região vazia da cena.

| Elemento | Valor |
|---|---|
| Faixas (centros x) | 61, 111, 161, 211 — mesmo espaçamento de 50 px de hoje |
| Extensão das faixas | 38,5 a 233,5 (alvos de 45 px) |
| Zona de acerto (y) | 600 |
| Nascimento (y) | −60 |
| Percurso total | 660 px |
| Percurso visível | 600 px |

Os alvos (`s_alvo_*`, 45x42) e as notas (`s_notas_setas`) ficam **intactos**. As setas
continuam servindo, porque em jogo de ritmo o que se lê de fato é a **cor** — vermelho,
verde, azul, amarelo — e não a direção do desenho.

---

## 4. A conta que decide o feel

Este é o ponto que exige decisão, não implementação.

O campo horizontal tem **1182 px visíveis** (de x 1280 até a zona em 98). O vertical teria
**600 px** — pouco mais da metade. A razão é **0,508**.

| Fase | v hoje | Leitura hoje | v mantido → leitura | v ajustado → leitura |
|---|---|---|---|---|
| Adaga | 4 | 4,92 s | 4 → **2,50 s** | 2,03 → 4,92 s |
| Lança / Espada | 5 | 3,94 s | 5 → **2,00 s** | 2,54 → 3,94 s |
| Teto do ramp | 12 | 1,64 s | 12 → **0,83 s** | 6,09 → 1,64 s |

Duas saídas, e elas são excludentes:

**Preservar o tempo de leitura** multiplica todas as velocidades por 0,508. O jogo fica
exatamente tão difícil quanto hoje. Custo: o ramp de dificuldade (`+0,5` por trecho, teto
12) precisa virar `+0,25` com teto 6,1, e as notas passam a andar 2 px por frame — o
movimento fica visivelmente mais "passo a passo".

**Preservar as velocidades** corta o tempo de leitura pela metade. 2,5 s de antecedência é
um valor normal para jogo de ritmo — os 4,92 s de hoje são longos justamente porque o campo
é largo. Mas é uma mudança real de dificuldade, e numa feira o público é iniciante.

Recomendação para o experimento: **começar preservando o tempo de leitura**, porque isola a
variável. Se o layout vertical melhorar o feeling com a dificuldade idêntica, a melhora é do
layout. Ajustar as duas coisas ao mesmo tempo não permitiria concluir nada.

---

## 5. O que se reaproveita inteiro

Sem tocar em uma linha:

- **Julgamento**: `ritmo_julgar`, `ritmo_nota_alcancavel`, as três janelas, o enum
- **Notas**: `o_nota_seta` e seus quatro modos (viva, estourou, perdida, sumir)
- **Alvos**: `o_buttons_forja` — a lógica de acerto não sabe de eixo, só de posição
- **Sprites**: alvos, notas, pergaminho (girado), moldura, faíscas
- **HUD**: `hud_texto` (escala e posição inteiras), `hud_texto_painel`, `hud_cor_combo`, a
  fila de julgamentos, o fade de entrada, `hud_barra`
- **Helpers novos**: `hud_placa_suave` e `hud_vinheta_perigo` — os dois são construções
  geométricas parametrizadas, servem em qualquer orientação
- **Perigo**: `hud_perigo_estagio` e os quatro estágios
- **Cena**: ferreiro, bigorna, forja, fumaça, parallax — nada se move
- **Fora da partida**: menu, opções, controles, tutorial, seletor e resultado não conhecem o
  corredor. Zero impacto.

---

## 6. O que muda, sem maquiagem

- `scr_ritmo`: `RITMO_LINHA_X` vira ponto de acerto por faixa; as duas contas de erro passam
  a pedir a distância à pista
- `o_nota_seta`: os três `x -= velocidade` viram `pista_avancar()`
- `o_spawner_ritmo`: nascimento por faixa
- `o_fundo_ui`: pergaminho girado e trilhos no outro eixo — o degradê é o mesmo
  `pr_trianglestrip`, com os eixos trocados
- `rm_forja`: reposicionar os quatro alvos
- **HUD, o grosso do trabalho**: o bloco de pontos (230x128, hoje em x 5) precisa ir para a
  direita, porque a esquerda virou pista; a barra de progresso sai do rodapé; o título da
  fase deixa de ser centrado em 640, senão nasce por trás das notas; e a vinheta de perigo
  precisa poupar a coluna da pista em vez de poupar o corredor de baixo

### O ponto em aberto que exige sua decisão

A cascata de julgamento sobe hoje **a partir da bigorna** — foi uma escolha sua, testada e
aprovada ("o efeito ficou perfeito"). Com a pista na esquerda e a bigorna em 619, as duas
coisas ficam longe.

Três caminhos, e nenhum é obviamente certo:

1. **Cascata ao lado da pista** (x ≈ 290), subindo da zona de acerto. Fica onde o olho já
   está, que é o argumento forte. Perde o vínculo com o ferreiro.
2. **Cascata na bigorna**, como hoje. Preserva a leitura de "a forja reagiu", mas obriga o
   olho a atravessar a tela no meio da música.
3. **Separar os dois feedbacks**: o texto sobe ao lado da pista, e o ferreiro continua
   martelando e soltando faísca na bigorna. O julgamento fica onde se lê, a reação física
   fica onde faz sentido narrativo.

A terceira é a que eu defenderia, mas é chamada sua.

---

## 7. Risco honesto

Isto mexe em praticamente toda decisão visual tomada da D-20 em diante. O trabalho não está
no algoritmo — o julgamento sai de graça — e sim em **recalibrar o HUD inteiro num espaço
com metade da largura útil**, o que significa repetir as medições de contraste, de
enquadramento e de corredor que já foram feitas uma vez.

Por isso: só depois que o plano original fechar, e sempre com o horizontal intacto ao lado.
A extração para `scr_pista` é o que torna esse "ao lado" possível — sem ela, o experimento
seria um fork, e um fork não volta.
