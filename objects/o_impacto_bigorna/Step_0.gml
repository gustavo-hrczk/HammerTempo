if (gameplay_congelado()) {
    exit;
}

// --- ESPERA ATE O MARTELO ENCOSTAR ---
if (atraso > 0) {
    atraso--;

    if (atraso <= 0) {
        visible = true;
        image_index = 0;
        image_speed = 1;   // sprite declara 30 fps: 7 quadros em 0,23 s

        // o tremor sai junto com o clarao, porque os dois SAO o contato
        var _b = bigorna_de(dono);
        if (_b != noone) {
            _b.tremor = forca;
        }
    }
}

// Rede da trava descrita no Create: se a animacao nao andar, o efeito some sozinho.
vida--;
if (vida <= 0) {
    instance_destroy();
}
