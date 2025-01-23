#!/bin/bash

# Fonction pour afficher les tâches cron actuelles
list_cron_jobs() {
    echo "Tâches cron actuelles :"
    crontab -l
}

# Fonction pour créer une nouvelle tâche cron
create_cron_job() {
    echo "Veuillez entrer la commande à planifier :"
    read -r command
    echo "Veuillez entrer la planification cron (ex. : '0 2 * * *' pour 2h du matin tous les jours) :"
    read -r schedule
    (crontab -l ; echo "$schedule $command") | crontab -
    echo "Tâche cron créée avec succès."
}

# Fonction pour supprimer une tâche cron
delete_cron_job() {
    echo "Tâches cron actuelles :"
    crontab -l
    echo "Veuillez entrer le numéro de la ligne de la tâche cron à supprimer :"
    read -r line_number
    crontab -l | sed "${line_number}d" | crontab -
    echo "Tâche cron supprimée avec succès."
}

# Menu interactif
while true; do
    echo "Menu de gestion des tâches cron"
    echo "1. Afficher les tâches cron actuelles"
    echo "2. Créer une nouvelle tâche cron"
    echo "3. Supprimer une tâche cron"
    echo "4. Quitter"
    read -p "Choisissez une option (1-4) : " choice

    case $choice in
        1)
            list_cron_jobs
            ;;
        2)
            create_cron_job
            ;;
        3)
            delete_cron_job
            ;;
        4)
            echo "Au revoir !"
            break
            ;;
        *)
            echo "Option invalide. Veuillez réessayer."
            ;;
    esac
done
