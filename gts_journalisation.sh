#!/bin/bash

# Vérifier et installer rsyslog
install_rsyslog() {
    if dpkg -l | grep -q rsyslog; then
        echo "rsyslog est déjà installé."
    else
        echo "Installation de rsyslog..."
        sudo apt update && sudo apt install -y rsyslog
        echo "rsyslog installé avec succès."
    fi
}

# Configurer la journalisation centralisée
configure_central_logging() {
    log_file="/var/log/syslog-central.log"
    
    if ! grep -q "$log_file" /etc/rsyslog.conf; then
        echo "Configuration de la journalisation centralisée..."
        echo "*.*    $log_file" | sudo tee -a /etc/rsyslog.conf
        echo "Journalisation centralisée activée dans $log_file."
    else
        echo "La journalisation centralisée est déjà configurée."
    fi
}

# Mise en place de la rotation des journaux
configure_log_rotation() {
    logrotate_file="/etc/logrotate.d/custom_logs"

    echo "Création de la rotation des logs..."
    sudo tee "$logrotate_file" > /dev/null <<EOL
/var/log/syslog-central.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOL

    echo "Rotation des logs configurée (7 jours, compression activée)."
}

# Activer la journalisation avancée pour les services critiques
configure_advanced_logging() {
    echo "Activation de la journalisation avancée pour SSH, Apache et MySQL..."

    sudo tee -a /etc/rsyslog.d/custom_services.conf > /dev/null <<EOL
if \$programname == 'sshd' then /var/log/ssh.log
if \$programname == 'apache2' then /var/log/apache.log
if \$programname == 'mysqld' then /var/log/mysql.log
EOL

    echo "Journalisation avancée activée pour SSH (/var/log/ssh.log), Apache (/var/log/apache.log) et MySQL (/var/log/mysql.log)."
}

# Redémarrer le service rsyslog
restart_rsyslog() {
    echo "Redémarrage du service rsyslog..."
    sudo systemctl restart rsyslog
    echo "rsyslog redémarré avec succès."
}

# Vérifier la configuration des journaux
check_logs() {
    echo "Vérification des fichiers de log..."
    ls -lh /var/log/syslog-central.log /var/log/ssh.log /var/log/apache.log /var/log/mysql.log 2>/dev/null || echo "Certains fichiers de log n'existent pas encore."
    echo "Dernières lignes des logs :"
    sudo tail -n 10 /var/log/syslog-central.log 2>/dev/null
}

# Menu interactif
while true; do
    echo "=== Menu de gestion de la journalisation ==="
    echo "1. Vérifier et installer rsyslog"
    echo "2. Configurer la journalisation centralisée"
    echo "3. Configurer la rotation des journaux"
    echo "4. Activer la journalisation avancée (SSH, Apache, MySQL)"
    echo "5. Redémarrer rsyslog"
    echo "6. Vérifier la configuration des journaux"
    echo "7. Quitter"
    read -p "Choisissez une option (1-7) : " choice

    case $choice in
        1) install_rsyslog ;;
        2) configure_central_logging ;;
        3) configure_log_rotation ;;
        4) configure_advanced_logging ;;
        5) restart_rsyslog ;;
        6) check_logs ;;
        7) echo "Au revoir !"; break ;;
        *) echo "Option invalide. Veuillez réessayer." ;;
    esac
done
