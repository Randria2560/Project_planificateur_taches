#!/bin/bash
#
# Task Scheduler - Application de gestion de tâches cron
# Nécessite: yad (sudo apt install yad)
#

ICON="appointment-new"
TITLE="Task Scheduler"

# Fonction principale
main_window() {
    while true; do
        action=$(yad --width=500 --height=300 \
            --title="$TITLE" \
            --text="<b>Gestionnaire de tâches planifiées</b>\n" \
            --form \
            --field="":LBL "" \
            --field="Afficher les tâches:BTN" "bash -c 'show_tasks'" \
            --field="Ajouter une tâche:BTN" "bash -c 'add_task_window'" \
            --field="Supprimer une tâche:BTN" "bash -c 'remove_task_window'" \
            --field="":LBL "" \
            --button="Rafraîchir:2" \
            --button="Quitter:1")
        
        ret=$?
        
        case $ret in
            1) exit 0 ;;  # Quitter
            2) continue ;; # Rafraîchir
            *) exit 0 ;;
        esac
    done
}

# Afficher les tâches
show_tasks() {
    tasks=$(crontab -l 2>/dev/null)
    
    if [ -z "$tasks" ]; then
        yad --info \
            --title="$TITLE" \
            --text="Aucune tâche planifiée" \
            --width=300 \
            --button="OK:0"
    else
        # Créer un tableau formaté
        output=""
        line_num=1
        while IFS= read -r line; do
            # Extraire les champs cron
            min=$(echo "$line" | awk '{print $1}')
            hour=$(echo "$line" | awk '{print $2}')
            day=$(echo "$line" | awk '{print $3}')
            month=$(echo "$line" | awk '{print $4}')
            dow=$(echo "$line" | awk '{print $5}')
            cmd=$(echo "$line" | cut -d' ' -f6-)
            
            output+="$line_num|$min|$hour|$day|$month|$dow|$cmd\n"
            ((line_num++))
        done <<< "$tasks"
        
        echo -e "$output" | yad --list \
            --title="$TITLE - Tâches planifiées" \
            --text="Liste des tâches cron:" \
            --column="#" \
            --column="Min" \
            --column="Heure" \
            --column="Jour" \
            --column="Mois" \
            --column="J.Sem" \
            --column="Commande" \
            --width=800 --height=400 \
            --button="Fermer:0"
    fi
}

