// Rede da trava descrita no Create: se por algum motivo a animacao nao andar, o
// efeito some sozinho depois de um segundo.
vida--;
if (vida <= 0) {
    instance_destroy();
}
