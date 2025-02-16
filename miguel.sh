#!/bin/bash

# Configuración inicial
SCREEN_WIDTH=40
SCREEN_HEIGHT=15
PLAYER_X=5
PLAYER_Y=7
SCORE=0
DRUNK_LEVEL=0
LIVES=5  # Aumentado a 5 vidas
FOOD_SPAWN_TIME=0
FOOD_SPAWN_INTERVAL=30  # Intervalo de aparición de comida (en ciclos)

# Caracteres
PLAYER="M"
BEER="🍺"
TABLE="┬"
WALL="│"
FOOD="🍖"
ENEMY="👤"

# Variables de estado
SWAY_AMOUNT=0
FOOD_ACTIVE=false

# Configurar terminal
stty -echo -icanon time 0 min 0

# Arrays para obstáculos
declare -a OBSTACLES_X
declare -a OBSTACLES_Y
NUM_OBSTACLES=5

# Función para el game over
show_game_over() {
    clear
    echo
    echo "  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
    echo "  █▄░▄█ █▀▀█ █▀▄▀█ █▀▀   █▀▀█ ▀█▀ █▀▀ █▀▀█ █"
    echo "  █░█░█ █▄▄█ █░▀░█ █▀▀   █▄▄█ ░█░ █▀▀ █▄▄▀ █"
    echo "  █░░░█ ▀░░▀ ▀░░░▀ ▀▀▀   ▀░░▀ ▄█▄ ▀▀▀ ▀░▀▀ ▀"
    echo "  ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"
    echo
    echo "             Score final: $SCORE"
    echo "        Nivel de borrachera: $DRUNK_LEVEL"
    echo
    echo "       Presiona 'q' para salir"
    echo
}

# Función para inicializar obstáculos
init_obstacles() {
    for ((i=0; i<NUM_OBSTACLES; i++)); do
        OBSTACLES_X[$i]=$((RANDOM % (SCREEN_WIDTH-2) + 1))
        OBSTACLES_Y[$i]=$((RANDOM % (SCREEN_HEIGHT-2) + 1))
    done
}

# Optimización: Buffer para el dibujo
draw_to_buffer() {
    local buffer=""
    buffer+="=== Miguel's Tavern Run ===\n"
    buffer+="Score: $SCORE | Borrachera: $DRUNK_LEVEL | Vidas: $(printf '❤️%.0s' $(seq 1 $LIVES))\n\n"
    
    # Borde superior
    buffer+="+$(printf '%*s' $SCREEN_WIDTH | tr ' ' '-')+\n"
    
    # Área de juego
    for ((y=0; y<SCREEN_HEIGHT; y++)); do
        buffer+="$WALL"
        for ((x=0; x<SCREEN_WIDTH; x++)); do
            local char=" "
            for ((i=0; i<NUM_OBSTACLES; i++)); do
                if [ $x -eq ${OBSTACLES_X[$i]} ] && [ $y -eq ${OBSTACLES_Y[$i]} ]; then
                    char=$ENEMY
                    break
                fi
            done
            if [ $x -eq $PLAYER_X ] && [ $y -eq $PLAYER_Y ]; then
                char=$PLAYER
            elif [ $x -eq $BEER_X ] && [ $y -eq $BEER_Y ]; then
                char=$BEER
            elif [ "$FOOD_ACTIVE" = true ] && [ $x -eq $FOOD_X ] && [ $y -eq $FOOD_Y ]; then
                char=$FOOD
            elif [ $((x % 8)) -eq 0 ] && [ $((y % 4)) -eq 0 ]; then
                char=$TABLE
            fi
            buffer+="$char"
        done
        buffer+="$WALL\n"
    done
    
    # Borde inferior
    buffer+="+$(printf '%*s' $SCREEN_WIDTH | tr ' ' '-')+\n"
    buffer+="Controles: ←→↑↓ para moverte | 'q' para salir\n"
    echo -en "\e[H\e[2J$buffer"
}

