// =================================================================
// GUARDA DE INSTÂNCIA ÚNICA
// Objetos persistentes colocados em rooms não persistentes eram recriados a cada
// reentrada, acumulando cópias que disputavam o mesmo estado (auditoria CV-01).
// =================================================================
if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

// =================================================================
// BOOT DO JOGO
// Este objeto nasce em rm_splash e é o primeiro a rodar: é aqui que a camada
// GUI, o input, o save e a aleatoriedade são preparados, uma única vez.
// =================================================================
randomize();

// A GUI passa a ter exatamente o tamanho das rooms de jogo, então coordenada de
// GUI e coordenada de room voltam a ser a mesma coisa (auditoria UI-01).
display_set_gui_size(1280, 720);

input_init();
debug_init();
hud_init();
save_carregar();
save_aplicar_opcoes();

// Os vínculos remapeados só podem ser aplicados depois do save existir — input_init()
// roda antes dele e deixa apenas os de fábrica no lugar.
input_aplicar_save();

// Array com os dois sons que irão se alternar na navegação de menu
nav_sounds[0] = snd_menu01;
nav_sounds[1] = snd_menu02;
nav_sound_index = 0;

// --- ESTATÍSTICAS DA FASE ---
tutorial_ja_foi_visto = false;
pausa = false;
pontuacao = 0;
stats_total_notas = 0;
stats_acertos_perfeitos = 0;
stats_acertos_otimos = 0;
stats_acertos_bons = 0;
stats_sequencia = 0;
stats_erros = 0;
stats_sequencia_errada = 0;
stats_toques_invalidos = 0;

// --- PAUSA DA PARTIDA ---
// A variável `pausa` existia desde a jam e era checada em seis lugares, mas nunca
// era ativada (auditoria CV-07). Agora ela tem um menu.
pausa_opcao = 0;
// "Sair para o menu" media 218 px numa caixa de 243, e o cursor de espada precisa de
// 34,5 px de cada lado do texto: ele era empurrado para fora da moldura. "Reiniciar
// fase" (184) estourava por 10 px pelo mesmo motivo, sem ter sido notado.
//
// O rótulo antigo também mentia: abandonar_partida() leva ao SELETOR DE FASES, não
// ao menu principal.
pausa_opcoes = ["Continuar", "Reiniciar", "Sair"];

// Contagem de retomada: sair da pausa direto no meio da música é injusto se houver
// nota chegando. O jogo fica congelado mais alguns segundos, agora com o campo à
// vista, antes de voltar a valer. É o padrão dos jogos de ritmo.
retomada_timer = 0;

pausar_partida = function() {
    if (pausa) exit;
    pausa = true;
    pausa_opcao = 0;
    o_audio_manager.pausar_musica();
}

/// Inicia a contagem de retomada. A partida só volta a valer quando ela zera.
retomar_partida = function() {
    if (!pausa) exit;
    retomada_timer = 3 * room_speed;
}

/// Chamado quando a contagem de retomada termina.
concluir_retomada = function() {
    retomada_timer = 0;
    pausa = false;
    o_audio_manager.retomar_musica();
}

/// Limpa o gameplay em curso. Usada tanto por reiniciar quanto por sair.
limpar_partida = function() {
    pausa = false;
    retomada_timer = 0;
    o_audio_manager.retomar_musica();

    // O ferreiro pode estar congelado no meio de uma martelada por causa da pausa.
    if (instance_exists(o_ferreiro)) { o_ferreiro.voltar_ao_repouso(); }
    if (instance_exists(o_spawner_ritmo)) { instance_destroy(o_spawner_ritmo); }
    instance_destroy(o_nota_seta);
    resetar_estatisticas();
}

reiniciar_partida = function() {
    limpar_partida();

    // A faixa precisa PARAR, não seguir de onde estava: reiniciar a fase reinicia
    // também a música, que o spawner recomeça do zero ao ser recriado.
    o_audio_manager.stop_music();

    estado_jogo = MINIGAME.CONTAGEM;
    contagem_timer = 3 * room_speed;
}

