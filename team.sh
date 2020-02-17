#!/bin/bash

echo ""
TEAM_SERVER=$(cat SADB.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1} {print $2}')

TEAM_VSCAN=$(cat vscan_reports*.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1} {print $13}')

TEAM_APAR_OS=$(cat aparrecords.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1}{if ($28 == "os"){print $5}}')

TEAM_APAR_MW=$(cat aparrecords.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1}{if ($28 == "application"){print $5}}')

TEAM_TTT=$(cat TTT_Tickets.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1} {print $9}')

#definir totales
TOTAL_SERVER=0
TOTAL_VSCAN=0
TOTAL_APAR_OS=0
TOTAL_APAR_MW=0
TOTAL_TEAM=0

echo "                       ,   SERVER   ,    VULN.   ,   APAR OS  ,   APAR MW   ,   TICKETS "
echo "        NAME"

function team {
        #definir numeros
        THIS_SERVER=$(printf "$TEAM_SERVER" | grep -i $1 | grep -i $2 | grep -i $3 | wc -l)
        THIS_VSCAN=$(printf "$TEAM_VSCAN" | grep -i $1 | grep -i $2 | grep -i $3 | wc -l)
        THIS_APAR_OS=$(printf "$TEAM_APAR_OS" | grep -i $1 | grep -i $2 | grep -i $3 | wc -l)
        THIS_APAR_MW=$(printf "$TEAM_APAR_MW" | grep -i $1 | grep -i $2 | grep -i $3 | wc -l)
        THIS_TEAM=$(printf "$TEAM_TTT" | grep -i $1 | grep -i $2 | grep -i $3 | wc -l)

        #imprimir nombres
        printf "%10s %s" $1
        printf "%-12s" "$2"
        printf ","

        #imprimir numeros
        printf "%4s %s" "$THIS_SERVER" ","
        printf "%4s %s" "$THIS_VSCAN" ","
        printf "%4s %s" "$THIS_APAR_OS" ","
        printf "%4s %s" "$THIS_APAR_MW" ","
        printf "%4s %s" "$THIS_TEAM" ","
        printf "\n"

        #"%4s %s" significa que el valor tendrá 4 espacios a la derecha de limite para crecer
        #"%4s %s" afecta toda la sentencia del printf, por lo que los saltos de linea (\n) van en un printf aparte

        #definir totales
        TOTAL_SERVER=$(($TOTAL_SERVER + $THIS_SERVER))
        TOTAL_VSCAN=$(($TOTAL_VSCAN + $THIS_VSCAN))
        TOTAL_APAR_OS=$(($TOTAL_APAR_OS + $THIS_APAR_OS))
        TOTAL_APAR_MW=$(($TOTAL_APAR_MW + $THIS_APAR_MW))
        TOTAL_TEAM=$(($TOTAL_TEAM + $THIS_TEAM))
}

team Nombre Apellido mexico
team Nombre Apellido mexico
team Nombre Apellido mexico
team Nombre Apellido mexico
team Nombre Apellido mexico

printf  "       TOTAL           ,"
printf "%4s %s" "$TOTAL_SERVER" ","
printf "%4s %s" "$TOTAL_VSCAN" ","
printf "%4s %s" "$TOTAL_APAR_OS" ","
printf "%4s %s" "$TOTAL_APAR_MW" ","
printf "%4s %s" "$TOTAL_TEAM"

printf "\n"
