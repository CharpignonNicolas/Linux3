# README - Déploiement et Configuration Automatisée

Ce projet propose une série de scripts permettant l’automatisation de la configuration d’un serveur Debian vierge. L’objectif est de simplifier et d’accélérer le déploiement, la gestion des utilisateurs, des groupes, des tâches cron, ainsi que la surveillance et la gestion des logs du système.

---

## Table des matières

1. [Introduction](#introduction)
2. [Prérequis](#prérequis)
3. [Structure du projet](#structure-du-projet)
4. [Utilisation des scripts](#utilisation-des-scripts)
5. [Fonctionnalités des scripts](#fonctionnalités-des-scripts)
6. [Améliorations futures](#améliorations-futures)
7. [License](#license)

---

## Introduction

Ce projet permet de configurer automatiquement une machine Debian vierge à l’aide d'une série de scripts, facilitant le déploiement, la gestion des utilisateurs, des tâches planifiées, ainsi que la mise en place de sauvegardes et de journalisation. L'objectif est de rendre la gestion du système plus simple et plus rapide tout en assurant une automatisation complète des différentes étapes de configuration.

---

## Prérequis

Avant d'exécuter les scripts, assurez-vous que votre machine Debian dispose des éléments suivants :

- Debian 10 ou supérieur.
- Accès root ou sudo pour l’installation de paquets et la modification de configurations système.
- Connexion à Internet pour télécharger les paquets nécessaires.

---

## Structure du projet

Le projet est composé des scripts suivants :

1. **script_deploiement.sh** - Interface utilisateur principale pour le déploiement de la configuration.
2. **script.sh** - Script principal qui centralise les différentes actions.
3. **prepare_system.sh** - Script de préparation du système avant l'exécution des autres scripts.
4. **gts_utilisateurs.sh** - Gestion des utilisateurs et des groupes.
5. **gts_cron.sh** - Automatisation des tâches planifiées avec cron.
6. **gts_surveillance.sh** - Surveillance du système pour détecter les anomalies.
7. **gts_sauvegarde.sh** - Gestion des sauvegardes et restauration des données.
8. **gts_journalisation.sh** - Configuration de la journalisation système avancée.

---

## Utilisation des scripts

1. **Déplacement des scripts et permissions :**  
   Les scripts doivent être placés dans **`/usr/local/bin`** pour pouvoir être exécutés depuis n'importe quel endroit du système. Pour ce faire, exécutez le script **`script_deploiement.sh`**.

2. **Préparation du système :**  
   Avant d’exécuter les autres scripts, il est nécessaire de configurer la machine avec le script **`prepare_system.sh`**, qui s’occupe de l'installation des paquets nécessaires et de la configuration des services essentiels.

3. **Gestion des utilisateurs :**  
   Utilisez le script **`gts_utilisateurs.sh`** pour créer, supprimer des utilisateurs et gérer leurs groupes et quotas.

4. **Automatisation des tâches cron :**  
   Le script **`gts_cron.sh`** vous permet d’afficher, d'ajouter ou de supprimer des tâches cron pour automatiser diverses actions sur le serveur.

5. **Surveillance du système :**  
   Le script **`gts_surveillance.sh`** surveille l’espace disque, les processus actifs, et la mémoire afin de détecter des anomalies.

6. **Sauvegarde des données :**  
   **`gts_sauvegarde.sh`** permet de planifier des sauvegardes automatiques et d'effectuer des sauvegardes manuelles de fichiers ou dossiers.

7. **Journalisation des logs système :**  
   Le script **`gts_journalisation.sh`** configure la journalisation des événements du système à l’aide de **rsyslog** et gère la rotation des logs via **logrotate**.

---

## Fonctionnalités des scripts

### **script_deploiement.sh**  
- Déplacement des scripts dans **`/usr/local/bin`**.
- Attribution des permissions d’exécution.
- Création des groupes nécessaires et configuration de **visudo**.

### **script.sh**  
- Centralisation de l’exécution des scripts via **`/usr/local/bin`**.

### **prepare_system.sh**  
- Configuration du gestionnaire de démarrage **GRUB**.
- Passage au niveau d'exécution **multi-user.target**.
- Mise à jour du système et installation des paquets nécessaires.
- Configuration des quotas disques et vérification des services essentiels (ssh, cron, rsyslog).

### **gts_utilisateurs.sh**  
- Création d’utilisateurs avec mot de passe généré automatiquement.
- Suppression d’utilisateurs et nettoyage des fichiers associés.
- Gestion des groupes et des quotas.
- Activation du mode sudo pour des utilisateurs spécifiques.

### **gts_cron.sh**  
- Affichage, ajout et suppression de tâches cron.
- Gestion de la fréquence d'exécution des tâches avec 5 paramètres.

### **gts_surveillance.sh**  
- Surveillance de l’espace disque, des processus actifs et de la mémoire.
- Liste des processus les plus gourmands en ressources avec identification de l’utilisateur.

### **gts_sauvegarde.sh**  
- Sauvegardes manuelles et planification automatique via cron.
- Affichage des sauvegardes disponibles.

### **gts_journalisation.sh**  
- Configuration de la journalisation centralisée avec **rsyslog**.
- Gestion de la rotation des logs avec **logrotate**.
- Relance automatique de **rsyslog** pour appliquer les changements.

---

## Améliorations futures

- **Optimisation des scripts** : amélioration de la gestion des erreurs et de l'automatisation des tâches.
- **Amélioration de la gestion des logs** : automatisation de la relance de **rsyslog** à la fin des modifications, pour éviter les erreurs humaines.
- **Intégration avec des outils de gestion de configuration** comme Ansible pour un déploiement encore plus automatisé.

---

## License

Ce projet est sous **MIT License**. Vous êtes libre de l'utiliser, de le modifier et de le redistribuer, à condition de respecter les termes de cette licence.  
