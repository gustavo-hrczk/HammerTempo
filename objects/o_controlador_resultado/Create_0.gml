// A música da fase sai em fade pelo gerenciador de áudio, que devolve o ganho do
// asset ao normal no final. Mexer no ganho direto deixava a fase muda ao ser
// rejogada (auditoria CV-02). randomize() agora acontece uma única vez, no boot.
o_audio_manager.fade_out_music(1);

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
    "Cada golpe afina o aço... e o seu talento."
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

// Recorde da fase: registrado aqui e anunciado na tela quando é superado.
//
// Fase PERDIDA não grava recorde. A pontuação até o game over continua à vista na
// tela de resultado — ela é o placar da tentativa —, mas deixá-la virar recorde
// premiava abandonar o trabalho: bastava somar pontos numa fase difícil e falhar de
// propósito antes do trecho que não se acerta. Recorde é de fase concluída.
recorde_novo = false;

if (!o_controlador_geral.fase_falhou) {
    recorde_novo = save_registrar_recorde(o_controlador_geral.fase_atual,
                                          o_controlador_geral.pontuacao);
}

// Molduras por nivel de desempenho, vindas do controlador geral: o seletor de fases
// usa a mesma lista, e duas copias da mesma ordem ja renderam moldura trocada.
sprites_das_molduras = o_controlador_geral.molduras_resultado;

sprite_da_moldura_final = sprites_das_molduras[0]; // Padrao e a primeira


// --- LÓGICA DE CÁLCULO DE PERFORMANCE ---
var _fase_jogada = o_controlador_geral.fase_atual;
var _total_notas = o_controlador_geral.stats_total_notas;
var _acertos_perfeitos = o_controlador_geral.stats_acertos_perfeitos;
var _acertos_otimos = o_controlador_geral.stats_acertos_otimos;
var _acertos_bons = o_controlador_geral.stats_acertos_bons;
var _total_acertos = _acertos_perfeitos + _acertos_otimos + _acertos_bons;

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

// Game over é game over. Quem perde a fase por excesso de notas perdidas recebe o
// resultado de falha, mesmo que a precisão até ali estivesse alta — antes o jogador
// avançado levava jingle de vitória, comemoração e a melhor arma ao ser derrotado.
if (o_controlador_geral.fase_falhou) {
    _resultado_index = 0;
}

// Pega os dados da fase que acabamos de jogar
var _dados_fase = o_controlador_geral.fases_data[_fase_jogada];

// --- ESCOLHE A FRASE E A ARMA FINAL ---
sprite_da_arma_final = _dados_fase.sprites_resultado[_resultado_index];
sprite_da_moldura_final = sprites_das_molduras[_resultado_index];

// A lógica para escolher a frase pode ser baseada no mesmo índice
if (_resultado_index <= 1) { // Falha ou Aceitável
    frase_escolhida = frases_ruins[irandom(array_length(frases_ruins) - 1)];
	o_audio_manager.play_sfx(snd_resultado_ruim);
} else if (_resultado_index <= 3) { // Bom ou Excelente
    frase_escolhida = frases_boas[irandom(array_length(frases_boas) - 1)];
	o_audio_manager.play_sfx(snd_resultado_bom);
} else { // Perfeito
    frase_escolhida = frases_otimas[irandom(array_length(frases_otimas) - 1)];
	o_audio_manager.play_sfx(snd_resultado_bom);
}

// =================================================================
// --- COMANDA A ANIMAÇÃO DO FERREIRO (NOVA SEÇÃO) ---
// =================================================================
if (instance_exists(o_ferreiro)) {
    
    // Se a performance foi "Falha" ou "Aceitável"...
    if (_resultado_index <= 1) {
        // ...manda o ferreiro tocar a animação de falha. No game over ela já
        // começou durante o respiro, então não pode ser reiniciada aqui.
        if (o_ferreiro.estado != FERREIRO_ESTADO.FALHA
            && o_ferreiro.estado != FERREIRO_ESTADO.FALHOU_ESTATICO) {
            o_ferreiro.iniciar_animacao_falha();
        }
    }
    // Se a performance foi "Bom" ou melhor...
    else {
        // ...manda o ferreiro comemorar.
        o_ferreiro.iniciar_comemoracao();
    }
}