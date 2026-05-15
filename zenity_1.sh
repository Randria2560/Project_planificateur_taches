#!/bin/bash

# Variables globales
minutes="*"
hours="*"
day_of_month="*"
month="*"
day_of_week="*"
script=""
cron_line=""

menu(){
    while true
    do
        choice=$(zenity --list \
            --title="Task Scheduler" \
            --text="Choose an option:" \
            --radiolist \
            --column="Select" \
            --column="Option" \
            --column="Description" \
            TRUE "1" "List scheduled tasks" \
            FALSE "2" "Add a task" \
            FALSE "3" "Remove a task" \
            FALSE "4" "Exit" \
            --height=300 --width=500)
        
        case $choice in
            1) list_task ;;
            2) add_task ;;
            3) remove_task ;;
            4) exit 0 ;;
            *) exit 0 ;;
        esac
    done
}

list_task(){
    tasks=$(crontab -l 2>/dev/null)
    
    if [ -z "$tasks" ]; then
        zenity --info \
            --title="Scheduled Tasks" \
            --text="No scheduled tasks found" \
            --width=400
    else
        zenity --text-info \
            --title="Scheduled Tasks" \
            --filename=<(crontab -l | nl) \
            --width=700 --height=400
    fi
}

add_task(){
    # Réinitialiser les valeurs
    minutes="*"
    hours="*"
    day_of_month="*"
    month="*"
    day_of_week="*"
    
    # Demander le script/commande
    script=$(zenity --entry \
        --title="Add Task" \
        --text="Enter command or script to execute:" \
        --width=500)
    
    if [ -z "$script" ]; then
        return
    fi
    
    # Choisir le type de planification
    schedule_type=$(zenity --list \
        --title="Scheduling Type" \
        --text="Choose scheduling type:" \
        --radiolist \
        --column="Select" \
        --column="Type" \
        --column="Description" \
        TRUE "hourly" "Execute every hour" \
        FALSE "daily" "Execute once a day" \
        FALSE "weekly" "Execute once a week" \
        FALSE "monthly" "Execute once a month" \
        FALSE "custom" "Custom schedule" \
        --height=350 --width=500)
    
    case $schedule_type in
        hourly) schedule_hourly ;;
        daily) schedule_daily ;;
        weekly) schedule_weekly ;;
        monthly) schedule_monthly ;;
        custom) schedule_custom ;;
        *) return ;;
    esac
    
    # Activer les logs
    if zenity --question \
        --title="Enable Logs" \
        --text="Enable logging for this task?" \
        --width=300; then
        script="$script >> scheduler.log 2>&1"
    fi
    
    # Construire la ligne cron
    cron_line="$minutes $hours $day_of_month $month $day_of_week $script"
    
    # Ajouter la tâche
    add_cron_job
}

schedule_hourly(){
    minutes=$(zenity --entry \
        --title="Hourly Schedule" \
        --text="At which minute? (0-59)" \
        --entry-text="0" \
        --width=300)
}

schedule_daily(){
    result=$(zenity --forms \
        --title="Daily Schedule" \
        --text="Set time:" \
        --add-entry="Hour (0-23):" \
        --add-entry="Minute (0-59):" \
        --separator="|" \
        --width=300)
    
    hours=$(echo "$result" | cut -d'|' -f1)
    minutes=$(echo "$result" | cut -d'|' -f2)
}

schedule_weekly(){
    result=$(zenity --forms \
        --title="Weekly Schedule" \
        --text="Set schedule:" \
        --add-combo="Day of week:" \
        --combo-values="0 (Sunday)|1 (Monday)|2 (Tuesday)|3 (Wednesday)|4 (Thursday)|5 (Friday)|6 (Saturday)" \
        --add-entry="Hour (0-23):" \
        --add-entry="Minute (0-59):" \
        --separator="|" \
        --width=400)
    
    day_of_week=$(echo "$result" | cut -d'|' -f1 | cut -d' ' -f1)
    hours=$(echo "$result" | cut -d'|' -f2)
    minutes=$(echo "$result" | cut -d'|' -f3)
}

schedule_monthly(){
    result=$(zenity --forms \
        --title="Monthly Schedule" \
        --text="Set schedule:" \
        --add-entry="Day of month (1-31):" \
        --add-entry="Hour (0-23):" \
        --add-entry="Minute (0-59):" \
        --separator="|" \
        --width=300)
    
    day_of_month=$(echo "$result" | cut -d'|' -f1)
    hours=$(echo "$result" | cut -d'|' -f2)
    minutes=$(echo "$result" | cut -d'|' -f3)
}

schedule_custom(){
    result=$(zenity --forms \
        --title="Custom Schedule" \
        --text="Enter cron values (use * for any):" \
        --add-entry="Minutes (0-59):" \
        --add-entry="Hours (0-23):" \
        --add-entry="Day of month (1-31):" \
        --add-entry="Month (1-12):" \
        --add-entry="Day of week (0-7):" \
        --separator="|" \
        --width=400)
    
    minutes=$(echo "$result" | cut -d'|' -f1)
    hours=$(echo "$result" | cut -d'|' -f2)
    day_of_month=$(echo "$result" | cut -d'|' -f3)
    month=$(echo "$result" | cut -d'|' -f4)
    day_of_week=$(echo "$result" | cut -d'|' -f5)
}

add_cron_job(){
    if ! crontab -l 2>/dev/null | grep -F "$cron_line" > /dev/null
    then
        (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
        zenity --info \
            --title="Success" \
            --text="Task added successfully!\n\n$cron_line" \
            --width=500
    else
        zenity --warning \
            --title="Warning" \
            --text="This task already exists:\n\n$cron_line" \
            --width=500
    fi
}

remove_task(){
    # Créer un fichier temporaire avec les tâches numérotées
    temp_file=$(mktemp)
    crontab -l 2>/dev/null | nl -w2 -s'. ' > "$temp_file"
    
    if [ ! -s "$temp_file" ]; then
        zenity --info \
            --title="Remove Task" \
            --text="No tasks to remove" \
            --width=300
        rm "$temp_file"
        return
    fi
    
    # Afficher les tâches et demander laquelle supprimer
    task_number=$(zenity --list \
        --title="Remove Task" \
        --text="Select task to remove:" \
        --column="Line" \
        --column="Task" \
        $(cat "$temp_file" | awk '{print $1; $1=""; print $0}') \
        --height=400 --width=700)
    
    rm "$temp_file"
    
    if [ -n "$task_number" ]; then
        # Confirmation
        if zenity --question \
            --title="Confirm" \
            --text="Remove task #$task_number?" \
            --width=300; then
            
            crontab -l | sed "${task_number}d" | crontab -
            
            zenity --info \
                --title="Success" \
                --text="Task #$task_number removed successfully" \
                --width=300
        fi
    fi
}

# Démarrer le menu
menu
