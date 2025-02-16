#!/bin/bash

echo "=== Préparation du système Debian ==="

# 1. Configuration du gestionnaire de démarrage GRUB
configure_grub() {
    echo "Configuration de GRUB..."
    sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=2/' /etc/default/grub
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/' /etc/default/grub
    sudo update-grub
    echo "GRUB configuré avec succès (démarrage rapide activé)."
}

# 2. Configurer le niveau d'exécution (multi-user.target)
configure_runlevel() {
    echo "Configuration du niveau d'exécution (multi-user.target)..."
    sudo systemctl set-default multi-user.target
    echo "Le système démarrera désormais sans interface graphique."
}

# 3. Vérification et mise à jour du système
update_system() {
    echo "Mise à jour du système en cours..."
    sudo apt update && sudo apt upgrade -y
    echo "Mise à jour terminée."
}

# 4. Vérifier l’état des services critiques
check_services() {
    echo "Vérification des services critiques..."
    services=("rsyslog" "cron" "ssh")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            echo "✅ Service $service est actif."
        else
            echo "⚠️ Service $service est inactif, démarrage en cours..."
            sudo systemctl start "$service"
            sudo systemctl enable "$service"
        fi
    done
}

# 5. Configuration des quotas disque (optionnel)
configure_disk_quota() {
    echo "Configuration des quotas disque..."
    sudo apt install -y quota
    sudo mount -o remount,usrquota,grpquota /
    sudo quotacheck -avugm
    sudo quotaon -avug
    echo "Quotas disque activés."
}

# Exécution des fonctions
configure_grub
configure_runlevel
update_system
check_services
configure_disk_quota

echo "✅ Préparation du système terminée ! Redémarrage recommandé."
