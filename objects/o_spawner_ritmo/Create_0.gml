// Pega os dados da fase atual que está no controlador
var _dados_fase = o_controlador_geral.fases_data[o_controlador_geral.fase_atual];

// --- Configura as variáveis de DURAÇÃO e DIFICULDADE ---
minha_duracao = (_dados_fase.duracao_segundos == -1) ? -1 : _dados_fase.duracao_segundos * room_speed;
velocidade_das_notas = _dados_fase.velocidade_notas;
tipos_permitidos = _dados_fase.tipos_seta_permitidos;
is_endless_mode = (minha_duracao == -1);
dificuldade_level = 0;
dificuldade_timer = 15 * room_speed;
esta_finalizando = false;

// --- NOVA LÓGICA DE RITMO ---
// Calcula quantos frames dura uma batida completa, com base no BPM
var _bpm = _dados_fase.beat_tempo_bpm;
beat_interval_frames = (60 / _bpm) * room_speed;

// Escolhe aleatoriamente um dos padrões de ritmo definidos para a fase
var _patterns = _dados_fase.ritmo_patterns;
meu_pattern_atual = _patterns[irandom(array_length(_patterns) - 1)];

// Índice para saber em qual parte do padrão nós estamos
pattern_index = 0;

// Inicia o alarme para a primeira nota
alarm[0] = 60;

switch (o_controlador_geral.fase_atual)
{
	case 0:
	audio_play_sound(MusicaDificuldadeFacil,10,true);
	break;
	}