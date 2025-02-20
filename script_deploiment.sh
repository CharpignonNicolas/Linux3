#!/bin/bash

# Demander le chemin des fichiers
read -p "Entrez le chemin où se trouvent les scripts : " chemin

# Vérifier si le chemin existe
if [[ ! -d "$chemin" ]]; then
    echo "Erreur : Le chemin spécifié n'existe pas."
    exit 1
fi

# Créer les groupes IT et RH s'ils n'existent pas
sudo groupadd -f IT
sudo groupadd -f RH

# Déplacer gts_script.sh (exécutable par tout le monde)
sudo mv "$chemin/gts_script.sh" "/usr/local/bin/gts_script.sh"
sudo chmod 755 "/usr/local/bin/gts_script.sh"
echo "gts_script.sh déplacé et rendu exécutable pour tous."

# Liste des fichiers et de leurs groupes
scripts="gts_utilisateurs.sh RH
gts_cron.sh ALL
gts_sauvegarde.sh ALL
gts_journalisation.sh IT
activate.quota ALL
gts_surveillance.sh IT
prepare_system.sh ALL"

# Déplacer et configurer les permissions des scripts
while read -r script group; do
    if [[ -f "$chemin/$script" ]]; then
        sudo mv "$chemin/$script" "/usr/local/bin/$script"
 
        if [[ "$group" == "ALL" ]]; then
            sudo chmod 755 "/usr/local/bin/$script"
            echo "$script déplacé et exécutable par tous."
        else
            sudo chown root:$group "/usr/local/bin/$script"
            sudo chmod 750 "/usr/local/bin/$script"
            echo "$script déplacé et accessible uniquement au groupe $group."
        fi
    else
        echo "$script non trouvé dans $chemin."
    fi
done <<< "$scripts"

# Ajouter les groupes RH et IT à sudoers pour leurs scripts
sudo bash -c 'echo "%RH ALL=(ALL) NOPASSWD: /usr/local/bin/gts_utilisateurs.sh" >> /etc/sudoers'
sudo bash -c 'echo "%IT ALL=(ALL) NOPASSWD: /usr/local/bin/gts_journalisation.sh, /usr/local/bin/gts_surveillance.sh" >> /etc/sudoers'

echo "Installation terminée. gts_script.sh est prêt à être utilisé."
echo "Le groupe RH peut gérer les utilisateurs via sudo."
echo "Le groupe IT peut exécuter journalisation et surveillance via sudo."
