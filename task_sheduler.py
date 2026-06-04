#!/usr/bin/env python3
import tkinter as tk
from tkinter import messagebox, simpledialog
import subprocess

def cron_list():
    r = subprocess.run(["crontab", "-l"], capture_output=True, text=True)
    return r.stdout.strip()

def refresh():
    tasks = cron_list()
    listbox.delete(0, tk.END)
    for line in (tasks.splitlines() if tasks else []):
        listbox.insert(tk.END, line)

def add_task():
    cmd = simpledialog.askstring("Command", "Command to schedule:")
    if not cmd: return


    #genre fieldset:
    freq = simpledialog.askstring("Frequency", "1.Hourly 2.Daily 3.Weekly 4.Monthly 5.Custom:")
    m, h, dom, mon, dow = "*", "*", "*", "*", "*"

    if freq == "1":
        m = simpledialog.askstring("Minute", "Minute (0-59):") or "*"
    elif freq == "2":
        h = simpledialog.askstring("Hour",   "Hour (0-23):")   or "*"
        m = simpledialog.askstring("Minute", "Minute (0-59):") or "*"
    elif freq == "3":
        dow = simpledialog.askstring("Day",    "Day of week (0-6):") or "*"
        h   = simpledialog.askstring("Hour",   "Hour (0-23):")       or "*"
        m   = simpledialog.askstring("Minute", "Minute (0-59):")     or "*"
    elif freq == "4":
        dom = simpledialog.askstring("Day",    "Day of month (1-31):") or "*"
        h   = simpledialog.askstring("Hour",   "Hour (0-23):")         or "*"
        m   = simpledialog.askstring("Minute", "Minute (0-59):")       or "*"
    elif freq == "5":
        m   = simpledialog.askstring("Min",  "Minutes:")      or "*"
        h   = simpledialog.askstring("Hour", "Hours:")        or "*"
        dom = simpledialog.askstring("DOM",  "Day of month:") or "*"
        mon = simpledialog.askstring("Mon",  "Month:")        or "*"
        dow = simpledialog.askstring("DOW",  "Day of week:")  or "*"

    log = messagebox.askyesno("Logs", "Enable logs?")
    if log:
        cmd += " >> scheduler.log 2>&1"

    cron_line = f"{m} {h} {dom} {mon} {dow} {cmd}"
    existing = cron_list()

    if cron_line in existing:
        messagebox.showinfo("Info", "Task already exists.")
    else:
        new = (existing + "\n" + cron_line).strip()
        subprocess.run("crontab -", input=new, shell=True, text=True)
        messagebox.showinfo("Done", f"Task added:\n{cron_line}")
    refresh()

def remove_task():
    sel = listbox.curselection()
    if not sel:
        messagebox.showwarning("Warning", "Select a task first.")
        return
    lines = cron_list().splitlines()
    lines.pop(sel[0])
    subprocess.run("crontab -", input="\n".join(lines), shell=True, text=True)
    refresh()


root = tk.Tk()
root.title("Task Scheduler")
root.geometry("600x400")

listbox = tk.Listbox(root, font=("monospace", 11))
listbox.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

frame = tk.Frame(root)
frame.pack(pady=5)
tk.Button(frame, text="Refresh", command=refresh).pack(side=tk.LEFT, padx=5)
tk.Button(frame, text="Add",     command=add_task).pack(side=tk.LEFT, padx=5)
tk.Button(frame, text="Remove",  command=remove_task).pack(side=tk.LEFT, padx=5)
tk.Button(frame, text="Exit",    command=root.quit).pack(side=tk.LEFT, padx=5)

refresh()
root.mainloop()