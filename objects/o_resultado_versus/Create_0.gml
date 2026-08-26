// =================================================================
// RESULTADO DO VERSUS
//
// Tela própria, e não a do modo de um jogador com dois números. A do Modo Livre conta
// UMA história — quanto você forjou — e é construída em volta de uma arma só, de um
// bônus só e de um recorde. Aqui a história é a comparação, e nada mais importa.
//
// Sem placar: a disputa é entre os dois que estão ali, e um ranking transformaria uma
// partida entre amigos numa tabela de estranhos.
// =================================================================
o_audio_manager.fade_out_music(1);

var _j1 = jogador(0);
var _j2 = jogador(1);

pontos = [_j1.pontuacao, _j2.pontuacao];
precisoes = [_j1.precisao(), _j2.precisao()];
acertos = [_j1.acertos(), _j2.acertos()];

// O DETALHAMENTO POR TIER. Perfeito, otimo e bom valem pontuacoes diferentes (100, 75
// e 50 na base, mais o combo), e sem mostrar a divisao o jogador nao tem como saber
// por que perdeu tendo acertado quase tanto quanto o outro.
perfeitas = [_j1.stats_acertos_perfeitos, _j2.stats_acertos_perfeitos];
otimas    = [_j1.stats_acertos_otimos,    _j2.stats_acertos_otimos];
boas      = [_j1.stats_acertos_bons,      _j2.stats_acertos_bons];
erros = [_j1.stats_erros, _j2.stats_erros];
// A PECA FORJADA POR CADA UM, com a nota estampada nela.
//
// A nota era um "Nota S" em texto na ponta da linha. Cada jogador acabou de forjar uma
// arma, e mostrar so a letra jogava fora a metade da informacao que o medalhao carrega
// de graca: a arte da peca ja diz o desempenho pela propria aparencia, e o selo diz a
// letra. E o mesmo par que a tela de um jogador mostra — as duas passam a falar a
// mesma lingua.
//
// A escala do tier inclui o S+, que a precisao sozinha nunca alcanca: ela nao
// diz quantas notas sairam perfeitas, e numa disputa entre dois jogadores de 100% e
// exatamente isso que decide quem forjou melhor.
arma = o_controlador_geral.fases_data[o_controlador_geral.fase_atual].icone;

niveis = [
    icone_nivel(_j1.stats_total_notas, _j1.acertos(), false),
    icone_nivel(_j2.stats_total_notas, _j2.acertos(), false)
];

tiers = [
    icone_tier(precisoes[0], perfeitas[0], _j1.julgadas()),
    icone_tier(precisoes[1], perfeitas[1], _j2.julgadas())
];

// -1 é empate. Empate acontece de verdade quando ninguém toca, então precisa de um
// caminho próprio em vez de virar vitória de quem calhou de ser o índice 0.
vencedor = -1;
if (pontos[0] > pontos[1]) vencedor = 0;
else if (pontos[1] > pontos[0]) vencedor = 1;

// --- OS FERREIROS REAGEM ---
// A animação de vitória e a de falha já existem desde a jam, e é aqui que elas
// finalmente contam alguma coisa: o ferreiro de quem ganhou comemora, o do outro
// afunda. No empate os dois comemoram — ninguém perdeu.
for (var i = 0; i < 2; i++) {
    var _f = ferreiro_de(i);
    if (_f == noone) continue;

    if (vencedor == -1 || vencedor == i) {
        with (_f) iniciar_comemoracao();
    } else {
        with (_f) iniciar_animacao_falha();
    }
}

o_audio_manager.play_sfx((vencedor == -1) ? snd_resultado_bom : snd_resultado_bom);

// =================================================================
// REVELAÇÃO
//
// As barras crescem lado a lado até a proporção real entre os dois totais, e só então
// o vencedor é anunciado. Ver a diferença aparecer vale mais que ler o nome de quem
// ganhou — a barra é a única coisa desta tela que os dois vão olhar juntos.
// =================================================================
// 26 px de arte em escala 4 dao 104 px — visivel de longe sem dominar um corredor de
// 228 px de altura.
#macro VERSUS_ESCALA_ICONE 4

#macro VERSUS_T_BARRAS   0.30
#macro VERSUS_DUR_BARRAS 1.60
#macro VERSUS_T_DETALHE  2.10
#macro VERSUS_T_VENCEDOR 2.60
#macro VERSUS_T_PROMPT   3.20

tempo = 0;
revelacao_pronta = false;

concluir_revelacao = function() {
    tempo = VERSUS_T_PROMPT;
    revelacao_pronta = true;
};
