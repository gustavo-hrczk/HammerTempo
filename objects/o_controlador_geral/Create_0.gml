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

// =================================================================
// MODO DE JOGO E PERCURSO ARCADE
//
// modo_jogo e escolhido em o_tela_modos, antes de entrar na forja, e decide se o
// seletor de armas aparece (LIVRE) ou se o percurso comeca direto (ARCADE).
//
// arcade_pontos acumula ATRAVES das fases: a pontuacao de cada fase e somada aqui ao
// terminar, e e esse total que vai para leaderboard.arcade. A pontuacao normal
// (pontuacao) continua sendo so a da fase corrente, para a tela de resultado nao
// precisar saber em que modo esta.
// =================================================================
modo_jogo = MODO.LIVRE;
arcade_indice = 0;    // qual etapa do percurso, contando de zero
arcade_pontos = 0;    // total acumulado ate aqui

/// A primeira fase do percurso nao pode dar game over (ARCADE_PRIMEIRA_IMUNE).
arcade_fase_imune = function() {
    return (modo_jogo == MODO.ARCADE && ARCADE_PRIMEIRA_IMUNE && arcade_indice == 0);
}

/// Comeca o percurso na primeira fase da lista.
///
/// Chamada de dentro da forja, e nao da tela de modos: iniciar a contagem antes da
/// troca de sala faria o cronometro correr durante o fade.
arcade_iniciar_percurso = function() {
    arcade_indice = 0;
    arcade_pontos = 0;

    resetar_estatisticas();
    fase_atual = 0;

    estado_jogo = MINIGAME.CONTAGEM;
    contagem_timer = 3 * room_speed;
}

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

    // No Arcade nao existe seletor de armas para onde voltar: a unidade e o percurso
    // inteiro, entao abandonar leva ao menu. Sem isto o estado SELECAO_FASE chamaria
    // arcade_iniciar_percurso() no frame seguinte, e "Sair" reiniciaria o percurso
    // num laco em vez de sair.
    if (modo_jogo == MODO.ARCADE) {
        modo_jogo = MODO.LIVRE;
        estado_jogo = MINIGAME.NENHUM;
        ir_para_sala(rm_menu);
        return;
    }

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
//   Adaga 0,91 | Florete 1,60 | Lanca 1,70 | Espada 2,33 | Maca 2,37 | Machado 2,59
//
// A ORDEM NAO SEGUE O INDICE, e isso e deliberado. O degrau que o jogador sente
// primeiro e o NUMERO DE TECLAS, entao ele e o eixo principal: 2 / 3 3 / 4 4 4. Dentro
// de cada grupo a ordem e julgamento.
//
// Onde as duas leituras discordam: o indice bruto poe a Espada (2,33) abaixo da Maca
// (2,37) e do Machado (2,59), porque o motivo do Machado ganhou densidade em D-112.
// A Espada fica em Mestre assim mesmo — e a fase de referencia do projeto e a de maior
// duracao. Fica registrado que a tabela discorda.
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

// Novato - 2 faixas | Istampitta Ghaetta
// A fase de entrada, e a unica com duas teclas. Chegou a ir para tres, e voltou: com
// duas ela e a porta do jogo para quem nunca jogou, que e o caso da feira.
//
// Ela tambem nao pode receber mais NOTAS. O motivo ja usa os SEIS ataques que a faixa
// tem — as duas colcheias livres medem 0,68 e 0,61, silencio real — e semicolcheia nao
// cabe a 4 de velocidade: daria 8 px de vao entre sprites de 45 px.
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

    // GALOPE. Longa-curta-curta. Toca 1, 2, 2&, 3, 4, 4& — que sao exatamente as seis
    // posicoes vivas da faixa: 4,72 / 3,75 / 2,99 / 4,67 / 3,92 / 2,89.
    ritmo_patterns: [
        [1, 0.5, 0.5, 1, 0.5, 0.5]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    // Duas faixas nao tem o que atravessar, entao o movimento pende para ALTERNAR.
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
// O LEVANTAMENTO NAO TEM A MESMA FORCA NOS QUATRO TEMPOS: 3,62 / 2,04 / 1,87 / 1,35.
// A primeira versao tocava os dois mais fracos, e era isso que soava fora. Agora o
// motivo so usa os dois primeiros, e a taxa de notas mudas caiu de 18,4% para 12,4% —
// a melhor do jogo depois da Maca.
//
// Preencher os quatro foi testado e e pior: leva a nota mais fraca para 1,35 e a taxa
// para 16,6%. Aqui completar prejudica; remover resolve.
//
// A frase 1 traz o balanco nos dois primeiros tempos e caminha em seminima; a frase 2
// responde com o balanco so no primeiro. Os tercos usam 0,6667 e 0,3333, que somam
// 4,0000 exatos por compasso: nao ha acumulo de erro na grade.
//
// O 6/8 foi confirmado por varredura continua dentro do tempo: o pico do levantamento
// fica em 0,667 com forca 3,62, contra 0,50 em 3/4 — nao e ritmo pontuado. E o balanco
// se mantem pelos 60 s (4,62 / 3,11 / 3,62 / 3,42 por bloco de 15 s).
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

    // frase 1:  1  1a  2  2a  3  .  4  .      frase 2:  1  1a  2  .  3  .  4  .
    ritmo_patterns: [
        [0.6667, 0.3333, 0.6667, 0.3333, 1, 1,   0.6667, 0.3333, 1, 1, 1]
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    // ESCADA pesada: o passo do 6/8 sobe e desce, e a pista acompanha.
    figuras: [40, 20, 25, 15]
};

// Veterano - 4 faixas, e 45 s de exigencia continua | Saltarello II
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
    tipos_seta_permitidos: 4,
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

// Mestre - 4 faixas | a faixa original de 110 BPM
//
// REVERTIDA POR INTEIRO. Esta fase chegou a trocar de musica (In Taberna a 120 BPM),
// de andamento e de velocidade, e o teste reprovou: a versao antiga era melhor. Musica,
// motivo, velocidade, ganho e primeira batida voltaram todos ao que eram.
//
// Ela continua sendo A REFERENCIA de personalidade do projeto, e o motivo dela e a
// prova da regra que vale para as outras: toca o tempo 3, que mede 0,81 — abaixo do
// piso, silencio real — e pula o 4&, que mede 1,74. Toca onde a faixa cala.
//
// Os pesos de figura dela sao o padrao das fases que nao declaram os seus.
fases_data[5] = {
    id: "espada",
    nome: "Forjar Espada",
    dificuldade: "Mestre",
    musica_fase: snd_fase_06,
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
    ],

    // pesos de figura: [escada, varredura, alternar, repetir]
    figuras: [34, 24, 24, 18]
};

contagem_timer = 150; // Começa inativo
show_debug_message("Controlador Geral criado e configurado com sucesso!");
