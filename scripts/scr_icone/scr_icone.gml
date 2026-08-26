/// scr_icone — o ícone montado de uma arma forjada.
///
/// A arte de resultado deixou de ser um sprite de 250x250 por arma e por nível (30
/// arquivos) e virou um SANDUÍCHE de três camadas, cada uma com cinco quadros:
///
///     s_icone_fundo    20x20   o fundo, atrás de tudo
///     s_icone_<arma>   16x16   a arma, no meio
///     s_icone_moldura  26x26   a moldura, por cima
///
/// O quadro (image_index) é o NÍVEL DE DESEMPENHO, de 0 (falha) a 4 (perfeito). As
/// três camadas usam o mesmo nível, então a moldura e o fundo contam a mesma história
/// que a arma.
///
/// As três têm origem no CENTRO, então as três são desenhadas no mesmo x,y e se
/// alinham sozinhas — não há deslocamento para acertar à mão.

/// Escala mínima do ícone. 26 px é pequeno demais para leitura direta, então nada é
/// desenhado em escala 1: a miniatura da seleção de fases usa 3 e o resultado usa 6.
///
/// SEMPRE INTEIRA, pela regra do pixel art (D-33). Escala fracionária destrói a grade
/// de pixels da arte, que é o problema que a fonte de pixel já nos ensinou.
#macro ICONE_LADO 26

/// Nível de desempenho a partir da precisão da fase, de 0 (falha) a 4 (perfeito).
///
/// Game over é game over: quem perde a fase recebe o nível de falha mesmo que a
/// precisão até ali estivesse alta (D-67). Antes o jogador avançado levava a melhor
/// arma ao ser derrotado.
function icone_nivel(_total_notas, _acertos, _falhou) {
    if (_falhou) {
        return 0;
    }
    var _pct = (_total_notas > 0) ? ((_acertos / _total_notas) * 100) : 0;
    return icone_nivel_por_precisao(_pct);
}

/// Mesma escala, a partir de uma precisão já calculada.
///
/// Existe para o placar: entradas gravadas antes de o nível passar a ser guardado só
/// têm a precisão, e é dela que o nível é reconstruído. Note que a precisão do placar
/// é medida sobre as notas JULGADAS e o nível da fase sobre o TOTAL de notas — quando
/// sobram notas em voo no fim da fase os dois divergem um pouco, e é por isso que as
/// entradas novas guardam o nível em vez de recalculá-lo.
function icone_nivel_por_precisao(_pct) {
    if (_pct < 40)  return 0;   // falha
    if (_pct < 70)  return 1;   // aceitável
    if (_pct < 95)  return 2;   // bom
    if (_pct < 100) return 3;   // excelente
    return 4;                   // perfeito
}

/// Maior nível já alcançado numa fase, lido do placar dela.
///
/// O cartão mostra o MAIOR nível atingido, e não o do primeiro colocado: pontuação e
/// precisão não andam juntas — dá para somar mais pontos numa partida longa e menos
/// precisa. O que o cartão anuncia é a melhor forja, não o maior número.
function icone_nivel_do_placar(_indice_fase) {
    var _lista = placar_livre(_indice_fase);
    var _melhor = 0;

    for (var i = 0; i < array_length(_lista); i++) {
        var _e = _lista[i];

        // entradas antigas não têm o nível gravado
        var _n = variable_struct_exists(_e, "nivel")
            ? _e.nivel
            : icone_nivel_por_precisao(_e.precisao);

        _melhor = max(_melhor, _n);
    }
    return _melhor;
}

/// Maior DEGRAU ja alcancado numa fase, lido do placar.
///
/// Entradas gravadas antes de o degrau existir so tem o nivel da arma, que e o mesmo
/// numero de 0 a 4 — elas nunca devolvem S+, e nao ha como saber se mereciam: a
/// quantidade de notas perfeitas nao era guardada.
function icone_tier_do_placar(_indice_fase) {
    var _lista = placar_livre(_indice_fase);
    var _melhor = 0;

    for (var i = 0; i < array_length(_lista); i++) {
        var _e = _lista[i];

        if (variable_struct_exists(_e, "tier")) {
            _melhor = max(_melhor, _e.tier);
        } else if (variable_struct_exists(_e, "nivel")) {
            _melhor = max(_melhor, _e.nivel);
        } else {
            _melhor = max(_melhor, icone_nivel_por_precisao(_e.precisao));
        }
    }
    return _melhor;
}

/// Desenha o ícone montado, centrado em (_x, _y).
///
/// _arma aceita -1 para "arma ainda sem arte": o fundo e a moldura aparecem assim
/// mesmo, com o miolo vazio. Sumir seria pior — o lugar ficaria com um buraco e
/// pareceria defeito, não pendência (D-107).
///
/// Posição arredondada porque a arte é pixel art: meio pixel borra o traço.
/// _tier e a QUARTA FATIA: o selo da nota, no canto do medalhao. Aceita -1 para nao
/// desenhar selo nenhum — e o que a miniatura do seletor de armas usa, onde o icone
/// anuncia o melhor nivel ja atingido e nao o resultado de uma partida.
function icone_desenhar(_arma, _nivel, _x, _y, _escala, _alpha = 1, _tier = -1) {
    var _px = floor(_x);
    var _py = floor(_y);
    var _e = max(1, floor(_escala));
    var _n = clamp(_nivel, 0, 4);

    draw_sprite_ext(s_icone_fundo, _n, _px, _py, _e, _e, 0, c_white, _alpha);

    if (_arma != -1) {
        draw_sprite_ext(_arma, _n, _px, _py, _e, _e, 0, c_white, _alpha);
    }

    draw_sprite_ext(s_icone_moldura, _n, _px, _py, _e, _e, 0, c_white, _alpha);

    // POR CIMA DA MOLDURA, de proposito: o selo e uma marca puncionada na peca depois
    // de pronta, entao ele encosta na borda em vez de ficar contido por ela.
    if (_tier != -1) {
        draw_sprite_ext(s_icone_tier, clamp(_tier, 0, ICONE_TIER_MAX),
                        _px, _py, _e, _e, 0, c_white, _alpha);
    }
}

