#!/bin/bash

# Configuración inicial
clear
echo "🏇 ¡Bienvenido a Chocobo Race! 🏇"
echo "Usa las flechas izquierda y derecha para mover tu chocobo."
echo "Presiona 'q' para salir"

# Configuración del juego
PLAYER_POS=2
RIVAL_POS=2
TRACK_LENGTH=50
ROAD_WIDTH=4

# Configurar terminal
stty -echo -icanon time 0 min 0

# Función para dibujar la carretera y los chocobos
draw_game() {
    clear
    echo "🏇 Chocobo Race 🏇"
    echo
    
    # Dibujar borde superior
    printf "╔"
    printf '═%.0s' $(seq 1 $TRACK_LENGTH)
    printf "╗\n"
    
    # Dibujar espacios vacíos antes de los chocobos
    for ((i=1; i<$ROAD_WIDTH/2; i++)); do
        printf "║"
        printf ' %.0s' $(seq 1 $TRACK_LENGTH)
        printf "║\n"
    done
    
    # Dibujar línea del jugador
    printf "║"
    printf "%-${TRACK_LENGTH}s" "$(printf '%*s' $PLAYER_POS)🐥"
    printf "║\n"
    
    # Dibujar línea del rival
    printf "║"
    printf "%-${TRACK_LENGTH}s" "$(printf '%*s' $RIVAL_POS)🐦"
    printf "║\n"
    
    # Dibujar espacios vacíos después de los chocobos
    for ((i=1; i<$ROAD_WIDTH/2; i++)); do
        printf "║"
        printf ' %.0s' $(seq 1 $TRACK_LENGTH)
        printf "║\n"
    done
    
    # Dibujar borde inferior
    printf "╚"
    printf '═%.0s' $(seq 1 $TRACK_LENGTH)
    printf "╝\n"
}

# Función para mover el rival (IA)
move_rival() {
    # IA más inteligente que considera la posición del jugador
    if [ $RIVAL_POS -lt $PLAYER_POS ]; then
        # Si está atrás, tiene más probabilidad de moverse
        if [ $((RANDOM % 100)) -lt 70 ]; then
            ((RIVAL_POS++))
        fi
    else
        # Si está adelante, se mueve más lento
        if [ $((RANDOM % 100)) -lt 40 ]; then
            ((RIVAL_POS++))
        fi
    fi
}

# Bucle principal del juego
while true; do
    read -t 0.1 -n 1 key
    
    case $key in
        $'\x1b')
            read -t 0.1 -n 2 arrow
            case $arrow in
                '[C') # Flecha derecha
                    if [ $PLAYER_POS -lt $((TRACK_LENGTH-1)) ]; then
                        ((PLAYER_POS++))
                    fi
                    ;;
                '[D') # Flecha izquierda
                    if [ $PLAYER_POS -gt 1 ]; then
                        ((PLAYER_POS--))
                    fi
                    ;;
            esac
            ;;
        q|Q) break ;;
    esac
    
    # Mover rival
    move_rival
    
    # Dibujar el juego
    draw_game
    
    # Verificar victoria
    if [ $PLAYER_POS -ge $((TRACK_LENGTH-1)) ]; then
        echo "🎉 ¡Ganaste la carrera! 🎉"
        break
    elif [ $RIVAL_POS -ge $((TRACK_LENGTH-1)) ]; then
        echo "😞 Perdiste la carrera..."
        break
    fi
    
    sleep 0.05
done

# Restaurar configuración de terminal
stty sane
