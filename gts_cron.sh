#!/bin/bash

# Fonction pour afficher les tâches cron actuelles avec numéros de ligne
list_cron_jobs() {
    if crontab -l &>/dev/null; then
        echo "Tâches cron actuelles :"
        crontab -l | nl  # Numérotation des lignes
    else
        echo "Aucune tâche cron configurée."
    fi
}

# Fonction pour créer une nouvelle tâche cron
create_cron_job() {
    echo "Veuillez entrer la commande à planifier :"
    read -r command
    echo "Veuillez entrer la planification cron (ex. : '0 2 * * *' pour 2h du matin tous les jours) :"
    read -r schedule

    if crontab -l &>/dev/null; then
        (crontab -l; echo "$schedule $command") | crontab - 2>/dev/null  # Ajout sans afficher les messages de sauvegarde
    else
        echo "$schedule $command" | crontab - 2>/dev/null  # Ajout sans afficher les messages de sauvegarde
    fi

    echo "Tâche cron créée avec succès."
}

# Fonction pour supprimer une tâche cron
delete_cron_job() {
    echo "Tâches cron actuelles :"
    crontab -l | nl  # Numérotation des lignes
    echo "Veuillez entrer le numéro de la ligne à supprimer :"
    read -r line_number

    if ! [[ "$line_number" =~ ^[0-9]+$ ]]; then
        echo "Entrée invalide, veuillez entrer un numéro valide."
        return
    fi

    crontab -l | sed "${line_number}d" | crontab - 2>/dev/null  # Suppression sans afficher les messages de sauvegarde
    echo "Tâche cron supprimée avec succès."
}

# Menu interactif de gestion des tâches cron
while true; do
    echo  "========================================="
    echo  "       Menu de gestion des tâches cron    "
    echo  "========================================="
    echo  "1. Afficher les tâches cron actuelles"
    echo  "2. Créer une nouvelle tâche cron"
    echo  "3. Supprimer une tâche cron"
    echo  "4. Quitter"
    echo  "========================================="

    read -p "Choisissez une option (1-4) : " choice

  case $choice in
        1) list_cron_jobs ;;  
        2) create_cron_job ;; 
        3) delete_cron_job ;;  
        4) echo -e "Quitter..."; exit 0 ;;  
        *) echo -e "Option invalide, veuillez réessayer." ;; 
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu..."
done

