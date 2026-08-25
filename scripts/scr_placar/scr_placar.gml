/// scr_placar — placar de recordes
///
/// Duas frentes SEPARADAS, como decidido na D-52:
///   Livre  — top 10 por fase, com a pontuação daquela fase isolada
///   Arcade — top 10 do percurso inteiro, com o total acumulado
///
/// Elas nunca se misturam, e a separação é OBRIGATÓRIA e não estética: o Arcade soma
/// até seis fases, então um percurso mediano vale muito mais pontos que a melhor
/// partida solta de qualquer fase. Numa tabela só, o Modo Livre desapareceria do topo
/// para sempre — os dois números medem coisas diferentes.
///
/// Outra diferença: a frente Livre RECUSA fase perdida, porque recorde é de trabalho
/// concluído (D-67). A Arcade ACEITA percurso perdido, porque no Arcade perder é o
/// jeito normal de a partida acabar — e o quanto o jogador andou antes de perder é
/// exatamente o que a tabela mede.

#macro PLACAR_MAX 10
#macro PLACAR_LETRAS "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#macro PLACAR_NOME_TAMANHO 3

/// Lista de uma fase, do maior para o menor. Array vazio se ninguém jogou.
///
/// LEITURA PURA: não cria nada. A versão anterior criava a chave da fase como efeito
/// colateral de ser lida, e é chamada de dentro do Draw — três vezes por frame no
/// seletor. Uma função de leitura não pode alterar o save só porque alguém olhou
/// para uma tela.
function placar_livre(_indice) {
    if (!is_struct(global.save.leaderboard.livre)) return [];

    var _id = save_id_fase(_indice);
    var _livre = global.save.leaderboard.livre;

    if (!variable_struct_exists(_livre, _id) || !is_array(_livre[$ _id])) return [];

    return _livre[$ _id];
}

/// Lista de uma fase pronta para receber entrada, criando-a se ainda não existir.
/// Só o caminho de gravação usa isto.
function placar_livre_para_escrita(_indice) {
    if (!is_struct(global.save.leaderboard.livre)) {
        global.save.leaderboard.livre = {};
    }

    var _id = save_id_fase(_indice);
    var _livre = global.save.leaderboard.livre;

    if (!variable_struct_exists(_livre, _id) || !is_array(_livre[$ _id])) {
        _livre[$ _id] = [];
    }

    return _livre[$ _id];
}

/// Em que posição esta pontuação entraria (1 a PLACAR_MAX), ou 0 se não entra.
///
/// Empate NÃO ultrapassa: quem chegou primeiro fica na frente. Numa feira isso
/// importa, porque a fila inteira joga a mesma fase e empates acontecem.
function placar_posicao(_indice, _pontos) {
    if (_pontos <= 0) return 0;

    var _lista = placar_livre(_indice);

    for (var i = 0; i < array_length(_lista); i++) {
        if (_pontos > _lista[i].pontos) return i + 1;
    }

    // não superou ninguém: só entra se ainda houver vaga
    if (array_length(_lista) < PLACAR_MAX) return array_length(_lista) + 1;

    return 0;
}

/// Insere e grava. Devolve a posição obtida, ou 0 se não entrou.
function placar_registrar(_indice, _nome, _pontos, _precisao, _nivel = 0) {
    var _pos = placar_posicao(_indice, _pontos);
    if (_pos == 0) return 0;

    var _lista = placar_livre_para_escrita(_indice);

    array_insert(_lista, _pos - 1, {
        nome: string_copy(string_upper(_nome), 1, PLACAR_NOME_TAMANHO),
        pontos: _pontos,
        precisao: round(_precisao),

        // O nivel da arma forjada. Guardado em vez de reconstruido da precisao porque
        // as duas medidas tem denominadores diferentes — ver icone_nivel_por_precisao.
        nivel: _nivel
    });

    // a lista não cresce: o décimo primeiro cai fora
    while (array_length(_lista) > PLACAR_MAX) {
        array_delete(_lista, PLACAR_MAX, 1);
    }

    global.save.leaderboard.livre[$ save_id_fase(_indice)] = _lista;
    save_gravar();

    return _pos;
}

