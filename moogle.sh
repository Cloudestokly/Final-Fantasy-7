#!/bin/bash

# Configuración inicial
PLAYER_X=5
PLAYER_Y=1
VELOCITY_Y=0
JUMP_FORCE=5      # Aumentado de 3 a 5
GRAVITY=0.5       # Reducido de 1 a 0.5
SCREEN_WIDTH=30
SCREEN_HEIGHT=10
GOAL_X=25
GOAL_Y=8
CAN_JUMP=true
MAX_VELOCITY=6    # Nueva variable para limitar la velocidad máxima

# Caracteres del juego
CHARACTER="@"
PLATFORM="-"
WALL="|"
GOAL="*"

# Configurar terminal
stty -echo -icanon time 0 min 0

# Función para limpiar pantalla
clear_screen() {
    clear
}

# Función para dibujar el juego
draw_game() {
    clear_screen
    echo "=== Moogle Jump ==="
    echo "Usa flechas para moverte. Flecha arriba para saltar. 'q' para salir"
    echo "Mantén pulsada la flecha arriba para saltar más alto"
    
    # Dibujar borde superior
    echo "+$(printf '%*s' "$SCREEN_WIDTH" | tr ' ' '-')+"
    
    # Dibujar área de juego
    for ((y=SCREEN_HEIGHT; y>=0; y--)); do
        echo -n "|"
        for ((x=0; x<SCREEN_WIDTH; x++)); do
            if [ $x -eq $PLAYER_X ] && [ $y -eq $PLAYER_Y ]; then
                echo -n "$CHARACTER"
            elif [ $x -eq $GOAL_X ] && [ $y -eq $GOAL_Y ]; then
                echo -n "$GOAL"
            else
                echo -n " "
            fi
        done
        echo "|"
    done
    
    # Dibujar suelo
    echo "+$(printf '%*s' "$SCREEN_WIDTH" | tr ' ' '-')+"
}

# Función para verificar colisiones
check_collision() {
    # Límites horizontales
    if [ $PLAYER_X -lt 0 ]; then
        PLAYER_X=0
    elif [ $PLAYER_X -ge $SCREEN_WIDTH ]; then
        PLAYER_X=$((SCREEN_WIDTH-1))
    fi
    
    # Límites verticales
    if [ $PLAYER_Y -le 1 ]; then
        PLAYER_Y=1
        VELOCITY_Y=0
        CAN_JUMP=true
    elif [ $PLAYER_Y -ge $SCREEN_HEIGHT ]; then
        PLAYER_Y=$SCREEN_HEIGHT
        VELOCITY_Y=0
    fi
}

# Función para verificar victoria
check_win() {
    if [ $PLAYER_X -eq $GOAL_X ] && [ $PLAYER_Y -eq $GOAL_Y ]; then
        clear_screen
        echo "¡Felicidades! ¡Has ganado!"
        return 0
    fi
    return 1
}

# Mensaje inicial
clear_screen
echo "¡Alcanza la estrella (*) !"
sleep 2

# Variables para el salto mejorado
JUMP_HELD=0

# Bucle principal del juego
while true; do
    read -t 0.1 -n 1 key
    
    if [ "$key" = $'\x1b' ]; then
        read -t 0.1 -n 2 arrow
        case $arrow in
            '[C') # Derecha
                ((PLAYER_X++))
                ;;
            '[D') # Izquierda
                ((PLAYER_X--))
                ;;
            '[A') # Arriba (salto)
                if [ "$CAN_JUMP" = true ]; then
                    VELOCITY_Y=$JUMP_FORCE
                    CAN_JUMP=false
                    JUMP_HELD=1
                elif [ $JUMP_HELD -eq 1 ] && [ $VELOCITY_Y -gt 0 ]; then
                    # Proporciona un pequeño impulso adicional mientras se mantiene presionada la tecla
                    VELOCITY_Y=$(echo "$VELOCITY_Y + 0.5" | bc)
                    if [ $(echo "$VELOCITY_Y > $MAX_VELOCITY" | bc) -eq 1 ]; then
                        VELOCITY_Y=$MAX_VELOCITY
                    fi
                fi
                ;;
            '[B') # Abajo
                VELOCITY_Y=0
                JUMP_HELD=0
                ;;
        esac
    elif [ "$key" = "q" ]; then
        clear_screen
        echo "¡Gracias por jugar!"
        break
    else
        JUMP_HELD=0
    fi
    
    # Física
    if [ $PLAYER_Y -gt 1 ]; then
        VELOCITY_Y=$(echo "$VELOCITY_Y - $GRAVITY" | bc)
    fi
    PLAYER_Y=$(echo "$PLAYER_Y + $VELOCITY_Y" | bc | cut -d. -f1)
    
    # Verificaciones
    check_collision
    draw_game
    
    if check_win; then
        break
    fi
    
    sleep 0.05
done

# Restaurar terminal
stty sane
