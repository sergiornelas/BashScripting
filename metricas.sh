#!/bin/bash

function getServers {
if [[ "$2" == aix ]]; then
 echo "$1" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 == "aix"){print $1}}' | wc -l
elif [[ "$2" == linux ]]; then
  echo "$1" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 == "linux" || $1 == "rhel" || $1 ~ "ubuntu" || $1 ~ "redhat" || $1 ~ "red hat"){print $1}}' | wc -l
elif [[ "$2" == windows ]]; then
  echo "$1" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 ~ "windows"){print $1}}' | wc -l
fi
}

#--------------------INVENTORY---------------------

SADB_INV_TOTAL=$(cat SADB.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1}{if ($2 ~ "mexico"){if ($1 !~ "w3-969" && $1 !~ "bluecloud" && $1 !~ ".podc" && $1 !~ "podbtest" && $7 !~ "bluecloud"){print $3}}}' | grep -v '""')

OTHER=$(($(echo "$SADB_INV_TOTAL" | wc -l) - $(getServers "$SADB_INV_TOTAL" "aix") - $(getServers "$SADB_INV_TOTAL" "linux") - $(getServers "$SADB_INV_TOTAL" "windows")))

printf "\n,,,SADB\n"
printf "\n,,,Inventory\n"
echo ",AIX,Linux,Windows,Other,TOTAL"
echo ,$(getServers "$SADB_INV_TOTAL" "aix"),$(getServers "$SADB_INV_TOTAL" "linux"),$(getServers "$SADB_INV_TOTAL" "windows"),$OTHER,$(echo "$SADB_INV_TOTAL" | wc -l)

#-----------------BIGFIX---------------------------

SADB_BIGFIX_TOTAL=$(cat SADB.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1}{if ($2 ~ "Mexico"){if ($1 !~ "w3-969" && $1 !~ "bluecloud" && $1 !~ ".podc" && $1 !~ "podbtest" && $7 !~ "bluecloud"){print $3","$6}}}' | grep -v '""')

SADB_BIGFIX_TOTAL_INV=$(($(getServers "$SADB_INV_TOTAL" "aix") + $(getServers "$SADB_INV_TOTAL" "linux") + $(getServers "$SADB_INV_TOTAL" "windows")))

SADB_BIGFIX_TOTAL_AIX=$(($(getServers "$SADB_INV_TOTAL" "aix") - $(getServers "$SADB_BIGFIX_TOTAL" "aix")))
SADB_BIGFIX_TOTAL_LINUX=$(($(getServers "$SADB_INV_TOTAL" "linux") - $(getServers "$SADB_BIGFIX_TOTAL" "linux")))
SADB_BIGFIX_TOTAL_WINDOWS=$(($(getServers "$SADB_INV_TOTAL" "windows") - $(getServers "$SADB_BIGFIX_TOTAL" "windows")))

SADB_BIGFIX_TOTAL_BIGFIX=$(($(getServers "$SADB_BIGFIX_TOTAL" "aix") + $(getServers "$SADB_BIGFIX_TOTAL" "linux") + $(getServers "$SADB_BIGFIX_TOTAL" "windows")))
SADB_BIGFIX_TOTAL_TOTAL=$(($SADB_BIGFIX_TOTAL_AIX + $SADB_BIGFIX_TOTAL_LINUX + $SADB_BIGFIX_TOTAL_WINDOWS))

printf "\n,,,BigFix\n"
echo ",Type,AIX,Linux,Windows,TOTAL"
echo ",Inven.,"$(getServers "$SADB_INV_TOTAL" "aix"),$(getServers "$SADB_INV_TOTAL" "linux"),$(getServers "$SADB_INV_TOTAL" "windows"),$SADB_BIGFIX_TOTAL_INV
echo ",BigFix",$(getServers "$SADB_BIGFIX_TOTAL" "aix"),$(getServers "$SADB_BIGFIX_TOTAL" "linux"),$(getServers "$SADB_BIGFIX_TOTAL" "windows"),$SADB_BIGFIX_TOTAL_BIGFIX
echo ",Total",$SADB_BIGFIX_TOTAL_AIX,$SADB_BIGFIX_TOTAL_LINUX,$SADB_BIGFIX_TOTAL_WINDOWS,$SADB_BIGFIX_TOTAL_TOTAL

#-----------------QRADAR---------------------------

#EL ARCHIVO QRADAR DEBE TENER EXACTAMENTE LAS MISMAS FILAS DEL PRINCIPIO (QUE SE ELIMINAN) PARA QUE EL CODIGO FUNCIONE OPTIMAMENTE.
#NO DEBE TENER ESPACIOS VACÍOS LA COLUMNN DE ServerName

SADB_QRADAR=$(cat SADB.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1}{if ($2 ~ "mexico"){if ($1 !~ "w3-969" && $1 !~ "bluecloud" && $1 !~ ".podc" && $1 !~ "podbtest" && $7 !~ "bluecloud"){if($5 !~ /^sl/){if($1 !~ /^wdc/){print $3","$1}}}}}' | cut -f 1 -d '.' | sort | uniq)

