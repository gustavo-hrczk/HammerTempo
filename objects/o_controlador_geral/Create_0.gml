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
// ESTADO POR JOGADOR. Pontuacao, combo, acertos e erros deixaram de ser variaveis
// soltas aqui e viraram um struct por jogador (ver scr_jogador): no Versus os dois
// dividem tela, musica e teclado, e nada da pontuacao de um pode vazar para o outro.
//
// Fora do Versus so o indice 0 e usado, e jogador() sem argumento devolve ele.
jogadores = [];
for (var i = 0; i < JOGADORES_MAX; i++) {
    array_push(jogadores, new EstadoJogador());
}

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

/// Quem esta jogando, nos modos de UM jogador.
///
/// Quase sempre 0. Vale 1 quando o jogador 2 inicia a partida com as teclas dele — ele
/// joga com a propria arte e o proprio placar, no layout de um jogador que ja esta
/// validado. Zerado ao entrar no Versus, onde os dois jogam.
solo_dono = 0;

// A cena do Versus esta montada agora? Bandeira global porque quem monta e quem
// desmonta sao funcoes de script, e nao o controlador.
global.versus_montado = false;
global.versus_pista_montada = false;
global.versus_x_original = [-1, -1];
arcade_indice = 0;    // qual etapa do percurso, contando de zero
arcade_pontos = 0;    // total acumulado ate aqui

// O JULGAMENTO DAS FASES JA FECHADAS do percurso. A leitura do painel e da tela de
// resultado e a soma destes com os da fase corrente — ver arcade_stats_totais.
//
// Sao os quatro contadores, e nao so um par de totais: a tela de resultado mostra a
// divisao por tier, e mostrar a precisao do percurso ao lado das contagens de uma fase
// so faria os numeros da mesma tela discordarem entre si.
arcade_stats_base = { perfeitas: 0, otimas: 0, boas: 0, erros: 0, notas: 0 };

/// Uma entrada por fase JA CONCLUIDA do percurso: { icone, nivel, pontos }.
///
/// E o que a tela final desenha como fileira de armas. So as fases jogadas entram —
/// um percurso encerrado na terceira arma mostra tres, e nao seis com tres vazias:
/// a fileira e o registro do que foi forjado, nao um mapa do que faltou.
arcade_forjadas = [];

/// A primeira fase do percurso nao pode dar game over (ARCADE_PRIMEIRA_IMUNE).
arcade_fase_imune = function() {
    return (modo_jogo == MODO.ARCADE && ARCADE_PRIMEIRA_IMUNE && arcade_indice == 0);
}

/// Bonus de fim de fase, pela regra de D-67: bonus e de trabalho CONCLUIDO, entao
/// fase perdida nao bonifica. Devolve as duas parcelas separadas porque a tela de
/// resultado mostra uma linha para cada.
///
/// Virou funcao porque no Arcade as fases do meio do percurso nao passam pela tela de
/// resultado — sem isto, so a ultima fase de um percurso seria bonificada.
fase_bonus = function(_base) {
    var _j = jogador();
    var _r = { sem_erro: 0, impecavel: 0 };

    if (fase_falhou || _j.julgadas() <= 0 || _j.stats_erros > 0) {
        return _r;
    }

    _r.sem_erro = floor(_base * 0.10);

    if (_j.stats_acertos_otimos == 0 && _j.stats_acertos_bons == 0) {
        _r.impecavel = floor(_base * 0.15);
    }
    return _r;
}

/// Guarda a arma que a fase corrente rendeu, para a fileira da tela final.
///
/// O nivel sai de icone_nivel, a mesma regra que a tela de resultado usa para desenhar
/// a arma: numa fase perdida ele da 0, que e a arma QUEBRADA — o quadro 0 de cada arma
/// existe so para isso.
arcade_registrar_forjada = function(_pontos_da_fase) {
    var _j = jogador();

    array_push(arcade_forjadas, {
        icone:  fases_data[fase_atual].icone,
        nivel:  icone_nivel(_j.stats_total_notas, _j.acertos(), fase_falhou),
        pontos: _pontos_da_fase
    });
}

