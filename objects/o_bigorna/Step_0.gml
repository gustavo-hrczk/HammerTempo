if (gameplay_congelado()) {
    exit;
}

// Queda de 0,55 px por frame: um tremor de 3 px dura 6 frames, um decimo de segundo.
// Curto de proposito — a bigorna reage ao golpe, nao vibra.
tremor = max(0, tremor - 0.55);