QRADAR_REPORT=$(cat Qradar\ Implement\ Report.csv | tail -n+9 | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")";IGNORECASE=1}{print $8}' | grep -v '""')

QRADAR_TOTAL=0
QUITAR_OS_VACIOS=$(echo "$SADB_QRADAR" | awk -F ',' '{print $1}' | grep '""' | wc -l)
QRADAR_AIX=0
QRADAR_LINUX=0
QRADAR_WINDOWS=0

for i in $(echo "$SADB_QRADAR" | awk -F ',' '{print $2}'); do
        VAR=$(echo "$QRADAR_REPORT" | grep -x -c -i "$i")
        QRADAR_OS=$(echo "$SADB_QRADAR" | grep -w "$i" | head -1 | awk -F ',' '{print $1}')

        if [[ $VAR == 0  ]]; then
                let QRADAR_TOTAL=QRADAR_TOTAL+1
                if [[ "${QRADAR_OS,,}" == "aix" ]]; then
                        let QRADAR_AIX=QRADAR_AIX+1
                elif [[ "${QRADAR_OS,,}" == "linux" || "${QRADAR_OS,,}" == "rhel" || "${QRADAR_OS,,}" =~ "ubuntu" || "${QRADAR_OS,,}" =~ "redhat" || "${QRADAR_OS,,}" =~ *'red hat'* ]]; then
                        let QRADAR_LINUX=QRADAR_LINUX+1
                elif [[ "${QRADAR_OS,,}" =~ "windows" ]]; then
                        let QRADAR_WINDOWS=QRADAR_WINDOWS+1
                fi
#               echo "$QRADAR_OS"
        fi
done

QRADAR_OTHER=$(($QRADAR_TOTAL - $QUITAR_OS_VACIOS - $QRADAR_AIX - $QRADAR_LINUX - $QRADAR_WINDOWS))

printf "\n,,,Qradar\n"
echo ",,,OS,Report"
echo ",,,AIX",$QRADAR_AIX
echo ",,,Linux",$QRADAR_LINUX
echo ",,,Windows",$QRADAR_WINDOWS
echo ",,,Other",$QRADAR_OTHER
echo ",,,TOTAL",$(($QRADAR_TOTAL - $QUITAR_OS_VACIOS - $QRADAR_OTHER))

#------------------APARS---------------------

printf "\n,,,APARS\n\n"

function apars {
APAR=$(cat APAR\ "$1" | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1}{if ($6 !~ "w3-969" && $6 !~ "bluecloud" && $6 !~ ".podc" && $6 !~ "podbtest"){print $11}}' | grep -v '""')

APAR_CRITICAL=$(echo "$APAR" | grep -i critical | wc -l)
APAR_HIGH=$(echo "$APAR" | grep -i high | wc -l)
APAR_MEDIUM=$(echo "$APAR" | grep -i medium | wc -l)
APAR_LOW=$(echo "$APAR" | grep -i low | wc -l)

echo -n  ",,,$1" | sed 's/.csv//g'
printf "\n"
echo ",,,Severity,Count"
echo ",,,Critical",$APAR_CRITICAL
echo ",,,High",$APAR_HIGH
echo ",,,Medium",$APAR_MEDIUM
echo ",,,Low",$APAR_LOW
echo ",,,TOTAL",$((APAR_CRITICAL + APAR_HIGH + APAR_MEDIUM + APAR_LOW))
printf "\n"
}

apars "Overdue.csv"
apars "Pending.csv"
apars "MW.csv"

#------------------HC---------------------

printf "\n,,,HC\n\n"

HC=$(cat HC.csv | sed 1d | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")";IGNORECASE=1}{if ($18 ~ "mexico"){if ($2 !~ "w3-969" && $2 !~ "bluecloud" && $2 !~ ".podc" && $2 !~ "podbtest" && $6 !~ "bluecloud"){print $5","$13}}}')

function getTicketHC {
case $2 in
aix)
if [[ "$1" == complete ]]; then
echo "$HC" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 == "aix"){if ($2 == "closed"){print $1}}}' | wc -l

elif [[ "$1" == allocated ]]; then
echo "$HC" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 == "aix"){if ($2 != "closed"){print $1}}}' | wc -l
fi
;;
linux)
if [[ "$1" == complete ]]; then
echo "$HC" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 == "linux" || $1 == "rhel" || $1 ~ "ubuntu" || $1 ~ "redhat" || $1 ~ "red hat"){if ($2 == "closed"){print $1}}}' | wc -l

elif [[ "$1" == allocated ]]; then
echo "$HC" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 == "linux" || $1 == "rhel" || $1 ~ "ubuntu" || $1 ~ "redhat" || $1 ~ "red hat"){if ($2 != "closed"){print $1}}}' | wc -l
fi
;;
windows)
if [[ "$1" == complete ]]; then
echo "$HC" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 ~ "windows"){if ($2 == "closed"){print $1}}}' | wc -l

elif [[ "$1" == allocated ]]; then
echo "$HC" | awk -F ',' 'BEGIN{IGNORECASE=1}{if ($1 ~ "windows"){if ($2 != "closed"){print $1}}}' | wc -l
fi
;;
esac
}

