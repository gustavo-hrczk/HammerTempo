// De quem e esta nota. No Versus os dois recebem o mesmo padrao, mas cada nota
// pertence a uma pista so — e o erro dela penaliza um jogador so.
dono = 0;

velocidade = 5;
tipo_seta = 0;

// Instante, em segundos da faixa, em que esta nota deve encostar na zona de acerto.
// -1 significa "sem relogio": a nota volta a andar quadro a quadro, que e o que
// acontece se a faixa nao estiver tocando.
t_alvo = -1;
image_speed = 0;
escala = 1;

// 0 = viva, 1 = estourou no acerto, 2 = perdida (erro), 3 = saindo de cena
modo = 0;

/// Acerto: a nota estoura como uma bolha — cresce rápido enquanto some, no lugar
/// onde foi acertada. Substitui a absorção, que ficou apagada demais.
estourar = function(_cor = c_white) {
    if (modo != 0) exit;
    modo = 1;
    velocidade = 0;
    image_blend = _cor;
}

/// Sai de cena sem contabilizar nada. Usada no game over: as notas que ainda
/// estavam na tela não são culpa do jogador, então não viram erro.
sumir = function() {
    if (modo != 0) exit;
    modo = 3;
}

/// Nota perdida: contabiliza o erro uma única vez e sai de cena em vermelho.
registrar_erro = function() {
    if (modo != 0) exit;
    modo = 2;
    image_blend = c_red;

    jogador().stats_erros++;
    jogador().pontuacao = max(0, jogador().pontuacao - 50);
    jogador().stats_sequencia_errada++;
    jogador().stats_sequencia = 0;

    var _f = ferreiro_de(dono);
    if (_f != noone) {
        with (_f) aplicar_dano();
    }

    hud_registrar_julgamento("ERRO", COR_ERRO, false);
}
