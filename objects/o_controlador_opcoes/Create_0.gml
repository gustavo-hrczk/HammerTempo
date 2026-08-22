// Este objeto deixou de ser persistente: ele pertence a rm_opcoes e antes acumulava
// uma cópia a cada visita (auditoria CV-01). Os valores vêm do save, e o que o
// jogador mexe aqui é aplicado na hora, para ele ouvir e ver o efeito.
opcoes_menu = ["Música", "Efeitos", "Janela", "Tela Cheia", "Controles", "Aplicar!"];
opcao_selecionada = 0;

opcoes_musica = save_opcao("volume_musica");
opcoes_sfx = save_opcao("volume_sfx");
opcoes_janela = save_opcao("janela");
opcoes_tela_cheia = save_opcao("tela_cheia");

// Aplica o que está sendo experimentado, sem gravar em disco.
previa_audio = function() {
    global.ganho_musica = opcoes_musica / 10;
    global.ganho_sfx = opcoes_sfx / 10;
    o_audio_manager.aplicar_volume_musica();
}
