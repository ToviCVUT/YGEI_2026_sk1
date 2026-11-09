
clc, clear all, format long g

%% 1. Nacteni mapy a priprava barevnych prostoru

% Nacteni puvodni topograficke mapy
mapa = imread('TM25_sk1.jpg');

% Rozdeleni obrazu na jednotlive RGB kanaly
R = double(mapa(:,:,1));
G = double(mapa(:,:,2));
B = double(mapa(:,:,3));

% Prevod RGB do HSV
mapa_hsv = rgb2hsv(mapa);

% Rozdeleni HSV kanalu
H = mapa_hsv(:,:,1);  % Barevny odstin
S = mapa_hsv(:,:,2);  % Sytost
V = mapa_hsv(:,:,3);  % Jasova hodnota

% Prevod RGB do Lab
mapa_lab = rgb2lab(mapa);

% Rozdeleni Lab kanalu
L = mapa_lab(:,:,1);  % Svetlost
a = mapa_lab(:,:,2);  % Zelena - cervena
b = mapa_lab(:,:,3);  % Modra - zluta


%% 2. Segmentace k-means

% Vyber barevneho prostoru
varianta = 2;  % 1 = Lab, 2 = Lab (a,b), 3 = HSV

rng(1)

if varianta == 1
    % Vsechny tri kanaly Lab
    vstup = mapa_lab;

elseif varianta == 2
    % Pouze barevne kanaly a, b
    vstup = cat(3, a, b);

elseif varianta == 3
    % Barevny prostor HSV
    vstup = mapa_hsv;
end

% Segmentace zvoleneho barevneho prostoru
[pixely, stredy] = imsegkmeans(single(vstup), 3);

%% 3. Vizualizace segmentace

% Zobrazeni vsech clusteru ruznymi barvami
figure(1)
imshow(label2rgb(pixely))
title('Segmentace k-means')

% Samostatne zobrazeni jednotlivych clusteru
figure(2)

for i = 1:3
    subplot(2,3,i)
    imshow(pixely == i)
    title(['Cluster ', num2str(i)])
end


%% 4. Barevne zvyrazneni clusteru na puvodni mape

figure(4)

for i = 1:3
    subplot(2,3,i)

    % Zobrazeni puvodni mapy
    imshow(mapa)
    hold on

    % Vytvoreni binarni masky aktualniho clusteru
    maska = pixely == i;

    % Vytvoreni zeleneho RGB prekryvu
    h = imshow(cat(3, zeros(size(maska)), ...
                    ones(size(maska)), ...
                    zeros(size(maska))));

    % Nastaveni pruhlednosti prekryvu podle masky
    set(h, 'AlphaData', 0.5 * double(maska))

    title(['Cluster ', num2str(i)])
    hold off
end


%% 5. Vytvoreni binarni masky lesnich ploch

% Spojeni clusteru 
% 1 = vybrany pixel lesa, 0 = ostatni plochy
 les = (pixely == 1); % | (pixely == 5);

% Odstraneni souvislych bilych objektu mensich nez 50 px
les_cisty = bwareaopen(les, 50);


%% 6. Vyplneni malych uzavrenych der

% Vyplneni vsech uzavrenych cernych der
les_vyplneny = imfill(les_cisty, 'holes');

% % Zjisteni pixelu, ktere funkce imfill vyplnila
% diry = les_vyplneny & ~les_cisty;
% 
% % Zachovani pouze der o velikosti alespon 51 px
% velke_diry = bwareaopen(diry, 51);
% 
% % Odecteni velkych der od vyplnene masky
% les_vysledek = les_vyplneny & ~velke_diry;


%% 7. Porovnani vysledku vyplnovani der

% figure(7)
% imshow(les_vysledek)
% title('Vycistena maska lesa')
% 
% figure(9)
% subplot(1,2,1)
% imshow(les_cisty)
% title('Pred imfill')
% 
% subplot(1,2,2)
% imshow(les_vyplneny)
% title('Po imfill')


