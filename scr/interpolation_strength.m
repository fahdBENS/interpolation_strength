data = readtable('vitt.xlsx');

% Définir les colonnes (Time, VitVoit, VehSpd)
Time = data.Var1;  % Colonne A
VitVoit = data.Var2;  % Colonne B
VehSpd = data.Var4;  % Colonne D 

% Définir la constante TestMasse
TestMasse = VehSpd(1);

% Initialiser les vecteurs pour stocker les résultats
idx1_list = zeros(11, 1);
idx2_list = zeros(11, 1);
valeurs_VehSpd = zeros(11, 1);
valeurs_VehSpd_moins5 = zeros(11, 1);
valeurs_VehSpd_plus5 = zeros(11, 1);
delta_t_decel = zeros(11, 1);
Strength = zeros(11, 1);

% Boucle sur les valeurs de VehSpd2 à VehSpd12
for i = 2:12
    valeur_VehSpd_i = VehSpd(i);
    
    % Trouver l'indice de la valeur la plus proche et inférieure à (VehSpd_i-5)
    indices_valides1 = find(VitVoit <= (valeur_VehSpd_i - 5));
    if ~isempty(indices_valides1)
        [~, idx_rel1] = max(VitVoit(indices_valides1));
        idx1 = indices_valides1(idx_rel1);
    else
        idx1 = NaN;
    end
    
    % Trouver l'indice de la valeur la plus proche et inférieure à (VehSpd_i+5)
    indices_valides2 = find(VitVoit <= (valeur_VehSpd_i + 5));
    if ~isempty(indices_valides2)
        [~, idx_rel2] = max(VitVoit(indices_valides2));
        idx2 = indices_valides2(idx_rel2);
    else
        idx2 = NaN;
    end
    
    idx1_list(i-1) = idx1;
    idx2_list(i-1) = idx2;
    
    if ~isnan(idx1) && ~isnan(idx2)
        delta_t = (Time(idx1) - Time(idx2)) / 1000;
    else
        delta_t = NaN;
    end
    
    if delta_t ~= 0 && ~isnan(delta_t)
        V1 = (valeur_VehSpd_i + 5) / 3.6;
        V2 = (valeur_VehSpd_i - 5) / 3.6;
        V = valeur_VehSpd_i / 3.6;
        Strength(i-1) = 0.5 * TestMasse * ((V1^2 - V2^2) / (V * delta_t));
    else
        Strength(i-1) = NaN;
    end
    
    valeurs_VehSpd(i-1) = valeur_VehSpd_i;
    valeurs_VehSpd_moins5(i-1) = VitVoit(idx1);
    valeurs_VehSpd_plus5(i-1) = VitVoit(idx2);
    delta_t_decel(i-1) = delta_t;
end

% Créer un tableau avec les résultats
resultats = table(valeurs_VehSpd, valeurs_VehSpd_moins5, idx1_list, valeurs_VehSpd_plus5, idx2_list, delta_t_decel, Strength, ...
    'VariableNames', {'VehSpd', 'VehSpd-5', 'Time1', 'VehSpd+5', 'Time2' , 'Delta_t_decel', 'Strength'});

disp('Tableau des résultats :');
disp(resultats);

% Ajustement polynomial (y = F1x^2 + F2x + F3)
d_valides = valeurs_VehSpd(~isnan(Strength));
strength_valides = Strength(~isnan(Strength));
D_interp = linspace(min(d_valides), max(d_valides), 100);

p = polyfit(d_valides, strength_valides, 2);
F1 = p(1);
F2 = p(2);
F3 = p(3);

disp('Coefficients du polynôme :');
disp(['F1 = ', num2str(F1)]);
disp(['F2 = ', num2str(F2)]);
disp(['F3 = ', num2str(F3)]);

% Tracé du polynôme
Strength_poly = polyval(p, D_interp);
figure;
plot(d_valides, strength_valides, 'ro', 'MarkerSize', 8, 'DisplayName', 'Données originales');
hold on;
plot(D_interp, Strength_poly, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Ajustement polynomial');
grid on;
xlabel('Vitesse VehSpd (km/h)');
ylabel('Strength');
title('Ajustement polynomial de Strength en fonction de VehSpd');
legend;
hold off;
