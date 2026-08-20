// Este objeto deixou de ser persistente: ele pertence a rm_opcoes e antes acumulava
// uma cópia a cada visita (auditoria CV-01). Os valores agora vêm do save.
opcoes_menu = ["Volume", "Janela", "Tela Cheia", "Aplicar!"];
opcao_selecionada = 0;

opcoes_volume = save_opcao("volume");
opcoes_janela = save_opcao("janela");
opcoes_tela_cheia = save_opcao("tela_cheia");
