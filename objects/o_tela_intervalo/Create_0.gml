// =================================================================
// INTERVALO DO PERCURSO ARCADE
//
// Aparece entre uma arma e a próxima, com o total até aqui e a escolha de seguir ou
// encerrar. Existe para RESPEITAR O TEMPO DO JOGADOR: o percurso completo leva quase
// seis minutos, e quem não está gostando não deve precisar perder a partida de
// propósito para sair — nem ficar preso numa fila que ele já não quer.
//
// "Continuar" vem selecionado por padrão: quem está gostando aperta o botão que já
// estava apertando e segue, sem ler nada.
//
// Encerrar NÃO é desistir: o percurso é fechado com os pontos que ele já tem, e o
// total entra no ranking do Arcade normalmente.
// =================================================================
opcoes_menu = ["Continuar", "Encerrar percurso"];
opcao_selecionada = 0;

PAINEL_LARGURA = 340;

var _ctrl = o_controlador_geral;

total_ate_aqui = _ctrl.arcade_total_projetado();

// A fileira e capturada AQUI, uma vez, ja com a arma que acabou de sair da forja —
// ver arcade_fileira_ate_agora. Ler arcade_forjadas direto no Draw mostrava sempre uma
// arma a menos, e a primeira fase nao mostrava nenhuma.
fileira = _ctrl.arcade_fileira_ate_agora();

// Quantas armas já foram forjadas e quantas o percurso tem. arcade_indice conta de
// zero e a fase corrente acabou de terminar, então ela já conta como feita.
feitas = _ctrl.arcade_indice + 1;
total_armas = min(ARCADE_TOTAL_FASES, array_length(_ctrl.fases_data));

proxima_arma = _ctrl.fases_data[_ctrl.arcade_indice + 1].nome;
