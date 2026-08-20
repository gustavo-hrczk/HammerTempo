if (instance_exists(o_controlador_geral) && o_controlador_geral.pausa) {
    exit;
}

vida++;

x += vel_x;
y += vel_y;

// desacelera aos poucos, como um impacto perdendo força
vel_y *= 0.94;
vel_x *= 0.94;

escala += (escala_alvo - escala) * 0.25;

// os primeiros frames ficam opacos; depois some
if (vida > 18) {
    alpha -= 0.07;
    if (alpha <= 0) {
        instance_destroy();
    }
}
