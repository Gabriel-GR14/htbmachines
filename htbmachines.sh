#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c (){
  echo -e "\n\n [!] Saliendo...\n"
  tput cnorm && exit 1
}

# Ctrl+C 
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por nombre de máquinas${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de una máquina${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por la el sistema operativo${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por skills${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de la resolución de la máquina${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n"
}

function updateFile(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, lo tienes todo al dia ;)${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${redColour}[!]${endColour}${grayColour} Se han encontrado actualizaciones disponibles${endColour}"
      sleep 1

      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actu alizados${endColour}"
    fi
  
    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"
 
  
  machineName_checker=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/: / -> /' | awk '{sub(/^([^->]+->)/, "\033[1;32m&\033[0m")}1')

  if [ "$machineName_checker" ]; then

    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/: / -> /' | awk '{sub(/^([^->]+->)/, "\033[1;32m&\033[0m")}1'

  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi
}

function searchIP(){
  ipAdress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La máquina correspondiente a la IP ${endColour}${blueColour}$ipAdress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}\n"

  else  
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi  
}

function searchYT(){
  machineName="$1"

  youtubelink=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | sed 's/: / -> /' | grep youtube | awk 'NF{print $NF}')
  
  if [ "$youtubelink" ];then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para la máquina está en el siguiente enlace:${endColour}${blueColour} $youtubelink${endColour}\n"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi    
}

function searchDifficulty(){
  difficulty="$1"
  
  results_check=$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',') 

  if [ "$results_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando las máquinas que posee un nivel de dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour}:${endColour}\n"
    printf "%s\n" $results_check | while read line; do
    echo -e "${grayColour}${line}${endColour}"
    done | column
  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}\n"
  fi 
}

function searchOS(){
  os="$1"
 
  os_check=$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')

  if [ "$os_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando las máquinas con el sistema operativo${endColour}${blueColour} $os${endColour}${grayColour}:${endColour}\n"
    printf "%s\n" $os_check | while read line; do 
    echo -e "${grayColour}${line}${endColour}"
    done | column 
  else
    echo -e "\n${redColour}[!] El sistema operativo indicado no existe${endColour}\n"
  fi

}

function searchOSDifficulty(){
  difficulty="$1"
  os="$2"

  OSDifficulty_check=$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')

 if [ "$OSDifficulty_check" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas de dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} y los sistemas operativos que sean${endColour}${purpleColour} $os${endColour}${grayColour}:${endColour}\n"
  printf "%s\n" $OSDifficulty_check | while read line; do 
  echo -e "${grayColour}${line}${endColour}"
  done | column  
  else
  echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrectos${endColour}\n"
  fi
}

function searchSkill(){
  skill="$1"

  skill_check=$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')

  if [ "$skill_check" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquinas con la skill:${endColour}${blueColour} $skill${endColour}\n"
  printf "%s\n" $skill_check | while read line; do 
  echo -e "${grayColour}${line}${endColour}"
  done | column
  else 
  echo -e "\n${redColour}[!] No se ha encontrando ninguna máquina con la skill indicada${endColour}\n"
  fi
}

# Indicadores 
declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0 
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAdress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFile
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
  searchYT $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  searchOS $os
elif [ $parameter_counter -eq 7 ]; then
  searchSkill "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  searchOSDifficulty $difficulty $os
else
  helPanel
fi
