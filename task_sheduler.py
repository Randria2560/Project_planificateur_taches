#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess

class TaskScheduler:
    def __init__(self, root):
        self.root = root
        self.root.title("Task Scheduler")
        self.root.geometry("600x400")
        
        # Boutons
        btn_frame = tk.Frame(root)
        btn_frame.pack(pady=10)
        
        tk.Button(btn_frame, text="List Tasks", command=self.list_tasks, width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Add Task", command=self.add_task, width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Remove Task", command=self.remove_task, width=15).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Exit", command=root.quit, width=15).pack(side=tk.LEFT, padx=5)
        
        # Zone de texte
        self.text_area = scrolledtext.ScrolledText(root, width=70, height=20)
        self.text_area.pack(pady=10)
        
    def list_tasks(self):
        try:
            result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
            self.text_area.delete(1.0, tk.END)
            self.text_area.insert(tk.END, result.stdout if result.stdout else "No tasks")
        except:
            messagebox.showerror("Error", "Cannot read crontab")
    
    def add_task(self):
        # Fenêtre d'ajout
        add_window = tk.Toplevel(self.root)
        add_window.title("Add Task")
        add_window.geometry("400x300")
        
        tk.Label(add_window, text="Command:").pack(pady=5)
        cmd_entry = tk.Entry(add_window, width=50)
        cmd_entry.pack()
        
        tk.Label(add_window, text="Schedule:").pack(pady=5)
        schedule_var = tk.StringVar(value="daily")
        ttk.Combobox(add_window, textvariable=schedule_var, 
                     values=["hourly", "daily", "weekly", "monthly"]).pack()
        
        def save_task():
            cmd = cmd_entry.get()
            # Logique d'ajout...
            messagebox.showinfo("Success", "Task added!")
            add_window.destroy()
        
        tk.Button(add_window, text="Add", command=save_task).pack(pady=10)
    
    def remove_task(self):
        # Logique de suppression
        pass

if __name__ == "__main__":
    root = tk.Tk()
    app = TaskScheduler(root)
    root.mainloop()
