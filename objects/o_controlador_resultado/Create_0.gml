// Impede que a mesma frase aleatória seja escolhida toda vez que o jogo inicia
randomize();
audio_sound_gain((o_controlador_geral.fases_data[o_controlador_geral.fase_atual].musica_fase),0,500);
if(audio_sound_get_gain(o_controlador_geral.fases_data[o_controlador_geral.fase_atual].musica_fase) == 0){
	audio_stop_all();
}
// Arrays para guardar as frases de feedback
frases_ruins = [
    "Todo mestre já falhou na primeira batida.",
    "Refaça. Reforce. Reforje.",
    "Um erro é só metal esperando ser moldado.",
    "As melhores espadas nascem de muitas tentativas.",
    "A bigorna chama novamente.",
    "Seu ritmo ainda pode ser afiado.",
    "Reaqueça a forja e tente outra vez!",
    "Cada batida errada é um passo para o acerto.",
    "Não desista, o fogo ainda está aceso!"
];

frases_boas = [
    "O aço começa a tomar forma!",
    "Está no caminho certo! mais uma batida e será perfeito.",
    "A lâmina já brilha, mas pode reluzir ainda mais.",
    "Forja firme! A perfeição está próxima.",
    "O metal responde bem às suas mãos.",
    "O ritmo está surgindo, continue aquecendo o martelo!",
    "Boa batida! o mestre ferreiro ficaria orgulhoso.",
    "Sente o ritmo? Ele está quase em sincronia com o fogo.",
    "Cada golpe afina o aço… e o seu talento."
];

frases_otimas = [
    "Perfeito! O aço canta sob o seu comando!",
    "Forja lendária! O fogo o reconhece como mestre.",
    "Golpe preciso! a bigorna vibrou em harmonia!",
    "Você forjou com a alma de um verdadeiro mestre.",
    "Ritmo impecável! O ferro se curvou à sua vontade.",
    "A lâmina nasceu perfeita! uma obra digna de canções.",
    "Seu ritmo é puro aço!",
    "Nada menos que lendário.",
    "Cada faísca brilha como sua precisão.",
    "A bigorna te saúda, mestre ferreiro."
];

// Variável para guardar a frase escolhida para esta rodada
frase_escolhida = "";

// --- NOVO ARRAY PARA AS MOLDURAS ---
// A ordem DEVE corresponder aos níveis de performance:
// Índice 0 = Falha, 1 = Aceitável, 2 = Bom, 3 = Excelente, 4 = Perfeito
sprites_das_molduras = [
    s_canva01, // Moldura para Falha
    s_canva02, // Moldura para Aceitável
    s_canva03, // Moldura para Bom
    s_canva04, // Moldura para Excelente
    s_canva05  // Moldura para Perfeito
];

// Variável para guardar a moldura escolhida
sprite_da_moldura_final = sprites_das_molduras[0]; // Padrão é a primeira


// --- LÓGICA DE CÁLCULO DE PERFORMANCE ---
var _fase_jogada = o_controlador_geral.fase_atual;
var _total_notas = o_controlador_geral.stats_total_notas;
var _acertos_perfeitos = o_controlador_geral.stats_acertos_perfeitos;
var _acertos_bons = o_controlador_geral.stats_acertos_bons;
var _total_acertos = _acertos_perfeitos + _acertos_bons;

// Calcula a porcentagem de acertos
var _porcentagem_acerto_total = 0;
if (_total_notas > 0) {
    _porcentagem_acerto_total = (_total_acertos / _total_notas) * 100;
}

// Variável para guardar o índice do resultado (0=Falha, 1=Aceitável, etc.)
var _resultado_index = 0;

// Define o resultado com base na performance
if (_porcentagem_acerto_total < 40) { _resultado_index = 0; } // Falha
else if (_porcentagem_acerto_total < 70) { _resultado_index = 1; } // Aceitável
else if (_porcentagem_acerto_total < 95) { _resultado_index = 2; } // Bom
else if (_porcentagem_acerto_total < 100) { _resultado_index = 3; } // Excelente
else { _resultado_index = 4; } // Perfeito (100% de acertos)

// Pega os dados da fase que acabamos de jogar
var _dados_fase = o_controlador_geral.fases_data[_fase_jogada];

// --- ESCOLHE A FRASE E A ARMA FINAL ---
sprite_da_arma_final = _dados_fase.sprites_resultado[_resultado_index];
sprite_da_moldura_final = sprites_das_molduras[_resultado_index];

// A lógica para escolher a frase pode ser baseada no mesmo índice
if (_resultado_index <= 1) { // Falha ou Aceitável
    frase_escolhida = frases_ruins[irandom(array_length(frases_ruins) - 1)];
	if(!audio_is_playing(snd_resultado_ruim)){
		audio_play_sound(snd_resultado_ruim, 10, false);
		audio_sound_gain(snd_resultado_ruim,o_controlador_opcoes.opcoes_volume,0);
	} else {
		audio_resume_sound(snd_resultado_ruim);
		audio_sound_gain(snd_resultado_ruim,o_controlador_opcoes.opcoes_volume,0);
	}
} else if (_resultado_index <= 3) { // Bom ou Excelente
    frase_escolhida = frases_boas[irandom(array_length(frases_boas) - 1)];
	if(!audio_is_playing(snd_resultado_bom)){
		audio_play_sound(snd_resultado_bom, 10, false);
		audio_sound_gain(snd_resultado_bom,o_controlador_opcoes.opcoes_volume,0);
	} else {
		audio_resume_sound(snd_resultado_bom);
		audio_sound_gain(snd_resultado_bom,1,0);
	}
} else { // Perfeito
    frase_escolhida = frases_otimas[irandom(array_length(frases_otimas) - 1)];
	if(!audio_is_playing(snd_resultado_bom)){
		audio_play_sound(snd_resultado_bom, 10, false);
		audio_sound_gain(snd_resultado_bom,o_controlador_opcoes.opcoes_volume,0);
	} else {
		audio_resume_sound(snd_resultado_bom);
		audio_sound_gain(snd_resultado_bom,o_controlador_opcoes.opcoes_volume,0);
	}
}

// =================================================================
// --- COMANDA A ANIMAÇÃO DO FERREIRO (NOVA SEÇÃO) ---
// =================================================================
if (instance_exists(o_ferreiro)) {
    
    // Se a performance foi "Falha" ou "Aceitável"...
    if (_resultado_index <= 1) {
        // ...manda o ferreiro tocar a animação de falha.
        o_ferreiro.iniciar_animacao_falha();
    }
    // Se a performance foi "Bom" ou melhor...
    else {
        // ...manda o ferreiro comemorar.
        o_ferreiro.iniciar_comemoracao();
    }
}