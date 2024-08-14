import tkinter as tk
from tkinter import filedialog, messagebox
import os
import subprocess

class RootkitManagerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Rootkit Manager")
        self.geometry("600x400")

        # Labels
        self.label_title = tk.Label(self, text="Rootkit Manager", font=("Arial", 16))
        self.label_title.pack(pady=10)

        # Frame for Buttons
        self.frame = tk.Frame(self)
        self.frame.pack(pady=10)

        # Buttons
        self.btn_compile_rootkit = tk.Button(self.frame, text="Compile Rootkit", command=self.compile_rootkit)
        self.btn_compile_rootkit.grid(row=0, column=0, padx=10, pady=5)

        self.btn_load_rootkit = tk.Button(self.frame, text="Load Rootkit", command=self.load_rootkit)
        self.btn_load_rootkit.grid(row=0, column=1, padx=10, pady=5)

        self.btn_unload_rootkit = tk.Button(self.frame, text="Unload Rootkit", command=self.unload_rootkit)
        self.btn_unload_rootkit.grid(row=0, column=2, padx=10, pady=5)

        self.btn_run_command = tk.Button(self.frame, text="Run Command", command=self.run_command)
        self.btn_run_command.grid(row=1, column=0, padx=10, pady=5)

        self.btn_compile_command_sender = tk.Button(self.frame, text="Compile Command Sender", command=self.compile_command_sender)
        self.btn_compile_command_sender.grid(row=1, column=1, padx=10, pady=5)

        self.btn_exit = tk.Button(self.frame, text="Exit", command=self.exit_app)
        self.btn_exit.grid(row=1, column=2, padx=10, pady=5)

    def compile_rootkit(self):
        # Select the rootkit directory
        directory = filedialog.askdirectory(title="Select Rootkit Directory")
        if directory:
            try:
                # Run the make command in the selected directory
                result = subprocess.run(["make"], cwd=directory, capture_output=True, text=True)
                messagebox.showinfo("Compile Rootkit", result.stdout)
            except Exception as e:
                messagebox.showerror("Error", f"Failed to compile rootkit: {str(e)}")
        else:
            messagebox.showwarning("No Directory", "Please select a directory to compile the rootkit.")

    def load_rootkit(self):
        try:
            # Load the rootkit module
            result = subprocess.run(["sudo", "insmod", "rootkit.ko"], capture_output=True, text=True)
            messagebox.showinfo("Load Rootkit", result.stdout)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load rootkit: {str(e)}")

    def unload_rootkit(self):
        try:
            # Unload the rootkit module
            result = subprocess.run(["sudo", "rmmod", "rootkit"], capture_output=True, text=True)
            messagebox.showinfo("Unload Rootkit", result.stdout)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to unload rootkit: {str(e)}")

    def run_command(self):
        command = filedialog.askopenfilename(title="Select Command to Run", filetypes=[("Executable", "*.out *.exe *.sh"), ("All Files", "*.*")])
        if command:
            try:
                # Run the selected command
                result = subprocess.run([command], capture_output=True, text=True)
                messagebox.showinfo("Run Command", result.stdout)
            except Exception as e:
                messagebox.showerror("Error", f"Failed to run command: {str(e)}")
        else:
            messagebox.showwarning("No Command", "Please select a command to run.")

    def compile_command_sender(self):
        # Select the directory containing the command sender code
        directory = filedialog.askdirectory(title="Select Command Sender Directory")
        if directory:
            try:
                # Compile the command sender
                result = subprocess.run(["gcc", "-o", "command_sender", "command_sender.c"], cwd=directory, capture_output=True, text=True)
                messagebox.showinfo("Compile Command Sender", result.stdout)
            except Exception as e:
                messagebox.showerror("Error", f"Failed to compile command sender: {str(e)}")
        else:
            messagebox.showwarning("No Directory", "Please select a directory to compile the command sender.")

    def exit_app(self):
        self.quit()

if __name__ == "__main__":
    app = RootkitManagerApp()
    app.mainloop()
