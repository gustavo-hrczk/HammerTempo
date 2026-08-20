if (o_controlador_geral.pausa) {
    exit;
}

switch (modo) {

    case 0: // viva
        x -= velocidade;
        image_index = tipo_seta;

        // A nota é dada como perdida assim que passa da janela de acerto — o mesmo
        // limite usado pelo julgamento, então não existe faixa cega (auditoria GP-02).
        if (ritmo_nota_perdida(id)) {
            registrar_erro();
        }
        break;

    case 1: // absorvida pelo alvo
        x += (RITMO_LINHA_X - x) * 0.4;
        escala += (0.15 - escala) * 0.45;
        image_alpha -= 0.16;

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
}