/// Centro do MIOLO do selo dentro do quadro de 26x26. A arte fica no canto inferior
/// direito, entao o miolo nao coincide com o centro do quadro.
#macro ICONE_TIER_CX 18.5
#macro ICONE_TIER_CY 20.5

/// O selo sozinho, sem medalhao, com o miolo centrado em (_x, _y).
///
/// Existe para a tabela de recordes, onde a nota era uma letra colorida sobre o
/// pergaminho: medido, o ouro do S dava 1,09:1 de contraste e o cobre do A dava 2,70:1,
/// os dois muito abaixo do minimo de 4,5:1. Escurecer as cores mataria a leitura, que
/// vem do calor, e contorno nao serve para uma tabela — vira ruido em dez linhas
/// seguidas.
///
/// O selo resolve sem nenhum dos dois: ele traz a propria chapa escura atras da letra,
/// entao le em qualquer fundo pelo desenho e nao pela cor. E de quebra a tabela passa a
/// mostrar a MESMA marca que as duas telas de resultado estampam na peca.
function icone_tier_desenhar(_tier, _x, _y, _escala) {
    var _e = max(1, floor(_escala));
    var _t = clamp(_tier, 0, ICONE_TIER_MAX);

    // o S+ e quatro pixels mais largo, entao o miolo dele fica dois a direita
    var _cx = (_t == ICONE_TIER_MAX) ? (ICONE_TIER_CX + 2) : ICONE_TIER_CX;

    draw_sprite_ext(s_icone_tier, _t,
                    floor(_x - ((_cx - 13) * _e)),
                    floor(_y - ((ICONE_TIER_CY - 13) * _e)),
                    _e, _e, 0, c_white, 1);
}

/// Largura (e altura) que o ícone ocupa numa dada escala.
function icone_tamanho(_escala) {
    return ICONE_LADO * max(1, floor(_escala));
}

// =====================================================================
// NOTA DA FORJA
// =====================================================================

/// Ultimo quadro de s_icone_tier. O 5 e o S+, que nao tem nivel de arma correspondente.
#macro ICONE_TIER_MAX 5

/// O DEGRAU DA FORJA, de 0 a 5 — o indice do selo em s_icone_tier.
///
/// Os quadros 0 a 4 sao os MESMOS indices do nivel da arma, um a um: a arte da peca e
/// a letra estampada nela contam a mesma historia, e nao duas. O 5 e o degrau que so
/// existe na letra.
///
///     0  F   falha, ou precisao abaixo de 40%
///     1  C   ate 70%
///     2  B   ate 95%
///     3  A   abaixo de 100%
///     4  S   100% das notas acertadas
///     5  S+  100% e TODAS perfeitas
///
/// S+ nao e "quase S". Ele exige que nenhuma nota tenha saido como otima ou boa, o que
/// e muito mais raro que nao errar — e por isso ele vale um degrau proprio em vez de
/// um enfeite no S.
function icone_tier(_pct, _perfeitas, _julgadas, _falhou = false) {
    if (_falhou) return 0;

    var _n = icone_nivel_por_precisao(_pct);

    if (_n >= 4 && _julgadas > 0 && _perfeitas >= _julgadas) {
        return 5;
    }

    return _n;
}

/// Nota em letra, a partir do degrau.
function icone_rank_do_tier(_tier) {
    switch (clamp(_tier, 0, ICONE_TIER_MAX)) {
        case 0: return "F";
        case 1: return "C";
        case 2: return "B";
        case 3: return "A";
        case 4: return "S";
    }
    return "S+";
}

/// Nota em letra a partir da precisao, sem informacao de perfeitos.
///
/// Porcentagem e um numero que o jogador precisa INTERPRETAR: 87% e bom? e ruim? Ele
/// nao tem com o que comparar. A letra ele le de relance e compara com a do vizinho
/// na fila, que numa feira e exatamente o que acontece.
///
/// Nunca devolve S+, porque S+ depende de quantas notas sairam perfeitas e isso a
/// precisao sozinha nao diz. Quem tem o dado usa icone_tier.
function icone_rank(_pct) {
    return icone_rank_do_tier(icone_nivel_por_precisao(_pct));
}

/// Cor da nota. Segue a rampa de calor da forja: frio embaixo, incandescente no topo.
///
/// A cor NUNCA e o unico sinal — a letra ja diz tudo sozinha. Ela e reforco, pelo
/// mesmo motivo que as bolhas de julgamento deixaram de depender so de cor.
function icone_rank_cor(_rank) {
    switch (_rank) {
        case "S+": return make_colour_rgb(255, 232, 128);  // ouro claro, acima do S
        case "S":  return make_colour_rgb(255, 196,  64);  // ouro incandescente
        case "A":  return make_colour_rgb(212,  92,  32);  // cobre quente
        case "B":  return make_colour_rgb(150,  66,  24);  // cobre, a tinta do jogo
        case "C":  return make_colour_rgb(120, 105,  95);  // apagada
    }
    return make_colour_rgb(128,  40,  44);                 // F, carmim escuro
}
