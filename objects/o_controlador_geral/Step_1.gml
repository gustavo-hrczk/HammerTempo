// Begin Step: roda antes do Step de qualquer outro objeto, garantindo que todo mundo
// leia o estado de input do mesmo frame.
input_update();

if (keyboard_check_pressed(vk_f3)) {
    // Shift+F3 com o overlay ja aberto apaga os recordes. Dois passos deliberados,
    // para um esbarrao em F3 nunca zerar o placar do gabinete.
    if (keyboard_check(vk_shift) && global.debug_ativo) {
        debug_zerar_recordes();
    } else {
        debug_toggle();
    }
}
