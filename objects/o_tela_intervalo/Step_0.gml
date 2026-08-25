if (fluxo_ocupado()) {
    exit;
}

// --- NAVEGAÇÃO ---
var _move = input_eixo_v();

if (_move != 0) {
    var _total = array_length(opcoes_menu);
    opcao_selecionada = (opcao_selecionada + _move + _total) mod _total;

    var _som = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
}

// ESC encerra o percurso, e não sai do jogo: aqui a saída natural é fechar a conta.
if (keyboard_check_pressed(vk_escape) || input_pressed(ACAO.VOLTAR)) {
    opcao_selecionada = 1;
}
else if (!input_pressed(ACAO.CONFIRMAR)) {
    exit;
}

if (opcao_selecionada == 0) {
    // --- SEGUE O PERCURSO ---
    // arcade_avancar soma esta fase, empilha a arma na fileira e já deixa a contagem
    // da próxima rodando — é ele que faz a faixa com o nome da arma aparecer.
    o_audio_manager.play_sfx(snd_menu_confirm);
    o_controlador_geral.arcade_avancar();
    instance_destroy();
    exit;
}

// --- ENCERRA COM O QUE TEM ---
// Não é desistência: a fase corrente ainda não foi somada em arcade_pontos, então ela
// segue para a tela de resultado exatamente como seguiria a última do percurso. É lá
// que o bônus dela é calculado e o total fecha.
o_audio_manager.play_sfx(snd_menu_return);

o_controlador_geral.estado_jogo = MINIGAME.RESULTADO;
instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);

instance_destroy();
