# HTB Machines Lookup Script 🖥

Este es un script en Bash que permite consultar información de máquinas de Hack The Box (HTB) por nombre, IP, dificultad, sistema operativo, skill y más.

Inspirado por el proyecto de [s4vitar](https://github.com/s4vitar), adaptado y comprendido en profundidad para aprendizaje personal y mejora continua.

---

## ¿Qué hace este script?

Permite automatizar búsquedas de máquinas HTB usando diferentes parámetros desde la terminal.

---

## Opciones disponible

-u Descargar o actualizar archivos necesarios
-i Buscar por dirección IP
-m Buscar por nombre de máquinas
-d Buscar por la dificultad de una máquina
-o Buscar por el sistema operativo
-s Buscar por skills
-y Obtener link de la resolución de la máquina
-h Mostrar este panel de ayuda

---

## Ejemplos de uso

```bash
./htbmachines.sh -u
# Actualiza la base de datos local

./htbmachines.sh -i 10.10.10.238
# Devuelve la máquina correspondiente a esa IP

./htbmachines.sh -m SteamCloud
# Muestra toda la info detallada de esa máquina

./htbmachines.sh -d Media -o Windows
# Lista máquinas de dificultad Media que usen Windows

./htbmachines.sh -s "server side request"
# Busca máquinas que involucren esa skill

./htbmachines.sh -y Monitors
# Devuelve el link al video de resolución en YouTube
