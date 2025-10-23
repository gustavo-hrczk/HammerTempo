if (o_controlador_geral.pausa){
	exit;
}
// Se a nota NÃO está morrendo, ela se comporta normalmente.
if (esta_morrendo == false) {
    x -= velocidade;
    image_index = tipo_seta;
}
// Se a nota ESTÁ morrendo...
else {
    // >>> A GRANDE MUDANÇA <<<
    // A nota continua se movendo para a esquerda, pois a 'velocidade'
    // só foi zerada se foi um acerto.
    x -= velocidade;

    // A nota só se move para cima se for um acerto.
    if (sobe_ao_morrer) {
        y -= 2;
    }

    // O fade-out acontece em ambos os casos.
    image_alpha -= 0.03;

    // Se a nota ficou completamente invisível, ela se autodestrói.
    if (image_alpha <= 0) {
        instance_destroy();
    }
}