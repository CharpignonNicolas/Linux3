#!/bin/bash

# Définition des couleurs pour une meilleure lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # Réinitialisation couleur

# Vérifier si un script existe avant de l'exécuter
execute_script() {
    if [ -f "$1" ]; then
        chmod +x "$1"
        bash "$1"
    else
        echo -e "${RED}Erreur : Le script $1 est introuvable.${NC}"
    fi
}

# Fonction pour afficher le menu principal
show_menu() {
    clear
    echo -e "${CYAN}========================================="
    echo -e "       🔧 MENU DE GESTION DU SYSTÈME       "
    echo -e "=========================================${NC}"
    echo -e "${YELLOW}1.${NC} Préparer le système (GRUB, niveaux d'exécution, quotas...)"
    echo -e "${YELLOW}2.${NC} Gérer les utilisateurs et les groupes"
    echo -e "${YELLOW}3.${NC} Gérer les tâches automatisées (cron)"
    echo -e "${YELLOW}4.${NC} Surveiller le système (disque, mémoire, processus)"
    echo -e "${YELLOW}5.${NC} Gérer les sauvegardes"
    echo -e "${YELLOW}6.${NC} Configurer la journalisation système"
    echo -e "${YELLOW}7.${NC} Quitter"
    echo -e "${CYAN}=========================================${NC}"
}

# Boucle du menu principal
while true; do
    show_menu
    read -p "🔹 Choisissez une option (1-7) : " choice

    case $choice in
        1) echo -e "${GREEN}➡️ Exécution du script de préparation du système...${NC}"
           execute_script "./prepare_system.sh"
           ;;
        2) echo -e "${GREEN}➡️ Exécution du script de gestion des utilisateurs...${NC}"
           execute_script "./gts_utilisateurs.sh"
           ;;
        3) echo -e "${GREEN}➡️ Exécution du script de gestion des tâches cron...${NC}"
           execute_script "./gts_cron.sh"
           ;;
        4) echo -e "${GREEN}➡️ Exécution du script de surveillance du système...${NC}"
           execute_script "./gts_surveillance.sh"
           ;;
        5) echo -e "${GREEN}➡️ Exécution du script de gestion des sauvegardes...${NC}"
           execute_script "./gts_sauvegarde.sh"
           ;;
        6) echo -e "${GREEN}➡️ Exécution du script de journalisation du système...${NC}"
           execute_script "./gts_journalisation.sh"
           ;;
        7) echo -e "${GREEN}👋 Quitter...${NC}"
           exit 0
           ;;
        *) echo -e "${RED}⛔ Option invalide, veuillez réessayer.${NC}"
           ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu principal..."
done