/// O julgamento a EXIBIR: perfeitas, otimas, boas, erros.
///
/// No Arcade e o do percurso inteiro, e nao o da arma corrente. O percurso e uma
/// partida so — o placar e o combo ja atravessam as fases — e ver a precisao despencar
/// numa arma e voltar a 100% na seguinte fazia os numeros do painel contarem historias
/// diferentes ao mesmo tempo. Nos outros modos devolve a fase, que e a partida.
arcade_stats_totais = function(_dono = undefined) {
    var _j = jogador(_dono);

    var _t = {
        perfeitas: _j.stats_acertos_perfeitos,
        otimas:    _j.stats_acertos_otimos,
        boas:      _j.stats_acertos_bons,
        erros:     _j.stats_erros,
        notas:     _j.stats_total_notas
    };

    if (modo_jogo == MODO.ARCADE) {
        _t.perfeitas += arcade_stats_base.perfeitas;
        _t.otimas    += arcade_stats_base.otimas;
        _t.boas      += arcade_stats_base.boas;
        _t.erros     += arcade_stats_base.erros;
        _t.notas     += arcade_stats_base.notas;
    }

    return _t;
}

/// A fileira INCLUINDO a arma que acabou de ser forjada.
///
/// arcade_forjadas so recebe a fase quando o jogador confirma "Continuar", porque quem
/// calcula o bonus dela e arcade_avancar. O intervalo e desenhado ANTES disso e ficava
/// sempre uma arma atras: nenhuma depois da primeira fase, uma depois da segunda.
///
/// Aqui a entrada da fase corrente e montada em carater PROVISORIO, so para a leitura.
/// Quem grava continua sendo arcade_avancar, uma vez so — duplicar a gravacao para
/// arrumar o desenho faria a soma das entradas parar de fechar com o total.
arcade_fileira_ate_agora = function() {
    var _lista = [];

    for (var i = 0; i < array_length(arcade_forjadas); i++) {
        array_push(_lista, arcade_forjadas[i]);
    }

    var _j = jogador();
    var _b = fase_bonus(_j.pontuacao);

    array_push(_lista, {
        icone:  fases_data[fase_atual].icone,
        nivel:  icone_nivel(_j.stats_total_notas, _j.acertos(), fase_falhou),
        pontos: _j.pontuacao + _b.sem_erro + _b.impecavel
    });

    return _lista;
}

/// Ainda ha arma depois desta no percurso?
arcade_tem_proxima = function() {
    if (modo_jogo != MODO.ARCADE || fase_falhou) {
        return false;
    }
    return (arcade_indice + 1) < min(ARCADE_TOTAL_FASES, array_length(fases_data));
}

/// Total que o jogador tem AGORA, ja contando a fase que acabou de terminar.
///
/// A fase corrente ainda nao entrou em arcade_pontos — ela so e somada quando o
/// percurso emenda a proxima, ou quando a tela de resultado fecha o total. Aqui ela e
/// projetada, para o menu de intervalo poder mostrar o numero real.
arcade_total_projetado = function() {
    var _p = jogador().pontuacao;
    var _b = fase_bonus(_p);
    return arcade_pontos + _p + _b.sem_erro + _b.impecavel;
}

/// Fecha a fase corrente do percurso e emenda a proxima, se houver.
/// Devolve true quando emendou; false quando o percurso acabou aqui.
///
/// A fase FINAL — a sexta, ou aquela em que o jogador falhou — nao e somada aqui de
/// proposito: ela segue para a tela de resultado, que calcula o bonus dela e fecha o
/// total. arcade_pontos guarda sempre o que veio ANTES da fase corrente, e e essa
/// separacao que impede a ultima fase de ser contada duas vezes.
arcade_avancar = function() {
    if (modo_jogo != MODO.ARCADE) {
        return false;
    }

    var _ultima = min(ARCADE_TOTAL_FASES, array_length(fases_data));

    if (fase_falhou || arcade_indice + 1 >= _ultima) {
        return false;
    }

    var _p = jogador().pontuacao;
    var _b = fase_bonus(_p);
    var _total_fase = _p + _b.sem_erro + _b.impecavel;

    arcade_registrar_forjada(_total_fase);
    arcade_pontos += _total_fase;

    arcade_indice++;

    // O COMBO ATRAVESSA AS FASES. O percurso e uma partida so, e zerar a sequencia na
    // troca de arma puniria justamente quem vinha bem — a recompensa de manter o combo
    // e o que segura a atencao ao longo de seis minutos.
    // A PRECISAO ATRAVESSA AS FASES, como os pontos e o combo. Ela reiniciava em 100%
    // a cada arma, e o percurso — que e uma partida so — ficava com tres numeros
    // contando historias diferentes: o placar somando, o combo seguindo e a precisao
    // esquecendo. Guardado antes do reset, que zera as estatisticas da fase.
    var _jf = jogador();
    arcade_stats_base.perfeitas += _jf.stats_acertos_perfeitos;
    arcade_stats_base.otimas    += _jf.stats_acertos_otimos;
    arcade_stats_base.boas      += _jf.stats_acertos_bons;
    arcade_stats_base.erros     += _jf.stats_erros;
    arcade_stats_base.notas     += _jf.stats_total_notas;

    var _combo = jogador().stats_sequencia;
    resetar_estatisticas();
    jogador().stats_sequencia = _combo;

    fase_atual = arcade_indice;

    // Emenda pela CONTAGEM, que e o que faz a faixa com o nome da proxima arma
    // aparecer entre uma fase e outra. O respiro de 1,8 s do fim da fase anterior ja
    // cobre a saida da musica, entao a transicao inteira sai em ~4,8 s sem nenhum
    // momento morto.
    estado_jogo = MINIGAME.CONTAGEM;
    contagem_timer = 3 * room_speed;
    return true;
}

