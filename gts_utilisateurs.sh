#!/bin/bash

read -p "Quelle action effectuer ? (create_user = 1, delete_user = 2, create_group = 3, add_user_to_group = 4 , list all =5) : " action

# Fonction qui permet de créer un utilisateur

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

delete_user() {
    read -p "Quel utilisateur voulez-vous supprimer ? : " username

    # Vérifier si l'utilisateur existe
    if ! id "$username" &>/dev/null; then
        echo "L'utilisateur $username n'existe pas."
        return 1
    fi

    echo "Suppression de l'utilisateur : $username"

    # Supprimer les quotas de l'utilisateur
    echo "Suppression des quotas..."
    setquota -u "$username" 0 0 0 0 /home 2>/dev/null

    # Supprimer l'utilisateur de tous les groupes
    echo "Suppression de l'utilisateur des groupes secondaires..."
    user_groups=$(id -nG "$username" | tr ' ' '\n' | grep -v "^$username$")  
    for group in $user_groups; do
        sudo gpasswd -d "$username" "$group" 2>/dev/null
    done

    # Supprimer ses tâches cron s'il en a
    echo "🗑 Suppression des tâches cron..."
    crontab -r -u "$username" 2>/dev/null

    # Supprimer l'utilisateur (sans supprimer ses fichiers)
    echo "Suppression de l'utilisateur..."
    userdel -f "$username"

    # Supprimer son répertoire personnel
    echo "Suppression du répertoire personnel de $username..."
    rm -rf "/home/$username"

    echo "L'utilisateur $username a été supprimé avec succès."
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
        chown :$1 /ShareFolders/$1

    fi
}

#ajout d'un utilisateur à un groupe

add_user_to_group()
{
# Boucle pour vérifier si l'utilisateur existe et si son GID est supérieur ou égal à 1000
    while true; do
        read -p "Entrez le nom de l'utilisateur : " user
        if id "$user" &>/dev/null; then
            user_gid=$(id -g "$user")
            if [ "$user_gid" -ge 1000 ]; then
                echo "L'utilisateur $user existe et son GID est supérieur ou égal à 1000"
                break
            fi
        fi
        echo "L'utilisateur $user n'existe pas ou son GID est inférieur à 1000. Veuillez réessayer."
    done

    # Lister les groupes existants
    echo "Groupes existants :"
    liste_groupes=$(getent group | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}')
    echo "$liste_groupes"

    # Demander les groupes
    read -p "Entrez les groupes séparés par un espace : " groupes

    # Ajouter l'utilisateur aux groupes avec gpasswd
    for group in $groupes; do
        sudo gpasswd -a "$user" "$group"
        echo "L'utilisateur $user a été ajouté au groupe $group"
    done

}

list_all()
{
    # Récupérer la liste des utilisateurs avec un GID supérieur ou égal à 1000
    users=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}')

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
        add_user_to_group 
        ;;
    5)
        list_all
        ;;
    *)
        echo "Action inconnue"
        ;;
esac
