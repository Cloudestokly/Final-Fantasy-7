#!/bin/bash

# Variables
declare -a inventario
declare -A localizaciones
declare -a mensajes_error=(
    "¿Qué intentas hacer...?"
    "Eso no es posible aquí."
    "Mejor intenta otra cosa."
    "¿Estás seguro de eso?"
)
personaje=""
vida=0
magia=0
objetivo_obtenido=false
enemigo_derrotado=false

# ASCII Art para cada localización
midgar_ascii() {
    echo "      ■███████████████■"
    echo "      ██████■■■■■█████"
    echo "      ██████■■■■■█████"
    echo "      ■■■■■█████████"
}

nibelheim_ascii() {
    echo "        /\\"
    echo "       /  \\"
    echo "      /____\\"
    echo "      |    |"
    echo "      |____| "
}

costa_del_sol_ascii() {
    echo "       _/\\_"
    echo "     _/    \\_"
    echo "    /        \\"
    echo "    \\~~~~~~~~/"
}

gongaga_ascii() {
    echo "      ^  ^  ^"
    echo "     /|\\/|\\/|\\"
    echo "    /||\\||\\|||\\"
}

templo_ascii() {
    echo "        /\\"
    echo "       /  \\"
    echo "      /----\\"
    echo "     /######\\"
}

# Función para mostrar mensaje de error aleatorio
mostrar_error() {
    local total=${#mensajes_error[@]}
    local indice=$((RANDOM % total))
    echo "${mensajes_error[$indice]}"
}

# Función para mostrar inventario
mostrar_inventario() {
    clear
    echo "Tu inventario:"
    if [ ${#inventario[@]} -eq 0 ]; then
        echo "No tienes objetos."
    else
        for item in "${inventario[@]}"; do
            echo "- $item"
        done
    fi
    read -p "Presiona Enter para continuar."
}

# Función para elegir personaje
elegir_personaje() {
    clear
    echo "Selecciona tu personaje:"
    echo "1) Cloud Strife - Equilibrado"
    echo "2) Tifa Lockhart - Ágil"
    echo "3) Barret Wallace - Potente"
    read -p "Elige un número (1-3): " seleccion
    
    case $seleccion in
        1) 
            personaje="Cloud"
            vida=100
            magia=50
            inventario+=("Espada Buster" "Poción" "Armadura Básica")
            ;;
        2) 
            personaje="Tifa"
            vida=80
            magia=40
            inventario+=("Guantes de Cuero" "Poción" "Chaleco Ligero")
            ;;
        3) 
            personaje="Barret"
            vida=120
            magia=30
            inventario+=("Metralleta" "Poción" "Chaleco Pesado")
            ;;
        *) 
            personaje="Cloud"
            vida=100
            magia=50
            inventario+=("Espada Buster" "Poción" "Armadura Básica")
            echo "Selección inválida. Cloud seleccionado por defecto."
            ;;
    esac
    echo "Has elegido a $personaje."
    echo "Vida: $vida | Magia: $magia"
    sleep 2
}

# Función para batalla con Sephiroth
batalla_sephiroth() {
    clear
    local vida_sephiroth=$((RANDOM % 200 + 300))  # Vida entre 300-500
    local vida_jugador=$vida
    local defensa=false
    
    echo "¡Sephiroth aparece! Vida: $vida_sephiroth"
    templo_ascii
    
    while [ $vida_jugador -gt 0 ] && [ $vida_sephiroth -gt 0 ]; do
        echo "
Tu vida: $vida_jugador | Vida Sephiroth: $vida_sephiroth
1) Atacar
2) Defenderse
3) Usar poción (Cura 50 HP)
4) Huir"
        read -p "¿Qué quieres hacer? " accion
        
        case $accion in
            1)  # Atacar
                local damage=$((RANDOM % 30 + 20))
                echo "¡Atacas a Sephiroth y causas $damage de daño!"
                vida_sephiroth=$((vida_sephiroth - damage))
                ;;
            2)  # Defender
                defensa=true
                echo "¡Te preparas para defenderte!"
                ;;
            3)  # Curar
                if [[ " ${inventario[@]} " =~ " Poción " ]]; then
                    vida_jugador=$((vida_jugador + 50))
                    if [ $vida_jugador -gt $vida ]; then
                        vida_jugador=$vida
                    fi
                    echo "¡Te has curado! Vida actual: $vida_jugador"
                    # Eliminar una poción del inventario
                    for i in "${!inventario[@]}"; do
                        if [ "${inventario[$i]}" = "Poción" ]; then
                            unset "inventario[$i]"
                            break
                        fi
                    done
                    inventario=("${inventario[@]}")
                else
                    echo "¡No tienes pociones!"
                fi
                ;;
            4)  # Huir
                if [ $((RANDOM % 2)) -eq 0 ]; then
                    echo "¡Has logrado escapar!"
                    return
                else
                    echo "¡No puedes huir!"
                fi
                ;;
            *)
                mostrar_error
                continue
                ;;
        esac
        
        # Ataque de Sephiroth
        if [ $vida_sephiroth -gt 0 ]; then
            local damage_sephiroth=$((RANDOM % 40 + 10))
            if [ "$defensa" = true ]; then
                damage_sephiroth=$((damage_sephiroth / 2))
                echo "¡Te defiendes y reduces el daño!"
                defensa=false
            fi
            echo "¡Sephiroth te ataca y causa $damage_sephiroth de daño!"
            vida_jugador=$((vida_jugador - damage_sephiroth))
        fi
        
        sleep 1
    done
    
    if [ $vida_jugador -le 0 ]; then
        echo "Has sido derrotado por Sephiroth..."
        read -p "Presiona Enter para continuar."
        return
    else
        echo "¡Has derrotado a Sephiroth!"
        enemigo_derrotado=true
        read -p "Presiona Enter para continuar."
    fi
}

