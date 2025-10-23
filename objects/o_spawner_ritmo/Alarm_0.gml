if (o_controlador_geral.pausa){

} else {
// Se estivermos no período de tolerância, não cria mais notas.
if (esta_finalizando) {
    exit;
}

// --- LÓGICA PARA CRIAR UMA NOVA NOTA ---
// Sorteia um dos tipos permitidos (ex: se for 2, sorteia entre 0 e 1)
var _tipo_random = irandom(tipos_permitidos - 1);

// ... (seu 'switch (_tipo_random)' com as posições Y continua o mesmo aqui) ...
switch (_tipo_random) {
    case 0: _pos_y = 665; break;
    case 1: _pos_y = 515; break;
    case 2: _pos_y = 615; break;
    case 3: _pos_y = 565; break;
}

// Cria a instância da nota e configura ela
var _nova_nota = instance_create_layer(x, _pos_y, "Gameplay", o_nota_seta);
_nova_nota.tipo_seta = _tipo_random;
_nova_nota.velocidade = velocidade_das_notas; // <<< APLICA A VELOCIDADE DA FASE

// >>> ADICIONE ESTA LINHA <<<
o_controlador_geral.stats_total_notas++; // Incrementa o total de notas

// --- REINICIA O ALARME PARA A PRÓXIMA NOTA ---
}
alarm[0] = random_range(intervalo_min, intervalo_max);