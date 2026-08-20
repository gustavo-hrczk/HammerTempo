/// scr_fluxo — troca de telas com fade padronizado
/// Antes cada objeto chamava room_goto direto e o corte era seco; o o_transicao
/// existia e só era usado no splash (auditoria CV-06).

/// Duração do fade, em frames. 15 frames = 250 ms a 60 fps.
#macro FLUXO_FADE_FRAMES 15

/// Troca de sala com fade. Cai para room_goto se o gerenciador não existir.
function ir_para_sala(_sala) {
    if (instance_exists(o_transicao)) {
        o_transicao.mudar_de_sala(_sala);
    } else {
        room_goto(_sala);
    }
}

/// Há uma transição em andamento? Menus devem ignorar input enquanto for verdade,
/// para o jogador não disparar duas ações no mesmo fade.
function fluxo_ocupado() {
    return (instance_exists(o_transicao) && o_transicao.estado == FADE.OUT);
}
