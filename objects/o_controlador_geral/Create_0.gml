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
fases_data[0] = {
    nome: "Forjar Adaga",
	dificuldade: "Fácil",
	sprites_resultado: [s_adaga01, s_adaga02, s_adaga03, s_adaga04, s_adaga05],
    duracao_segundos: 40,
    velocidade_notas: 4,
    tipos_seta_permitidos: 2, // Apenas 0 e 1 (Baixo, Cima)
	stats_limite_sequencia_errada: 4,
	beat_tempo_bpm: 90,
    ritmo_patterns: [
        [1, 1, 0.5, 0.5, 2],    // Padrão 1: Lento, Lento, Rápido, Rápido, Pausa.
        [0.5, 0.5, 1, 1, 2],    // Padrão 2: Rápido, Rápido, Lento, Lento, Pausa. (Inverte a expectativa)
        [1, 0.5, 0.5, 1, 2]     // Padrão 3: Lento, Rápido, Rápido, Lento, Pausa. (Um sanduíche rítmico)
    ]
};

// Fase 2: Lança (Médio)
fases_data[1] = {
    nome: "Forjar Lança",
	dificuldade: "Médio",
	sprites_resultado: [s_lanca01, s_lanca02, s_lanca03, s_lanca04, s_lanca05],
    duracao_segundos: 40,
    velocidade_notas: 5,
    tipos_seta_permitidos: 3, // Todas as 4 setas
	stats_limite_sequencia_errada: 5,
	beat_tempo_bpm: 110, // Ritmo mais acelerado
    ritmo_patterns: [
        [1, 0.5, 1, 0.5, 1],    // Padrão 1: Ritmo "galopante" (longo-curto, longo-curto).
        [0.5, 0.5, 0.5, 0.5, 2], // Padrão 2: Sequência de 4 notas rápidas, seguida de uma pausa para respirar.
        [1.5, 0.5, 1, 2]        // Padrão 3: Introduz a síncopa (batida quebrada), desafiando o timing.
    ]
};

// Fase 3: Espada (Difícil)
fases_data[2] = {
    nome: "Forjar Espada",
	dificuldade: "Difícil",
	sprites_resultado: [s_espada01, s_espada02, s_espada03, s_espada04, s_espada05],
    duracao_segundos: 40,
    velocidade_notas: 6,
    tipos_seta_permitidos: 4,
	stats_limite_sequencia_errada: 6,
	beat_tempo_bpm: 130, // Bem rápido
    ritmo_patterns: [
        [0.5, 1, 0.5, 1.5, 0.5], // Padrão 1: Síncopa complexa, difícil de ler em alta velocidade.
        [1, 1, 0.5, 0.5, 0.5, 0.5], // Padrão 2: Duas batidas lentas seguidas por uma rajada de notas rápidas.
        [0.5, 0.5, 1, 0.5, 0.5, 1]  // Padrão 3: Um fluxo quase constante de notas com pouquíssima pausa.
    ]
};

// Fase 3: Machado (Extremo)
fases_data[3] = {
    nome: "Forjar Machado",
	dificuldade: "Extremo",
	sprites_resultado: [s_machado01, s_machado02, s_machado03, s_machado04, s_machado05],
    duracao_segundos: 10,
    velocidade_notas: 8,
    tipos_seta_permitidos: 4,
	stats_limite_sequencia_errada: 6,
	beat_tempo_bpm: 140,
    ritmo_patterns: [
        [0.5, 1, 0.5, 1.5, 0.5], // Padrão 1: Síncopa complexa, difícil de ler em alta velocidade.
        [1, 1, 0.5, 0.5, 0.5, 0.5], // Padrão 2: Duas batidas lentas seguidas por uma rajada de notas rápidas.
        [0.5, 0.5, 1, 0.5, 0.5, 1]  // Padrão 3: Um fluxo quase constante de notas com pouquíssima pausa.
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