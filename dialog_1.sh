#!/bin/bash

while true; do
    choix=$(dialog --clear --title "SYS MANAGER (dialog)" \
    --menu "Choisis une option :" 15 50 4 \
    1 "Afficher la date" \
    2 "Lister fichiers" \
    3 "Afficher utilisateur" \
    4 "Quitter" \
    3>&1 1>&2 2>&3)

    clear

    case $choix in
        1)
            echo "📅 Date : $(date)"
            ;;
        2)
            echo "📁 Fichiers :"
            ls -lah
            ;;
        3)
            echo "👤 User : $USER"
            ;;
        4)
            echo "👋 Fin dialog"
            break
            ;;
        *)
            echo "Aucune sélection"
            break
            ;;
    esac

    read -p "Entrer pour continuer..."
done
