// Enum para controlar os estados do jogo de forma legível
// Enum para controlar os estados do jogo de forma legível
enum MINIGAME {
    NENHUM,
    SELECAO_FASE,
	TUTORIAL,
    CONTAGEM,
    RITMO,
    TEMPERA,
    AFIACAO,
    RESULTADO
}

// Array com os dois sons que irão se alternar
nav_sounds[0] = snd_menu01; 
nav_sounds[1] = snd_menu02; // Certifique-se de que este som exista!

// Índice para controlar qual som tocar (começa em 0)
nav_sound_index = 0;

// --- NOVAS VARIÁVEIS PARA ESTATÍSTICAS DA FASE ---//
//--- FORJA ---//
tutorial_ja_foi_visto = false; // Começa como 'falso'
pausa = false;
stats_total_notas = 0;
stats_acertos_perfeitos = 0;
stats_acertos_bons = 0;
stats_sequencia = 0;
stats_erros = 0;
stats_sequencia_errada = 0;
stats_limite_sequencia_errada = 0;
stats_spam_detect = 0;
// Função para resetar as estatísticas antes de começar uma fase
resetar_estatisticas = function() {
    pontuacao = 0;
    stats_total_notas = 0;
    stats_acertos_perfeitos = 0;
    stats_acertos_bons = 0;
    stats_erros = 0;
	stats_sequencia = 0;
	stats_sequencia_errada = 0;
	stats_limite_sequencia_errada = 0;
	stats_spam_detect = 0;
}

// Variável que guarda o estado atual do jogo
estado_jogo = MINIGAME.NENHUM; // O jogo sempre começa no menu principal

// Variáveis de controle do jogo
fase_atual = 0; // Guarda o ÍNDICE da fase selecionada
pontuacao = 0;

// --- ESTRUTURA DE DADOS DAS FASES ---
// Um array que guarda as configurações de cada fase como um objeto (struct)
fases_data = [];

// Fase 1: Adaga (Fácil)
// Fase 1: Adaga (Fácil) - BPM: 90
fases_data[0] = {
    nome: "Forjar Adaga",
    dificuldade: "Fácil",
    musica_fase: snd_fase_01,
    sprites_resultado: [s_adaga01, s_adaga02, s_adaga03, s_adaga04, s_adaga05],
    duracao_segundos: 40,
    velocidade_notas: 4,
    tipos_seta_permitidos: 2,
    stats_limite_sequencia_errada: 4,
    beat_tempo_bpm: 90,
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
    sprites_resultado: [s_lanca01, s_lanca02, s_lanca03, s_lanca04, s_lanca05],
    duracao_segundos: 40,
    velocidade_notas: 5,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 5,
    beat_tempo_bpm: 100, 
    ritmo_patterns: [
        [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 2]
    ]
};

// Fase 3: Espada (Difícil - BPM: 120 - Ritmo de Cantiga)
fases_data[2] = {
    nome: "Forjar Espada",
    dificuldade: "Difícil",
    musica_fase: snd_fase_03,
    sprites_resultado: [s_espada01, s_espada02, s_espada03, s_espada04, s_espada05],
    duracao_segundos: 60,
    velocidade_notas: 6,
    tipos_seta_permitidos: 4,
    stats_limite_sequencia_errada: 6,
    beat_tempo_bpm: 120,
    ritmo_patterns: [
        // Síncopa e pulso forte. Simula o andamento da Cantiga.
        [1, 0.5, 0.5, 1, 1, 2]
    ]
};

// Fase 3: Machado (Extremo)
fases_data[3] = {
    nome: "Forjar Machado",
	dificuldade: "Extremo",
	musica_fase: snd_fase_04,
	sprites_resultado: [s_machado01, s_machado02, s_machado03, s_machado04, s_machado05],
    duracao_segundos: 60,
    velocidade_notas: 8,
    tipos_seta_permitidos: 4,
	stats_limite_sequencia_errada: 6,
	beat_tempo_bpm: 130,
    ritmo_patterns: [
        [0.5, 0.5, 1, 0.5, 0.5, 1, 1]
    ]
};

// Fase 5: Modo Infinito (Começa fácil)
//fases_data[4] = {
//    nome: "Modo Infinito",
//    dificuldade: "Progressiva",
//    duracao_segundos: -1, // -1 significa que não tem fim
//    velocidade_notas: 4, // Velocidade inicial
//    intervalo_min_frames: 60, // Intervalo inicial
//    intervalo_max_frames: 100,
//    tipos_seta_permitidos: 2, // Começa com apenas 2 setas
//	stats_limite_sequencia_errada: 6
//};

contagem_timer = 150; // Começa inativo
show_debug_message("Controlador Geral criado e configurado com sucesso!");