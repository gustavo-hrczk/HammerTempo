/// scr_save — persistência em disco
/// Base para as opções (Sprint 2) e para o leaderboard (Sprint 4).
/// O arquivo fica na pasta de save do jogo, criada pelo próprio GameMaker.

#macro SAVE_ARQUIVO "hammertempo_save.json"
#macro SAVE_VERSAO 1

/// Estrutura padrão, usada em primeira execução ou se o arquivo estiver corrompido.
function save_padrao() {
    return {
        versao: SAVE_VERSAO,
        opcoes: {
            volume: 10,        // 0 a 10
            tela_cheia: false,
            offset_ms: 0       // calibração de latência (Sprint 5)
        },
        leaderboard: {
            arcade: [],
            livre: {}
        }
    };
}

/// Garante que todo campo esperado existe, mesmo em saves antigos ou incompletos.
function save_normalizar(_dados) {
    var _padrao = save_padrao();

    if (!is_struct(_dados)) return _padrao;

    if (!variable_struct_exists(_dados, "opcoes") || !is_struct(_dados.opcoes)) {
        _dados.opcoes = _padrao.opcoes;
    } else {
        var _chaves = variable_struct_get_names(_padrao.opcoes);
        for (var i = 0; i < array_length(_chaves); i++) {
            var _k = _chaves[i];
            if (!variable_struct_exists(_dados.opcoes, _k)) {
                _dados.opcoes[$ _k] = _padrao.opcoes[$ _k];
            }
        }
    }

    if (!variable_struct_exists(_dados, "leaderboard") || !is_struct(_dados.leaderboard)) {
        _dados.leaderboard = _padrao.leaderboard;
    }
    if (!variable_struct_exists(_dados.leaderboard, "arcade") || !is_array(_dados.leaderboard.arcade)) {
        _dados.leaderboard.arcade = [];
    }
    if (!variable_struct_exists(_dados.leaderboard, "livre") || !is_struct(_dados.leaderboard.livre)) {
        _dados.leaderboard.livre = {};
    }

    _dados.versao = SAVE_VERSAO;
    return _dados;
}

/// Carrega o save para global.save. Nunca falha: em caso de erro, recria o padrão.
function save_carregar() {
    global.save = save_padrao();

    if (!file_exists(SAVE_ARQUIVO)) {
        show_debug_message("[save] arquivo inexistente, usando padrões");
        return;
    }

    try {
        var _buffer = buffer_load(SAVE_ARQUIVO);
        var _texto = buffer_read(_buffer, buffer_string);
        buffer_delete(_buffer);
        global.save = save_normalizar(json_parse(_texto));
        show_debug_message("[save] carregado");
    } catch (_erro) {
        show_debug_message("[save] arquivo inválido, recriando: " + string(_erro));
        global.save = save_padrao();
    }
}

/// Grava global.save em disco.
function save_gravar() {
    try {
        var _texto = json_stringify(global.save);
        var _buffer = buffer_create(string_byte_length(_texto) + 1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _texto);
        buffer_save(_buffer, SAVE_ARQUIVO);
        buffer_delete(_buffer);
        return true;
    } catch (_erro) {
        show_debug_message("[save] falha ao gravar: " + string(_erro));
        return false;
    }
}

/// Aplica as opções salvas ao jogo (volume e tela cheia).
function save_aplicar_opcoes() {
    audio_master_gain(global.save.opcoes.volume / 10);
    if (window_get_fullscreen() != global.save.opcoes.tela_cheia) {
        window_set_fullscreen(global.save.opcoes.tela_cheia);
    }
}

/// Atalho de leitura de uma opção.
function save_opcao(_nome) {
    return global.save.opcoes[$ _nome];
}

/// Atalho de escrita de uma opção (não grava em disco sozinho).
function save_set_opcao(_nome, _valor) {
    global.save.opcoes[$ _nome] = _valor;
}