# Función para obtener el objeto clave
obtener_objeto() {
    clear
    echo "En un rincón de la Zona Oculta encuentras la Materia Legendaria."
    inventario+=("Materia Legendaria")
    objetivo_obtenido=true
    echo "Has obtenido la Materia Legendaria."
    read -p "Presiona Enter para continuar."
}

# Función para enfrentar al enemigo final
enfrentar_enemigo() {
    if [ "$objetivo_obtenido" = true ]; then
        clear
        echo "⚔️  Te enfrentas a Sephiroth en el Templo de los Ancianos."
        batalla_sephiroth
        if [ "$enemigo_derrotado" = true ]; then
            echo "🌟 ¡Has salvado el mundo y completado tu misión!"
            read -p "Presiona Enter para salir del juego."
            exit
        fi
    else
        echo "❌ Necesitas la Materia Legendaria para vencer a Sephiroth."
        read -p "Presiona Enter para volver."
    fi
    menu_principal
}

# Exploración de localizaciones
explorar_localizacion() {
    local loc=$1
    while true; do
        clear
        echo "Te encuentras en $loc."
        
        # Mostrar ASCII art según localización
        case $loc in
            "Midgar") midgar_ascii ;;
            "Nibelheim") nibelheim_ascii ;;
            "Costa del Sol") costa_del_sol_ascii ;;
            "Gongaga") gongaga_ascii ;;
            "Templo de los Ancianos") templo_ascii ;;
        esac
        
        # Mostrar información específica de cada localización
        case $loc in
            "Midgar") echo "La ciudad de Midgar, dominada por la corporación Shinra." ;;
            "Nibelheim") echo "Tu pueblo natal, guarda muchos secretos..." ;;
            "Costa del Sol") echo "Una hermosa playa para descansar." ;;
            "Gongaga") echo "Un pueblo remoto rodeado de jungla." ;;
            "Templo de los Ancianos") echo "Un lugar místico y peligroso." ;;
        esac
        
        echo "Selecciona una zona:"
        echo "1️⃣ Mercado (Comprar pociones)"
        echo "2️⃣ Plaza Central (Descansar)"
        if [ "$loc" == "Nibelheim" ]; then
            echo "3️⃣ Zona Oculta (¡Aquí hay algo especial!)"
        else
            echo "3️⃣ Zona Oculta"
        fi
        echo "4️⃣ Ver inventario"
        echo "5️⃣ Volver al menú principal"
        
        read -p "Opción: " opcion
        case $opcion in
            1) 
                clear
                echo "En el mercado encuentras una poción."
                inventario+=("Poción")
                echo "Has obtenido una poción."
                ;;
            2) 
                clear
                echo "Descansas en la plaza..."
                sleep 2
                ;;
            3) 
                if [ "$loc" == "Nibelheim" ]; then
                    obtener_objeto
                else
                    echo "Descubres un área secreta... pero no hay nada interesante."
                fi
                ;;
            4) mostrar_inventario ;;
            5) return ;;
            *) mostrar_error ;;
        esac
        read -p "Presiona Enter para continuar."
    done
}

# Menú principal
menu_principal() {
    while true; do
        clear
        echo "Final Fantasy VII - Juego de Texto"
        echo "Jugando como: $personaje"
        echo "Selecciona una localización:"
        echo "1️⃣ Midgar"
        echo "2️⃣ Nibelheim"
        echo "3️⃣ Costa del Sol"
        echo "4️⃣ Gongaga"
        echo "5️⃣ Templo de los Ancianos (Enfrenta a Sephiroth)"
        echo "6️⃣ Ver inventario"
        echo "7️⃣ Salir"
        read -p "Opción: " opcion
        case $opcion in
            1) explorar_localizacion "Midgar" ;;
            2) explorar_localizacion "Nibelheim" ;;
            3) explorar_localizacion "Costa del Sol" ;;
            4) explorar_localizacion "Gongaga" ;;
            5) enfrentar_enemigo ;;
            6) mostrar_inventario ;;
            7) exit ;;
            *) mostrar_error ;;
        esac
    done
}

# Inicio del juego
elegir_personaje
menu_principal
