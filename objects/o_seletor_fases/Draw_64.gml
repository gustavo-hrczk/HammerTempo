// Este menu só desenha no estado de seleção de fase
if (o_controlador_geral.estado_jogo != MINIGAME.SELECAO_FASE) {
    exit;
}

// =================================================================
// 1. SETUP DA GRADE E POSICIONAMENTO
// =================================================================
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- Variáveis de Ajuste da Grade ---
var _items_por_linha = 3;
var _gap_horizontal = 350;
var _gap_vertical = 80;
var _start_y_base = 640; // Altura inicial da primeira linha

var _num_linhas = ceil(total_opcoes / _items_por_linha);
var _block_altura = (_num_linhas - 1) * _gap_vertical;
var _start_y = _start_y_base - (_block_altura / 2);

var _cx = display_get_gui_width() / 2;
// A linha abaixo agora usa min() para funcionar corretamente com menos de 3 itens na última linha
var _start_x = _cx - ((min(_items_por_linha, total_opcoes) - 1) * _gap_horizontal) / 2;


// =================================================================
// 2. DESENHO DO TÍTULO INSTRUCIONAL (NOVA SEÇÃO)
// =================================================================
var _titulo_y = _start_y - 50; // Posição acima da primeira linha
draw_set_font(f_padrao_pequena); // Usa a fonte pequena
draw_set_color(c_dkgray);   // Cor cinza escuro
draw_text(_cx, _titulo_y, "Selecione a arma para forjar");


// =================================================================
// 3. DESENHO DAS OPÇÕES DE FASE EM GRADE
// =================================================================
for (var i = 0; i < total_opcoes; i++) {
    
    var _col = i % _items_por_linha;
    var _row = i div _items_por_linha;
    
    var _pos_x = _start_x + (_col * _gap_horizontal);
    var _pos_y = _start_y + (_row * _gap_vertical);
    
    var _fase_data = opcoes_fase[i];
    var _nome_fase = _fase_data.nome;
    var _dificuldade = _fase_data.dificuldade;
    
    var _cor_nome = c_black;
    var _cor_dificuldade = c_dkgray; // Cinza escuro para consistência
    
    if (i == opcao_selecionada) {
        _cor_nome = c_yellow;
        
        // --- DESENHA A FAIXA DE DESTAQUE ---
        ui_caixa_pulsante(_pos_x, _pos_y, 280, 70);

        // --- DESENHA O SELETOR (LÓGICA CORRIGIDA) ---
        var _seletor_padding = 125;
        // A posição X do seletor agora é calculada corretamente com base no _pos_x do item atual
        var _seletor_x = _pos_x - _seletor_padding;
        draw_sprite(s_menu_seletor, 0, _seletor_x, _pos_y);
    }
    
    // --- DESENHA O NOME DA FASE ---
    draw_set_font(f_padrao);
    draw_text_color(_pos_x, _pos_y - 12, _nome_fase, _cor_nome, _cor_nome, _cor_nome, _cor_nome, 1);
    
    // --- DESENHA A DIFICULDADE ---
    draw_set_font(f_padrao_pequena);
    draw_text_color(_pos_x, _pos_y + 18, "(" + _dificuldade + ")", _cor_dificuldade, _cor_dificuldade, _cor_dificuldade, _cor_dificuldade, 1);
}

ui_reset();