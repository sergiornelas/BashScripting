#!/bin/bash

mail -s "Metricas semanales" -a resultados.csv correo@hotmail.com < ./resultados.csv
mail -s "Metricas team" -a resultados.csv correo@hotmail.com < ./team.csv