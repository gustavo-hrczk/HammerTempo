/// Texto de julgamento que sobe (ou afunda) a partir da bigorna.
/// A "cascata" acontece porque cada novo julgamento empurra os anteriores para
/// trás: eles encolhem, aceleram e desaparecem antes.

texto = "";
cor = c_white;
escala = 1;
escala_alvo = 1;
alpha = 1;
vel_y = -1.6;      // negativo sobe, positivo afunda
vel_x = 0;
vida = 0;
