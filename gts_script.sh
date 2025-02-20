#!/bin/bash


# Exécuter la préparation du système au démarrage, sans affichage dans le menu
if [ ! -f "/tmp/system_prepared" ]; then
    echo -e "Préparation initiale du système en cours..."
    chmod +x /usr/local/bin/prepare_system.sh && /usr/local/bin/prepare_system.sh
    touch /tmp/system_prepared  # Marqueur pour éviter l'exécution multiple
    echo -e "Système préparé avec succès."
    sleep 2  # Petite pause avant d'afficher le menu
fi

# Vérifier si un script existe avant de l'exécuter
execute_script() {
    if [ -f "$1" ]; then
        chmod +x "$1"
        bash "$1"
    else
        echo " Erreur : Le script $1 est introuvable."
    fi
}

# Fonction pour afficher le menu principal
show_menu() {
    clear
    echo  "=========================================="
    echo  "       MENU DE GESTION DU SYSTÈME         "
    echo  "=========================================="
    echo  "1 Gérer les utilisateurs et les groupes"
    echo  "2 Gérer les tâches automatisées (cron)"
    echo  "3 Surveiller le système (disque, mémoire, processus)"
    echo  "4 Gérer les sauvegardes"
    echo  "5 Configurer la journalisation système"
    echo  "6 Quitter"
    echo  "==========================================="
}

# Boucle du menu principal
while true; do
    show_menu
    read -p "Choisissez une option (1-6) : " choice

    case $choice in
        1) execute_script "/usr/local/bin/gts_utilisateurs.sh"
           ;;
        2) execute_script "/usr/local/bingts_cron.sh"
           ;;
        3) execute_script "/usr/local/bin/gts_surveillance.sh"
           ;;
        4) execute_script "/usr/local/bin/gts_sauvegarde.sh"
           ;;
        5) execute_script "/usr/local/bin/gts_journalisation.sh"
           ;;
        6) echo -e " Quitter..."
           exit 0
           ;;
        *) echo -e "Option invalide, veuillez réessayer."
           ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu principal..."
done
