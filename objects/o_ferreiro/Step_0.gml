if (o_controlador_geral.pausa){
	exit;
}
// A única responsabilidade do Step é garantir que, se o ferreiro
// estiver no estado IDLE, ele toque a animação de IDLE.
if (estado == FERRreiro_ESTADO.IDLE) {
    sprite_index = s_ferreiro_idle;
    image_speed = 0.5; // Velocidade da animação de "respiro"
}