# Generar nueva posición para la cerveza
spawn_beer() {
    while true; do
        BEER_X=$((RANDOM % (SCREEN_WIDTH-2) + 1))
        BEER_Y=$((RANDOM % (SCREEN_HEIGHT-2) + 1))
        local collision=false
        for ((i=0; i<NUM_OBSTACLES; i++)); do
            if [ $BEER_X -eq ${OBSTACLES_X[$i]} ] && [ $BEER_Y -eq ${OBSTACLES_Y[$i]} ]; then
                collision=true
                break
            fi
        done
        [ "$collision" = false ] && break
    done
}

# Generar power-up de comida
spawn_food() {
    FOOD_ACTIVE=true
    while true; do
        FOOD_X=$((RANDOM % (SCREEN_WIDTH-2) + 1))
        FOOD_Y=$((RANDOM % (SCREEN_HEIGHT-2) + 1))
        local collision=false
        for ((i=0; i<NUM_OBSTACLES; i++)); do
            if [ $FOOD_X -eq ${OBSTACLES_X[$i]} ] && [ $FOOD_Y -eq ${OBSTACLES_Y[$i]} ]; then
                collision=true
                break
            fi
        done
        [ "$collision" = false ] && break
    done
}

# Inicializar juego
clear
init_obstacles
spawn_beer
spawn_food

# Bucle principal del juego
while true; do
    read -t 0.05 -n 1 key
    
    # Control de aparición de comida
    ((FOOD_SPAWN_TIME++))
    if [ $FOOD_SPAWN_TIME -ge $FOOD_SPAWN_INTERVAL ]; then
        FOOD_SPAWN_TIME=0
        spawn_food
    fi
    
    if [ "$key" = $'\x1b' ]; then
        read -t 0.05 -n 2 arrow
        OLD_X=$PLAYER_X
        OLD_Y=$PLAYER_Y
        
        case $arrow in
            '[C') PLAYER_X=$((PLAYER_X + 1)) ;;  # Derecha
            '[D') PLAYER_X=$((PLAYER_X - 1)) ;;  # Izquierda
            '[A') PLAYER_Y=$((PLAYER_Y - 1)) ;;  # Arriba
            '[B') PLAYER_Y=$((PLAYER_Y + 1)) ;;  # Abajo
        esac
        
        # Límites
        [ $PLAYER_X -lt 1 ] && PLAYER_X=1
        [ $PLAYER_X -ge $((SCREEN_WIDTH-1)) ] && PLAYER_X=$((SCREEN_WIDTH-1))
        [ $PLAYER_Y -lt 1 ] && PLAYER_Y=1
        [ $PLAYER_Y -ge $((SCREEN_HEIGHT-1)) ] && PLAYER_Y=$((SCREEN_HEIGHT-1))
        
        # Colisiones con obstáculos
        for ((i=0; i<NUM_OBSTACLES; i++)); do
            if [ $PLAYER_X -eq ${OBSTACLES_X[$i]} ] && [ $PLAYER_Y -eq ${OBSTACLES_Y[$i]} ]; then
                PLAYER_X=$OLD_X
                PLAYER_Y=$OLD_Y
                ((LIVES--))
                if [ $LIVES -le 0 ]; then
                    show_game_over
                    while true; do
                       read -n 1 exit_key
                       [ "$exit_key" = "q" ] && break
               #     while read -t 0.1 -n 1 exit_key; do
               #         [ "$exit_key" = "q" ] && break 2
                    done
                fi
                break
            fi
        done
    elif [ "$key" = "q" ]; then
        break
    fi
    
    # Colisión con cerveza
    if [ $PLAYER_X -eq $BEER_X ] && [ $PLAYER_Y -eq $BEER_Y ]; then
        ((SCORE++))
        ((DRUNK_LEVEL++))
        spawn_beer
    fi
    
    # Colisión con comida
    if [ "$FOOD_ACTIVE" = true ] && [ $PLAYER_X -eq $FOOD_X ] && [ $PLAYER_Y -eq $FOOD_Y ]; then
        FOOD_ACTIVE=false
        if [ $DRUNK_LEVEL -gt 0 ]; then
            ((DRUNK_LEVEL--))
        fi
    fi
    
    # Dibujar el juego usando buffer
    draw_to_buffer
    sleep 0.03
done

# Restaurar terminal
stty sane
clear
