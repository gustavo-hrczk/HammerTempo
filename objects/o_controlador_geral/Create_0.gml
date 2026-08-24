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

// Fase 1: Adaga (Fácil) - BPM: 88
fases_data[0] = {
    nome: "Forjar Adaga",
    dificuldade: "Fácil",
    musica_fase: snd_fase_01,
    ganho_musica: 0.951,   // nivelamento medido (ver o_audio_manager)
    sprites_resultado: [s_adaga01, s_adaga02, s_adaga03, s_adaga04, s_adaga05],
    duracao_segundos: 40,
    velocidade_notas: 4,
    tipos_seta_permitidos: 2,
    stats_limite_sequencia_errada: 4,
    beat_tempo_bpm: 89.99,
    primeira_batida_ms: 290.2,
    ritmo_patterns: [
        [1, 1, 1, 1],
        [1, 0.5, 0.5, 2],
        [1, 1, 0.5, 0.5, 0.5, 0.5]
    ]
};

// Fase 2: Lança (Médio - BPM: 100)
fases_data[1] = {
    nome: "Forjar Lança",
    dificuldade: "Médio",
    musica_fase: snd_fase_02,
    ganho_musica: 0.703,   // nivelamento medido (ver o_audio_manager)
    sprites_resultado: [s_lanca01, s_lanca02, s_lanca03, s_lanca04, s_lanca05],
    duracao_segundos: 40,
    velocidade_notas: 5,
    tipos_seta_permitidos: 3,
    stats_limite_sequencia_errada: 5,
    beat_tempo_bpm: 100,
    primeira_batida_ms: 592.1,
    ritmo_patterns: [
        [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3]
    ]
};

// Fase 3: Espada (Difícil - BPM: 108)
fases_data[2] = {
    nome: "Forjar Espada",
    dificuldade: "Difícil",
    musica_fase: snd_fase_03,
    ganho_musica: 0.917,   // nivelamento medido (ver o_audio_manager)
    sprites_resultado: [s_espada01, s_espada02, s_espada03, s_espada04, s_espada05],
    duracao_segundos: 60,
    velocidade_notas: 5,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 110,
    primeira_batida_ms: 383.1,
    ritmo_patterns: [
        [1, 1, 0.5, 0.5, 1]
    ]
};

// Fase 4: Machado (Mestre - BPM: 115)
// Primeira fase montada com o processo de medicao: BPM e primeira batida vieram de
// tools/analisar_faixa.py, com confianca de 7,7x acima do piso de ruido. A faixa e o
// conjunto de armas ja estavam no projeto, sem uso.
fases_data[3] = {
    nome: "Forjar Machado",
    dificuldade: "Mestre",
    musica_fase: snd_fase_04,
    ganho_musica: 0.869,   // nivelamento medido (ver o_audio_manager)
    sprites_resultado: [s_machado01, s_machado02, s_machado03, s_machado04, s_machado05],
    duracao_segundos: 60,
    velocidade_notas: 5,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 115,
    primeira_batida_ms: 220.6,

    // PADRAO EM COLCHEIAS, e isso foi medido, nao escolhido por gosto.
    //
    // O perfil de acento desta faixa no trecho jogado e |# + + # + # + # |: energia
    // em TODA colcheia, com contraste tempo/contratempo de 0,77 — ou seja, pulso
    // continuo, sem tempo forte. As fases 1 e 2 medem 1,25 e 1,18, que e musica com
    // hierarquia, e por isso os padroes delas em seminima funcionam.
    //
    // O padrao anterior era de seminimas contra uma musica de colcheias: ela fazia
    // "ta-ta-ta-ta-ta-ta-ta-ta" e o mapa fazia "ta - ta-ta - ta - ta". Era
    // literalmente tocar outra coisa.
    //
    // As seminimas do fim de cada padrao sao respiro: colcheia direto por 60 s nao
    // deixa o jogador tirar a mao.
    ritmo_patterns: [
        [0.5, 0.5, 0.5, 0.5, 1, 1],
        [0.5, 0.5, 1, 0.5, 0.5, 1]
    ]
};

// Fase 5: Maca (Medio - BPM: 100)
// Faixa: Saltarello II, danca italiana do seculo XIII (dominio publico).
// Medido em tools/analisar_faixa.py: 100,01 BPM, primeira batida 568,9 ms,
// confianca 10,3x.
//
// SEM ARTE DE ARMA AINDA. sprites_resultado vazio e tratado: o seletor e a tela de
// resultado desenham a moldura com um "?" dentro, em vez de quebrar ou deixar buraco.
fases_data[4] = {
    nome: "Forjar Maca",
    dificuldade: "Medio",
    musica_fase: snd_fase_05,
    ganho_musica: 0.550,   // nivelamento medido (ver o_audio_manager)
    sprites_resultado: [],
    duracao_segundos: 45,
    velocidade_notas: 5,
    tipos_seta_permitidos: 3,
    stats_limite_sequencia_errada: 5,
    beat_tempo_bpm: 100.01,
    primeira_batida_ms: 568.9,

    // Esta faixa ja entra tocando, e esperar os 5,3 s do respiro padrao deixava a
    // tela vazia com a musica correndo. Com 2 s, a primeira nota cai na 3a batida da
    // faixa. Como e menos que o tempo de viagem (4,34 s), as primeiras notas nascem
    // ja no meio do caminho — o que funciona porque a posicao vem do relogio (D-94).
    primeira_nota_seg: 2.0,

    // OS PADROES NAO FECHAM NO COMPASSO, e isso e o ponto.
    //
    // O primeiro que escrevi somava 4 tempos: travado no compasso, repetindo
    // identico por 45 s. Media 8,55x de aderencia (energia de ataque nos instantes
    // de nota, contra o piso da faixa) e soava "quase certo, fora do lugar".
    //
    // Estes somam 6 e 7 tempos. Como nao dividem o compasso de 4, giram contra ele:
    // cada repeticao cai numa posicao metrica diferente, entao o mesmo padrao produz
    // variacao sozinho. E a propriedade do padrao da Lanca, [0.5 x8, 3] = 7 tempos,
    // que e a fase de melhor aderencia depois da Adaga.
    //
    // Escolhidos por busca automatica sobre o espaco de padroes, maximizando
    // aderencia: 9,82x e 9,90x contra 8,55x do anterior. Referencias medidas —
    // Adaga 12,86x, Lanca 11,19x, Espada 8,54x.
    // Os dois somam 6 e 5 tempos: continuam girando contra o compasso de 4, mas com
    // densidade de 2,22 e 2,00 notas por segundo, contra 1,69 dos anteriores. A
    // aderencia cai de 9,82x para 9,15x e 9,34x — e a troca declarada: mais notas
    // significam mais notas em posicao fraca, entao densidade e aderencia se opoem.
    //
    // 2,22 notas/s e exatamente a densidade da Lanca.
    ritmo_patterns: [
        [0.5, 0.5, 1, 1, 1, 0.5, 0.5, 1],
        [1, 1, 1, 1, 0.5, 0.5]
    ]
};

// Fase 4: Machado (Extremo) e Modo Infinito entram na Sprint 7, junto com o
// novo pipeline de mapeamento rítmico. Os assets (snd_fase_04, s_machado01..05)
// já existem no projeto.

contagem_timer = 150; // Começa inativo
show_debug_message("Controlador Geral criado e configurado com sucesso!");
