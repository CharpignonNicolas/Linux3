#!/bin/bash

# Fonction qui permet de créer un utilisateur

create_user()
{
    # On vérifie si l'utilisateur existe
    if id "$1" &>/dev/null; then
        echo "L'utilisateur $1 existe déjà"
    else
        # On crée l'utilisateur
        sudo useradd -m -s /bin/bash "$1"
        echo "L'utilisateur $1 a été créé"
    fi
}