import numpy as np
import rasterio
import geopandas as gpd
import matplotlib.pyplot as plt

from rasterio.features import shapes
from rasterio.transform import from_gcps
from rasterio.control import GroundControlPoint
from shapely.geometry import shape
from rasterio.features import shapes
from rasterio.transform import Affine
from shapely.geometry import shape
from pyproj import CRS

# Nacteni binarni masky lesa
with rasterio.open('les_maska.png') as src:
    maska = src.read(1)

# Prevod masky na binarni hodnoty
les = maska > 0

# Prevod souvislych lesnich ploch na polygony
polygony = []

for geometrie, hodnota in shapes(
    les.astype("uint8"),
    mask=les,
    transform=Affine.identity()
):
    polygony.append(shape(geometrie))

print("Pocet polygonu lesa:", len(polygony))   

# Zobrazeni puvodni mapy
mapa = plt.imread("TM25_sk1.jpg")

fig, ax = plt.subplots(figsize=(12, 12))
ax.imshow(mapa)

ax.set_title("Vyber vlicovacich bodu")
ax.set_xlabel("Pixelova souradnice x")
ax.set_ylabel("Pixelova souradnice y")

plt.show()
