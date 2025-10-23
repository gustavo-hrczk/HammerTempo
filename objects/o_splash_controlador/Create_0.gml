// O splash agora só precisa de um timer para saber quanto tempo ficar na tela.
tempo_de_espera_segundos = 2;
timer_hold = tempo_de_espera_segundos * room_speed;

// Variável para garantir que o timer só comece depois do fade-in inicial
timer_iniciado = false;