#!/bin/bash

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

# Función para mostrar el menú de minijuegos
mostrar_menu() {
    clear
    echo
    echo "                            MINIJUEGOS - FINAL FANTASY VII"
    echo
    echo "                                      ╔══════════════════╗"
    local opcion_seleccionada=$1
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 1
    echo "Chocobo Race    ║"
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 2
    echo "Miguel Borracho ║"
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 3
    echo "Moogle Jump     ║"
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 4
    echo "Sobrevive       ║"
    echo -n "                                      ║ "
    mostrar_cursor $opcion_seleccionada 5
    echo "Volver         ║"
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
            if [ $opcion_seleccionada -lt 5 ]; then
                ((opcion_seleccionada++))
            fi
            ;;
        '')  # Enter
            case $opcion_seleccionada in
                1)
                    clear
                    echo "Iniciando Chocobo Race..."
                    sleep 2
                    bash chocobo.sh
                    ;;  
                2)
                    clear
                    echo "Iniciando Miguel Borracho..."
                    sleep 2
                    bash miguel.sh
                    ;;  
                3)
                    clear
                    echo "Iniciando Moogle Jump..."
                    sleep 2
                    bash moogle.sh
                    ;;  
                4)
                    clear
                    bash midgar.sh sobrevive
                    exit 0
                    ;;
                5)
                    clear
                    bash ff7_3.sh
                    exit 0
                    ;;
            esac
            ;;
    esac
done
