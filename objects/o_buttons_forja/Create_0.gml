// Guarda a tecla que esta instância específica deve escutar.
minha_tecla = [-1,-1];

// Guarda o tipo de seta desta instância.
meu_tipo = -1;

// Inicia a animação parada no primeiro frame.
image_speed = 0;
image_index = 0;

//função para aleatorizar som de martelada
function scr_audio_random(){
	var _endereco_random = irandom(argument_count -1);
	audio_play_sound(argument[_endereco_random],1,false);
}
	