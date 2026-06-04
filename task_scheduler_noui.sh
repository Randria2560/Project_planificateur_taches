#!/bin/bash

cron_line=""

menu(){
	while true; do
		clear
		echo "1. List scheduled tasks"
		echo "2. Add a task"
		echo "3. Remove a task"
		echo "4. Exit"
		read -p "Choice: " choice
		case $choice in
			1) list_task   ;;
			2) add_task    ;;
			3) remove_task ;;
			4) exit        ;;
		esac
	done
}

list_task(){
	clear
	task=$(crontab -l 2>/dev/null)
	[[ -z "$task" ]] && echo "No scheduled tasks found." || echo "$task" | nl
	read -p "Press Enter to continue..."
}

add_task(){
	clear
	minutes="*"; hours="*"; day_of_month="*"; month="*"; day_of_week="*"

	read -p "Command: " script

	echo "1.Hourly 2.Daily 3.Weekly 4.Monthly 5.Custom"
	read -p "Choice: " nb
	case $nb in
		1) read -p "Minute(0-59): " minutes ;;
		2) read -p "Hour(0-23): " hours   ; read -p "Minute(0-59): " minutes ;;
		3) read -p "Day(0-6): " day_of_week ; read -p "Hour(0-23): " hours ; read -p "Minute(0-59): " minutes ;;
		4) read -p "Day(1-31): " day_of_month ; read -p "Hour(0-23): " hours ; read -p "Minute(0-59): " minutes ;;
		5) read -p "Min: " minutes ; read -p "Hour: " hours ; read -p "DOM: " day_of_month ; read -p "Mon: " month ; read -p "DOW: " day_of_week ;;
	esac

	read -p "Enable logs? (yes/no): " log
	[[ "$log" == "yes" ]] && script="$script >> scheduler.log 2>&1"

	cron_line="$minutes $hours $day_of_month $month $day_of_week $script"

	if crontab -l 2>/dev/null | grep -qF "$cron_line"; then
		echo "Task already exists."
	else
		(crontab -l 2>/dev/null; echo "$cron_line") | crontab -
		echo "Task added: $cron_line"
	fi
	read -p "Press Enter to continue..."
}

remove_task(){
	clear
	task=$(crontab -l 2>/dev/null)
	if [[ -z "$task" ]]; then
		echo "No scheduled tasks found."
		read -p "Press Enter to continue..."
		return
	fi
	echo "$task" | nl
	read -p "Line to remove: " nbr
	crontab -l | sed "${nbr}d" | crontab -
	echo "Line $nbr removed."
	read -p "Press Enter to continue..."
}

menu