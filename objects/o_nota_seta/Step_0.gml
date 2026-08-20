if (o_controlador_geral.pausa) {
    exit;
}

// Se a nota NÃO está morrendo, ela se comporta normalmente.
if (esta_morrendo == false) {
    x -= velocidade;
    image_index = tipo_seta;

    // A nota é dada como perdida assim que passa da janela de acerto — o mesmo
    // limite usado pelo julgamento, então não existe mais a faixa em que a tecla
    // certa não valia nada (auditoria GP-02).
    if (ritmo_nota_perdida(id)) {
        registrar_erro();
    }
}
// Se a nota ESTÁ morrendo...
else {
    // Continua se movendo para a esquerda: a 'velocidade' só foi zerada em caso de acerto.
    x -= velocidade;

    if (sobe_ao_morrer) {
        y -= 2;
    }

    image_alpha -= 0.03;

    if (image_alpha <= 0) {
        instance_destroy();
    }
}
