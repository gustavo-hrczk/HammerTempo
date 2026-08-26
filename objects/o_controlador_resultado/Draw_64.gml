// --- SETUP DE DESENHO ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// --- POSICIONAMENTO ---
// Com a faixa "ótimas" a lista de duas colunas passou a estourar o painel: a frase
// de feedback invadia a caixa do prompt. Virou uma grade 2x3 em fonte pequena, que
// economiza uma linha inteira e ainda agrupa os três julgamentos lado a lado.
var _cx = display_get_gui_width() / 2;
var _col_esq = _cx - 300;
var _col_dir = _cx + 300;

var _linha1 = 522;
var _linha2 = 558;

// NO ARCADE ESTES SAO OS NUMEROS DO PERCURSO, e nao os da ultima arma — ver
// arcade_stats_totais. Nos outros modos a fase E a partida, e nada muda.
var _tot = o_controlador_geral.arcade_stats_totais();

var _perfeitas = _tot.perfeitas;
var _otimas = _tot.otimas;
var _boas = _tot.boas;
var _erros = _tot.erros;

var _julgadas = _perfeitas + _otimas + _boas + _erros;
var _precisao = (_julgadas > 0) ? ((_perfeitas + _otimas + _boas) / _julgadas) * 100 : 0;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);

// --- GRADE DE ESTATÍSTICAS ---
// Em f_padrao: com a grade 2x3 o espaço permite o tamanho cheio, e os números
// são a informação que o jogador mais quer ler nesta tela.
draw_set_font(f_padrao);

if (tempo >= RESULTADO_T_ESTATISTICAS) {
    draw_text(_col_esq, _linha1, "Perfeitas: " + string(_perfeitas));
    draw_text(_cx,      _linha1, "Ótimas: " + string(_otimas));
    draw_text(_col_dir, _linha1, "Boas: " + string(_boas));

    draw_text(_col_esq, _linha2, "Erros: " + string(_erros));
    draw_text(_cx,      _linha2, "Total: " + string(_tot.notas));
    draw_text(_col_dir, _linha2, "Precisão: " + ui_pct(_precisao));
}

// --- NOTA DA FORJA ---
// A mesma letra que a tabela de recordes mostra, pela mesma função. As duas telas
// precisam dizer a mesma coisa do mesmo jeito: o jogador vê a nota aqui e a procura
// lá, e porcentagem de um lado com letra do outro quebraria essa ponte.
//
// Fica AO LADO DA ARMA, e não na grade de estatísticas: a nota é o veredito sobre a
// peça forjada, então ela pertence à peça. Em escala 2, inteira (D-33).
//
// Só no Modo Livre. Num percurso a precisão é a da ÚLTIMA fase, e uma nota grande ao
// lado de seis armas diria que ela vale para todas — quem conta a história do
// percurso ali é a fileira.
if (array_length(fileira) == 0 && tempo >= RESULTADO_T_ESTATISTICAS) {
    var _rank = icone_rank(_precisao);
    var _nota_x = _cx + 150;

    // A nota fica sobre o CENARIO, e nao sobre o painel: sem placa, a letra dourada do
    // S sumia contra o ceu claro do ciclo. Mesmo padrao de ui_texto_flutuante.
    hud_placa_suave(_nota_x - 74, 122, _nota_x + 74, 250,
                    c_black, UI_PLACA_ALPHA, 30, 22);

    draw_set_font(f_padrao_pequena);
    draw_set_color(UI_COR_APAGADA);
    draw_text(_nota_x, 152, "NOTA");

    draw_set_font(f_padrao);
    draw_set_color(icone_rank_cor(_rank));
    draw_text_transformed(floor(_nota_x), floor(212), _rank, 2, 2, 0);

    draw_set_color(c_black);
}

// --- PONTUAÇÃO EM DESTAQUE ---
// Era preta, igual à grade de estatísticas acima, e sumia no meio delas. O cobre
// vem da rampa do combo, então a paleta da partida e a do resultado são a mesma;
// mede 4,68:1 sobre o pergaminho (229,214,161).
//
// O número SOBE até o total em vez de aparecer pronto: contar dá peso ao resultado,
// e é o único momento da tela em que o jogador olha um número mudar.
var _texto_pontos = "Pontuação: " + string(pontuacao_exibida);

draw_set_font(f_padrao);
draw_set_color(UI_COR_COBRE);

if (tempo >= RESULTADO_T_CONTAGEM) {
    draw_text(_cx, 594, _texto_pontos);
}

// --- BÔNUS ---
// Entram como LINHA PRÓPRIA e só depois somam no total. Ver "SEM ERRO +1200" e ver o
// número subir por causa dele recompensa mais do que um total maior já pronto.
draw_set_font(f_padrao_pequena);

