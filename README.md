# Project_planificateur_taches

# 📅 Scheduler — Gestionnaire de tâches cron multi-interfaces

> Gérez vos tâches planifiées Linux via **5 interfaces** : terminal C, GUI Qt, GUI Tkinter, dialogs YAD et script Bash pur.

![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)
![Languages](https://img.shields.io/badge/languages-C%20%7C%20C%2B%2B%20%7C%20Python%20%7C%20Bash-orange)

---

## ✨ Fonctionnalités

- 📋 **Lister** les tâches cron existantes avec numérotation
- ➕ **Ajouter** une tâche — fréquences prédéfinies (horaire, quotidienne, hebdomadaire, mensuelle) ou personnalisée
- 🗑️ **Supprimer** une tâche par son numéro de ligne
- 📝 **Journalisation** optionnelle vers `task_scheduler.log`
- 🔁 Détection des doublons avant insertion

---

## 🗂️ Structure du dépôt

```
scheduler/
├── bash/            # Script Bash pur (menu terminal)
|    ├── task_scheduler.sh/        # Script Bash + YAD (dialogs GTK)
|    ├── task_scheduler_no_ui.sh    #Bash no UI
├── c/               # 
├── cpp/          # Interface graphique Qt 6 (C++)
├── python/       # Interface graphique Tkinter (Python)
├── docs/
│   └── livrable.tex # Livrable technique LaTeX
└── README.md
```

---

## 🚀 Installation

### Prérequis

```bash
sudo apt update && sudo apt install -y \
  build-essential libncurses-dev \
  qt6-base-dev cmake \
  python3 python3-tk \
  yad
```

### Compilation

```bash
# Module C
cd c/ && make

# Module C++ / Qt
cd cpp_qt/
cmake -B build && cmake --build build
```

Les modules **Python**, **Bash** et **Bash/YAD** ne nécessitent aucune compilation.

---

## ▶️ Utilisation

| Interface | Commande |
|-----------|----------|
| Bash pur | `bash bash/task_scheduler.sh` |
| Bash + YAD | `bash bash_yad/task_scheduler.sh` |
| C | `./c/scheduler_c` |
| C++ / Qt | `./cpp_qt/build/scheduler` |
| Python / Tk | `python3 python_tk/task_scheduler.py` |

---

## 📐 Syntaxe cron rappel

```
MIN  HEURE  JOUR_MOIS  MOIS  JOUR_SEM  COMMANDE
 *     *        *        *      *       /chemin/script.sh
```

**Exemples :**

```bash
# Toutes les heures, à la 30e minute
30 * * * * /usr/bin/backup.sh

# Tous les jours à 3h du matin, avec log
0 3 * * * /opt/clean.sh >> task_task_scheduler.log 2>&1

# Tous les lundis à 08h15
15 8 * * 1 /usr/bin/report.sh
```

---

## 🛠️ Technologies

| Module | Langage | UI |
|--------|---------|----|
| `bash/` | Bash | Terminal interactif |
| `bash_yad/` | Bash + YAD | Dialogs GTK natifs |
| `c/` | C | No Interface |
| `cpp_qt/` | C++ 17 + Qt 6 | GUI native Qt |
| `python_tk/` | Python 3 + Tkinter | GUI Tkinter |

---

## 📄 Documentation

Le livrable technique complet (architecture, extraits de code, tests) est disponible en LaTeX dans [`docs/livrable.tex`](docs/livrable.tex).

Pour compiler le PDF :

```bash
cd docs/
pdflatex livrable.tex
```

---

## ⚠️ Limitations connues

- Pas de validation des plages de valeurs en saisie libre (ex. minute > 59 acceptée)
- La suppression par numéro de ligne est fragile en cas d'édition concurrente de crontab
- Les macros cron (`@reboot`, `@weekly`…) ne sont pas prises en charge

---

## 🤝 Contribution

Les contributions sont les bienvenues !

1. Fork le dépôt
2. Crée une branche : `git checkout -b feature/ma-fonctionnalite`
3. Commit tes changements : `git commit -m "feat: description"`
4. Push : `git push origin feature/ma-fonctionnalite`
5. Ouvre une Pull Request

---

## 📝 Licence

Distribué sous licence **MIT**. Voir [LICENSE](LICENSE) pour plus de détails.
