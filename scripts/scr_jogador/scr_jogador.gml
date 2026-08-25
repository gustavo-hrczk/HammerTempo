/// scr_jogador — o estado que pertence a UM jogador.
///
/// Pontuação, combo, acertos e erros eram variáveis soltas em o_controlador_geral, o
/// que funcionou enquanto existia um jogador só. O Versus obriga a separá-las: dois
/// jogadores dividem a tela, a música e o teclado, mas nada da pontuação de um pode
/// vazar para o outro.
///
/// A escolha aqui foi UMA fonte de verdade, e não espelhamento. A alternativa — deixar
/// as variáveis antigas valendo para o jogador 1 e criar um struct paralelo para o 2 —
/// seria menos invasiva agora e viraria dois lugares para atualizar em toda mudança
/// futura, com a garantia de que um dia eles discordariam.
///
/// Fora do Versus só existe o jogador 0, e `jogador()` sem argumento devolve ele — o
/// código de um jogador continua lendo como código de um jogador.

/// Quantos jogadores o jogo comporta. Só o Versus usa os dois.
#macro JOGADORES_MAX 2

function EstadoJogador() constructor {
    pontuacao = 0;

    stats_total_notas = 0;
    stats_acertos_perfeitos = 0;
    stats_acertos_otimos = 0;
    stats_acertos_bons = 0;
    stats_erros = 0;

    // combo em curso e a contagem que leva ao game over
    stats_sequencia = 0;
    stats_sequencia_errada = 0;

    // toque sem nota alcançável: custa pontos, não encerra a fase (GP-04)
    stats_toques_invalidos = 0;

    /// Zera tudo para o começo de uma fase.
    static reiniciar = function() {
        pontuacao = 0;
        stats_total_notas = 0;
        stats_acertos_perfeitos = 0;
        stats_acertos_otimos = 0;
        stats_acertos_bons = 0;
        stats_erros = 0;
        stats_sequencia = 0;
        stats_sequencia_errada = 0;
        stats_toques_invalidos = 0;
    }

    /// Quantas notas o jogador acertou, em qualquer qualidade.
    static acertos = function() {
        return stats_acertos_perfeitos + stats_acertos_otimos + stats_acertos_bons;
    }

    /// Notas efetivamente JULGADAS — acertos mais erros.
    ///
    /// Diferente de stats_total_notas, que conta tudo o que foi gerado: no fim da fase
    /// pode haver nota ainda em voo, e é por isso que a precisão e o nível da arma têm
    /// denominadores diferentes (ver icone_nivel_por_precisao).
    static julgadas = function() {
        return acertos() + stats_erros;
    }

    /// Precisão em porcentagem, sobre as notas julgadas.
    static precisao = function() {
        var _j = julgadas();
        return (_j > 0) ? ((acertos() / _j) * 100) : 0;
    }
}

/// Estado de um jogador. Sem argumento, o jogador 1 — que é o único fora do Versus.
function jogador(_n = 0) {
    return o_controlador_geral.jogadores[_n];
}
