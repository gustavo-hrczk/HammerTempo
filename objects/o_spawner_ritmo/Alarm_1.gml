// O período de tolerância acabou. Agora sim, terminamos o jogo.
show_debug_message("Fase Concluída! Mostrando resultados...");

// Muda o estado do jogo para RESULTADO
o_controlador_geral.estado_jogo = MINIGAME.RESULTADO;

// Cria o objeto que vai mostrar os resultados na tela
instance_create_layer(0, 0, "Gameplay", o_controlador_resultado);

// O spawner finalmente se autodestrói.
instance_destroy();