/// Apaga os placares. Usada junto do SHIFT+F3 que zera os recordes: deixar o placar
/// cheio com os recordes zerados daria duas verdades diferentes na mesma tela.
function placar_limpar() {
    global.save.leaderboard.livre = {};
    global.save.leaderboard.arcade = [];
}

/// Letra na posição de um nome em edição.
function placar_letra(_indice_letra) {
    return string_char_at(PLACAR_LETRAS, _indice_letra + 1);
}

/// Desenha um nome com espaçamento FIXO por letra.
///
/// Em f_padrao_pequena as maiúsculas variam de 8 px ("I") a 15 px ("M"): um "WWW"
/// mede 18 px a mais que um "III". Desenhado como string única, cada nome fica com
/// uma largura diferente e as três colunas de letras não se alinham de uma linha
/// para outra — o placar é uma tabela, e tabela pede coluna.
///
/// Aqui cada letra é centrada num slot de largura fixa. O nome passa a ocupar sempre
/// o mesmo espaço, independentemente das letras.
///
/// `_x` é a borda ESQUERDA do bloco do nome.
function placar_desenhar_nome(_x, _y, _nome, _slot = 18) {
    var _halign = draw_get_halign();
    draw_set_halign(fa_center);

    for (var i = 1; i <= string_length(_nome); i++) {
        // posição inteira: Kobold 7 é fonte de pixel (D-33)
        draw_text(floor(_x + ((i - 0.5) * _slot)), _y, string_char_at(_nome, i));
    }

    draw_set_halign(_halign);
}


// =====================================================================
// FRENTE ARCADE
// Uma tabela só para o jogo inteiro, com o total do percurso. Não é por fase.
// =====================================================================

/// Tabela do Arcade, do maior para o menor. Leitura pura, como placar_livre.
function placar_arcade() {
    var _l = global.save.leaderboard;

    if (!variable_struct_exists(_l, "arcade") || !is_array(_l.arcade)) {
        return [];
    }
    return _l.arcade;
}

/// Em que posição este total entraria (1 a PLACAR_MAX), ou 0 se não entra.
///
/// Empate não ultrapassa, pelo mesmo motivo da frente Livre: numa fila de feira,
/// empates acontecem e quem chegou primeiro fica na frente.
function placar_arcade_posicao(_pontos) {
    if (_pontos <= 0) return 0;

    var _lista = placar_arcade();

    for (var i = 0; i < array_length(_lista); i++) {
        if (_pontos > _lista[i].pontos) return i + 1;
    }

    if (array_length(_lista) < PLACAR_MAX) return array_length(_lista) + 1;

    return 0;
}

/// Grava um percurso na tabela do Arcade. Devolve a posição, ou 0 se não entrou.
///
/// _armas é quantas armas o jogador chegou a forjar, e _completou diz se ele
/// fechou o percurso inteiro. Os dois viram coluna: entre dois totais parecidos, quem
/// forjou mais armas fez a corrida mais longa, e isso merece aparecer.
function placar_arcade_registrar(_nome, _pontos, _armas, _completou) {
    var _pos = placar_arcade_posicao(_pontos);
    if (_pos == 0) return 0;

    var _l = global.save.leaderboard;

    if (!variable_struct_exists(_l, "arcade") || !is_array(_l.arcade)) {
        _l.arcade = [];
    }

    array_insert(_l.arcade, _pos - 1, {
        nome: string_copy(string_upper(_nome), 1, PLACAR_NOME_TAMANHO),
        pontos: _pontos,
        armas: _armas,
        completou: _completou
    });

    while (array_length(_l.arcade) > PLACAR_MAX) {
        array_delete(_l.arcade, PLACAR_MAX, 1);
    }

    save_gravar();
    return _pos;
}
