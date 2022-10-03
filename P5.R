###############################################################################-
# Práctica 5
# Fusionado de conjuntos de doaso
# Autor:Ana Escoto
# Fecha: 03-10-2022
############################################################################# -


## Importación bases ENIGH 2020 ----

# Vamos a trabajar con esta base que tiene elementos separados.

# Paquetes ----
if (!require("pacman")) install.packages("pacman") # instala pacman si se requiere
pacman::p_load(skimr,tidyverse, magrittr, # sobretodo para dplyr
               haven, readxl, #importación
               janitor, 
               sjlabelled) 


# datos ----

# Hoy cargamos la versión seccionada de la base

viviendas <- haven::read_dta("datos/viviendas2020.dta")
hogares <- haven::read_dta("datos/hogares2020.dta")
poblacion<- haven::read_dta("datos/poblacion2020.dta")

## Juntando bases ----
# 
# Muchas bases de datos están organizadas en varias tablas. 
# La ventaja de la programación por objetos de R, nos permite tener las bases
# cargadas en nuestro ambiente y llamarlas y juntarlas cuando sea necesario.


dim(viviendas)
names(viviendas[,1:15])
dim(hogares)
names(hogares[,1:15])
dim(poblacion)
names(poblacion[,1:15])


# Para juntar bases usamos el comando "merge"

# En "by" ponemos el id, correspondiente a la variable o variables que forman el
# id, entrecomillado. Cuando estamos mezclando bases del mismo nivel de análisis
# el id es igual en ambas bases. Cuando estamos incoporando información de bases
# de distinto nivel debemos escoger

# En general ponemos el id de la base de mayor nivel. En este caso, sabemos que a
# una vivienda corresponde más de un hogar. Tal como revisamos nuestra documentación,
# sabemos que el id de la tabla "viviendas" es "folioviv"


merge_data<- merge(viviendas,
                   hogares,
                   by="folioviv")

# Revisemos la base creada


names(merge_data)
dim(merge_data)


## Merge con id compuesto

viviendas %>% 
  janitor::get_dupes(folioviv)



hogares %>% 
  janitor::get_dupes(c(folioviv, foliohog))


poblacion %>% 
  janitor::get_dupes(c(folioviv, foliohog, numren))

merge_data2<- merge(hogares, poblacion, by=c("folioviv", "foliohog"))
dim(merge_data2)

#Revisemos la base

merge_data2 %>% 
  tail()


## Bases de distinto tamaño ----

# Hasta ahorita hemos hecho merge que son de unidades de distinto nivel y son incluyentes. A veces tenemos bases de datos que son de distinto tamaño y del mismo nivel.
# A veces las dos aportan casos y a veces aportan variables, y a veces, las dos aportan las dos cosas.
# Vamos a revisar qué pasaría si quisiéramos incorporar la información los ingresos


rm(merge_data, merge_data2) # botamos otros ejemplos

ingresos<- haven::read_dta("datos/ingresos2020.dta")

#Esta base tiene otro ID

ingresos %>% 
  janitor::get_dupes(c(folioviv, foliohog, numren, clave))

#¿Cuántas claves de ingreso hay?
  
ingresos %>% 
  tabyl(clave)


ingresos_sueldos<-ingresos %>% 
  filter(clave=="P001") 

dim(ingresos_sueldos)


# Vamos a hacer el primer tipo de merge

merge_data3<-merge(poblacion,
                   ingresos_sueldos, 
                   by=c("folioviv", "foliohog", "numren"))
dim(merge_data3)

 
# ¡La base nueva no tiene a todas las observaciones, solo la que tiene en la base
# más pequeña! Tenemos sólo 99,9992 individuos.

## Cuatro formas de hacer un fusionado ----

# En realidad hay cuatro formas de hacer un "merge"

### Casos en ambas bases ----

# Por default, el comando tiene activado la opción "all = FALSE", 
# que nos deja los datos de ambas bases comunes. (tipo una intersección)

merge_data3<-merge(poblacion, ingresos_sueldos, by=c("folioviv", "foliohog", "numren"), all = F)
dim(merge_data3)


### Todos los casos

# Si cambiamos la opción "all = TRUE", que nos deja los datos comunes a ambas bases. (como una unión)


merge_data3<-merge(poblacion, 
                  ingresos_sueldos, 
                  by=c("folioviv", "foliohog", "numren"), all = T)
dim(merge_data3)


### Casos en la base 1

# Si queremos quedarnos con todos los datos que hay en la primera base, x,
# vamos a usar a opción all.x = TRUE.


merge_data3<-merge(poblacion,
                   ingresos_sueldos, 
                   by=c("folioviv", "foliohog", "numren"), 
                   all.x  = TRUE)
dim(merge_data3)


### Casos de la base 2

# Notamos que hoy sí tenemos los datos de toda la población y hay missings en las
# variables aportadas por la base de trabajo
# 
# Si queremos lo contrario, quedarnos con los datos aportados por la segunda base,
# y, vamos a usar la opción all.y=TRUE


merge_data3<-merge(poblacion, 
                   ingresos_sueldos, 
                   by=c("folioviv", "foliohog", "numren"), 
                   all.y  = TRUE)
dim(merge_data3)


## Las cuatro formas en `dplyr` ----

# El caso 1:
  
merge_data3<-dplyr::inner_join(poblacion,
                               ingresos_sueldos, 
                               by=c("folioviv", "foliohog", "numren"))
dim(merge_data3)

# El caso 2:
  
merge_data3<-dplyr::full_join(poblacion,
                              ingresos_sueldos, 
                              by=c("folioviv", "foliohog", "numren"))
dim(merge_data3)

# El caso 3:
  
merge_data3<-dplyr::left_join(poblacion,
                              ingresos_sueldos,
                              by=c("folioviv", "foliohog", "numren"))
dim(merge_data3)



# El caso 4:
  
merge_data3<-dplyr::right_join(poblacion, ingresos_sueldos, by=c("folioviv", "foliohog", "numren"))
dim(merge_data3)


# También se puede usar con pipes, cualquier opción de dplyr

merge_data3<-poblacion %>% # pongo el conjunto que será la "izquierda
  dplyr::right_join(ingresos_sueldos, by=c("folioviv", "foliohog", "numren"))

dim(merge_data3)



## Práctica

# - Pegue a la última base la información de los hogares y las viviendas.