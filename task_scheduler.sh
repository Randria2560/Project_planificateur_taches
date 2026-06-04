#!/bin/bash

# ─────────────────────────────────────────────
#  Task Scheduler — full yad GUI, no terminal input
# ─────────────────────────────────────────────

cron_line=""

# ── helpers ──────────────────────────────────

yad_error() {
    yad --error \
        --title="Error" \
        --text="$1" \
        --center \
        --width=350
}

yad_info() {
    yad --info \
        --title="Info" \
        --text="$1" \
        --center \
        --width=350
}

# ── main menu ────────────────────────────────

menu() {
    while true; do
        choice=$(yad --list \
            --title="⏱ Task Scheduler" \
            --width=500 \
            --height=300 \
            --center \
            --no-headers \
            --column="Option" \
            "📋  List scheduled tasks" \
            "➕  Add a task" \
            "🗑️   Remove a task" \
            "❌  Exit"
        )

        case "$choice" in
            "📋  List scheduled tasks|") list_task   ;;
            "➕  Add a task|")           add_task    ;;
            "🗑️   Remove a task|")        remove_task ;;
            "❌  Exit|")                 exit 0      ;;
            "")                          exit 0      ;;   # window closed
            *)                           ;;               # ignore stray clicks
        esac
    done
}

# ── list tasks ───────────────────────────────

list_task() {
    task=$(crontab -l 2>/dev/null)
    [[ -z "$task" ]] && task="No scheduled tasks found."

    yad --text-info \
        --title="Scheduled Tasks" \
        --width=750 \
        --height=400 \
        --center \
        --filename=<(echo "$task")
}

# ── add task ─────────────────────────────────

add_task() {
    # 1. Command / script
    script=$(yad --entry \
        --title="Command" \
        --text="Enter the command or script path to schedule:" \
        --width=500 \
        --center
    )
    [[ -z "$script" ]] && return   # cancelled

    # 2. Scheduling type
    sched_type=$(yad --list \
        --title="Scheduling Type" \
        --width=400 \
        --height=280 \
        --center \
        --no-headers \
        --column="Type" \
        "⏰  Hourly" \
        "📅  Daily" \
        "🗓️   Weekly" \
        "📆  Monthly" \
        "⚙️   Custom"
    )
    [[ -z "$sched_type" ]] && return   # cancelled

    minutes="*"
    hours="*"
    day_of_month="*"
    month="*"
    day_of_week="*"

    case "$sched_type" in
        "⏰  Hourly|")   pick_hourly   ;;
        "📅  Daily|")    pick_daily    ;;
        "🗓️   Weekly|")  pick_weekly   ;;
        "📆  Monthly|")  pick_monthly  ;;
        "⚙️   Custom|")  pick_custom   ;;
        *) return ;;
    esac

    # 3. Logging
    log=$(yad --list \
        --title="Logging" \
        --width=350 \
        --height=180 \
        --center \
        --no-headers \
        --column="Option" \
        "✅  Yes — append output to scheduler.log" \
        "🚫  No  — discard output"
    )
    case "$log" in
        "✅  Yes — append output to scheduler.log|")
            script="$script >> ~/scheduler.log 2>&1" ;;
    esac

    # 4. Build & register
    cron_line="$minutes $hours $day_of_month $month $day_of_week $script"
    add_cron_job
}

# ── schedule pickers (fully yad) ─────────────

pick_hourly() {
    result=$(yad --form \
        --title="Hourly Schedule" \
        --width=350 \
        --center \
        --field="Minute (0-59):NUM" "0!0..59!1"
    )
    [[ -z "$result" ]] && return
    minutes=$(echo "$result" | cut -d'|' -f1 | cut -d'.' -f1)
    hours="*"
}

pick_daily() {
    result=$(yad --form \
        --title="Daily Schedule" \
        --width=350 \
        --center \
        --field="Hour (0-23):NUM"   "0!0..23!1" \
        --field="Minute (0-59):NUM" "0!0..59!1"
    )
    [[ -z "$result" ]] && return
    hours=$(  echo "$result" | cut -d'|' -f1 | cut -d'.' -f1)
    minutes=$(echo "$result" | cut -d'|' -f2 | cut -d'.' -f1)
    day_of_month="*"; month="*"; day_of_week="*"
}

