#!/bin/bash


# Fonction qui permet de créer un utilisateur

create_user() {

    #Demander a l'utilisateur le nom de l'utilisateur
    read -p "Quel est le nom de l'utilisateur à créer ? : " username

    # Vérification si l'utilisateur existe déjà
    if id "$username" &>/dev/null; then
        echo "L'utilisateur $1 existe déjà"
    else
        # Création de l'utilisateur
        sudo useradd -m -s /bin/bash "$username"
        echo "L'utilisateur $1 a été créé"

        # Génération du mot de passe aléatoire
        password=$(openssl rand -base64 6)
        echo "Mot de passe généré : $password"

        # Affectation du mot de passe à l'utilisateur
        echo "$username:$password" | sudo chpasswd

        # Forcer l'utilisateur à changer son mot de passe au prochain login
        sudo passwd -e --quiet "$username"

        echo "L'utilisateur $1 a maintenant un mot de passe aléatoire."


        # Demander à l'utilisateur quel quota en mégaoctets il souhaite définir
        echo "Quel quota en mégaoctets voulez-vous attribuer à l'utilisateur $username ?"
        read quota_mb

        # Convertir le quota de Mo en Ko (1 Mo = 1024 Ko)
        quota_ko=$((quota_mb * 1024))

        # Appliquer le quota à l'utilisateur sur la partition /home
        sudo setquota -u $1 $quota_ko 0 0 0 /home

        # Afficher un message de confirmation
        echo "Le quota de $quota_mb Mo a été défini pour l'utilisateur $1 sur la partition /home."


        # Affecter l'utilisateur à un ou plusieurs groupes
        read -p "Souhaitez-vous affecter l'utilisateur $username à un ou plusieurs groupes ? (y/n) : " response
        if [ "$response" == "y" ]; then
            # Lister les groupes existants
            echo "Groupes existants :"
            liste_groupes=$(getent group | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' | grep -vxF -f <(getent passwd | awk -F: '$3 >= 1000 {print $1}'))
            echo "$liste_groupes"
            
            # Demander les groupes
            read -p "Entrez les groupes séparés par un espace : " groupes

            # Ajouter l'utilisateur aux groupes avec gpasswd
            for group in $groupes; do
                sudo gpasswd -a "$username" "$group"
                #echo "L'utilisateur $1 a été ajouté au groupe $group"
            done
        fi
    fi
}

delete_user() {
    #lister tt les users
    echo "Liste des utilisateurs :";
    liste_users=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}')
    echo "$liste_users"

    # Demander le nom de l'utilisateur à supprimer
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
    echo "Suppression des tâches cron..."
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
    #demander le nom du groupe
    read -p "Entrez le nom du groupe à créer : " group_name

    echo "Création du groupe : $group_name"
    # On vérifie si le groupe existe
    if grep -q "^$group_name:" /etc/group; then
        echo "Le groupe $group_name existe déjà"
    else
        # On crée le groupe
        sudo groupadd "$group_name"
        echo "Le groupe $group_name a été créé"

        # On crée le dossier partagé du département 
        mkdir -p /ShareFolders/$group_name
        chown root:root /ShareFolders
        chown :$1 /ShareFolders/$groupe_name

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




# Menu interactif
while true; do
    echo -e "========================================="
    echo -e "          Menu Utilisateur               "
    echo -e "========================================="
    echo -e "1.Cree un utilisateur"
    echo -e "2.Supprimer un utilisateur"
    echo -e "3.Creer un groupe"
    echo -e "4.Ajouter un utilisateur à un groupe"
    echo -e "5.Lister tous les utilisateurs"
    echo -e "6.Quitter"
    echo -e "========================================="

    read -p "Choisissez une option (1-6) : " choice

    case $choice in
        1) create_user ;;
        2) delete_user ;;
        3) create_group ;;
        4) add_user_to_group ;;
        5) list_all ;;
        6) echo -e "Quitter..."; exit 0 ;;
        *) echo -e "$Option invalide, veuillez réessayer." ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu..."
done
