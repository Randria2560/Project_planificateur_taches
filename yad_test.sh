#!/bin/bash


yad --info \
   --title="Bienvenu" \
   --width=500
   --height=300
   --text="Bonjour"

nom=$(yad --entry \
         --title="Connexion" \
	 --text="Votre nom: ")

echo "[$nom]"
yad --info --text="Bonjour $nom"

choix=$(yad --list \
	--title="task manager" \
	--column="Option" \
	"Process"\
	"CPU"\
	"Quitter")

case $choix in
	"Voir")
		yad --text-info --filename=<(ps aux) 
		;;

	"CPU");;
		yad --info --text="$(top -bn1 | head -5)"
	"Quitter")
		exit
		;;
esac
