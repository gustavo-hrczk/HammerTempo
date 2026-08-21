// --- ESTRUTURA DOS CENÁRIOS ---
// Adicionamos o novo conjunto "Dia Padrão" no início (índice 0).
background_sets = [
    // 0: Manhã
    [bg_manha01, bg_manha02, bg_manha03, bg_manha04],
	
    // 1: Dia Padrão (NOVO CONJUNTO)
    [s_bg_stars, s_bg_far_clouds, s_bg_mid_clouds, s_bg_front_clouds],
    
    // 2: Tarde
    [bg_tarde01, bg_tarde02, bg_tarde03, bg_tarde04],
    
    // 3: Noite
    [bg_noite01, bg_noite02, bg_noite03, bg_noite04, bg_noite05]
];
total_sets = array_length(background_sets);

// --- CORES DE FUNDO PARA CADA TEMA ---
// Adicionamos uma cor correspondente para o novo conjunto.
bg_colors = [
    make_colour_rgb(137, 178, 255), // Cor para Dia Padrão (NOVO)
    make_colour_rgb(137, 178, 255), // Cor para Manhã
    make_colour_rgb(252, 175, 99),  // Cor para Tarde
    make_colour_rgb(25, 22, 38)     // Cor para Noite
];

// --- VELOCIDADES DAS CAMADAS (PARA CADA CONJUNTO) --- // <<< MUDANÇA PRINCIPAL
// Agora, cada conjunto tem seu próprio array de velocidades.
background_speeds = [
    // 0: Velocidades para Dia Padrão (as que você forneceu)
    [0.1, 0.2, 0.3, 0.5], 
    
    // 1: Velocidades para Manhã (ajuste se necessário)
    [0.1, 0.3, 0.6, 1.0],
    
    // 2: Velocidades para Tarde (ajuste se necessário)
    [0.1, 0.3, 0.6, 1.0],
    
    // 3: Velocidades para Noite (ajuste se necessário)
    [0.1, 0.3, 0.6, 1.0, 1.5]
];

// Lógica para descobrir o número máximo de camadas em qualquer conjunto
var _max_layers = 0;
for (var i = 0; i < total_sets; i++) {
    _max_layers = max(_max_layers, array_length(background_sets[i]));
}
max_layers = _max_layers;

// --- CONTROLE DE POSIÇÃO PARALLAX ---
layer_x_current = array_create(max_layers, 0);
layer_x_next = array_create(max_layers, 0);

// --- GERENCIADOR DE TRANSIÇÃO (USANDO OS VALORES DE TESTE RÁPIDO) ---
state = 0;
current_set_index = 0;
next_set_index = 1;

time_between_changes = room_speed * 20; // Muda a cada 5 segundos
transition_duration = room_speed * 10;   // Transição dura 1 segundo
transition_timer = time_between_changes;
transition_progress = 0;

// --- CONTINUIDADE ENTRE SALAS ---
// Cada sala tem a sua própria instância deste objeto, então o céu recomeçava do zero
// a cada troca de tela: a rolagem do parallax voltava para 0 e o tema voltava para o
// primeiro do ciclo. Era o "salto" ao sair do menu para as opções ou os créditos.
// O estado atravessa as salas por um global gravado a cada frame no Draw.
// A fonte da verdade é o menu, que é a primeira sala a criar o fundo.
if (variable_global_exists("bg_ceu_estado") && is_struct(global.bg_ceu_estado)) {
    var _e = global.bg_ceu_estado;
    layer_x_current     = _e.layer_x_current;
    layer_x_next        = _e.layer_x_next;
    state               = _e.state;
    current_set_index   = _e.current_set_index;
    next_set_index      = _e.next_set_index;
    transition_timer    = _e.transition_timer;
    transition_progress = _e.transition_progress;
}