abandonar_partida = function() {
    limpar_partida();
    estado_jogo = MINIGAME.SELECAO_FASE;
}

// A fase terminou em derrota? Game over é game over: a tela de resultado não pode
// premiar quem estava com boa precisão e perdeu mesmo assim.
fase_falhou = false;
falha_timer = 0;

// Função para resetar as estatísticas antes de começar uma fase
resetar_estatisticas = function() {
    pontuacao = 0;
    stats_total_notas = 0;
    stats_acertos_perfeitos = 0;
    stats_acertos_otimos = 0;
    stats_acertos_bons = 0;
    stats_erros = 0;
    stats_sequencia = 0;
    stats_sequencia_errada = 0;
    stats_toques_invalidos = 0;
    fase_falhou = false;
    falha_timer = 0;
}

// Variável que guarda o estado atual do jogo
estado_jogo = MINIGAME.NENHUM; // O jogo sempre começa no menu principal
estado_anterior = MINIGAME.NENHUM; // usado para disparar o que acontece na virada de estado

// Variáveis de controle do jogo
fase_atual = 0; // Guarda o ÍNDICE da fase selecionada

// --- ESTRUTURA DE DADOS DAS FASES ---
// Um array que guarda as configurações de cada fase como um objeto (struct)
// Molduras do resultado, por nivel de desempenho: 0 falha ... 4 perfeito. Cada arma
// tem a sua moldura correspondente, e o par arma+moldura precisa vir sempre do MESMO
// indice. Ficava so no o_controlador_resultado, e o seletor de fases desenhava a
// melhor arma dentro da moldura de falha por copiar o sprite errado.
molduras_resultado = [s_canva01, s_canva02, s_canva03, s_canva04, s_canva05];

fases_data = [];

// ORDENADAS POR DIFICULDADE, com um nivel para cada fase.
//
// A ordem sai do indice medido — densidade x faixas / tempo de leitura:
//
//   Adaga 1,37 | Lanca 1,69 | Florete 1,74 | Maca 1,78 | Machado 2,59 | Espada 3,35
//
// Ressalva honesta: Lanca, Florete e Maca ficam em 5% umas das outras. A ordem entre
// as tres e medida, mas por margem estreita — se o teste contrariar, e a percepcao que
// manda, nao a tabela.
//
// COMO OS MOTIVOS SAO ESCRITOS (D-130 e D-131). Cada posicao do compasso e medida
// contra o piso de ruido da PROPRIA faixa, amostrando o maximo numa vizinhanca de
// +-40 ms. Duas regras saem dai:
//
//   1. nenhuma nota cai em silencio real;
//   2. cada fase pula de proposito UMA posicao viva.
//
// A regra 2 e o que separa ritmo de metronomo, e ela foi lida na propria Espada: o
// motivo dela toca o tempo 3, que mede 0,81 (abaixo do piso), e pula o 4&, que mede
// 1,74. A fase de maior personalidade do jogo toca onde a faixa cala. Dobrar o tambor
// com exatidao produz metronomo, por mais alinhado que esteja.
//
// O indice do asset de audio acompanha a ordem: snd_fase_01 e a primeira fase, 06 a
// ultima. O campo `id` e o identificador do PLACAR e nao acompanha nada (D-115).

