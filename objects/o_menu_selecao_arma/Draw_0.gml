// Este menu só deve aparecer se o jogo estiver no estado "NENHUM" (seleção)
if (o_controlador_geral.estado_jogo != MINIGAME.NENHUM) {
    exit; // Se estiver em um minigame, não desenha nada.
}

// Desenha o fundo da UI (se necessário)
draw_sprite(s_fundo_ui, 0, x, y);

// Desenha as opções de armas (exemplo simples)
draw_text(100, 600, "1. Adaga");
draw_text(300, 600, "2. Espada (Bloqueado)");
// ...etc