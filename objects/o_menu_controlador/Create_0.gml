// O menu agora só precisa saber das suas opções, sem estados de fade.

// Entra em fade: a sala carrega com a tela ainda preta, e o tema estourando em
// volume cheio no escuro soava abrupto.
o_audio_manager.play_music_crossfade(snd_tema, 1.2);

opcoes_menu = ["Começar Jogo", "Opções", "Créditos", "Sair do Jogo"];
opcao_selecionada = 0;