// Novato - 3 faixas | Istampitta Ghaetta
// A Adaga deixou de ser a fase de duas teclas. O motivo dela ja usava os SEIS ataques
// que a faixa tem — as duas colcheias livres medem 0,68 e 0,61, silencio real — e
// semicolcheia nao cabe a 4 de velocidade: daria 8 px de vao entre sprites de 45 px.
// Entao a fase cresce pela LARGURA da pista, e nao pela densidade. Indice 0,91 -> 1,37.
fases_data[0] = {
    id: "adaga",
    nome: "Forjar Adaga",
    dificuldade: "Novato",
    musica_fase: snd_fase_01,
    ganho_musica: 0.951,
    sprites_resultado: [s_adaga01, s_adaga02, s_adaga03, s_adaga04, s_adaga05],
    duracao_segundos: 40,
    velocidade_notas: 4,
    tipos_seta_permitidos: 3,
    stats_limite_sequencia_errada: 4,
    beat_tempo_bpm: 89.99,
    primeira_batida_ms: 290.2,

    // GALOPE. Longa-curta-curta. Toca 1, 2, 2&, 3, 4, 4& — que sao exatamente as seis
    // posicoes vivas da faixa: 4,72 / 3,75 / 2,99 / 4,67 / 3,92 / 2,89.
    ritmo_patterns: [
        [1, 0.5, 0.5, 1, 0.5, 0.5]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    // Com a terceira faixa a pista passou a ter o que atravessar, entao o peso saiu do
    // ALTERNAR (60, que era a unica coisa possivel com duas) e foi para a ESCADA.
    figuras: [30, 20, 30, 20]
};

// Aprendiz - 3 faixas
fases_data[1] = {
    id: "lanca",
    nome: "Forjar Lança",
    dificuldade: "Aprendiz",
    musica_fase: snd_fase_02,
    ganho_musica: 0.703,
    sprites_resultado: [s_lanca01, s_lanca02, s_lanca03, s_lanca04, s_lanca05],
    duracao_segundos: 40,
    velocidade_notas: 5,
    tipos_seta_permitidos: 3,
    stats_limite_sequencia_errada: 5,
    beat_tempo_bpm: 100,
    primeira_batida_ms: 592.1,
    // RAJADA E SILENCIO. Oito colcheias seguidas e tres tempos de nada: variedade 0,786,
    // a maior do jogo. Ja tinha identidade e fica como esta.
    ritmo_patterns: [
        [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [20, 30, 20, 30]
};

// Adepto - 3 faixas | Ductia
//
// FASE EM SEIS. E a unica faixa do projeto que anda em compasso composto, e por pouco
// ela nao entrou errada: subdividida em DOIS os contratempos medem 0,08, que e silencio
// puro, e a faixa parecia so aceitar seminima. Subdividida em TRES eles medem 1,28, e o
// ultimo terco de cada tempo e ataque de verdade: 3,62 / 2,04 / 1,87 / 1,35. O balanco
// 6/8 estava la o tempo todo; a grade e que estava errada.
//
// primeira_batida_ms conta a partir do TERCEIRO tempo (392,4 + 2 batidas): e la que
// esta o ataque mais forte do compasso, 5,41.
//
// Duas frases que se respondem, cada uma com um buraco diferente sobre posicao viva —
// a frase 1 pula o tempo 2, a frase 2 pula o terco do tempo 3. Os tercos usam 0,6667 e
// 0,3333, que somam 4,0000 exatos por compasso: nao ha acumulo de erro na grade.
//
// Sem arte de arma ainda: sprites_resultado vazio e tratado (D-107).
fases_data[2] = {
    id: "florete",
    nome: "Forjar Florete",
    dificuldade: "Adepto",
    musica_fase: snd_fase_03,
    ganho_musica: 0.975,
    sprites_resultado: [],
    duracao_segundos: 50,
    velocidade_notas: 5,
    tipos_seta_permitidos: 3,
    stats_limite_sequencia_errada: 5,
    beat_tempo_bpm: 90,
    primeira_batida_ms: 1725.7,

    // frase 1:  1  1a  .  2a  3  3a  4  .      frase 2:  1  1a  2  2a  3  .  4  .
    ritmo_patterns: [
        [0.6667, 1, 0.3333, 0.6667, 0.3333, 1,   0.6667, 0.3333, 0.6667, 0.3333, 1, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    // ESCADA pesada: o passo do 6/8 sobe e desce, e a pista acompanha.
    figuras: [40, 20, 25, 15]
};

// Veterano - 3 faixas, mas 45 s de exigencia continua | Saltarello II
// Sem arte de arma ainda: sprites_resultado vazio e tratado (D-107).
fases_data[3] = {
    id: "maca",
    nome: "Forjar Maca",
    dificuldade: "Veterano",
    musica_fase: snd_fase_04,
    ganho_musica: 0.544,
    sprites_resultado: [],
    duracao_segundos: 45,
    velocidade_notas: 5,
    tipos_seta_permitidos: 3,
    stats_limite_sequencia_errada: 5,
    beat_tempo_bpm: 99.99,
    primeira_batida_ms: 348.3,
    primeira_nota_seg: 8.0,
    // CELULA DO SALTARELLO. Colcheia-colcheia-seminima, a figura caracteristica da
    // danca, com uma seminima de sobra que impede o padrao de fechar no compasso.
    ritmo_patterns: [
        [0.5, 0.5, 1, 0.5, 0.5, 1, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [45, 15, 25, 15]
};

// Especialista - 4 faixas | Il Trotto
// Contraste tempo/contratempo de 24,16, o melhor material do projeto: so ha ataque
// nos tempos, entao o padrao e todo em seminima (D-112).
fases_data[4] = {
    id: "machado",
    nome: "Forjar Machado",
    dificuldade: "Especialista",
    musica_fase: snd_fase_05,
    ganho_musica: 1.0,
    sprites_resultado: [s_machado01, s_machado02, s_machado03, s_machado04, s_machado05],
    duracao_segundos: 60,
    velocidade_notas: 5,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 130.01,
    primeira_batida_ms: 0,
    // MARCHA COM TROPECO. A faixa e seminima pura, e o martelo entrava dobrando o
    // tambor — variedade zero. Agora ele insere um par de colcheias no meio da marcha:
    // contracanto, nao copia.
    ritmo_patterns: [
        [1, 1, 0.5, 0.5, 1, 1, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [50, 15, 20, 15]
};

// Mestre - 4 faixas | In Taberna Quando Sumus, 120 BPM
//
// A MESMA MELODIA DA ESPADA, ACELERADA. Fecha o jogo com a musica que o jogador ja
// domina, 10 BPM mais rapida e com a pista inteira aberta.
//
// Substituiu La Rotta, que NAO era problema de sincronia: medida contra os ataques
// reais, a grade dela ficava a -2,5 ms com dispersao de 75,9 ms, mais travada que a da
// propria Espada (+83,7 ms). O defeito era outro — flauta solo sem tambor nao produz
// pulso que o jogador consiga ANTECIPAR, e antecipar e o que o jogo pede. In Taberna
// tem razao percussao/melodia 3,87 contra 0,22 de La Rotta, e 93% das batidas com
// ataque real a menos de 40 ms.
//
// Perfil: 3,04 / 1,84 / 2,33 / 1,17 / 2,81 / 1,51 / 2,61 / 0,83. Vivas sao os quatro
// tempos mais os contratempos de 1 e de 3; o 4& e morto e nunca e tocado.
//
// A frase 2 pula o tempo 2, que mede 2,33 e esta bem vivo — e o buraco de proposito.
//
// A 6 de velocidade a colcheia fica com 45 px de vao, MAIS largo que os 37 px que a
// Espada usava a 110 BPM: a fase fica mais dificil sem ficar menos legivel.
fases_data[5] = {
    id: "espada",
    nome: "Forjar Espada",
    dificuldade: "Mestre",
    musica_fase: snd_fase_06,
    ganho_musica: 0.830,
    sprites_resultado: [s_espada01, s_espada02, s_espada03, s_espada04, s_espada05],
    duracao_segundos: 60,
    velocidade_notas: 6,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 120,
    primeira_batida_ms: 355.3,

    // frase 1:  1  1&  2  .  3  3&  4  .      frase 2:  1  1&  .  .  3  3&  4  .
    ritmo_patterns: [
        [0.5, 0.5, 1, 0.5, 0.5, 1,   0.5, 1.5, 0.5, 0.5, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    // o perfil da Espada, que e o padrao das fases que nao declaram o seu
    figuras: [34, 24, 24, 18]
};

contagem_timer = 150; // Começa inativo
show_debug_message("Controlador Geral criado e configurado com sucesso!");
