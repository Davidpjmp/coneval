###############################################################################-
# Práctica X
# Mapas a mano
# Autor:Ana Escoto
# Fecha: 03-11-2022
############################################################################# -

if (!require("pacman")) install.packages("pacman") # instala pacman si se requiere
pacman::p_load(cowplot, googleway, ggplot2, ggrepel, 
ggspatial, lwgeom, sf, rnaturalearth, rnaturalearthdata) 


# Mapa mundial 

world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
class(world)

sfdf_mexico <- ne_countries(country = 'mexico', returnclass = "sf")


world %>% 
  ggplot() +
  geom_sf() +
  theme_void()


sfdf_mexico %>% 
  ggplot()+
  geom_sf() +
  theme_void() # no es la mejor capa de México :-p

## ggspatial

ggplot(data = world) +
  geom_sf() +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  coord_sf(xlim = c(-102.15, -74.12), ylim = c(7.65, 33.97)) +
  theme_minimal()



## https://www.inegi.org.mx/app/mapas/


gd_mx <- read_sf("datos/mx_maps/00ent.shp")

gd_mx %>% 
  ggplot()+
  geom_sf()+ 
  coord_sf(crs = 2154)

