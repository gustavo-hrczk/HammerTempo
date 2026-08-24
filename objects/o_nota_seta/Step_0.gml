if (o_controlador_geral.pausa) {
    exit;
}

switch (modo) {

    case 0: // viva
        // POSICAO DERIVADA DO RELOGIO DA FAIXA, nao integrada quadro a quadro.
        // Integrar acumula erro de truncamento e de frame perdido; derivar nao
        // acumula nada, porque cada quadro recalcula do zero contra o audio.
        var _agora = ritmo_relogio();

        if (t_alvo >= 0 && _agora >= 0) {
            x = ritmo_x_da_nota(t_alvo, _agora, velocidade);
        } else {
            x -= velocidade;   // sem faixa tocando, segue no modo antigo
        }

        image_index = tipo_seta;

        // A nota é dada como perdida assim que passa da janela de acerto — o mesmo
        // limite usado pelo julgamento, então não existe faixa cega (auditoria GP-02).
        if (ritmo_nota_perdida(id)) {
            registrar_erro();
        }
        break;

    case 1: // estourou no acerto
        escala += (1.45 - escala) * 0.3;
        image_alpha -= 0.14;

        if (image_alpha <= 0) {
            instance_destroy();
        }
        break;

    case 2: // perdida
        x -= velocidade;
        image_alpha -= 0.05;

        if (image_alpha <= 0) {
            instance_destroy();
        }
        break;

    case 3: // saindo de cena no game over
        x -= velocidade;
        image_alpha -= 0.07;

        if (image_alpha <= 0) {
            instance_destroy();
        }
        break;
}
