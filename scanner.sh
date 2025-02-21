#!/bin/bash

# Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n${redColour}[!] Saliendo..${endColour}\n\n"  
  exit 1
}

trap ctrl_c INT

# Variables Globales

declare -i flag=0

function helppanel(){
  echo -e "\n${blueColour}[+]${endColour} ${grayColour}Panel de ayuda: ${purpleColour}-h${endColour} ${grayColour}/ Ejecutar el script como sudo${endColour}"
  echo -e "${blueColour}[+]${endColour} ${grayColour}Escanear los puertos abiertos de una IP:${endColour} ${purpleColour}-i${endColour} ${greenColour}192.168.x.x ${endColour}"
  echo -e "${blueColour}[+]${endColour} ${grayColour}Copiar puertos en el portapapeles:${endColour} ${purpleColour}-c${endColour}"
  echo -e "${blueColour}[+] ${endColour}${grayColour}Realizar un escaneo -sCV con nmap con los puertso descubiertos: ${endColour}${purpleColour}-s${endColour}\n\n"
}

function ipTarget(){
  targetip="$1"
  echo -e "\n${blueColour}[+]${endColour} ${grayColour}Iniciando el escaneo sobre el host: ${endColour}${greenColour}$targetip${endColour}\n\n"
  (sudo nmap -p- --open -sS --min-rate 5000 -vvv -Pn -n $targetip -oG Allports) &>/dev/null
  ports="$(cat ./Allports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
  echo -e "\t${blueColour}[+] ${endColour}${grayColour}Puertos abiertos: ${endColour}${turquoiseColour}$ports${endColour}\n"
  rm Allports
}

function ipTarget_clip(){
  targetip="$1" 
  echo -e "\n${blueColour}[+] ${endColour}${grayColour}Iniciando el escaneo sobre el host: ${endColour}${greenColour}$targetip${endColour}\n\n"
  (sudo nmap -p- --open -sS --min-rate 5000 -vvv -Pn -n $targetip -oG Allports) &>/dev/null
  ports="$(cat ./Allports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
  echo -e "\t${blueColour}[+]$endColour ${grayColour}Puertos abiertos: ${endColour}${turquoiseColour}$ports${endColour}\n"  >> extractPorts.tmp
  echo -e "${turquoiseColour}$ports$endColour" | tr -d '\n' | xclip -sel clip
  echo -e "${blueColour}[+]${endColour} ${grayColour}Puertos copiados en el portapapeles${endColour}\n"  >> extractPorts.tmp
  cat extractPorts.tmp; rm extractPorts.tmp; rm Allports
}

function ipTarget_scan(){
  targetip="$1" 
  echo -e "\n${blueColour}[+]${endColour} ${grayColour}Iniciando el escaneo sobre el host: ${endColour}${greenColour}$targetip${endColour}\n\n"
  (sudo nmap -p- --open -sS --min-rate 5000 -vvv -Pn -n $targetip -oG Allports) &>/dev/null
  ports="$(cat ./Allports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
  echo -e "\t${blueColour}[+]${endColour} ${grayColour}Puertos abiertos:${endColour} ${turquoiseColour}$ports${endColour}\n"  >> extractPorts.tmp
  echo -e "${turquoiseColour}$ports${endColour}" | tr -d '\n' | xclip -sel clip
  echo -e "${blueColour}[+]${endColour} ${grayColour}Puertos copiados en el portapapeles${endcolour}\n"  >> extractPorts.tmp
  cat extractPorts.tmp; rm extractPorts.tmp; rm Allports 
  echo -e "\n${blueColour}[+]${endColour} ${grayColour}Iniciando -sCV de puertos${endColour} ${turquoiseColour}$ports${endColour}${grayColour} abiertos${endColour}\n"
  nmap -p$ports -sCV $targetip -oN targeted
  echo -e "\n\n${blueColour}[+]${endColour} ${grayColour}Escaneo guardado en targeted!${endColour}\n"
}


while getopts "hci:s" arg; do
  case $arg in
    h)let flag=6;;
    c)let flag+=1;;
    i) targetip=$OPTARG;let flag+=1;;
    s)let flag+=2;;
  esac
done
if [ $flag -eq 1 ]; then
  ipTarget $targetip
elif [ $flag -eq 2 ]; then
  ipTarget_clip $targetip
elif [ $flag -eq 3 ]; then
  ipTarget_scan $targetip
elif [ $flag -eq 4 ]; then
  ipTarget_scan $targetip
elif [ $flag -eq 6 ]; then
  helppanel
else 
  echo -e "[!]Uso $0 -h"
fi
