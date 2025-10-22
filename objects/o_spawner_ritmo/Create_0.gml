// Pega os dados da fase atual que está no controlador
var _dados_fase = o_controlador_geral.fases_data[o_controlador_geral.fase_atual];

// --- Configura as variáveis do spawner com base nos dados da fase ---
minha_duracao = (_dados_fase.duracao_segundos == -1) ? -1 : _dados_fase.duracao_segundos * room_speed;
velocidade_das_notas = _dados_fase.velocidade_notas;
intervalo_min = _dados_fase.intervalo_min_frames;
intervalo_max = _dados_fase.intervalo_max_frames;
tipos_permitidos = _dados_fase.tipos_seta_permitidos;

// --- NOVAS VARIÁVEIS PARA O MODO INFINITO ---
is_endless_mode = (minha_duracao == -1); // É modo infinito?
dificuldade_level = 0;
// Timer para aumentar a dificuldade a cada 15 segundos
dificuldade_timer = 15 * room_speed; 

esta_finalizando = false;

// Inicia o alarme para a primeira nota
alarm[0] = 60;