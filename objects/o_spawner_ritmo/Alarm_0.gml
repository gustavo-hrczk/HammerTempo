// --- LÓGICA PARA CRIAR UMA NOVA NOTA ---

// 1. Escolhe aleatoriamente o tipo da próxima nota (agora de 0 a 3).
var _tipo_random = irandom_range(0, 3); // Alterado de 1 para 3

// 2. Define a posição Y onde a nota deve aparecer, para alinhar com o alvo certo.
var _pos_y;

// Usaremos uma estrutura 'switch' que é mais limpa para múltiplas opções.
switch (_tipo_random) {
    

    case 1: // Seta para Cima
        _pos_y = 502; // Sua posição Y para o alvo de Cima
        break;
		
    case 2: // NOVA: Seta para a Esquerda
        // !! VOCÊ PRECISA INSERIR O VALOR CORRETO AQUI !!
        _pos_y = 612; // Insira a posição Y do seu alvo da ESQUERDA
        break;
		
    case 3: // NOVA: Seta para a Direita
        // !! VOCÊ PRECISA INSERIR O VALOR CORRETO AQUI !!
        _pos_y = 557; // Insira a posição Y do seu alvo da DIREITA
        break;
		
    case 0: // Seta para Baixo
        _pos_y = 667; // Sua posição Y para o alvo de Baixo
        break;
}


// 3. Cria a instância da nota na camada correta.
var _nova_nota = instance_create_layer(x, _pos_y, "Gameplay", o_nota_seta); // Camada "Gameplay"

// 4. Configura a nota que acabamos de criar.
_nova_nota.tipo_seta = _tipo_random;


// --- REINICIA O ALARME PARA A PRÓXIMA NOTA ---
alarm[0] = random_range(45, 90);