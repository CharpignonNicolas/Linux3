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

# Suivi des processus actifs trie de sorte ( Utilisateur , nombre de processus , %cpu , %mem )
process()
{
    ps -eo user=|sort|uniq -c|sort -nr
}

# Surveillance de l’utilisation de la mémoire
memory()
{
    free -h
}

case $action in
    1)
        echo "Surveillance de l'espace disque  " 
        disk
        ;;
    2)
        echo "Surveillance des processus actifs  " 
        process
        ;;
    3)
        echo "Surveillance de l'utilisation de la mémoire  " 
        memory
        ;;
    *)
        echo "Action inconnue"
        ;;
esac