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

    if (_pct < 40)  return 0;   // falha
    if (_pct < 70)  return 1;   // aceitável
    if (_pct < 95)  return 2;   // bom
    if (_pct < 100) return 3;   // excelente
    return 4;                   // perfeito
}

/// Desenha o ícone montado, centrado em (_x, _y).
///
/// _arma aceita -1 para "arma ainda sem arte": o fundo e a moldura aparecem assim
/// mesmo, com o miolo vazio. Sumir seria pior — o lugar ficaria com um buraco e
/// pareceria defeito, não pendência (D-107).
///
/// Posição arredondada porque a arte é pixel art: meio pixel borra o traço.
function icone_desenhar(_arma, _nivel, _x, _y, _escala, _alpha = 1) {
    var _px = floor(_x);
    var _py = floor(_y);
    var _e = max(1, floor(_escala));
    var _n = clamp(_nivel, 0, 4);

    draw_sprite_ext(s_icone_fundo, _n, _px, _py, _e, _e, 0, c_white, _alpha);

    if (_arma != -1) {
        draw_sprite_ext(_arma, _n, _px, _py, _e, _e, 0, c_white, _alpha);
    }

    draw_sprite_ext(s_icone_moldura, _n, _px, _py, _e, _e, 0, c_white, _alpha);
}

/// Largura (e altura) que o ícone ocupa numa dada escala.
function icone_tamanho(_escala) {
    return ICONE_LADO * max(1, floor(_escala));
}