%% 8. Morfologicke uzavreni

% Strukturni element - disk o polomeru 1 pixel
se = strel('disk', 2);
se2 = strel('disk', 5);

% Uzavreni uzkych mezer pomoci dilatace a eroze
les_uzavreny = imclose(les_vyplneny, se);
les_uzavreny = imopen(les_uzavreny, se2);

% % Porovnani pred a po morfologickem uzavreni
% figure(8)
% 
% subplot(1,2,1)
% imshow(les_vyplneny)
% title('Pred uzavrenim')
% 
% subplot(1,2,2)
% imshow(les_uzavreny)
% title('Po uzavreni')

%% 9. Vytvoreni matice pixelovych souradnic

% Vyhledani pixelu lesnich ploch
[y, x] = find(les_uzavreny);

% Vytvoreni matice souradnic [x, y]
souradnice = [x, y];
writematrix(souradnice, 'souradnice_lesa.csv');

%% 10. Kontrola pixelovych souradnic

figure(11)
imshow(mapa)
hold on

plot(x, y, 'r.', 'MarkerSize', 1)

title('Kontrola pixelovych souradnic lesa')
hold off

%% 11. Export masky lesa pro Python

imwrite(les_uzavreny, 'les_maska.png');


%% BONUS 1 - Segmentace pomoci STD filtru

% 1. Prevod mapy do odstinu sedi
mapa_gray = rgb2gray(mapa);

% 2. Vypocet lokalni smerodatne odchylky
mapa_std = stdfilt(mapa_gray, true(3));

% 3. Normalizace slozek
a_norm = rescale(a);
b_norm = rescale(b);
std_norm = rescale(mapa_std);

% 4. Spojeni barevnych a texturovych informaci
vstup_std = cat(3, a_norm, b_norm, std_norm);

% 5. Segmentace k-means
rng(1)
[pixely_std, stredy_std] = imsegkmeans(single(vstup_std), 3);


%% 2. Vizualizace segmentace STD

figure(12)
imshow(label2rgb(pixely_std))
title('Segmentace Lab (a,b) + STD')

% Samostatne zobrazeni jednotlivych clusteru
figure(13)

for i = 1:3
    subplot(2,3,i)
    imshow(pixely_std == i)
    title(['Cluster ', num2str(i)])
end


%% 3. Barevne zvyrazneni clusteru na puvodni mape

figure(14)

for i = 1:3
    subplot(2,3,i)

    imshow(mapa)
    hold on

    maska_std = pixely_std == i;

    h = imshow(cat(3, zeros(size(maska_std)), ...
                    ones(size(maska_std)), ...
                    zeros(size(maska_std))));

    set(h, 'AlphaData', 0.5 * double(maska_std))

    title(['Cluster ', num2str(i)])
    hold off
end


%% 4. Vytvoreni binarni masky lesnich ploch

% Vyber clusteru predstavujiciho les
les_std = (pixely_std == 3);

% Odstraneni souvislych bilych objektu mensich nez 50 px
%les_cisty_std = bwareaopen(les_std, 50);


%% 5. Vyplneni uzavrenych der

% Vyplneni vsech uzavrenych cernych der
les_vyplneny_std = imfill(les_std, 'holes');


%% 6. Morfologicke upravy

% Stejne strukturni elementy jako u puvodni segmentace
se_std = strel('disk', 2);
se2_std = strel('disk', 5);

% Morfologicke uzavreni
les_uzavreny_std = imclose(les_vyplneny_std, se_std);

% Morfologicke otevreni
les_uzavreny_std = imopen(les_uzavreny_std, se2_std);



%% 7. Porovnani puvodni a bonusove segmentace

figure(16)

subplot(1,2,1)
imshow(les_uzavreny)
title('Segmentace Lab (a,b)')

subplot(1,2,2)
imshow(les_uzavreny_std)
title('Segmentace Lab (a,b) + STD')