// No Arcade as duas linhas somem: elas descrevem so a ULTIMA fase, e ao lado de um
// total de seis fases isso mente sobre de onde vieram os pontos. Quem detalha o
// percurso ali e a fileira.
var _mostra_bonus = (array_length(fileira) == 0);

if (_mostra_bonus && bonus_sem_erro > 0 && tempo >= RESULTADO_T_BONUS_1) {
    draw_set_color(UI_COR_CARMIM);
    draw_text(_col_esq, 594, "SEM ERRO  +" + string(bonus_sem_erro));
}

if (_mostra_bonus && bonus_impecavel > 0 && tempo >= RESULTADO_T_BONUS_2) {
    draw_set_color(UI_COR_CARMIM);
    draw_text(_col_dir, 594, "IMPECÁVEL  +" + string(bonus_impecavel));
}

draw_set_color(c_black);

// --- RECORDE NOVO ---
// Ancorado na largura real da pontuação, não num deslocamento fixo: com 6 dígitos o
// antigo +190 encostava no número.
//
// A onda percorre o texto letra a letra. O deslocamento é ARREDONDADO porque Kobold 7
// é fonte de pixel: posição fracionária suja o traço, que foi o problema do contador
// dinâmico da contagem regressiva.
if (recorde_novo && revelacao_pronta) {
    draw_set_font(f_padrao_pequena);
    draw_set_halign(fa_left);

    var _rec = "NOVO RECORDE!";
    var _rx = _cx + (string_width(_texto_pontos) / 2) + 30;

    // carmim, 5,57:1 — o vermelho anterior (178,58,22) ficava em 4,12:1 e quase
    // se confundia com o cobre da pontuação ao lado
    draw_set_color(UI_COR_CARMIM);

    for (var i = 1; i <= string_length(_rec); i++) {
        var _ch = string_char_at(_rec, i);
        var _onda = round(sin((current_time * 0.006) - (i * 0.55)) * 4);

        draw_text(floor(_rx), 594 + _onda, _ch);
        _rx += string_width(_ch);
    }

    draw_set_color(c_black);
    draw_set_halign(fa_center);
}

// --- FRASE DE FEEDBACK (escolhida no evento Create) ---
// Junto com o prompt: ela é o fecho da leitura, não parte dos dados.
if (revelacao_pronta) {
    draw_set_font(f_padrao_pequena);
    draw_set_color(c_gray);
    draw_text(_cx, 628, frase_escolhida);
}
draw_set_color(c_black);

// --- PROMPT PARA CONTINUAR ---
// A GUI agora tem 720 px de altura (antes herdava os 768 do splash), então o prompt
// desceu para dentro da tela — auditoria UI-01.
// Só aparece quando a revelação termina. Antes disso CONFIRMAR corta a animação —
// quem tem pressa não espera, mas nada na tela convida a apressar.
if (revelacao_pronta) {
    ui_prompt(_cx, 676, ui_texto_confirmar() + " para continuar", 65);
}

// =================================================================
// A ARMA FORJADA
//
// Sanduiche de fundo, arma e moldura, montado por icone_desenhar. Escala 6 leva os
// 26 px do icone a 156 px na tela — inteira, pela regra do pixel art (D-33). A arte
// antiga era de 250x250 e vinha em escala 0,8, o que sujava a grade de pixels.
// =================================================================
var _n_fileira = array_length(fileira);

if (_n_fileira > 0) {
    // ARCADE: as armas do percurso, lado a lado, montando uma a uma da esquerda para
    // a direita. So as fases JOGADAS aparecem — a fileira registra o que foi forjado,
    // e nao o que faltava forjar.
    //
    // A fase perdida entra com nivel 0, que e a arma QUEBRADA. O quadro 0 de cada arma
    // existe so para isso.
    var _lado = icone_tamanho(RESULTADO_ESCALA_FILEIRA);
    var _passo = _lado + 20;
    var _inicio = _cx - (((_n_fileira - 1) * _passo) / 2);

    for (var i = 0; i < _n_fileira; i++) {
        var _t = RESULTADO_T_CONTAGEM + (i * RESULTADO_GAP_FILEIRA);
        if (tempo < _t) continue;

        // cada arma entra em degrade curto, para a fileira ler como sequencia e nao
        // como seis coisas piscando
        var _a = min(1, (tempo - _t) / 0.22);

        icone_desenhar(fileira[i].icone, fileira[i].nivel,
                       _inicio + (i * _passo), 190,
                       RESULTADO_ESCALA_FILEIRA, _a);
    }

} else {
    icone_desenhar(arma_forjada, nivel_forjado, _cx, 190, 6);
}

ui_reset();