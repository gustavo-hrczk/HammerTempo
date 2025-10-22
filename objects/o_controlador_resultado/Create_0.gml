// Impede que a mesma frase aleatória seja escolhida toda vez que o jogo inicia
randomize();

// Arrays para guardar as frases de feedback
frases_ruins = [
    "Todo mestre já falhou na primeira batida.",
    "Refaça. Reforce. Reforje.",
    "Um erro é só metal esperando ser moldado.",
    "As melhores espadas nascem de muitas tentativas.",
    "A bigorna chama novamente.",
    "Seu ritmo ainda pode ser afiado.",
    "Reaqueça a forja e tente outra vez!",
    "Cada batida errada é um passo para o acerto.",
    "Não desista — o fogo ainda está aceso!"
];

frases_boas = [
    "O aço começa a tomar forma!",
    "Está no caminho certo — mais uma batida e será perfeito.",
    "A lâmina já brilha, mas pode reluzir ainda mais.",
    "Forja firme! A perfeição está próxima.",
    "O metal responde bem às suas mãos.",
    "O ritmo está surgindo, continue aquecendo o martelo!",
    "Boa batida — o mestre ferreiro ficaria orgulhoso.",
    "Sente o ritmo? Ele está quase em sincronia com o fogo.",
    "Cada golpe afina o aço… e o seu talento."
];

frases_otimas = [
    "Perfeito! O aço canta sob o seu comando!",
    "Forja lendária! O fogo o reconhece como mestre.",
    "Golpe preciso — a bigorna vibrou em harmonia!",
    "Você forjou com a alma de um verdadeiro mestre.",
    "Ritmo impecável! O ferro se curvou à sua vontade.",
    "A lâmina nasceu perfeita — uma obra digna de canções.",
    "Seu ritmo é puro aço!",
    "Nada menos que lendário.",
    "Cada faísca brilha como sua precisão.",
    "A bigorna te saúda, mestre ferreiro."
];

// Variável para guardar a frase escolhida para esta rodada
frase_escolhida = "";

// Lógica para escolher a frase (só roda uma vez)
var _total_notas = o_controlador_geral.stats_total_notas;
var _acertos_perfeitos = o_controlador_geral.stats_acertos_perfeitos;
var _acertos_bons = o_controlador_geral.stats_acertos_bons;
var _total_acertos = _acertos_perfeitos + _acertos_bons;

// Calcula a porcentagem de acertos
var _porcentagem_acerto = 0;
if (_total_notas > 0) {
    _porcentagem_acerto = (_total_acertos / _total_notas) * 100;
}

// Escolhe a categoria da frase
if (_porcentagem_acerto < 50) { // Menos de 50% de acerto
    frase_escolhida = frases_ruins[irandom(array_length(frases_ruins) - 1)];
} else if (_porcentagem_acerto < 90) { // Entre 50% e 80%
    frase_escolhida = frases_boas[irandom(array_length(frases_boas) - 1)];
} else { // 91% ou mais
    frase_escolhida = frases_otimas[irandom(array_length(frases_otimas) - 1)];
}