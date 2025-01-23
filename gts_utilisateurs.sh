#!/bin/bash

# Fonction qui permet de créer un utilisateur


read -p "Quelle action effectuer ? (create_user = 1, delete_user = 2, create_group = 3, add_user_to_group = 4 , list all =5) : " action

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


        # Demander à l'utilisateur quel quota en mégaoctets il souhaite définir
        echo "Quel quota en mégaoctets voulez-vous attribuer à l'utilisateur $1 ?"
        read quota_mb

        # Convertir le quota de Mo en Ko (1 Mo = 1024 Ko)
        quota_ko=$((quota_mb * 1024))

        # Appliquer le quota à l'utilisateur sur la partition /home
        sudo setquota -u $1 $quota_ko 0 0 0 /home

        # Afficher un message de confirmation
        echo "Le quota de $quota_mb Mo a été défini pour l'utilisateur $1 sur la partition /home."


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

        # On crée le dossier partagé du département 
        mkdir -p /ShareFolders/$1
        chown root:root /ShareFolders
        chown $1:$1 /ShareFolders/$1

    fi
}

#ajout d'un utilisateur à un groupe
add_user_to_group()
{

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
}

list_all()
{
    # Récupérer la liste des utilisateurs avec un GID supérieur ou égal à 1000
    users=$(getent passwd | awk -F: '$4 >= 1000 {print $1}')

    # Parcourir chaque utilisateur
    for user in $users; do
        # Récupérer les groupes de l'utilisateur
        groups=$(id -nG $user)

        # Vérifier si l'utilisateur est dans le groupe sudo
        if [[ " $groups " == *" sudo "* ]]; then
            sudo_status="Oui"
        else
            sudo_status="Non"
        fi

        # Afficher les informations formatées
        echo "Utilisateur: $user"
        echo "Groupes: $groups"
        echo "Sudo: $sudo_status"
        echo "---------------------"

    done
}



case $action in
    1)
        read -p "Quel est le nom de l'utilisateur a ajouter? : " USER
        create_user "$USER"
        ;;
    2)
        read -p "Quel est le nom de l'utilisateur a suprimer? : " USER
        delete_user "$USER"
        ;;
    3)
        read -p "Quel est le nom du groupe à creer ? : " GROUP
        create_group "$GROUP"
        ;;
    4)
        read -p "Quel est le nom du l'utilisateur ? : " USER
        add_user_to_group "$USER"
        ;;
    5)
        list_all
        ;;
    *)
        echo "Action inconnue"
        ;;
esac
