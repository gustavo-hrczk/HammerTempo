// Prepara o alinhamento e a cor do texto que vamos desenhar
draw_set_font(f_padrao);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// --- DESENHA INFORMAÇÕES DE DEBUG ---
var _texto_estado = "Estado Atual: " + string(estado_jogo);
draw_text(10, 10, _texto_estado);

// --- DESENHA A PONTUAÇÃO ---
draw_set_halign(fa_right); // Alinha à direita
draw_text(room_width - 20, 20, "Pontos: " + string(pontuacao));
draw_set_halign(fa_left); // Volta ao padrão

// --- DESENHA O PROMPT PARA INICIAR ---
if (estado_jogo == MINIGAME.NENHUM) {
    draw_set_halign(fa_center);
    draw_text(room_width / 2, room_height - 100, "Pressione ENTER para começar a forjar!");
    draw_set_halign(fa_left); // Volta ao padrão
}