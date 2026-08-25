// De quem e este impacto. Decide em qual bigorna ele treme.
dono = 0;

// =================================================================
// IMPACTO NA BIGORNA
// Toca uma vez, na cor da faixa acertada, e se destroi no fim da animacao.
//
// Nasce ESPERANDO: o efeito e o tremor sao o momento em que o martelo encosta, e o
// martelo leva um quadro de animacao para chegar la. Sem essa espera o clarao
// aparecia com a tecla e ja tinha sumido quando o ferreiro golpeava.
//
// A folha de origem e lida DE BAIXO PARA CIMA. A inversao foi feita na importacao
// dos sprites, entao aqui a animacao roda na ordem natural.
// =================================================================
image_speed = 0;      // parado ate o contato
image_index = 0;
visible = false;

atraso = 0;           // frames ate o martelo encostar; quem cria define
forca = 0;            // amplitude do tremor da bigorna, idem

// Trava de seguranca: animacao parada nunca dispara o evento de fim, e um objeto que
// nao se destroi vira vazamento no meio da partida (D-89).
vida = room_speed;
