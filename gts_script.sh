#!/bin/bash

# Définition des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # Réinitialisation couleur

# Exécuter la préparation du système au démarrage, sans affichage dans le menu
if [ ! -f "/tmp/system_prepared" ]; then
    echo -e "${GREEN}🚀 Préparation initiale du système en cours...${NC}"
    chmod +x ./prepare_system.sh && ./prepare_system.sh
    touch /tmp/system_prepared  # Marqueur pour éviter l'exécution multiple
    echo -e "${GREEN}✅ Système préparé avec succès.${NC}"
    sleep 2  # Petite pause avant d'afficher le menu
fi

# Vérifier si un script existe avant de l'exécuter
execute_script() {
    if [ -f "$1" ]; then
        chmod +x "$1"
        bash "$1"
    else
        echo -e "${RED}⛔ Erreur : Le script $1 est introuvable.${NC}"
    fi
}

# Fonction pour afficher le menu principal
show_menu() {
    clear
    echo -e "${CYAN}========================================="
    echo -e "       🔧 MENU DE GESTION DU SYSTÈME       "
    echo -e "=========================================${NC}"
    echo -e "${YELLOW}1.${NC} Gérer les utilisateurs et les groupes"
    echo -e "${YELLOW}2.${NC} Gérer les tâches automatisées (cron)"
    echo -e "${YELLOW}3.${NC} Surveiller le système (disque, mémoire, processus)"
    echo -e "${YELLOW}4.${NC} Gérer les sauvegardes"
    echo -e "${YELLOW}5.${NC} Configurer la journalisation système"
    echo -e "${YELLOW}6.${NC} Quitter"
    echo -e "${CYAN}=========================================${NC}"
}

# Boucle du menu principal
while true; do
    show_menu
    read -p "🔹 Choisissez une option (1-6) : " choice

    case $choice in
        1) echo -e "${GREEN}➡️ Exécution du script de gestion des utilisateurs...${NC}"
           execute_script "./gts_utilisateurs.sh"
           ;;
        2) echo -e "${GREEN}➡️ Exécution du script de gestion des tâches cron...${NC}"
           execute_script "./gts_cron.sh"
           ;;
        3) echo -e "${GREEN}➡️ Exécution du script de surveillance du système...${NC}"
           execute_script "./gts_surveillance.sh"
           ;;
        4) echo -e "${GREEN}➡️ Exécution du script de gestion des sauvegardes...${NC}"
           execute_script "./gts_sauvegarde.sh"
           ;;
        5) echo -e "${GREEN}➡️ Exécution du script de journalisation du système...${NC}"
           execute_script "./gts_journalisation.sh"
           ;;
        6) echo -e "${GREEN}👋 Quitter...${NC}"
           exit 0
           ;;
        *) echo -e "${RED}⛔ Option invalide, veuillez réessayer.${NC}"
           ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu principal..."
done
