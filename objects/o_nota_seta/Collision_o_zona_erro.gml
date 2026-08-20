// Rede de segurança: o erro normalmente já foi registrado pelo Step, assim que a
// nota passou da janela de acerto. registrar_erro() ignora notas já finalizadas.
if (o_controlador_geral.pausa) {
    exit;
}

registrar_erro();
