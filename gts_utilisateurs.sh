#!/bin/bash

# Fonction qui permet de créer un utilisateur


read -p "Quelle action effectuer ? (create_user, delete_user, create_group) : " action

#generation d'un mdp akeatoire  pour l'utilisateur


create_user() {

    

    # Vérification si l'utilisateur existe déjà
    if id "$1" &>/dev/null; then
        echo "L'utilisateur $1 existe déjà"
    else
        # Création de l'utilisateur
        sudo useradd -m -s /bin/bash "$1"
        echo "L'utilisateur $1 a été créé"

        # Génération du mot de passe aléatoire
        password=$(openssl rand -base64 6)
        echo "Mot de passe généré : $password"

        # Affectation du mot de passe à l'utilisateur
        echo "$1:$password" | sudo chpasswd

        # Forcer l'utilisateur à changer son mot de passe au prochain login
        sudo passwd -e "$1"

        echo "L'utilisateur $1 a maintenant un mot de passe aléatoire."

        # Affecter l'utilisateur à un ou plusieurs groupes
        read -p "Souhaitez-vous affecter l'utilisateur $1 à un ou plusieurs groupes ? (y/n) : " response
        if [ "$response" == "y" ]; then
            # Lister les groupes existants
            echo "Groupes existants :"
            liste_groupes=$(cut -d: -f1 /etc/group | tr '\n' ' ')
            echo "$liste_groupes"
            
            # Demander les groupes
            read -p "Entrez les groupes séparés par un espace : " groupes

            # Ajouter l'utilisateur aux groupes avec gpasswd
            for group in $groupes; do
                sudo gpasswd -a "$1" "$group"
                #echo "L'utilisateur $1 a été ajouté au groupe $group"
            done
        fi
    fi
}



delete_user()

{
    read -p "Quel est le nom de l'utilisateur ? : " USER

    #for group in $(groups $1 | cut -d: -f2); do
    #   sudo gpasswd -d "$1" "$group"
    #  echo "L'utilisateur $1 a été supprimé du groupe $group"
    #done

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

#creation d'un groupe
create_group()
{
    

    echo "Création du groupe : $1"
    # On vérifie si le groupe existe
    if grep -q "^$1:" /etc/group; then
        echo "Le groupe $1 existe déjà"
    else
        # On crée le groupe
        sudo groupadd "$1"
        echo "Le groupe $1 a été créé"
    fi
}


case $action in
    create_user)
        read -p "Quel est le nom de l'utilisateur ? : " USER
        create_user "$USER"
        ;;
    delete_user)
        read -p "Quel est le nom de l'utilisateur ? : " USER
        delete_user "$USER"
        ;;
    create_group)
        read -p "Quel est le nom du groupe ? : " GROUP
        create_group "$GROUP"
        ;;
    *)
        echo "Action inconnue"
        ;;
esac