/// Comeca o percurso na primeira fase da lista.
///
/// Chamada de dentro da forja, e nao da tela de modos: iniciar a contagem antes da
/// troca de sala faria o cronometro correr durante o fade.
arcade_iniciar_percurso = function() {
    arcade_indice = 0;
    arcade_pontos = 0;
    arcade_stats_base = { perfeitas: 0, otimas: 0, boas: 0, erros: 0, notas: 0 };
    arcade_forjadas = [];

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

/// As opcoes de pausa da partida corrente.
///
/// REINICIAR SAI DO ARCADE E DO VERSUS. No Arcade ele e uma porta dos fundos para o
/// game over: bastava pausar antes de perder e refazer a fase com a pontuacao das
/// anteriores intacta, o que esvazia o risco que da sentido ao percurso.
///
/// No Versus o motivo e outro: reiniciar e decisao de UM jogador sobre a partida dos
/// dois, e quem esta ganhando nunca vai querer.
pausa_opcoes_agora = function() {
    if (modo_jogo == MODO.ARCADE || modo_jogo == MODO.VERSUS) {
        return ["Continuar", "Sair"];
    }
    return pausa_opcoes;
};

/// O que a opcao escolhida faz. Separado da lista porque os indices mudam com ela.
pausa_executar = function(_opcao) {
    var _lista = pausa_opcoes_agora();
    var _rotulo = _lista[_opcao];

    if (_rotulo == "Continuar") { retomar_partida();   return; }
    if (_rotulo == "Reiniciar") { reiniciar_partida(); return; }
    abandonar_partida();
};

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
    // No Versus a cena SOBREVIVE entre uma partida e a proxima: o retorno e a selecao
    // de armas, com os dois ferreiros ja em cena. Desmontar aqui os faria sumir e
    // renascer em degrade a cada rodada.
    if (!versus_ativo()) versus_desmontar_cena();

    pausa = false;
    retomada_timer = 0;
    o_audio_manager.retomar_musica();

    // O ferreiro pode estar congelado no meio de uma martelada por causa da pausa.
    with (o_ferreiro) voltar_ao_repouso();
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
    // ARCADE e VERSUS nao tem seletor de armas para onde voltar: a unidade dos dois e
    // a partida inteira, entao abandonar leva ao menu.
    //
    // O Versus faltava aqui, e o efeito era pior que voltar ao lugar errado: o estado
    // SELECAO_FASE chamava versus_montar_cena() de novo com a cena ja montada e o
    // seletor por cima, e a tela virava um amontoado.
    if (modo_jogo == MODO.ARCADE || modo_jogo == MODO.VERSUS) {
        modo_jogo = MODO.LIVRE;
        solo_dono = 0;
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
    for (var i = 0; i < array_length(jogadores); i++) {
        jogadores[i].reiniciar();
    }
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
    icone: s_icone_adaga,
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
    icone: s_icone_lanca,
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
fases_data[2] = {
    id: "florete",
    nome: "Forjar Florete",
    dificuldade: "Adepto",
    musica_fase: snd_fase_03,
    ganho_musica: 0.975,
    icone: s_icone_florete,
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
fases_data[3] = {
    id: "maca",
    nome: "Forjar Maca",
    dificuldade: "Veterano",
    musica_fase: snd_fase_04,
    ganho_musica: 0.544,
    icone: s_icone_maca,
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
    icone: s_icone_machado,
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
    icone: s_icone_espada,
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
