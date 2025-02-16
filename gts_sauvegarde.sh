#!/bin/bash

# Définition des couleurs pour une meilleure lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # Réinitialisation couleur

# Dossier où seront stockées les sauvegardes
BACKUP_DIR="/var/backups/system_backups"

# Vérifier si le dossier de sauvegarde existe, sinon le créer
mkdir -p "$BACKUP_DIR"

# Fonction pour effectuer une sauvegarde manuelle
manual_backup() {
    read -p "Entrez le chemin du dossier à sauvegarder : " folder

    if [ ! -d "$folder" ]; then
        echo -e "${RED}⛔ Erreur : Le dossier n'existe pas.${NC}"
        return
    fi

    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_name="backup_$(basename "$folder")_$timestamp.tar.gz"
    
    echo -e "${GREEN}📦 Sauvegarde en cours...${NC}"
    tar -czf "$BACKUP_DIR/$backup_name" "$folder"

    echo -e "${GREEN}✅ Sauvegarde terminée : $BACKUP_DIR/$backup_name${NC}"
}

# Fonction pour planifier une sauvegarde automatique via cron
schedule_backup() {
    read -p "Entrez le chemin du dossier à sauvegarder automatiquement : " folder

    if [ ! -d "$folder" ]; then
        echo -e "${RED}⛔ Erreur : Le dossier n'existe pas.${NC}"
        return
    fi

    read -p "À quelle fréquence voulez-vous sauvegarder ? (ex: '0 2 * * *' pour 2h du matin chaque jour) : " cron_schedule

    cron_command="$cron_schedule tar -czf $BACKUP_DIR/backup_$(basename "$folder")_$(date +\%Y\%m\%d_\%H\%M\%S).tar.gz $folder"

    # Ajouter la tâche au crontab
    (crontab -l 2>/dev/null; echo "$cron_command") | crontab -

    echo -e "${GREEN}✅ Sauvegarde automatique programmée !${NC}"
}

# Fonction pour lister les sauvegardes disponibles
list_backups() {
    echo -e "${CYAN}📂 Sauvegardes disponibles :${NC}"
    ls -lh "$BACKUP_DIR"
}

# Fonction pour restaurer une sauvegarde
restore_backup() {
    list_backups
    read -p "Entrez le nom du fichier de sauvegarde à restaurer : " backup_file

    if [ ! -f "$BACKUP_DIR/$backup_file" ]; then
        echo -e "${RED}⛔ Erreur : Fichier de sauvegarde introuvable.${NC}"
        return
    fi

    read -p "Entrez le dossier où restaurer la sauvegarde : " restore_folder
    mkdir -p "$restore_folder"

    echo -e "${GREEN}🔄 Restauration en cours...${NC}"
    tar -xzf "$BACKUP_DIR/$backup_file" -C "$restore_folder"

    echo -e "${GREEN}✅ Restauration terminée dans : $restore_folder${NC}"
}

# Menu interactif
while true; do
    echo -e "${CYAN}========================================="
    echo -e "       🔄 MENU DE SAUVEGARDE       "
    echo -e "=========================================${NC}"
    echo -e "${YELLOW}1.${NC} Sauvegarde manuelle"
    echo -e "${YELLOW}2.${NC} Planifier une sauvegarde automatique"
    echo -e "${YELLOW}3.${NC} Lister les sauvegardes disponibles"
    echo -e "${YELLOW}4.${NC} Restaurer une sauvegarde"
    echo -e "${YELLOW}5.${NC} Quitter"
    echo -e "${CYAN}=========================================${NC}"

    read -p "🔹 Choisissez une option (1-5) : " choice

    case $choice in
        1) manual_backup ;;
        2) schedule_backup ;;
        3) list_backups ;;
        4) restore_backup ;;
        5) echo -e "${GREEN}👋 Quitter...${NC}"; exit 0 ;;
        *) echo -e "${RED}⛔ Option invalide, veuillez réessayer.${NC}" ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu..."
done