pick_weekly() {
    result=$(yad --form \
        --title="Weekly Schedule" \
        --width=400 \
        --center \
        --field="Day of week:CB"    "Sunday!Monday!Tuesday!Wednesday!Thursday!Friday!Saturday" \
        --field="Hour (0-23):NUM"   "0!0..23!1" \
        --field="Minute (0-59):NUM" "0!0..59!1"
    )
    [[ -z "$result" ]] && return

    dow_name=$(echo "$result" | cut -d'|' -f1)
    hours=$(   echo "$result" | cut -d'|' -f2 | cut -d'.' -f1)
    minutes=$( echo "$result" | cut -d'|' -f3 | cut -d'.' -f1)

    case "$dow_name" in
        Sunday)    day_of_week=0 ;;
        Monday)    day_of_week=1 ;;
        Tuesday)   day_of_week=2 ;;
        Wednesday) day_of_week=3 ;;
        Thursday)  day_of_week=4 ;;
        Friday)    day_of_week=5 ;;
        Saturday)  day_of_week=6 ;;
    esac
    day_of_month="*"; month="*"
}

pick_monthly() {
    result=$(yad --form \
        --title="Monthly Schedule" \
        --width=350 \
        --center \
        --field="Day of month (1-31):NUM" "1!1..31!1" \
        --field="Hour (0-23):NUM"         "0!0..23!1" \
        --field="Minute (0-59):NUM"       "0!0..59!1"
    )
    [[ -z "$result" ]] && return
    day_of_month=$(echo "$result" | cut -d'|' -f1 | cut -d'.' -f1)
    hours=$(       echo "$result" | cut -d'|' -f2 | cut -d'.' -f1)
    minutes=$(     echo "$result" | cut -d'|' -f3 | cut -d'.' -f1)
    month="*"; day_of_week="*"
}

pick_custom() {
    result=$(yad --form \
        --title="Custom Cron Expression" \
        --width=400 \
        --center \
        --field="Minutes  (e.g. */5, 0-30, 15):" "*" \
        --field="Hours    (e.g. 8-18, */2, 9):"  "*" \
        --field="Day of month (e.g. 1, 15, *):"  "*" \
        --field="Month    (e.g. 1-6, */3, 12):"  "*" \
        --field="Day of week  (e.g. 1-5, 0, 6):" "*"
    )
    [[ -z "$result" ]] && return
    minutes=$(     echo "$result" | cut -d'|' -f1)
    hours=$(       echo "$result" | cut -d'|' -f2)
    day_of_month=$(echo "$result" | cut -d'|' -f3)
    month=$(       echo "$result" | cut -d'|' -f4)
    day_of_week=$( echo "$result" | cut -d'|' -f5)
}

# ── crontab helpers ───────────────────────────

add_cron_job() {
    if crontab -l 2>/dev/null | grep -qF "$cron_line"; then
        yad_info "This task is already scheduled:\n\n<tt>$cron_line</tt>"
    else
        (crontab -l 2>/dev/null; echo "$cron_line") | crontab -
        yad_info "Task added successfully:\n\n<tt>$cron_line</tt>"
    fi
}

remove_task() {
    # Build a numbered list from existing crontab entries
    mapfile -t tasks < <(crontab -l 2>/dev/null)

    if [[ ${#tasks[@]} -eq 0 ]]; then
        yad_info "No scheduled tasks to remove."
        return
    fi

    # Build yad --list rows: index + task
    rows=()
    for i in "${!tasks[@]}"; do
        rows+=("$((i+1))" "${tasks[$i]}")
    done

    selection=$(yad --list \
        --title="Remove a Task" \
        --width=800 \
        --height=400 \
        --center \
        --column="#" \
        --column="Cron entry" \
        "${rows[@]}"
    )
    [[ -z "$selection" ]] && return

    line_num=$(echo "$selection" | cut -d'|' -f1)

    if [[ "$line_num" =~ ^[0-9]+$ ]]; then
        crontab -l | sed "${line_num}d" | crontab -
        yad_info "Task on line $line_num removed."
    else
        yad_error "Invalid selection."
    fi
}

# ── entry point ───────────────────────────────
menu