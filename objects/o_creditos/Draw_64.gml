// =================================================================
// CRÉDITOS
//
// O texto rolava em cinza escuro direto sobre o céu, e o céu do jogo faz ciclo de cor.
// Medido contra os quatro cenários: 5,95:1 no dia claro, 9,09:1 sobre nuvem branca —
// e 4,45:1 no entardecer e 1,46:1 na noite, onde ele praticamente desaparecia.
//
// Não existe uma cor de texto que resolva isso: o fundo muda, então o contraste tem
// de vir de algo que muda junto. A placa é o que garante a cor de trás. A 0,68 o pior
// caso dos quatro céus vai a 5,84:1, e ela ainda deixa o cenário aparecer por baixo —
// escurecer até o preto resolveria o contraste apagando a arte que os créditos
// justamente creditam.
// =================================================================
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Coluna do texto, com folga dos dois lados. O degradê largo faz a placa ler como
// penumbra e não como uma caixa retangular no meio da tela.
//
// SEM QUEDA NA VERTICAL: em cima e embaixo quem corta é a borda da tela, e ali não há
// nada do outro lado para a transição suavizar. Reservar 90 px de degradê para as duas
// pontas só tirava contraste das primeiras e das últimas linhas do texto.
// O MIOLO DE ALPHA CHEIO COMECA FORA DO TEXTO: margem primeiro, queda depois. Somar a
// queda dentro da margem era o que deixava as pontas de cada linha em meia-luz.
hud_placa_suave(CREDITOS_X - CREDITOS_MARGEM - CREDITOS_QUEDA, -4,
                CREDITOS_X + CREDITOS_LARGURA + CREDITOS_MARGEM + CREDITOS_QUEDA, _gh + 4,
                c_black, 0.68, CREDITOS_QUEDA, 0);

draw_set_font(f_padrao);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// POSIÇÃO INTEIRA. A rolagem anda 1,5 px por quadro, então metade dos quadros caía em
// meio pixel — e meio pixel numa fonte de pixel borra o traço inteiro (D-33).
var _ty = floor(y_pos);

// Contorno, pelo mesmo motivo do HUD: a placa garante o contraste médio, a borda
// garante o de cada letra. Juntas, nenhum quadro do ciclo do céu fica ilegível.
draw_set_color(c_black);
draw_text_ext(CREDITOS_X - 1, _ty,     credit_text, line_height, CREDITOS_LARGURA);
draw_text_ext(CREDITOS_X + 1, _ty,     credit_text, line_height, CREDITOS_LARGURA);
draw_text_ext(CREDITOS_X,     _ty - 1, credit_text, line_height, CREDITOS_LARGURA);
draw_text_ext(CREDITOS_X,     _ty + 1, credit_text, line_height, CREDITOS_LARGURA);

draw_set_color(make_colour_rgb(229, 214, 161));   // pergaminho, a tinta clara do jogo
draw_text_ext(CREDITOS_X, _ty, credit_text, line_height, CREDITOS_LARGURA);

// --- COMO SAIR ---
// No gabinete não há teclado, então a saída precisa dizer o botão que existe ali. Fica
// fixa no rodapé, e não rolando com o texto: quem quer pular procura a instrução no
// mesmo lugar o tempo todo.
ui_prompt(_gw / 2, _gh - 34, ui_texto_confirmar() + " para voltar", 55);

ui_reset();
