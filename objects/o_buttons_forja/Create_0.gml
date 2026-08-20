// A ação que esta instância escuta e o tipo de seta que ela julga são definidos
// pelo Instance Creation Code de cada alvo, em rm_forja.
minha_acao = ACAO.LANE_CIMA;
meu_tipo = -1;

// Inicia a animação parada no primeiro frame.
image_speed = 0;
image_index = 0;

// Feedback de toque: o alvo afunda ao ser pressionado e acende ao acertar.
// A cor e a força do brilho distinguem perfeito de bom — redundância com o texto.
pop = 0;
brilho = 0;
brilho_cor = c_white;
afundamento = 0;
