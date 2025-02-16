#!/bin/bash

# Configuración de terminal para leer teclas de flecha
configure_terminal() {
    # Guardar configuración actual
    old_settings=$(stty -g)
    # Configurar terminal para leer teclas sin Enter
    stty -icanon -echo
}

# Restaurar configuración original de terminal
restore_terminal() {
    stty $old_settings
}

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Variables globales
PLAYER_HP=100
PLAYER_MP=50
PLAYER_X=10
PLAYER_Y=10
CURRENT_LOCATION="midgar"
INVENTORY=()
SELECTED_CHARACTER=""

# Arte ASCII de los personajes
CLOUD_ASCII="
    /\\____/\\
   /  o  o  \\
  ( ==  ^  == )
   )         (
  (           )
   |  |---|  |
   |__|   |__|"

TIFA_ASCII="
    /\\___/\\
   (  o o  )
   (  =^=  )
    (    )
   /|__|__|\\ 
  |   |  |   |"

BARRET_ASCII="
    /\\___/\\
   |  o o  |
   |   ^   |
   |  ===  |
   |_______|"

# Función para leer teclas de flecha
read_arrow_key() {
    read -rsn1 mode
    if [[ $mode == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            '[A') echo "UP" ;;    # Flecha arriba
            '[B') echo "DOWN" ;;  # Flecha abajo
            '[C') echo "RIGHT" ;; # Flecha derecha
            '[D') echo "LEFT" ;;  # Flecha izquierda
        esac
    elif [[ $mode == 'q' ]]; then
        echo "QUIT"
    fi
}

# Función para limpiar la pantalla
clear_screen() {
    clear
}

# Función para seleccionar personaje
select_character() {
    clear_screen
    echo -e "${BLUE}=== Selección de Personaje ===${NC}"
    echo "1) Cloud"
    echo "$CLOUD_ASCII"
    echo "2) Tifa"
    echo "$TIFA_ASCII"
    echo "3) Barret"
    echo "$BARRET_ASCII"
    echo
    echo "Selecciona tu personaje (1-3):"
    read choice
    
    case $choice in
        1) SELECTED_CHARACTER="Cloud"
           PLAYER_HP=100
           PLAYER_MP=50
           ;;
        2) SELECTED_CHARACTER="Tifa"
           PLAYER_HP=90
           PLAYER_MP=40
           ;;
        3) SELECTED_CHARACTER="Barret"
           PLAYER_HP=120
           PLAYER_MP=30
           ;;
        *) echo "Selección inválida. Seleccionando Cloud por defecto."
           SELECTED_CHARACTER="Cloud"
           ;;
    esac
}

# Sistema de batalla
battle() {
    local ENEMY_HP=50
    local ENEMY_NAME="Guardia Shinra"
    
    while true; do
        clear_screen
        echo -e "${RED}=== BATALLA ===${NC}"
        echo "Tu HP: $PLAYER_HP"
        echo "HP Enemigo: $ENEMY_HP"
        echo
        echo "1) Atacar"
        echo "2) Habilidad especial"
        echo "3) Curar"
        echo "4) Huir"
        echo
        echo "¿Qué quieres hacer?"
        read action
        
        case $action in
            1) # Atacar
                damage=$((RANDOM % 15 + 10))
                ENEMY_HP=$((ENEMY_HP - damage))
                echo "¡Has causado $damage de daño!"
                ;;
            2) # Habilidad especial
                if [ $PLAYER_MP -ge 10 ]; then
                    damage=$((RANDOM % 25 + 20))
                    ENEMY_HP=$((ENEMY_HP - damage))
                    PLAYER_MP=$((PLAYER_MP - 10))
                    echo "¡Has usado una habilidad especial y causado $damage de daño!"
                else
                    echo "¡No tienes suficiente MP!"
                fi
                ;;
            3) # Curar
                heal=$((RANDOM % 20 + 10))
                PLAYER_HP=$((PLAYER_HP + heal))
                echo "¡Te has curado $heal HP!"
                ;;
            4) # Huir
                if [ $((RANDOM % 2)) -eq 0 ]; then
                    echo "¡Has escapado con éxito!"
                    sleep 2
                    return
                else
                    echo "¡No has podido escapar!"
                fi
                ;;
        esac
        
        if [ $ENEMY_HP -le 0 ]; then
            echo "¡Has derrotado al $ENEMY_NAME!"
            sleep 2
            return
        fi
        
        enemy_damage=$((RANDOM % 10 + 5))
        PLAYER_HP=$((PLAYER_HP - enemy_damage))
        echo "¡El enemigo te ha causado $enemy_damage de daño!"
        
        if [ $PLAYER_HP -le 0 ]; then
            echo "Has sido derrotado..."
            restore_terminal
            exit 1
        fi
        
        sleep 2
    done
}

# Función para dibujar el mapa
draw_map() {
    local map=()
    # Crear un mapa vacío de 20x20
    for ((i=0; i<20; i++)); do
        map[$i]=""
        for ((j=0; j<20; j++)); do
            if [ $i -eq $PLAYER_Y ] && [ $j -eq $PLAYER_X ]; then
                map[$i]="${map[$i]}@"
            else
                map[$i]="${map[$i]}."
            fi
        done
    done

    # Dibujar el mapa
    clear_screen
    echo -e "${GREEN}=== Midgar - Sector 7 ===${NC}"
    echo "Personaje: $SELECTED_CHARACTER | HP: $PLAYER_HP | MP: $PLAYER_MP"
    echo
    for ((i=0; i<20; i++)); do
        echo "${map[$i]}"
    done
    echo
    echo "Usa las flechas para moverte. 'q' para salir"
}

# Función principal del juego
main() {
    configure_terminal
    trap restore_terminal EXIT
    
    select_character
    
    while true; do
        draw_map
        
        key=$(read_arrow_key)
        case $key in
            "UP")
                if [ $PLAYER_Y -gt 0 ]; then
                    PLAYER_Y=$((PLAYER_Y - 1))
                    if [ $((RANDOM % 10)) -eq 0 ]; then
                        battle
                    fi
                fi
                ;;
            "DOWN")
                if [ $PLAYER_Y -lt 19 ]; then
                    PLAYER_Y=$((PLAYER_Y + 1))
                    if [ $((RANDOM % 10)) -eq 0 ]; then
                        battle
                    fi
                fi
                ;;
            "LEFT")
                if [ $PLAYER_X -gt 0 ]; then
                    PLAYER_X=$((PLAYER_X - 1))
                    if [ $((RANDOM % 10)) -eq 0 ]; then
                        battle
                    fi
                fi
                ;;
            "RIGHT")
                if [ $PLAYER_X -lt 19 ]; then
                    PLAYER_X=$((PLAYER_X + 1))
                    if [ $((RANDOM % 10)) -eq 0 ]; then
                        battle
                    fi
                fi
                ;;
            "QUIT")
                echo "¡Gracias por jugar!"
                break
                ;;
        esac
    done
}

# Iniciar el juego
main