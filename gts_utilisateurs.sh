#!/bin/bash


# Fonction qui permet de créer un utilisateur
create_user() {

    read -p "Quel est le nom de l'utilisateur à créer ? : " username

    if id "$username" &>/dev/null; then
        echo "L'utilisateur $1 existe déjà"
    else

        sudo useradd -m -s /bin/bash "$username"
        echo "L'utilisateur $1 a été créé"

        password=$(openssl rand -base64 6)
        echo "Mot de passe généré : $password"

        echo "$username:$password" | sudo chpasswd

        sudo passwd -e --quiet "$username"

        echo "L'utilisateur $username a maintenant un mot de passe aléatoire."


        # Demander à l'utilisateur quel quota en mégaoctets il souhaite définir
        echo "Quel quota en mégaoctets voulez-vous attribuer à l'utilisateur $username ?"
        read quota_mb

        quota_ko=$((quota_mb * 1024))

        # Appliquer le quota à l'utilisateur sur la partition /home
        sudo setquota -u $1 $quota_ko 0 0 0 /home

        # Afficher un message de confirmation
        echo "Le quota de $quota_mb Mo a été défini pour l'utilisateur $1 sur la partition /home."


        # Affecter l'utilisateur à un groupe
        echo "Groupes existants :"
        # Récupérer la liste des groupes système avec un ID entre 1000 et 60000, en excluant les groupes qui correspondent à des utilisateurs système ayant un ID >= 1000.
        liste_groupes=$(getent group | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' | grep -vxF -f <(getent passwd | awk -F: '$3 >= 1000 {print $1}'))
        echo "$liste_groupes"
            
        read -p "Entrez le groupes dans le quel vous voulez afecter $username : " groupe

        usermod -aG $groupe $username

        echo "L'utilisateur $username a été ajouté au groupe $groupe."
    fi
}

# Fonction qui permet de supprimer un utilisateur

delete_user() {

    echo "Liste des utilisateurs :";
    liste_users=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}')
    echo "$liste_users"

    read -p "Quel utilisateur voulez-vous supprimer ? : " username

    if ! id "$username" &>/dev/null; then
        echo "L'utilisateur $username n'existe pas."
        return 1
    fi

    echo "Suppression de l'utilisateur : $username"

    echo "Suppression des quotas..."
    setquota -u "$username" 0 0 0 0 /home 2>/dev/null

    echo "Suppression de l'utilisateur des groupes secondaires..."
    user_groups=$(id -nG "$username" | tr ' ' '\n' | grep -v "^$username$")  
    for group in $user_groups; do
        sudo gpasswd -d "$username" "$group" 2>/dev/null
    done

    echo "Suppression des tâches cron..."
    crontab -r -u "$username" 2>/dev/null

    echo "Suppression de l'utilisateur..."
    userdel -f "$username"

    echo "Suppression du répertoire personnel de $username..."
    rm -rf "/home/$username"

    echo "L'utilisateur $username a été supprimé avec succès."
}


#creation d'un groupe

create_group()
{

    read -p "Entrez le nom du groupe à créer : " group_name

    echo "Création du groupe : $group_name"

    if grep -q "^$group_name:" /etc/group; then
        echo "Le groupe $group_name existe déjà"
    else
        
        sudo groupadd "$group_name"
        echo "Le groupe $group_name a été créé"

        
        mkdir -p /ShareFolders/$group_name
        chown root:root /ShareFolders
        chown :$1 /ShareFolders/$groupe_name

    fi
}

#ajout d'un utilisateur à un groupe

add_user_to_group()
{
    
    while true; do
        echo "Liste des utilisateurs :";
        liste_users=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}')
        echo "$liste_users"
        read -p "Quel utilisateur voulez-vous ajouter à un groupe ? : " user

        if id "$user" &>/dev/null; then
            break
        else
            echo "L'utilisateur $user n'existe pas."
        fi
    done

    echo "Groupes existants :"
    liste_groupes=$(getent group | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' | grep -vxF -f <(getent passwd | awk -F: '$3 >= 1000 {print $1}'))
    echo "$liste_groupes"

    read -p "Entrez le groupe  : " groupe

    usermod -aG $groupe $user

    echo "L'utilisateur $user a été ajouté au groupe $groupe."
}

#liste de tous les utilisateurs

list_all()
{
    
    users=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}')

    for user in $users; do
        
         # Récupérer les groupes de l'utilisateur dont le GID est entre 1000 et 60000
        groups=$(id -nG "$user" | tr ' ' '\n' | xargs -I{} getent group {} | awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' | tr '\n' ' ')
        
        echo "Utilisateur: $user"
        echo "Groupe: $groups"
        echo "---------------------"

    done
}




# Menu interactif
while true; do
    echo  "========================================="
    echo  "          Menu Utilisateur               "
    echo  "========================================="
    echo  "1.Cree un utilisateur"
    echo  "2.Supprimer un utilisateur"
    echo  "3.Creer un groupe"
    echo  "4.Ajouter un utilisateur à un groupe"
    echo  "5.Lister tous les utilisateurs"
    echo  "6.Quitter"
    echo  "========================================="

    read -p "Choisissez une option (1-6) : " choice

    case $choice in
        1) create_user ;;
        2) delete_user ;;
        3) create_group ;;
        4) add_user_to_group ;;
        5) list_all ;;
        6) echo  "Quitter..."; exit 0 ;;
        *) echo  "$Option invalide, veuillez réessayer." ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu..."
done
