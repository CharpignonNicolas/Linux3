#!/bin/bash

read -p "Que voulez-vous faire ? 
1. Surveillance de l\'espace disque 
2. Surveillance des processus actifs 
3. Surveillance de l\'utilisation de la mémoire :
" action


# Surveillance de l’espace disque
disk()
{
    df -h
}

# Suivi des processus actifs 
process() {

    if [ $process -eq 1 ]; then
        # Afficher tous les processus
        ps aux
    else
         # Obtenir le nombre de cœurs CPU de la machine
        num_cores=$(nproc)

        # Afficher l'utilisateur, le nombre de processus, le total du %CPU et le total du %MEM pour chaque utilisateur
        ps aux --sort=user | \
        awk -v cores=$num_cores '{user[$1]+=$3; mem[$1]+=$4; count[$1]++} END {for (u in count) print u, count[u], user[u]/cores, mem[u]}' | \
        sort -k2,2nr | \
        awk '{print "Nom : " $1 ", nb process : " $2 ", Cpu % : " $3 ", Mem % : " $4}'
        fi
}
    


# Surveillance de l’utilisation de la mémoire
memory()
{
    free -h
}

case $action in
    1)
        echo "Surveillance de l espace disque  " 
        disk
        ;;
    2)
        read -p "Processus : 
Voir tous les processus : 1
Voir les prcessus par user :2
" process
        process
        ;;
    3)
        echo "Surveillance de l utilisation de la mémoire  " 
        memory
        ;;
    *)
        echo "Action inconnue"
        ;;
esac