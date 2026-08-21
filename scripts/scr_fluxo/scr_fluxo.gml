/// scr_fluxo — troca de telas com fade padronizado
/// Antes cada objeto chamava room_goto direto e o corte era seco; o o_transicao
/// existia e só era usado no splash (auditoria CV-06).

/// Duração do fade, em frames. 15 frames = 250 ms a 60 fps.
#macro FLUXO_FADE_FRAMES 15

/// Troca de sala com fade. Cai para room_goto se o gerenciador não existir.
/// `_com_fade` false troca de sala direto. Usado entre telas visualmente contínuas
/// (menu e opções compartilham logo e moldura): ali o fade não lê como transição,
/// lê como piscada.
function ir_para_sala(_sala, _espera = 0, _com_fade = true) {
    // Já estamos na sala pedida: piscar a tela à toa só atrapalha. Acontecia ao
    // voltar da tela de resultado para o seletor, que vivem na mesma room.
    if (room == _sala) return;

    if (_com_fade && instance_exists(o_transicao)) {
        o_transicao.mudar_de_sala(_sala, _espera);
    } else {
        room_goto(_sala);
    }
}

/// Há uma transição em andamento? Menus devem ignorar input enquanto for verdade,
/// para o jogador não disparar duas ações no mesmo fade.
function fluxo_ocupado() {
    if (!instance_exists(o_transicao)) return false;
    return (o_transicao.estado == FADE.OUT || o_transicao.estado == FADE.ESPERA);
}
