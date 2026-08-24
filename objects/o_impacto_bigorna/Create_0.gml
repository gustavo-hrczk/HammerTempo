// =================================================================
// IMPACTO NA BIGORNA
// Toca uma vez, na cor da faixa acertada, e se destroi no fim da animacao.
//
// A folha de origem e lida DE BAIXO PARA CIMA. A inversao foi feita na importacao
// dos sprites, entao aqui a animacao roda na ordem natural: o primeiro quadro e a
// faisca inicial (21 px de tinta), o segundo e o clarao (331 px), e dai dissipa.
// =================================================================
// image_speed MULTIPLICA a velocidade do proprio sprite. O gabarito de importacao
// veio de s_alvo_cima, que tem playbackSpeed 0 porque o_buttons_forja avanca aqueles
// quadros na mao — e 0,6 x 0 = 0. A animacao ficava parada no primeiro quadro, que
// tem 21 px de tinta, e sumia sem ninguem ver.
//
// Os sprites de impacto agora declaram 30 quadros por segundo, como s_notas_setas:
// 7 quadros em 0,23 s.
image_speed = 1;
image_index = 0;

// Trava de seguranca: animacao parada nunca dispara o evento de fim, e um objeto
// que nao se destroi vira vazamento no meio da partida. Ja fomos mordidos por isso
// com a martelada do ferreiro (D-25).
vida = room_speed;
