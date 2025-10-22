
esta_morrendo = false;

// NOVA VARIÁVEL: A nota deve subir quando desaparecer?
sobe_ao_morrer = false;

// Função para iniciar o fade final (agora com parada condicional)
iniciar_fade_final = function(cor, _deve_subir) {
    if (esta_morrendo == false) {
        esta_morrendo = true;
        image_blend = cor;
        sobe_ao_morrer = _deve_subir;

        // >>> A GRANDE MUDANÇA <<<
        // A nota só para de se mover para a esquerda se for um acerto (_deve_subir é true).
        // Se for um erro (_deve_subir é false), a velocidade continua a mesma!
    }
}