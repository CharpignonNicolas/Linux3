#!/bin/bash

# Afficher le menu principal
show_menu() {
    clear
    echo "==============================="
    echo "       GESTION UTILISATEURS"
    echo "==============================="
    echo "1. Créer un utilisateur"
    echo "2. Supprimer un utilisateur"
    echo "3. Créer un groupe"
    echo "4. Ajouter un utilisateur à un groupe"
    echo "5. Lister les utilisateurs et leurs détails"
    echo "0. Quitter"
    echo "==============================="
    read -p "Entrez votre choix : " action
}

# Fonction pour créer un utilisateur
create_user() {
    read -p "Quel est le nom de l'utilisateur ? : " USER
    if id "$USER" &>/dev/null; then
        echo "L'utilisateur $USER existe déjà"
    else
        sudo useradd -m -s /bin/bash "$USER"
        echo "L'utilisateur $USER a été créé"
        password=$(openssl rand -base64 6)
        echo "Mot de passe généré : $password"
        echo "$USER:$password" | sudo chpasswd
        sudo passwd -e "$USER"
        echo "L'utilisateur $USER a maintenant un mot de passe aléatoire."

        read -p "Souhaitez-vous affecter l'utilisateur $USER à un ou plusieurs groupes ? (y/n) : " response
        if [ "$response" == "y" ]; then
            echo "Groupes existants :"
            liste_groupes=$(cut -d: -f1 /etc/group | tr '\n' ' ')
            echo "$liste_groupes"
            read -p "Entrez les groupes séparés par un espace : " groupes
            for group in $groupes; do
                sudo gpasswd -a "$USER" "$group"
            done
        fi
    fi
}

# Fonction pour supprimer un utilisateur
delete_user() {
    read -p "Quel est le nom de l'utilisateur ? : " USER
    if id "$USER" &>/dev/null; then
        sudo userdel -r "$USER"
        echo "L'utilisateur $USER a été supprimé"
    else
        echo "L'utilisateur $USER n'existe pas"
    fi
}

# Fonction pour créer un groupe
create_group() {
    read -p "Quel est le nom du groupe ? : " GROUP
    if grep -q "^$GROUP:" /etc/group; then
        echo "Le groupe $GROUP existe déjà"
    else
        sudo groupadd "$GROUP"
        echo "Le groupe $GROUP a été créé"
    fi
}

# Fonction pour ajouter un utilisateur à un groupe
add_user_to_group() {
    read -p "Quel est le nom de l'utilisateur ? : " USER
    if id "$USER" &>/dev/null; then
        echo "Groupes existants :"
        liste_groupes=$(cut -d: -f1 /etc/group | tr '\n' ' ')
        echo "$liste_groupes"
        read -p "Entrez les groupes séparés par un espace : " groupes
        for group in $groupes; do
            sudo gpasswd -a "$USER" "$group"
        done
        echo "L'utilisateur $USER a été ajouté aux groupes spécifiés"
    else
        echo "L'utilisateur $USER n'existe pas"
    fi
}

# Fonction pour lister les utilisateurs et leurs détails
list_users() {
    echo "Liste des utilisateurs :"
    while IFS=: read -r username _ uid gid home shell; do
        if [ "$uid" -ge 1000 ]; then
            echo "Utilisateur : $username"
            echo "  UID : $uid"
            echo "  GID : $gid"
            echo "  Dossier personnel : $home"
            echo "  Shell : $shell"

            groups=$(id -nG "$username")
            echo "  Groupes : $groups"

            if sudo -l -U "$username" &>/dev/null; then
                echo "  Sudoer : Oui"
            else
                echo "  Sudoer : Non"
            fi

            quota=$(sudo repquota / | grep "^$username" | awk '{print $2 " fichiers, " $3 " blocs utilisés"}')
            if [ -n "$quota" ]; then
                echo "  Quotas : $quota"
            else
                echo "  Quotas : Non défini"
            fi
            echo "------------------------"
        fi
    done </etc/passwd
}

# Boucle principale
while true; do
    show_menu
    case $action in
        1)
            create_user
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        2)
            delete_user
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        3)
            create_group
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        4)
            add_user_to_group
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        5)
            list_users
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
        0)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Choix invalide. Veuillez réessayer."
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
    esac
done
