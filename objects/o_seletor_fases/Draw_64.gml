// Este menu só desenha no estado de seleção de fase
if (o_controlador_geral.estado_jogo != MINIGAME.SELECAO_FASE) {
    exit;
}

// =================================================================
// CARTÕES DE FASE
//
// O cartão não tem moldura própria, então segue o padrão dos outros menus: o cursor
// de espada se apoia na LARGURA DO NOME, rente à primeira linha do cartão.
//
// A caixa pulsante era fixa (300x180 centrada em 619) e não batia com o conteúdo:
// cortava o topo do ícone e sobrava um vão embaixo do recorde. Agora ela é medida —
// do topo da moldura da arma até a linha do recorde, na largura do texto mais largo.
// =================================================================
var _cx = display_get_gui_width() / 2;
var _gap_coluna = 360;

// o painel de pergaminho ocupa 492..720; o cartão inteiro tem de caber nesse vão.
// O título subiu de f_padrao_pequena para f_padrao e a linha ficou 7 px mais alta,
// então o cartão desceu os mesmos 7 px para não ser invadido pela caixa de destaque.
var _y_titulo  = 507;
var _y_icone   = 574;   // centro da moldura
var _y_nome    = 636;
var _y_detalhe = 663;
var _y_recorde = 694;   // em f_padrao, entao precisa de mais linha embaixo

var _escala_moldura = 0.34;             // s_canva01 tem 250px -> 85px na tela
var _escala_arma    = 0.26;
var _meia_moldura   = (250 * _escala_moldura) / 2;

var _tinta = UI_COR_TEXTO;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// --- título ---
// Na fonte pequena ele se perdia entre a dificuldade e o recorde dos cartões, que
// usam o mesmo corpo. Passou para f_padrao (30 px), o corpo dos nomes das fases.
draw_set_font(f_padrao);
draw_set_color(_tinta);
draw_text(_cx, _y_titulo, "Selecione a arma para forjar");

// --- cartões ---
var _inicio_x = _cx - (((min(3, total_opcoes) - 1) * _gap_coluna) / 2);

for (var i = 0; i < total_opcoes; i++) {

    var _pos_x = _inicio_x + (i * _gap_coluna);
    var _fase = opcoes_fase[i];
    var _selecionada = (i == opcao_selecionada);

    var _txt_detalhe = _fase.dificuldade + "  -  " + string(_fase.beat_tempo_bpm) + " BPM";

    // O cartao mostra o CAMPEAO da fase, nao o recorde pessoal: aqui a pergunta do
    // jogador e "quem eu preciso bater", e a resposta e o primeiro do placar.
    var _lista = placar_livre(i);
    var _tem_campeao = (array_length(_lista) > 0);
    var _campeao = _tem_campeao ? _lista[0] : undefined;

    // Nome com espacamento fixo (23 px por letra em f_padrao), pelo mesmo motivo da
    // tabela de recordes: tres letras de larguras diferentes desalinhariam os
    // cartoes entre si.
    var _NOME_SLOT = 23;
    var _NOME_VAO  = 16;

    // largura do nome define o cursor; a mais larga das linhas define a caixa
    draw_set_font(f_padrao);
    var _larg_nome = string_width(_fase.nome);
    var _larg_recorde = _tem_campeao
        ? ((PLACAR_NOME_TAMANHO * _NOME_SLOT) + _NOME_VAO + string_width(string(_campeao.pontos)))
        : string_width("Ainda não forjada");

    if (_selecionada) {
        draw_set_font(f_padrao_pequena);
        var _conteudo = max(_larg_nome + 70,                  // nome + espaço do cursor
                            string_width(_txt_detalhe),
                            _larg_recorde,
                            250 * _escala_moldura);

        var _caixa_topo = _y_icone - _meia_moldura - 5;
        var _caixa_base = _y_recorde + 16;

        ui_caixa_pulsante(_pos_x,
                          (_caixa_topo + _caixa_base) / 2,
                          min(_conteudo + 34, _gap_coluna - 40),
                          _caixa_base - _caixa_topo);
    }

    // Arma e moldura so aparecem em fase ja forjada: sem recorde nao ha o que
    // exibir, e mostrar a melhor arma de uma fase nunca jogada entregava o premio
    // antes da conquista.
    //
    // O par arma+moldura vem sempre do MESMO indice da lista de desempenho. Antes a
    // moldura era s_canva01 fixa, a de FALHA, enquanto a arma era a ultima da lista,
    // a melhor — a borda errada que voce viu.
    if (_tem_campeao) {
        var _nivel = array_length(_fase.sprites_resultado) - 1;
        var _arma = _fase.sprites_resultado[_nivel];
        var _moldura = o_controlador_geral.molduras_resultado[_nivel];

        draw_sprite_ext(_arma, 0, _pos_x, _y_icone, _escala_arma, _escala_arma, 0, c_white, 1);
        draw_sprite_ext(_moldura, 0, _pos_x, _y_icone, _escala_moldura, _escala_moldura, 0, c_white, 1);
    }

    // nome
    draw_set_font(f_padrao);
    draw_set_halign(fa_center);
    draw_set_color(_selecionada ? UI_COR_DESTAQUE : _tinta);
    draw_text(_pos_x, _y_nome, _fase.nome);

    // cursor rente à primeira linha, apoiado na largura dela
    if (_selecionada) {
        draw_sprite(s_menu_seletor, 0, _pos_x - (_larg_nome / 2) - 25, _y_nome);
    }

    // dificuldade e andamento
    draw_set_font(f_padrao_pequena);
    draw_set_color(_tinta);
    draw_text(_pos_x, _y_detalhe, _txt_detalhe);

    // campeao da fase, na fonte cheia: e a conquista do cartao, nao mais uma linha
    // de dados. A 30 px o limiar de contraste cai de 4,5:1 para 3:1, o que permite
    // o tom (176,92,32) com 3,29:1 sobre o pergaminho.
    draw_set_font(f_padrao);

    if (_tem_campeao) {
        var _bloco_nome = PLACAR_NOME_TAMANHO * _NOME_SLOT;
        var _txt_pontos = string(_campeao.pontos);
        var _esq_linha = _pos_x - (_larg_recorde / 2);

        draw_set_color(UI_COR_COBRE_CLARO);
        placar_desenhar_nome(_esq_linha, _y_recorde, _campeao.nome, _NOME_SLOT);

        draw_set_halign(fa_left);
        draw_text(floor(_esq_linha + _bloco_nome + _NOME_VAO), _y_recorde, _txt_pontos);
        draw_set_halign(fa_center);
    } else {
        // sem ninguem no placar nao ha conquista: tinta comum
        draw_text(_pos_x, _y_recorde, "Ainda não forjada");
    }

    draw_set_color(_tinta);
}

ui_reset();
