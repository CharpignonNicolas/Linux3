#!/bin/bash


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
    echo "==========================================================="
    echo "            Menu de gestion de la journalisation           "
    echo "==========================================================="
    echo "1. Configurer la journalisation centralisée"
    echo "2. Configurer la rotation des journaux"
    echo "3. Activer la journalisation avancée (SSH, Apache, MySQL)"
    echo "4. Redémarrer rsyslog"
    echo "5. Vérifier la configuration des journaux"
    echo "6. Quitter"
    read -p "Choisissez une option (1-6) : " choice

    case $choice in
        1) configure_central_logging ;;
        2) configure_log_rotation ;;
        3) configure_advanced_logging ;;
        4) restart_rsyslog ;;
        5) check_logs ;;
        6) echo "Au revoir !"; break ;;
        *) echo "Option invalide. Veuillez réessayer." ;;
    esac

    read -p "Appuyez sur [Entrée] pour revenir au menu..."
done
