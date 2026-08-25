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
    // GALOPE. Longa-curta-curta, repetido. A fase tinha [1,1,1,1] — variedade zero, um
    // metronomo lento. Densidade sobe de 1,50 para 2,23 notas/s, que era a queixa de
    // ter ficado agradavel e sem personalidade. Aderencia 11,88x.
    //
    // Duas faixas nao tem o que atravessar, entao o movimento pende para ALTERNAR.
    ritmo_patterns: [
        [1, 0.5, 0.5, 1, 0.5, 0.5]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [10, 10, 60, 20]
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
    //
    // O movimento acompanha: varre a pista na rajada e segura na pausa.
    ritmo_patterns: [
        [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [20, 30, 20, 30]
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
    // CELULA DO SALTARELLO. Colcheia-colcheia-seminima, que e a figura caracteristica da
    // danca, com uma seminima de sobra que impede o padrao de fechar no compasso.
    // Aderencia 8,68x, acima do piso da Espada.
    //
    // Movimento em ESCADA, que combina com o balanco da danca.
    ritmo_patterns: [
        [0.5, 0.5, 1, 0.5, 0.5, 1, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [45, 15, 25, 15]
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
    // MARCHA COM TROPECO. A faixa e semininma pura, e o martelo entrava dobrando o
    // tambor — variedade zero. Agora ele insere um par de colcheias no meio da marcha:
    // contracanto, nao copia. Aderencia 9,73x.
    //
    // Movimento em ESCADA, o mais marcial dos quatro.
    ritmo_patterns: [
        [1, 1, 0.5, 0.5, 1, 1, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [50, 15, 20, 15]
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
    // A REFERENCIA. Este e o motivo que voce apontou como o de maior personalidade, e
    // ele fecha no compasso de proposito: repetido identico a cada 4 tempos, vira um
    // gancho reconhecivel. Fica intocado, e os pesos de figura dele sao o padrao das
    // fases que nao declaram os seus.
    ritmo_patterns: [
        [1, 1, 0.5, 0.5, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [34, 24, 24, 18]
};

// Mestre - 4 faixas, a maior densidade e a maior velocidade do jogo
// In Taberna Quando Sumus
//
// LACO SEM A INTRODUCAO. O trecho tem 4 segundos de entrada — medidos: ate 3,99 s a
// faixa fica entre -44 e -28 dBFS e em 4,00 s salta para -15, um degrau de 15 dB.
// A primeira versao do laco comecava em 0,128 s e repetia essa introducao quatro
// vezes. O corte agora parte de 4,242 s, a linha de compasso onde o groove entra.
//
// A introducao TOCA UMA VEZ e so o groove entra em laco: 3 compassos de entrada
// mais 8 compassos repetidos 3x = 37,024 s, ou 27,000 compassos inteiros. Seis
// repeticoes tinham ficado longas e monotonas; faixa mais curta que as demais
// nao e problema numa fase de nivel Mestre.
// Fade de 3 ms nas pontas de cada copia mata o estalo sem deslocar o tempo.
//
// So o groove, o perfil fica |#   #   #   #   | com contraste 6,46 (era 5,37 com a
// introducao diluindo) e contratempos entre 0,06 e 0,12 — praticamente mudos.
// Colcheia aqui cairia em silencio: 2,92 notas/s em seminima e o TETO MUSICAL desta
// faixa, e nao uma escolha conservadora.
//
// Por isso a resposta ao "ficou lenta" e VELOCIDADE, nao densidade. E ha um segundo
// motivo, geometrico: a 175 BPM as notas distam 343 ms, o que na velocidade 5 dava
// 103 px entre elas — 58 px de vao para alvos de 45 px. A pista embolava justamente
// na fase mais densa. Na velocidade 7 o vao vai a 99 px: a mesma mudanca que casa
// com a energia da musica tambem desafoga a leitura.
//
// Sem arte de arma ainda: sprites_resultado vazio e tratado (D-107).
fases_data[5] = {
    id: "alabarda",
    nome: "Forjar Alabarda",
    dificuldade: "Mestre",
    musica_fase: snd_fase_06,
    ganho_musica: 0.663,
    sprites_resultado: [],
    duracao_segundos: 32,
    velocidade_notas: 7,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 175.02,
    primeira_batida_ms: 0,
    // FORMA COM RESPIRO. Semininma corrida dava 12,75x de aderencia e variedade ZERO — a
    // metrica premiava dobrar o tambor, e foi ela que empurrou esta fase para o
    // metronomo. Este motivo mantem a densidade (2,97 contra 2,94 n/s) e a folga na
    // pista (96 px), com variedade 0,500 — o dobro da Espada. Aderencia 10,68x.
    //
    // Movimento em VARREDURA: a 175 BPM a pista atravessada de ponta a ponta e o que
    // da escala ao nivel Mestre.
    ritmo_patterns: [
        [1, 1, 0.5, 0.5, 1, 2]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [20, 45, 20, 15]
};

// Fase 4: Machado (Extremo) e Modo Infinito entram na Sprint 7, junto com o
// novo pipeline de mapeamento rítmico. Os assets (snd_fase_04, s_machado01..05)
// já existem no projeto.

contagem_timer = 150; // Começa inativo
show_debug_message("Controlador Geral criado e configurado com sucesso!");
