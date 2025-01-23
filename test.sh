#!/bin/bash

USERNAME=$(whoami)
ls -R /home/$USERNAME

# Fonction pour sauvegarder un dossier sélectionné
sauvegarde_manuelle() {
	echo "Sélectionnez le dossier ou fichier à sauvegarder :"
	read -p "Entrez le chemin du fichier/dossier à sauvegarder (sans le /home/username) : " source
    	if [ -e "$source" ]; then
		read -p "Entrez votre département : " departement
		if [[ "$(groups | tr ' ' '\n' | grep -x "$departement")" ]]; then
            		cp -r /home/$USERNAME/$source /ShareFolders/$departement
            		echo "Sauvegarde de '$source' vers '/ShareFolders/$departement' réussie."
		else
			echo "Vous n'avez pas le droit sur ce groupe / Groupe inexistant"
		fi
	else
		echo "Le fichier ou dossier source n'existe pas. Veuillez réessayer."

        fi
}

# Fonction pour configurer une tâche cron pour sauvegarde automatique
configurer_cron() {
    echo "Configurer la tâche cron pour la sauvegarde automatique."
    echo "Entrez l'heure à laquelle vous souhaitez effectuer la sauvegarde (format 24h, ex: 02 pour 2h) :"
    read -p "Heure : " heure
    echo "Entrez la minute à laquelle vous souhaitez effectuer la sauvegarde (ex: 30 pour 30 minutes) :"
    read -p "Minute : " minute

# Demander le fichiers à sauvegarder
	read -p "Selectionner le fichier /Dossier à mettre en sauvegarde automatique :" source_fichier
	read -p "selectionner votre departement : " departement
	emplacement="/home/$USERNAME/$source_fichier"
	if [[ "$(groups | tr ' ' '\n' | grep -x "$departement")" ]]; then
		echo "Dans le bon departement"
        else
                echo "Vous n'avez pas le droit sur ce groupe / Groupe inexistant"
        fi

	# Créer un script de sauvegarde qui sera appelé par cron
	script_sauvegarde="/tmp/script_sauvegarde.sh"
	echo "#!/bin/bash" > "$script_sauvegarde"
	echo "cp -r $emplacement /ShareFolders/$departement" >> "$script_sauvegarde"
	chmod +x "$script_sauvegarde"

	# Ajouter une tâche cron pour exécuter la sauvegarde à l'heure spécifiée
    	(crontab -l 2>/dev/null; echo "$minute $heure * * * $script_sauvegarde") | crontab -
    	echo "Tâche cron ajoutée pour sauvegarder tous les jours à $heure:$minute."
}

# Menu principal
while true; do
    clear
    echo "==== Menu de Sauvegarde ===="
    echo "1. Sauvegarde manuelle"
    echo "2. Configurer une sauvegarde automatique"
    echo "3. Quitter"
    read -p "Choisissez une option (1-3) : " option

    case $option in
        1)
            sauvegarde_manuelle
            ;;
        2)
            configurer_cron
            ;;
        3)
            echo "Au revoir!"
            exit 0
            ;;
        *)
            echo "Option invalide. Essayez de nouveau."
            ;;
    esac

    read -p "Appuyez sur Entrée pour revenir au menu..."
done
