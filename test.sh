#!/bin/bash

menu(){

while true
do

choice=$(yad --list \
    --title="Task Manager" \
    --width=800 \
    --height=800 \
    --center \
    --column="Task Scheduler" \
    "1. List scheduled tasks" \
    "2. Add a task" \
    "3. Remove a task" \
    "4. Exit"
)

# utilisateur clique sur X
[ $? -ne 0 ] && break

case "$choice" in

    "1. List scheduled tasks")
        list_task
        ;;

    "2. Add a task")
        add_task
        ;;

    "3. Remove a task")
        remove_task
        ;;

    "4. Exit")
        exit_menu
        ;;

    *)
        yad --error --text="Invalid option"
        ;;
esac

done
}

list_task(){

task=$(crontab -l 2>/dev/null)

echo "$task" | yad --text-info \
    --title="Scheduled Tasks" \
    --width=700 \
    --height=400

}

exit_menu(){
    exit
}

menu
