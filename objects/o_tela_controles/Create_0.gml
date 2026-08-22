// =================================================================
// TELA DE CONTROLES
// Sobreposta à tela de opções, no padrão de o_tela_tutorial: evita uma room nova
// para uma tela que só existe enquanto está aberta.
// =================================================================
acoes = input_acoes_configuraveis();

// A ultima linha da lista nao e uma acao: e o "Restaurar padrao", que precisa estar
// aqui porque um vinculo mal escolhido pode deixar o jogo sem como responder — e no
// gabinete nao ha teclado para socorrer.
LINHA_RESTAURAR = array_length(acoes);
total_linhas = LINHA_RESTAURAR + 1;

opcao_selecionada = 0;
capturando = false;

// Uma TABELA precisa de mais largura que um menu: "Confirmar / BOTÃO 1" mede 242 px
// e o vão do padrão é de 205. O painel também sobe, porque sete linhas descem mais
// do que as cinco das opções.
PAINEL_LARGURA = 360;
ITEM_LARGURA   = 340;

// Sem logo, e por medida: a tinta dele desce ate y=400 na tela, e o painel das
// opcoes so nao a corta porque comeca em 367 e cobre o resto. Sete linhas mais o
// titulo formam 400 px de painel, que embaixo do logo terminariam fora da tela.
// Esta e uma sobreposicao, como o_tela_tutorial, entao o titulo vai dentro do painel.
PAINEL_OFFSET  = 20;
