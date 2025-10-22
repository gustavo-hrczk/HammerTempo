velocidade = 5;
tipo_seta = 0;
image_speed = 0;
esta_morrendo = false;
sobe_ao_morrer = false;

// Função para iniciar o fade final
iniciar_fade_final = function(cor, _deve_subir) {
    if (esta_morrendo == false) {
        esta_morrendo = true;
        image_blend = cor;
        sobe_ao_morrer = _deve_subir;
        if (_deve_subir) {
            velocidade = 0;
        }
    }
}