# Fenêtre d'ajout de tâche
add_task_window() {
    # Formulaire initial
    result=$(yad --form \
        --title="$TITLE - Ajouter une tâche" \
        --text="Configuration de la nouvelle tâche:" \
        --field="Commande ou script:" "" \
        --field="Type de planification:CB" "Toutes les heures!Tous les jours!Toutes les semaines!Tous les mois!Personnalisé" \
        --field="Activer les logs:CHK" "FALSE" \
        --width=500 \
        --button="Annuler:1" \
        --button="Suivant:0")
    
    ret=$?
    [ $ret -ne 0 ] && return
    
    # Extraire les valeurs
    command=$(echo "$result" | cut -d'|' -f1)
    schedule_type=$(echo "$result" | cut -d'|' -f2)
    enable_log=$(echo "$result" | cut -d'|' -f3)
    
    if [ -z "$command" ]; then
        yad --error --text="La commande est obligatoire!" --width=300
        return
    fi
    
    # Construire le cron selon le type
    case "$schedule_type" in
        "Toutes les heures")
            time_result=$(yad --form \
                --title="Planification horaire" \
                --field="À quelle minute? (0-59):" "0" \
                --width=300 \
                --button="Annuler:1" \
                --button="OK:0")
            [ $? -ne 0 ] && return
            
            minute=$(echo "$time_result" | cut -d'|' -f1)
            cron_schedule="$minute * * * *"
            ;;
            
        "Tous les jours")
            time_result=$(yad --form \
                --title="Planification quotidienne" \
                --field="Heure (0-23):" "0" \
                --field="Minute (0-59):" "0" \
                --width=300 \
                --button="Annuler:1" \
                --button="OK:0")
            [ $? -ne 0 ] && return
            
            hour=$(echo "$time_result" | cut -d'|' -f1)
            minute=$(echo "$time_result" | cut -d'|' -f2)
            cron_schedule="$minute $hour * * *"
            ;;
            
        "Toutes les semaines")
            time_result=$(yad --form \
                --title="Planification hebdomadaire" \
                --field="Jour:CB" "0 - Dimanche!1 - Lundi!2 - Mardi!3 - Mercredi!4 - Jeudi!5 - Vendredi!6 - Samedi" \
                --field="Heure (0-23):" "0" \
                --field="Minute (0-59):" "0" \
                --width=350 \
                --button="Annuler:1" \
                --button="OK:0")
            [ $? -ne 0 ] && return
            
            day_of_week=$(echo "$time_result" | cut -d'|' -f1 | cut -d' ' -f1)
            hour=$(echo "$time_result" | cut -d'|' -f2)
            minute=$(echo "$time_result" | cut -d'|' -f3)
            cron_schedule="$minute $hour * * $day_of_week"
            ;;
            
        "Tous les mois")
            time_result=$(yad --form \
                --title="Planification mensuelle" \
                --field="Jour du mois (1-31):" "1" \
                --field="Heure (0-23):" "0" \
                --field="Minute (0-59):" "0" \
                --width=300 \
                --button="Annuler:1" \
                --button="OK:0")
            [ $? -ne 0 ] && return
            
            day=$(echo "$time_result" | cut -d'|' -f1)
            hour=$(echo "$time_result" | cut -d'|' -f2)
            minute=$(echo "$time_result" | cut -d'|' -f3)
            cron_schedule="$minute $hour $day * *"
            ;;
            
        "Personnalisé")
            time_result=$(yad --form \
                --title="Planification personnalisée" \
                --text="Utilisez * pour 'tous' ou des valeurs spécifiques" \
                --field="Minutes (0-59):" "*" \
                --field="Heures (0-23):" "*" \
                --field="Jour du mois (1-31):" "*" \
                --field="Mois (1-12):" "*" \
                --field="Jour de la semaine (0-7):" "*" \
                --width=400 \
                --button="Annuler:1" \
                --button="OK:0")
            [ $? -ne 0 ] && return
            
            minute=$(echo "$time_result" | cut -d'|' -f1)
            hour=$(echo "$time_result" | cut -d'|' -f2)
            day=$(echo "$time_result" | cut -d'|' -f3)
            month=$(echo "$time_result" | cut -d'|' -f4)
            dow=$(echo "$time_result" | cut -d'|' -f5)
            cron_schedule="$minute $hour $day $month $dow"
            ;;
    esac
    
    # Ajouter la redirection des logs si demandé
    if [ "$enable_log" = "TRUE" ]; then
        command="$command >> ~/scheduler.log 2>&1"
    fi
    
    # Construire la ligne cron complète
    cron_line="$cron_schedule $command"
    
    # Vérifier si la tâche existe déjà
    if crontab -l 2>/dev/null | grep -F "$cron_line" > /dev/null; then
        yad --warning \
            --title="$TITLE" \
            --text="Cette tâche existe déjà:\n\n<tt>$cron_line</tt>" \
            --width=500 \
            --button="OK:0"
    else
        # Ajouter la tâche
        (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
        
        yad --info \
            --title="$TITLE" \
            --text="✓ Tâche ajoutée avec succès!\n\n<tt>$cron_line</tt>" \
            --width=500 \
            --button="OK:0"
    fi
}

# Fenêtre de suppression
remove_task_window() {
    tasks=$(crontab -l 2>/dev/null)
    
    if [ -z "$tasks" ]; then
        yad --info \
            --title="$TITLE" \
            --text="Aucune tâche à supprimer" \
            --width=300 \
            --button="OK:0"
        return
    fi
    
    # Créer la liste des tâches
    output=""
    line_num=1
    while IFS= read -r line; do
        output+="$line_num|$line\n"
        ((line_num++))
    done <<< "$tasks"
    
    # Sélectionner la tâche à supprimer
    selected=$(echo -e "$output" | yad --list \
        --title="$TITLE - Supprimer une tâche" \
        --text="Sélectionnez la tâche à supprimer:" \
        --column="Ligne" \
        --column="Tâche" \
        --width=700 --height=300 \
        --button="Annuler:1" \
        --button="Supprimer:0")
    
    ret=$?
    [ $ret -ne 0 ] && return
    
    # Extraire le numéro de ligne
    line_to_delete=$(echo "$selected" | cut -d'|' -f1)
    
    if [ -n "$line_to_delete" ]; then
        # Confirmation
        yad --question \
            --title="$TITLE" \
            --text="Confirmer la suppression de la tâche #$line_to_delete ?" \
            --width=350 \
            --button="Annuler:1" \
            --button="Supprimer:0"
        
        if [ $? -eq 0 ]; then
            # Supprimer la ligne
            crontab -l | sed "${line_to_delete}d" | crontab -
            
            yad --info \
                --title="$TITLE" \
                --text="✓ Tâche #$line_to_delete supprimée" \
                --width=300 \
                --button="OK:0"
        fi
    fi
}

# Export des fonctions pour les sous-shells
export -f show_tasks
export -f add_task_window
export -f remove_task_window
export TITLE

# Vérifier si YAD est installé
if ! command -v yad &> /dev/null; then
    echo "Erreur: YAD n'est pas installé"
    echo "Installation: sudo apt install yad"
    exit 1
fi

# Lancer l'application
main_window
