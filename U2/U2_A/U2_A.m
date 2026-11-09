clc, clear all, format long g
% Nacteni mapy
mapa = imread('MMC_sk1.jpg');

% Prevod RGB na odstiny sedi
mapa_gray = rgb2gray(mapa);
mapa_gray = im2double(mapa_gray);


% Volba varianty
varianta = 1;   % 1 = jeden vzor, 2 = prumer peti vzoru


if varianta == 1
%% 1 vzor

 % Výběr vzoru (pouze při prvním spuštění)
 % vzor = imcrop(mapa_gray);
 % imwrite(vzor, 'vzor.png');
 % Načtení uloženého vzoru
  vzor = imread('vzor.png');
  figure(3)
  subplot(2,2,2)
  imshow(vzor)
  title('Vybraný vzor')
 % Prevod na double
    vzor = im2double(vzor);

else
%% Vytvoreni prumerneho vzoru z peti 

% Nacteni puvodniho vzoru
vzor = imread('vzor.png');

% Rozmery puvodniho vzoru
[vyska, sirka] = size(vzor);

% Matice pro pet vzoru
vzory = zeros(vyska, sirka, 5);

% Ulozeni prvniho vzoru
vzory(:,:,1) = im2double(vzor);

% Vyber dalsich ctyr vzoru
for i = 2:5

    figure(1)
    clf
    set(gcf, 'WindowState', 'maximized')

    axes('Position', [0.05, 0.05, 0.90, 0.90])
    imshow(mapa_gray)
    title(sprintf('Vyberte vzor %d z 5', i));

    % Rucni vyber obdelnikove oblasti
    vzor_novy = imcrop;

    % Uprava na stejne rozmery jako puvodni vzor
    vzor_novy = imresize(vzor_novy, [vyska, sirka]);

    % Ulozeni vzoru
    vzory(:,:,i) = im2double(vzor_novy);

end

% Vypocet prumerneho vzoru
vzor = mean(vzory, 3);

% Zobrazeni vsech vzoru


for i = 1:5
    figure(2)
    subplot(2,3,i)
    imshow(vzory(:,:,i))
    title(sprintf('Vzor %d z 5', i));
end

figure(3)
subplot(2,2,2)
imshow(vzor)
title('Prumerny vzor')
end
%% Korelace

% Vypocet obrazove korelace
korelace = normxcorr2(vzor, mapa_gray);

% Zobrazeni korelacni matice
figure(3)
subplot(2,2,3)
imagesc(korelace)
colorbar
title('Obrazová korelace')

% Prah korelace
prah = 0.6;

% Vyhledani lokalnich maxim
maxima = imregionalmax(korelace);

% Vyber maxim nad prahem
nalezy = maxima & (korelace > prah);

% Ziskani souradnic
[y, x] = find(nalezy);

% Pocet nalezenych pozic
pocet = length(x);

fprintf('Počet nalezených pozic: %d\n', pocet);

% Zobrazeni mapy
figure(3)
subplot(2,2,1)
imshow(mapa)
title('Müllerova mapa Čech')

% Zobrazeni nalezu v puvodni mape
figure(4)
imshow(mapa)
hold on

% Rozmery vzoru
[vyska, sirka] = size(vzor);

% Matice pro ulozeni vysledku
souradnice = zeros(pocet, 5);

% Vykresleni ramecku a ulozeni souradnic
for i = 1:pocet

    % Prevod souradnic z korelacni matice
    x0 = x(i) - sirka + 1;
    y0 = y(i) - vyska + 1;

    % Souradnice stredu vzoru
    xs = x0 + (sirka - 1)/2;
    ys = y0 + (vyska - 1)/2;

    % Hodnota korelace
    r = korelace(y(i), x(i));

    % Ulozeni vysledku
    souradnice(i,:) = [x0, y0, xs, ys, r];

    % Vykresleni obdelniku
    rectangle('Position', [x0, y0, sirka, vyska], ...
        'EdgeColor', 'r', 'LineWidth', 1.5);

end

title('Nalezené kostely')
hold off

%% Tabulka vysledku

% Prevod matice na tabulku
vysledky = array2table(souradnice, ...
    'VariableNames', {'X_roh', 'Y_roh', 'X_stred', 'Y_stred', 'Korelace'});

% Zobrazeni tabulky
disp(vysledky)

% Ulozeni do CSV
writetable(vysledky, 'souradnice_kostelu.csv');







