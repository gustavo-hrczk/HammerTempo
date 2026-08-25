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

// "NOVO RECORDE" significa PRIMEIRO LUGAR no placar, e nada mais.
//
// Antes vinha de um sistema separado de recorde pessoal, que comparava com a melhor
// marca do proprio jogador. Os dois discordavam num caso que a feira produz depressa:
// placar cheio de pontuacoes altas, jogador supera a si mesmo mas nao entra no top 10
// — aparecia "NOVO RECORDE!", nao pedia iniciais e o placar nao mudava.
//
// Preenchido pela tela de iniciais, que e quem sabe a colocacao obtida.
recorde_novo = false;

// =================================================================
// BONIFICACAO
// Calculada ANTES de qualquer coisa olhar a pontuacao, senao o placar julgaria um
// numero que a tela ainda vai aumentar na frente do jogador.
//
// Duas faixas, e elas medem coisas diferentes:
//   sem erro   — nenhuma nota perdida. E consistencia, e o que a maioria alcanca.
//   impecavel  — TODAS perfeitas. E precisao, e quase ninguem alcanca.
//
// Proporcionais, nao fixas: uma fase de 137 notas vale mais que uma de 60, e um
// bonus fixo premiaria desproporcionalmente a fase curta.
// =================================================================
pontuacao_base = o_controlador_geral.pontuacao;

// A regra de bonus mora no controlador porque as fases do meio de um percurso Arcade
// nao chegam a esta tela — se ela vivesse so aqui, so a ultima seria bonificada.
var _bonus = o_controlador_geral.fase_bonus(pontuacao_base);
bonus_sem_erro = _bonus.sem_erro;
bonus_impecavel = _bonus.impecavel;

// No Arcade o numero que sobe e o TOTAL DO PERCURSO. arcade_pontos guarda o que veio
// antes desta fase; as duas linhas de bonus continuam sendo as DESTA fase, que e o
// que o jogador acabou de conquistar.
arcade_acumulado = (o_controlador_geral.modo_jogo == MODO.ARCADE)
    ? o_controlador_geral.arcade_pontos
    : 0;

pontuacao_final = arcade_acumulado + pontuacao_base + bonus_sem_erro + bonus_impecavel;
o_controlador_geral.pontuacao = pontuacao_final;

// =================================================================
// REVELACAO
// A tela conta a pontuacao em vez de exibi-la pronta, e revela uma coisa por vez.
// O momento de maior peso — o total com os bonus somados — fica por ultimo.
//
// A entrada de iniciais NAO nasce aqui. Ela vinha no Create e cobria a tela inteira
// antes de o jogador ver o proprio resultado. Agora espera a revelacao terminar e o
// jogador confirmar (ver o Step).
// =================================================================
#macro RESULTADO_T_ESTATISTICAS 0.35
#macro RESULTADO_T_CONTAGEM     0.90
#macro RESULTADO_DUR_CONTAGEM   2.20
#macro RESULTADO_T_BONUS_1      3.35
#macro RESULTADO_T_BONUS_2      3.85
#macro RESULTADO_T_PROMPT       4.35

tempo = 0;
revelacao_pronta = false;
pediu_iniciais = false;
pontuacao_exibida = 0;

/// Corta a animacao e mostra tudo. Numa feira com fila, esperar animacao e imposto.
concluir_revelacao = function() {
    tempo = RESULTADO_T_PROMPT;
    pontuacao_exibida = pontuacao_final;
    revelacao_pronta = true;
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
// Fase sem arte de arma ainda mostra a moldura, com um "?" dentro (ver o Draw).
// -1 e o sinal de "sem arma", e nao um sprite invalido passado adiante.
tem_arte = (array_length(_dados_fase.sprites_resultado) > 0);

sprite_da_arma_final = tem_arte ? _dados_fase.sprites_resultado[_resultado_index] : -1;
sprite_da_moldura_final = sprites_das_molduras[tem_arte ? _resultado_index : 0];

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