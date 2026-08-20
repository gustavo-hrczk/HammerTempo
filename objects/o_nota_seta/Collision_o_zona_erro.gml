// Rede de segurança: o erro normalmente já foi registrado pelo Step, assim que a
// nota passou da janela de acerto. Se por algum motivo isso não aconteceu, a zona
// morta garante a contabilização. registrar_erro() ignora notas já finalizadas.
if (o_controlador_geral.pausa) {
    exit;
}

registrar_erro();
