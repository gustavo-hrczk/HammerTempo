// Enum para controlar os estados do jogo de forma legível
// Enum para controlar os estados do jogo de forma legível
enum MINIGAME {
    NENHUM,
    SELECAO_FASE,
    CONTAGEM, // <<< NOVO ESTADO ADICIONADO AQUI
    RITMO,
    TEMPERA,
    AFIACAO,
    RESULTADO
}

// --- NOVAS VARIÁVEIS PARA ESTATÍSTICAS DA FASE ---//
//--- FORJA ---//
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
    intervalo_min_frames: 60, // Mais lento
    intervalo_max_frames: 100,
    tipos_seta_permitidos: 2, // Apenas 0 e 1 (Baixo, Cima)
	stats_limite_sequencia_errada: 4
};

// Fase 2: Lança (Médio)
fases_data[1] = {
    nome: "Forjar Lança",
	dificuldade: "Médio",
	sprites_resultado: [s_lanca01, s_lanca02, s_lanca03, s_lanca04, s_lanca05],
    duracao_segundos: 40,
    velocidade_notas: 5,
    intervalo_min_frames: 40,
    intervalo_max_frames: 80,
    tipos_seta_permitidos: 4, // Todas as 4 setas
	stats_limite_sequencia_errada: 5
};

// Fase 3: Espada (Difícil)
fases_data[2] = {
    nome: "Forjar Espada",
	dificuldade: "Difícil",
	sprites_resultado: [s_espada01, s_espada02, s_espada03, s_espada04, s_espada05],
    duracao_segundos: 10,
    velocidade_notas: 6,
    intervalo_min_frames: 30, // Mais rápido
    intervalo_max_frames: 60,
    tipos_seta_permitidos: 4,
	stats_limite_sequencia_errada: 6
};

// Fase 3: Machado (Extremo)
fases_data[3] = {
    nome: "Forjar Machado",
	dificuldade: "Extremo",
	sprites_resultado: [s_machado01, s_machado02, s_machado03, s_machado04, s_machado05],
    duracao_segundos: 10,
    velocidade_notas: 8,
    intervalo_min_frames: 20, // Mais rápido
    intervalo_max_frames: 50,
    tipos_seta_permitidos: 4,
	stats_limite_sequencia_errada: 6
};

// Fase 5: Modo Infinito (Começa fácil)
fases_data[4] = {
    nome: "Modo Infinito",
    dificuldade: "Progressiva",
    duracao_segundos: -1, // -1 significa que não tem fim
    velocidade_notas: 4, // Velocidade inicial
    intervalo_min_frames: 60, // Intervalo inicial
    intervalo_max_frames: 100,
    tipos_seta_permitidos: 2, // Começa com apenas 2 setas
	stats_limite_sequencia_errada: 6
};

contagem_timer = -1; // Começa inativo
show_debug_message("Controlador Geral criado e configurado com sucesso!");