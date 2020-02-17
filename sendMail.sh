#!/bin/bash

mail -s "Metricas semanales" -a resultados.csv correo@hotmail.com < ./resultados.csv
mail -s "Metricas team" -a resultados.csv correo@hotmail.com < ./team.csv

#Enviar files desde la computadora local a un servidor:
#   scp APAR* sergio@servidor.com:/home/sergio/metricas/
