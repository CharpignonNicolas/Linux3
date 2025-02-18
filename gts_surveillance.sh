#!/bin/bash

# Surveillance de l’espace disque
disk() {
    echo "Surveillance de l'espace disque :"
    df -h
}

process() {
    read -p "1. Voir tous les processus
2. Voir les processus par utilisateur
Choisissez une option (1-2) : " process_choice

    case $process_choice in
        1)
            echo "Affichage de tous les processus :"
            ps aux
            ;;
        2)
            echo "Affichage des processus par utilisateur :"
            ps -eo user,%cpu,%mem,pid --sort=-%cpu | head -n 10
            ;;
        *)
            echo "Option invalide."
            ;;
    esac
}

# Surveillance de l’utilisation de la mémoire
memory() {
    echo "Surveillance de l'utilisation de la mémoire :"
    free -h
}

# Menu interactif
while true; do
    echo -e "========================================="
    echo -e "         Menu de surveillance            "
    echo -e "========================================="
    echo -e "1. Surveillance de l'espace disque"
    echo -e "2. Surveillance des processus actifs"
    echo -e "3. Surveillance de l'utilisation de la mémoire"
    echo -e "4. Quitter"
    echo -e "========================================="

    read -p "Choisissez une option (1-4) : " action

    case $action in
        1)
            disk
            ;;
        2)
            process
            ;;
        3)
            memory
            ;;
        4)
            echo "Quitter..."
            break
            ;;
        *)
            echo "Option invalide, veuillez réessayer."
            ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu..."
done