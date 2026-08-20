// Begin Step: roda antes do Step de qualquer outro objeto, garantindo que todo mundo
// leia o estado de input do mesmo frame.
input_update();

if (keyboard_check_pressed(vk_f3)) {
    debug_toggle();
}
