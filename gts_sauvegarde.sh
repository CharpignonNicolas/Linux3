#!/bin/bash

#Groupe de l'utilisateur 
group=$(groups | awk '{print $2}')

# Dossier où seront stockées les sauvegardes
BACKUP_DIR="/ShareFolders/$group"

# Fonction pour effectuer une sauvegarde manuelle
manual_backup() {
    read -p "Entrez le chemin du fichier ou dossier à sauvegarder : " file_or_folder

    # Vérifier si le chemin existe
    if [ ! -e "$file_or_folder" ]; then  # -e vérifie l'existence (fichier ou dossier)
        echo "Erreur : Le fichier ou dossier n'existe pas."
        return
    fi

    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_name="backup_$(basename "$file_or_folder")_$timestamp"

    # Créer le dossier de destination
    mkdir -p "$BACKUP_DIR/$backup_name"

    echo "Sauvegarde en cours..."

    # Utiliser cp pour les fichiers et dossiers
    cp -r "$file_or_folder" "$BACKUP_DIR/$backup_name"

    echo "Sauvegarde terminée : $BACKUP_DIR/$backup_name"
}

# Fonction pour planifier une sauvegarde automatique via cron
schedule_backup() {
    read -p "Entrez le chemin du dossier à sauvegarder automatiquement : " folder

    if [ ! -e "$file_or_folder" ]; then
        echo "Erreur : Le dossier ou le fichier n'existe pas."
        return
    fi

    read -p "À quelle fréquence voulez-vous sauvegarder ? (ex: '0 2 * * *' pour 2h du matin chaque jour) : " cron_schedule

    cron_command="$cron_schedule cp -r $file_or_folder $BACKUP_DIR/backup_$(basename "$file_or_folder")_$(date +\%Y\%m\%d_\%H\%M\%S)"

    # Ajouter la tâche au crontab
    if crontab -l &>/dev/null; then
        (crontab -l; echo "$cron_command") | crontab - 2>/dev/null
    else
        echo "$cron_command" | crontab - 2>/dev/null
    fi

    echo "Sauvegarde automatique programmée."
}

# Fonction pour lister les sauvegardes disponibles
list_backups() {
    echo "Sauvegardes disponibles :"
    ls -lh "$BACKUP_DIR"
}

# Menu interactif
while true; do
    echo "========================================="
    echo "       MENU DE SAUVEGARDE       "
    echo "========================================="
    echo "1. Sauvegarde manuelle"
    echo "2. Planifier une sauvegarde automatique"
    echo "3. Lister les sauvegardes disponibles"
    echo "4. Quitter"
    echo "========================================="

    read -p "Choisissez une option (1-4) : " choice

    case $choice in
        1) manual_backup ;;
        2) schedule_backup ;;
        3) list_backups ;;
        4) echo "Quitter..."; exit 0 ;;
        *) echo "Option invalide, veuillez réessayer." ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu..."
done
