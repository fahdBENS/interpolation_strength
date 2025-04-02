data = readtable('vitt.xlsx');

% Définir les colonnes (A, B, D)
A = data.Var1;  % Colonne A
B = data.Var2;  % Colonne B
D = data.Var4;  % Colonne D 

% Définir la constante Var4(1)
constante = D(1);

% Initialiser les vecteurs pour stocker les résultats
idx1_list = zeros(11, 1);
idx2_list = zeros(11, 1);
valeurs_D = zeros(11, 1);
valeurs_D_moins5 = zeros(11, 1);
valeurs_D_plus5 = zeros(11, 1);
delta_t_decel = zeros(11, 1);
Strength = zeros(11, 1);

% Boucle sur les valeurs de D2 à D12
for i = 2:12
    valeur_Di = D(i);
    
    % Trouver l'indice de la valeur la plus proche et inférieure à (Di-5)
    indices_valides1 = find(B <= (valeur_Di - 5));
    if ~isempty(indices_valides1)
        [~, idx_rel1] = max(B(indices_valides1));
        idx1 = indices_valides1(idx_rel1);
    else
        idx1 = NaN;
    end
    
    % Trouver l'indice de la valeur la plus proche et inférieure à (Di+5)
    indices_valides2 = find(B <= (valeur_Di + 5));
    if ~isempty(indices_valides2)
        [~, idx_rel2] = max(B(indices_valides2));
        idx2 = indices_valides2(idx_rel2);
    else
        idx2 = NaN;
    end
    
    idx1_list(i-1) = idx1;
    idx2_list(i-1) = idx2;
    
    if ~isnan(idx1) && ~isnan(idx2)
        delta_t = (A(idx1) - A(idx2)) / 1000;
    else
        delta_t = NaN;
    end
    
    if delta_t ~= 0 && ~isnan(delta_t)
        V1 = (valeur_Di + 5) / 3.6;
        V2 = (valeur_Di - 5) / 3.6;
        V = valeur_Di / 3.6;
        Strength(i-1) = 0.5 * constante * ((V1^2 - V2^2) / (V * delta_t));
    else
        Strength(i-1) = NaN;
    end
    
    valeurs_D(i-1) = valeur_Di;
    valeurs_D_moins5(i-1) = valeur_Di - 5;
    valeurs_D_plus5(i-1) = valeur_Di + 5;
    delta_t_decel(i-1) = delta_t;
end

% Créer un tableau avec les résultats
resultats = table(valeurs_D, valeurs_D_moins5, idx1_list, valeurs_D_plus5, idx2_list, delta_t_decel, Strength, ...
    'VariableNames', {'D', 'D-5', 'Time1', 'D+5', 'Time2' , 'Delta_t_decel', 'Strength'});

disp('Tableau des résultats :');
disp(resultats);

% Ajustement polynomial (y = Ax^2 + Bx + C)
d_valides = valeurs_D(~isnan(Strength));
strength_valides = Strength(~isnan(Strength));
D_interp = linspace(min(d_valides), max(d_valides), 100);

p = polyfit(d_valides, strength_valides, 2);
A = p(1);
B = p(2);
C = p(3);

disp('Coefficients du polynôme :');
disp(['A = ', num2str(A)]);
disp(['B = ', num2str(B)]);
disp(['C = ', num2str(C)]);

% Tracé du polynôme
Strength_poly = polyval(p, D_interp);
figure;
plot(d_valides, strength_valides, 'ro', 'MarkerSize', 8, 'DisplayName', 'Données originales');
hold on;
plot(D_interp, Strength_poly, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Ajustement polynomial');
grid on;
xlabel('Vitesse D (km/h)');
ylabel('Strength');
title('Ajustement polynomial de Strength en fonction de D');
legend;
hold off;