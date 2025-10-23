// Se estivermos no período de tolerância, não cria mais notas.
if (esta_finalizando) {
    exit;
}

// --- LÓGICA PARA CRIAR UMA NOVA NOTA ---
var _tipo_random = irandom(tipos_permitidos - 1);
var _pos_y;
switch (_tipo_random) {
    case 0: _pos_y = 665; break;
    case 1: _pos_y = 515; break;
    case 2: _pos_y = 615; break;
    case 3: _pos_y = 565; break;
}
var _nova_nota = instance_create_layer(x, _pos_y, "Gameplay", o_nota_seta);
_nova_nota.tipo_seta = _tipo_random;
_nova_nota.velocidade = velocidade_das_notas;
o_controlador_geral.stats_total_notas++;

// --- LÓGICA PARA AGENDAR A PRÓXIMA NOTA RITMICAMENTE ---
// Pega o multiplicador de tempo da posição atual no padrão
var _multiplicador_de_tempo = meu_pattern_atual[pattern_index];

// Calcula o tempo de espera em frames para a próxima nota
var _proximo_delay_em_frames = _multiplicador_de_tempo * beat_interval_frames;

// Define o alarme para a próxima batida
alarm[0] = _proximo_delay_em_frames;

// Avança para a próxima posição no padrão
pattern_index++;

// Se o padrão acabou, volta para o início para criar um loop
if (pattern_index >= array_length(meu_pattern_atual)) {
    pattern_index = 0;
}