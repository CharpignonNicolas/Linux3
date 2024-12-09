#!/bin/bash

# Fonction qui permet de créer un utilisateur


create_user()

{
    echo "Création de l'utilisateur : $1"


    # On vérifie si l'utilisateur existe
    if id "$1" &>/dev/null; then
        echo "L'utilisateur $1 existe déjà"
    else
        # On crée l'utilisateur
        sudo useradd -m -s /bin/bash "$1"
        echo "L'utilisateur $1 a été créé"
        # On définit le mot de passe de l'utilisateur
        sudo passwd 

    fi
}


delete_user()

{
    echo "Suppression de l'utilisateur : $1" 
    # On vérifie si l'utilisateur existe
    if id "$1" &>/dev/null; then
        # On supprime l'utilisateur
        sudo userdel -r "$1"
        echo "L'utilisateur $1 a été supprimé"
    else
        echo "L'utilisateur $1 n'existe pas"
    fi

}

