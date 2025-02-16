#!/bin/bash

# Menu interactif
read -p "Que voulez-vous faire ?
1. Surveillance de l'espace disque
2. Surveillance des processus actifs
3. Surveillance de l'utilisation de la mémoire
Choisissez une option (1-3) : " action

# Surveillance de l’espace disque
disk() {
    echo "Surveillance de l'espace disque :"
    df -h
}

# Suivi des processus actifs
process() {
    read -p "Processus :
1. Voir tous les processus
2. Voir les processus par utilisateur
Choisissez une option (1-2) : " process_choice

    case $process_choice in
        1)
            echo "Affichage de tous les processus :"
            ps aux
            ;;
        2)
            echo "Affichage des processus par utilisateur :"
            num_cores=$(nproc)  # Nombre de cœurs CPU

            ps aux --no-headers | awk -v cores=$num_cores '
            {
                user[$1]+=$3; 
                mem[$1]+=$4; 
                count[$1]++
            } 
            END {
                for (u in count) 
                    print "Utilisateur : " u ", Nb processus : " count[u] ", CPU % : " user[u]/cores ", Mémoire % : " mem[u]
            }' | sort -k2,2nr
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

# Exécution de l'action choisie
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
    *)
        echo "Action inconnue."
        ;;
esac
