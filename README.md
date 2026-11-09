
# 155YGEI – Geoinformatika

Repozitář obsahuje semestrální úlohy z předmětu **155YGEI Geoinformatika** na Fakultě stavební ČVUT v Praze.

## Úlohy

### U1 – JPEG komprese

Implementace a analýza metod komprese rastrových obrazových dat v prostředí MATLAB.

- Diskrétní kosinová transformace (DCT)
- Diskrétní Fourierova transformace (DFT)
- Haarova vlnková transformace (DWT)
- Porovnání výsledků komprese

### U2 – Vyhledávání objektů v mapách

#### Část A – Obrazová korelace

- Vyhledávání kartografických značek obcí s kostelem v Müllerově mapě Čech pomocí normalizované vzájemné korelace.
- Odstranění vícenásobných detekcí pomocí regionálních maxim.
- Průměrování pěti obrazových vzorů.
- Export nalezených pozic do pixelových souřadnic.

#### Část B – Segmentace lesních ploch

- Segmentace lesních ploch z topografické mapy ČSSR v měřítku 1 : 25 000 pomocí algoritmu k-means.
- Využití barevného prostoru Lab (složky a, b).
- Odstranění nežádoucích objektů pomocí morfologických operací.
- Bonusová segmentace s využitím STD filtru.
- Export pixelových souřadnic lesních ploch.
- Převod výsledné binární masky do polygonové vrstvy GeoPackage v souřadnicovém systému WGS 84 / UTM zone 33N (EPSG:32633).