HC_COMPLETE=$(($(getTicketHC "complete" "aix")+$(getTicketHC "complete" "linux"
)+$(getTicketHC "complete" "windows")))

HC_ALLOCATED=$(($(getTicketHC "allocated" "aix")+$(getTicketHC "allocated" "linux"
)+$(getTicketHC "allocated" "windows")))

HC_TOTAL=$(($HC_COMPLETE + $HC_ALLOCATED))

echo ",OS,Complete,Allocated"
echo ",AIX",$(getTicketHC "complete" "aix"),$(getTicketHC "allocated" "aix")
echo ",Linux",$(getTicketHC "complete" "linux"),$(getTicketHC "allocated" "linux")
echo ",Windows",$(getTicketHC "complete" "windows"),$(getTicketHC "allocated" "windows")
echo ",TOTAL",$HC_COMPLETE,$HC_ALLOCATED,$HC_TOTAL
printf "\n"

#--------------VULNERABILIDADES------------

printf "\n,,,VULN\n\n"

#Si la fecha de hoy pasa de lunes o martes (mié, jue, vie, sáb, dom)
if [[ $(date +%Y%m%d) < $(date -dtuesday +%Y%m%d) ]]; then
        #la fecha a calcular será el martes pasado
        DATETODAY=$(date -dlast-tuesday +%Y%m%d)
else
        #la fecha a calcular será este martes (si se ejecuta el código lunes o martes)
        DATETODAY=$(date -dtuesday +%Y%m%d)
fi

#VSCAN=$(cat vscanNew.csv | sed 1d | sed 's/+\AC0//g' | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1} {if($2 ~ "mexico"){if ($1 !~ "w3-969" && $1 !~ "bluecloud" && $1 !~ "podbtest" && $1 !~ ".podc"){print $3", "$4}}}')

VSCAN=$(cat vscan_reports*.csv | sed 1d | sed 's/+\AC0//g' | awk -F ',' 'BEGIN{FPAT="([^,]*)|(\"[^\"]*\")"; IGNORECASE=1} {if($13 ~ "mexico"){if ($2 !~ "w3-969" && $2 !~ "bluecloud" && $2 !~ "podbtest" && $2 !~ ".podc"){print $19", "$26}}}' | tr -d '"')

VSCAN_HIGH=0
VSCAN_LOW=0
VSCAN_MEDIUM=0
VSCAN_OVERDUE=0
VSCAN_NO_OVERDUE=0

#2
#función toma como parámetro cada fila de VSCAN columna 2 (fecha) {10/22/2019}
function getStatus {

	#Quitar los diagonales a DATESORT y acomoda fecha {20191022}
        DATESORT_DIA="$(echo $1 | awk -F"/" '{print $2}')"
        DATESORT_MES="$(echo $1 | awk -F"/" '{print $1}')"
        DATESORT_ANNIO="$(echo $1 | awk -F"/" '{print $3}')"

        #Comprobar si los días o meses tienen el formato correcto (9 -> 09)
        if [[ $(echo "${#DATESORT_DIA}") -lt 2 ]]; then
                DATESORT_DIA="$(echo $1 | awk -F"/" '{print '0'$2}')"
        fi
        if [[ $(echo "${#DATESORT_MES}") -lt 2 ]]; then
                DATESORT_MES="$(echo $1 | awk -F"/" '{print '0'$1}')"
        fi

        #DATESORT="$(echo $1 | awk -F"/" '{print $3$1$2}')"

        DATESORT=$DATESORT_ANNIO$DATESORT_MES$DATESORT_DIA

        VSCAN_SEVERITY="$(echo "$i" | awk -F ',' '{printf $1}')"
        #si 20191022 NO es más grande o igual que la fecha de hoy {20191106}
        if [[ ! "$DATESORT" -ge "$DATETODAY" ]]; then
                let VSCAN_OVERDUE=VSCAN_OVERDUE+1
                if [[ "${VSCAN_SEVERITY,,}" =~ "low" ]]; then
                        let VSCAN_LOW=VSCAN_LOW+1
                elif [[ "${VSCAN_SEVERITY,,}" =~ "medium" ]]; then
                        let VSCAN_MEDIUM=VSCAN_MEDIUM+1
                elif [[ "${VSCAN_SEVERITY,,}" =~ "high" ]]; then
                        let VSCAN_HIGH=VSCAN_HIGH+1
                fi
        else
                #en caso quieras saber los que no son overdue
                let VSCAN_NO_OVERDUE=VSCAN_NO_OVERDUE+1
        fi
}

IFS=$'\n';

#1)
#i = Por cada fila de VSCAN
for i in $(echo "$VSCAN"); do
        #función toma como parámetro cada fila de VSCAN columna 2 (fecha) {10/22/2019}
        getStatus $(echo $i | awk -F ',' '{print $2}' | cut -d" " -f2)
done

#echo ",,Vscan overdue"
echo ",,Severity,Count"
echo ",,High",$VSCAN_HIGH
echo ",,Medium",$VSCAN_MEDIUM
echo ",,Low",$VSCAN_LOW
echo ",,TOTAL",$VSCAN_OVERDUE
