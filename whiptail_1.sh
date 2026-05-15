#!/bin/bash

while true; do
    choix=$(whiptail --title "SYS MANAGER (whiptail)" \
    --menu "Choisis une option :" 15 50 4 \
    "1" "Afficher date" \
    "2" "Lister fichiers" \
    "3" "Utilisateur" \
    "4" "Quitter" 3>&1 1>&2 2>&3)

    clear

    case $choix in
        1)
            echo "📅 $(date)"
            ;;
        2)
            ls -lah
            ;;
        3)
            echo "👤 $USER"
            ;;
        4)
            echo "Bye"
            break
            ;;
    esac

    read -p "Entrer..."
done
