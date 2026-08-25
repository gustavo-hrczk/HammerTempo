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
// Os dois primeiros niveis sao definidos pelo NUMERO DE FAIXAS, que e o degrau que o
// jogador sente primeiro: Novato tem 2, Aprendiz tem 3. Dai em diante a ordem sai do
// indice medido (densidade x faixas / tempo de leitura, ajustado pela tolerancia):
//
//   Adaga 0,89 | Maca 1,61 | Lanca 1,63 | Machado 1,73 | Espada 1,94
//
// Ressalva honesta: Maca e Lanca diferem em 1,2%, dentro do ruido da medicao. A
// ordem entre as duas e julgamento, nao medida — Lanca vem antes por ter 40 s contra
// os 45 s da Maca, ou seja, menos tempo de exigencia continua.
//
// A Espada e a mais dificil apesar de ser 20 BPM mais lenta que o Machado: tem mais
// notas por segundo com o mesmo tempo de leitura. Andamento alto nao e dificuldade
// quando o padrao e todo em seminima.
//
// "Mestre" fica vago de proposito, para a sexta faixa.
//
// O campo `id` e o identificador do placar e NAO acompanha a ordem (D-115).

// Novato - 2 faixas
fases_data[0] = {
    id: "adaga",
    nome: "Forjar Adaga",
    dificuldade: "Novato",
    musica_fase: snd_fase_01,
    ganho_musica: 0.951,
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
    ritmo_patterns: [
        [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3]
    ]
};

// Adepto - 3 faixas, mas 45 s de exigencia continua | Saltarello II
// Sem arte de arma ainda: sprites_resultado vazio e tratado (D-107).
fases_data[2] = {
    id: "maca",
    nome: "Forjar Maca",
    dificuldade: "Adepto",
    musica_fase: snd_fase_05,
    ganho_musica: 0.544,
    sprites_resultado: [],
    duracao_segundos: 45,
    velocidade_notas: 5,
    tipos_seta_permitidos: 3,
    stats_limite_sequencia_errada: 5,
    beat_tempo_bpm: 99.99,
    primeira_batida_ms: 348.3,
    primeira_nota_seg: 8.0,
    ritmo_patterns: [
        [1, 1, 1, 0.5, 0.5, 1, 0.5, 0.5],
        [1, 1, 1, 1, 0.5, 0.5]
    ]
};

// Veterano - 4 faixas | Il Trotto
// Contraste tempo/contratempo de 24,16, o melhor material do projeto: so ha ataque
// nos tempos, entao o padrao e todo em seminima (D-112).
fases_data[3] = {
    id: "machado",
    nome: "Forjar Machado",
    dificuldade: "Veterano",
    musica_fase: snd_fase_04,
    ganho_musica: 1.0,
    sprites_resultado: [s_machado01, s_machado02, s_machado03, s_machado04, s_machado05],
    duracao_segundos: 60,
    velocidade_notas: 5,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 130.01,
    primeira_batida_ms: 0,
    ritmo_patterns: [
        [1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 2, 1, 1, 1]
    ]
};

// Especialista - 4 faixas, a maior densidade do jogo
fases_data[4] = {
    id: "espada",
    nome: "Forjar Espada",
    dificuldade: "Especialista",
    musica_fase: snd_fase_03,
    ganho_musica: 0.917,
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

// Mestre - 4 faixas, a maior densidade do jogo | In Taberna Quando Sumus
//
// O trecho original tinha 15,7 s e 11,38 compassos — nao fechava. Foi cortado em 10
// compassos exatos (13,7127 s, evitando o fade do fim) e repetido 4x, com 3 ms de
// fade nas pontas de cada copia para matar o estalo da emenda sem deslocar o tempo.
// Remedido no arquivo final: 175,02 BPM, primeira batida em 0,0 ms, 40,000 compassos
// inteiros. A grade sobreviveu ao laco.
//
// Perfil |#   #   #   #   |, contraste 5,37: os quatro tempos fortes e parelhos, os
// contratempos praticamente mudos. Padrao em seminima corrida, que a 175 BPM da 2,92
// notas por segundo — indice 2,47 contra 1,94 da Espada.
//
// Velocidade fica em 5, e nao 6: a 175 BPM as notas ja chegam a cada 343 ms, e
// encurtar o tempo de leitura junto tornaria a fase punitiva em vez de dificil. A
// dificuldade vem da densidade.
//
// Sem arte de arma ainda: sprites_resultado vazio e tratado (D-107).
fases_data[5] = {
    id: "alabarda",
    nome: "Forjar Alabarda",
    dificuldade: "Mestre",
    musica_fase: snd_fase_06,
    ganho_musica: 0.746,
    sprites_resultado: [],
    duracao_segundos: 45,
    velocidade_notas: 5,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 175.02,
    primeira_batida_ms: 0,
    ritmo_patterns: [
        [1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 2, 1, 1, 1, 1]
    ]
};

// Fase 4: Machado (Extremo) e Modo Infinito entram na Sprint 7, junto com o
// novo pipeline de mapeamento rítmico. Os assets (snd_fase_04, s_machado01..05)
// já existem no projeto.

contagem_timer = 150; // Começa inativo
show_debug_message("Controlador Geral criado e configurado com sucesso!");
