#!/bin/bash

# ASCII art de la Buster Sword
buster_sword() {
    echo "                       ________________________________________________"
    echo "                      ||-----------------------------------------------|>"
    echo "             =========||:::::::::::::::::::::::::::::::::::::::::::::::|"
    echo "                      ||-----------------------------------------------|>"
    echo "                      ||_______________________________________________|"
}

# Función para mostrar el cursor
mostrar_cursor() {
    local opcion=$1
    local pos=$2
    if [ $opcion -eq $pos ]; then
        echo -n "》"
    else
        echo -n "  "
    fi
}

# Función para mostrar el menú
mostrar_menu() {
    clear
    echo
    echo "                            FINAL FANTASY VII - JUEGO TEXTUAL"
    echo
    buster_sword
    echo
    echo "                                      ╔══════════════════╗"
    local opcion_seleccionada=$1
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 1
    echo "NEW GAME        ║"
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 2
    echo "MINIGAMES       ║"
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 3
    echo "CREDITS        ║"
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 4
    echo "EXIT           ║"
    echo "                                      ╚══════════════════╝"
}

# Bucle principal
opcion_seleccionada=1
while true; do
    mostrar_menu $opcion_seleccionada
    read -s -n 1 key  # Lee una tecla sin mostrarla

    case $key in
        'A'|'w')  # Flecha arriba o W
            if [ $opcion_seleccionada -gt 1 ]; then
                ((opcion_seleccionada--))
            fi
            ;;
        'B'|'s')  # Flecha abajo o S
            if [ $opcion_seleccionada -lt 4 ]; then
                ((opcion_seleccionada++))
            fi
            ;;
        '')  # Enter
            case $opcion_seleccionada in
                1)
                    clear
                    bash story.sh  # Inicia la primera localización sin usar funciones extra
                    ;;
                2)
                    clear
                    echo "Accediendo a los minijuegos..."
                    sleep 2
                    bash minijuegos.sh
                    ;;  
                3)
                    clear
                    bash creditos.sh  # Ejecuta el script de créditos
                    ;;
                4)
                    clear
                    echo "Saliendo del juego..."
                    sleep 2
                    exit 0
                    ;;
            esac
            ;;
    esac
done