"""
Therapist Desktop Client (Windows/Linux/macOS)

A simple desktop client using Python's built-in tkinter.
Requires the backend to be running at http://localhost:8000

Usage:
    python desktop_client.py
"""

import json
import threading
import urllib.request
import urllib.error
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox

BASE_URL = "http://localhost:8000"


class TherapistDesktop:
    def __init__(self, root):
        self.root = root
        self.root.title("Therapist Desktop Client")
        self.root.geometry("900x700")
        self.session_id = None

        self._build_ui()
        self._check_health()

    def _build_ui(self):
        top = ttk.Frame(self.root)
        top.pack(fill=tk.X, padx=8, pady=4)

        ttk.Label(top, text="Session:").pack(side=tk.LEFT)
        self.session_var = tk.StringVar()
        self.session_combo = ttk.Combobox(top, textvariable=self.session_var, width=40)
        self.session_combo.pack(side=tk.LEFT, padx=4)
        self.session_combo.bind("<<ComboboxSelected>>", self._on_session_select)

        ttk.Button(top, text="New", command=self._new_session).pack(side=tk.LEFT, padx=2)
        ttk.Button(top, text="Refresh", command=self._load_sessions).pack(side=tk.LEFT, padx=2)
        ttk.Button(top, text="Health", command=self._check_health).pack(side=tk.LEFT, padx=2)

        self.health_label = ttk.Label(top, text="")
        self.health_label.pack(side=tk.RIGHT, padx=8)

        panes = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        panes.pack(fill=tk.BOTH, expand=True, padx=8, pady=4)

        right = ttk.Frame(panes)
        panes.add(right, weight=1)

        self.chat_area = scrolledtext.ScrolledText(right, wrap=tk.WORD, state=tk.DISABLED, font=("Segoe UI", 11))
        self.chat_area.pack(fill=tk.BOTH, expand=True)

        input_frame = ttk.Frame(right)
        input_frame.pack(fill=tk.X, pady=4)

        self.message_entry = ttk.Entry(input_frame, font=("Segoe UI", 11))
        self.message_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 4))
        self.message_entry.bind("<Return>", lambda e: self._send_message())

        ttk.Button(input_frame, text="Send", command=self._send_message).pack(side=tk.RIGHT)

    def _api(self, method, path, body=None):
        url = f"{BASE_URL}{path}"
        data = json.dumps(body).encode() if body else None
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                return json.loads(resp.read().decode())
        except urllib.error.HTTPError as e:
            msg = json.loads(e.read().decode()).get("detail", str(e))
            messagebox.showerror("Error", msg)
            return None
        except Exception as e:
            messagebox.showerror("Error", str(e))
            return None

    def _check_health(self):
        def run():
            result = self._api("GET", "/health")
            self.root.after(0, lambda: self.health_label.config(
                text=f"Status: {result.get('status', 'down')}" if result else "Status: down",
                foreground="green" if result and result.get("status") == "ok" else "red",
            ))
        threading.Thread(target=run, daemon=True).start()

    def _load_sessions(self):
        def run():
            sessions = self._api("GET", "/sessions") or []
            self.root.after(0, lambda: self._update_session_list(sessions))
        threading.Thread(target=run, daemon=True).start()

    def _update_session_list(self, sessions):
        self.session_combo["values"] = [s["title"] for s in sessions]
        self._sessions = {s["title"]: s for s in sessions}

    def _new_session(self):
        dialog = tk.Toplevel(self.root)
        dialog.title("New Session")
        dialog.geometry("300x200")

        ttk.Label(dialog, text="Title:").pack(pady=4)
        title_var = tk.StringVar()
        ttk.Entry(dialog, textvariable=title_var).pack(pady=4)

        ttk.Label(dialog, text="Modality:").pack(pady=4)
        modality_var = tk.StringVar(value="integrated")
        ttk.Combobox(dialog, textvariable=modality_var,
                      values=["integrated", "adlerian", "jungian", "dbt"]).pack(pady=4)

        def create():
            data = {"title": title_var.get(), "modality": modality_var.get()}
            result = self._api("POST", "/sessions", data)
            if result:
                self.session_id = result["id"]
                self.session_var.set(result["title"])
                self._load_sessions()
                self._append_chat(f"[System] Created session: {result['title']}\n")
            dialog.destroy()

        ttk.Button(dialog, text="Create", command=create).pack(pady=12)

    def _on_session_select(self, event=None):
        title = self.session_var.get()
        session = getattr(self, "_sessions", {}).get(title)
        if session:
            self.session_id = session["id"]
            self._load_messages()

    def _load_messages(self):
        if not self.session_id:
            return

        def run():
            msgs = self._api("GET", f"/chat/{self.session_id}") or []
            self.root.after(0, lambda: self._display_messages(msgs))
        threading.Thread(target=run, daemon=True).start()

    def _display_messages(self, messages):
        self.chat_area.config(state=tk.NORMAL)
        self.chat_area.delete(1.0, tk.END)
        for m in messages:
            role = "You" if m["role"] == "user" else "Therapist"
            self.chat_area.insert(tk.END, f"{role}: {m['content']}\n\n")
        self.chat_area.config(state=tk.DISABLED)
        self.chat_area.see(tk.END)

    def _append_chat(self, text):
        self.chat_area.config(state=tk.NORMAL)
        self.chat_area.insert(tk.END, text)
        self.chat_area.config(state=tk.DISABLED)
        self.chat_area.see(tk.END)

    def _send_message(self):
        text = self.message_entry.get().strip()
        if not text or not self.session_id:
            return
        self.message_entry.delete(0, tk.END)

        self._append_chat(f"You: {text}\n")

        def run():
            result = self._api("POST", "/chat", {"session_id": self.session_id, "message": text})
            if result:
                self.root.after(0, lambda: self._append_chat(f"Therapist: {result['response']}\n\n"))
        threading.Thread(target=run, daemon=True).start()


if __name__ == "__main__":
    root = tk.Tk()
    app = TherapistDesktop(root)
    root.mainloop()
