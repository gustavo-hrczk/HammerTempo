// =================================================================
// IMPACTO NA BIGORNA
// Toca uma vez, na cor da faixa acertada, e se destroi no fim da animacao.
//
// A folha de origem e lida DE BAIXO PARA CIMA. A inversao foi feita na importacao
// dos sprites, entao aqui a animacao roda na ordem natural: o primeiro quadro e a
// faisca inicial (21 px de tinta), o segundo e o clarao (331 px), e dai dissipa.
// =================================================================
image_speed = 0.6;   // 7 quadros / 0,6 = 11,7 frames = 0,19 s
image_index = 0;

// Trava de seguranca: animacao parada nunca dispara o evento de fim, e um objeto
// que nao se destroi vira vazamento no meio da partida. Ja fomos mordidos por isso
// com a martelada do ferreiro (D-25).
vida = room_speed;
