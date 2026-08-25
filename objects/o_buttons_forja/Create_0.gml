// Ver o_ferreiro: so o que o Versus criou e destruido no desmonte.
criado_pelo_versus = false;

// De quem e este alvo. Decide qual jogador ele julga e qual entrada ele escuta.
dono = 0;

// O tipo de seta que esta instância julga vem do Instance Creation Code de cada alvo,
// em rm_forja. A AÇÃO deixou de ser gravada aqui: ela é derivada do dono e do tipo
// (ver input_lane), porque os alvos do jogador 2 são criados em código e não têm
// creation code para preencher.
meu_tipo = -1;

// Inicia a animação parada no primeiro frame.
image_speed = 0;
image_index = 0;

// Feedback de toque: o alvo afunda ao ser pressionado e acende ao acertar.
// A cor e a força do brilho distinguem perfeito de bom — redundância com o texto.
pop = 0;
brilho = 0;

// ECO: anel que se expande a partir do alvo no acerto.
//
// A "bolha" sobre a tecla precisava separar os tres acertos de forma NITIDA, e o pop
// sozinho nao dava conta: a 0,11 de amplitude, Bom e Perfeito ficavam a 1,06 e 1,11
// de escala — 5% de diferenca, que ninguem enxerga no meio da partida.
//
// O eco e o eixo novo, e ele e categorico em vez de gradual: Perfeito tem eco cheio,
// Otimo tem eco curto, Bom nao tem nenhum. Presenca ou ausencia le mais rapido que
// intensidade.
eco = 0;
eco_cor = c_white;
brilho_cor = c_white;
afundamento = 0;
