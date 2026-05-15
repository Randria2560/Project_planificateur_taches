#!/bin/bash

cron_line=""

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
		echo "[$choice]"

		    case $choice in
			"1. List scheduled tasks|") list_task 
				;;
			"2. Add a task|") add_task 
				;;
			"3. Remove a task|") remove_task 
				;;
			"4. Exit|") exit_menu 
				;;
			*) echo "Invalid Option" 
				;;
			esac
	done

	}

	list_task(){

	task=$(crontab -l 2>/dev/null)

	if [[ -z "$task" ]]
	then
	    task="No scheduled tasks found."
	fi

	yad --text-info \
	    --title="Scheduled Tasks" \
	    --width=700 \
	    --height=400 \
	    --filename=<(echo "$task")

	}



	add_task(){

	    # Valeurs par défaut cron
	    minutes="*"
	    hours="*"
	    day_of_month="*"
	    month="*"
	    day_of_week="*"

	    script=$(yad --entry \
		    --title="Enter the command" \
		    --text="Enter command or script to execute:"
	           )

	    nb=$(yad --list \
		    --title="Liste des interférences:" \
		    --center \
	    	    --column= "Choose scheduling type:" \
	    		 "1. Hourly" \
	    		 "2. Daily" \
	    		 "3. Weekly" \
	    		 "4. Monthly" \
	    		 "5. Custom"
   		 )

		case $nb in
		    "1. Hourly|")
			hourly
			break
			;;
		    "2. Daily|")
			daily
			break
			;;
		    "3. Weekly|")
			weekly
			break
			;;
		    "4. Monthly|")
			monthly
			break
			;;
		   "5. Custom|")
			personnalise
			break
			;;
		    *)
			echo "Invalid option. Try again."
			;;
		esac
	   


	    # Journalisation
	    read -p "Enable logs? (yes/no): " log

	    if [[ "$log" == "yes" ]]
	    then
		script="$script >> scheduler.log 2>&1"
	    fi

	    cron_line="$minutes $hours $day_of_month $month $day_of_week $script"
	    add_cron_job
	    read -p "Press Enter to continue..."
	}	

	hourly(){
	    read -p "Minute (0-59): " minutes
	}

	daily(){
	    read -p "Hour (0-23): " hours
	    read -p "Minute (0-59): " minutes
	}

	weekly(){
	    read -p "Day of week (0=Sun ... 6=Sat): " day_of_week
	    read -p "Hour (0-23): " hours
	    read -p "Minute (0-59): " minutes
	}

	monthly(){
	    read -p "Day of month (1-31): " day_of_month
	    read -p "Hour (0-23): " hours
	    read -p "Minute (0-59): " minutes
	}

	personnalise(){
	    read -p "Minutes: " minutes
	    read -p "Hours: " hours
	    read -p "Day of month: " day_of_month
	    read -p "Month: " month
	    read -p "Day of week: " day_of_week
	}

	add_cron_job(){
		if ! crontab -l 2> /dev/null | grep -F "$cron_line" > /dev/null
		then
			(crontab -l 2> /dev/null ; echo "$cron_line") | crontab -
			echo "Tache ajoutée: $cron_line"
		else
			echo "Tache déja présente: $cron_line"
		fi

	}

	remove_task(){
    		crontab -l | nl
    		read -p "Entrer le numéro de la tache à effacer: " nbr
    		crontab -l | sed "${nbr}d" | crontab -
    		echo "Tache à la ligne $nbr supprimée"
    		read -p "Press Enter to continue..."
	}

	exit_menu(){
	    exit
	}

	menu
