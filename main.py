#!/usr/bin/env python3
import gi
import hashlib
import os
import threading

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")

from gi.repository import Gtk, Adw, Gdk, Gio, GLib

CSS = """
.result-card { border-radius: 12px; padding: 16px; margin-top: 10px; }
.card-success { background-color: rgba(38, 162, 105, 0.15); border: 2px solid #26a269; }
.card-error { background-color: rgba(192, 28, 40, 0.15); border: 2px solid #c01c28; }
.success-text { color: #26a269; font-weight: bold; font-size: 1.1rem; }
.error-text { color: #c01c28; font-weight: bold; font-size: 1.1rem; }
.caption { color: alpha(currentColor, 0.7); font-size: 0.9rem; }
.success-icon { color: #26a269; }
"""

class HashCheckerWin(Adw.ApplicationWindow):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.set_title("Проверка контрольных сумм")
        self.set_default_size(520, 580)
        
        self.file_path = None
        self.hash_path = None
        self.manual_hash = None 
        self.calculated_hash = None
        self.is_dialog_open = False 

        self.algo_map = {
            "SHA-256": hashlib.sha256,
            "SHA-512": hashlib.sha512,
            "SHA-1": hashlib.sha1,
            "MD5": hashlib.md5
        }
        self.available_algos = list(self.algo_map.keys())

        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(CSS.encode())
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), 
            style_provider, 
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.toast_overlay = Adw.ToastOverlay()
        self.set_content(self.toast_overlay)

        self.toolbar_view = Adw.ToolbarView()
        self.toast_overlay.set_child(self.toolbar_view)

        header_bar = Adw.HeaderBar()
        self.window_title = Adw.WindowTitle(title="Hash Checker")
        header_bar.set_title_widget(self.window_title)
        self.toolbar_view.add_top_bar(header_bar)

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_propagate_natural_height(True)
        self.toolbar_view.set_content(scrolled)

        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18)
        content_box.set_margin_top(24); content_box.set_margin_bottom(24)
        content_box.set_margin_start(24); content_box.set_margin_end(24)
        scrolled.set_child(content_box)

        # Настройки
        settings_group = Adw.PreferencesGroup(title="Настройки")
        content_box.append(settings_group)

        self.algo_row = Adw.ComboRow(title="Алгоритм хеширования")
        self.algo_row.set_model(Gtk.StringList.new(self.available_algos))
        self.algo_row.set_selected(0)
        self.algo_row.connect("notify::selected", self.on_algo_changed)
        settings_group.add(self.algo_row)

        # Данные
        files_group = Adw.PreferencesGroup(title="Данные для сверки")
        content_box.append(files_group)

        self.row_file = Adw.ActionRow(title="Файл для проверки", subtitle="Выберите файл...")
        self.row_file.add_prefix(Gtk.Image.new_from_icon_name("document-open-symbolic"))
        
        file_actions = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.file_spinner = Gtk.Spinner()
        self.file_done_icon = Gtk.Image.new_from_icon_name("emblem-ok-symbolic")
        self.file_done_icon.add_css_class("success-icon")
        self.file_done_icon.set_visible(False)
        btn_file = Gtk.Button(icon_name="document-open-symbolic", css_classes=["flat"], tooltip_text="Выбрать файл")
        btn_file.connect("clicked", self.on_choose_file)
        
        file_actions.append(self.file_spinner); file_actions.append(self.file_done_icon); file_actions.append(btn_file)
        self.row_file.add_suffix(file_actions)
        files_group.add(self.row_file)

        self.row_hash = Adw.ActionRow(title="Эталонный хеш", subtitle="Файл или вставка (sha256:...)")
        self.row_hash.add_prefix(Gtk.Image.new_from_icon_name("edit-paste-symbolic"))
        
        hash_actions = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        btn_paste = Gtk.Button(icon_name="edit-paste-symbolic", css_classes=["flat"], tooltip_text="Вставить из буфера")
        btn_paste.connect("clicked", self.on_paste_clicked)
        btn_hash_file = Gtk.Button(icon_name="document-open-symbolic", css_classes=["flat"], tooltip_text="Выбрать файл с хешем")
        btn_hash_file.connect("clicked", self.on_choose_hash)
        
        hash_actions.append(btn_paste); hash_actions.append(btn_hash_file)
        self.row_hash.add_suffix(hash_actions)
        files_group.add(self.row_hash)

        self.check_button = Gtk.Button(label="Сверить хеш-суммы", css_classes=["suggested-action", "pill"])
        self.check_button.set_halign(Gtk.Align.CENTER)
        self.check_button.set_margin_top(12)
        self.check_button.set_size_request(220, 44)
        self.check_button.set_sensitive(False)
        self.check_button.connect("clicked", self.on_verify_clicked)
        content_box.append(self.check_button)

        self.result_card = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12, css_classes=["result-card"])
        self.result_card.set_visible(False)
        content_box.append(self.result_card)
        self.result_icon = Gtk.Image(pixel_size=32)
        self.result_card.append(self.result_icon)
        res_text_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        self.result_title = Gtk.Label(xalign=0)
        self.result_desc = Gtk.Label(xalign=0, css_classes=["caption"])
        res_text_box.append(self.result_title); res_text_box.append(self.result_desc)
        self.result_card.append(res_text_box)

    def get_current_algo_name(self):
        return self.available_algos[self.algo_row.get_selected()]

    def show_toast(self, message, timeout=1):
        toast = Adw.Toast.new(message)
        toast.set_timeout(timeout)
        self.toast_overlay.add_toast(toast)

    def on_algo_changed(self, *args):
        if self.file_path: self.start_hashing(self.file_path)

    # --- УНИВЕРСАЛЬНЫЙ ПАРСЕР ХЕША ---
    def process_hash_input(self, raw_text, source_display_name):
        """Парсит строку, определяет алгоритм и обновляет состояние"""
        if not raw_text: return False

        clean_text = raw_text.strip()
        final_hash = clean_text
        detected_algo_idx = None

        # Проверка на формат префикса "sha256:хеш"
        if ":" in clean_text:
            prefix, content = clean_text.split(":", 1)
            prefix = prefix.lower().strip().replace("-", "")
            for i, algo_name in enumerate(self.available_algos):
                if algo_name.lower().replace("-", "") == prefix:
                    detected_algo_idx = i
                    final_hash = content.strip()
                    break

        # Очистка от мусора (берем первое слово)
        final_hash = final_hash.split()[0].lower()

        if len(final_hash) < 8:
            return False

        self.manual_hash = final_hash
        
        # Авто-переключение алгоритма
        if detected_algo_idx is not None:
            if self.algo_row.get_selected() != detected_algo_idx:
                self.algo_row.set_selected(detected_algo_idx)
                self.show_toast(f"Алгоритм изменен на {self.available_algos[detected_algo_idx]}", timeout=1)

        # Обновление UI
        short_hash = f"{final_hash[:6]}...{final_hash[-6:]}" if len(final_hash) > 16 else final_hash
        self.row_hash.set_subtitle(f"{source_display_name}: {short_hash}")
        self.result_card.set_visible(False)
        self.update_button_state()
        return True

    def on_paste_clicked(self, _):
        clipboard = self.get_clipboard()
        clipboard.read_text_async(None, self.on_paste_received)

    def on_paste_received(self, clipboard, result):
        text = clipboard.read_text_finish(result)
        if not self.process_hash_input(text, "Из буфера"):
            self.show_toast("Неверный формат хеша")

    def on_choose_hash(self, _):
        if self.is_dialog_open: return
        self.is_dialog_open = True
        Gtk.FileDialog(title="Выберите файл с хешем").open(self, None, self.on_hash_file_selected)

    def on_hash_file_selected(self, dialog, result):
        self.is_dialog_open = False
        try:
            file = dialog.open_finish(result)
            if file:
                path = file.get_path()
                self.hash_path = path
                # Пытаемся прочитать файл и сразу распарсить хеш
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read().strip()
                    if not self.process_hash_input(content, os.path.basename(path)):
                        # Если не распарсилось красиво, просто ставим имя файла
                        self.row_hash.set_subtitle(os.path.basename(path))
                        self.manual_hash = None
        except Exception as e:
            self.show_toast("Ошибка чтения файла")

    # --- ФАЙЛОВЫЕ ОПЕРАЦИИ ---
    def on_choose_file(self, _):
        if self.is_dialog_open: return
        self.is_dialog_open = True
        Gtk.FileDialog(title="Выберите файл для проверки").open(self, None, self.on_file_selected)

    def on_file_selected(self, dialog, result):
        self.is_dialog_open = False
        try:
            file = dialog.open_finish(result)
            if file:
                self.file_path = file.get_path()
                self.start_hashing(self.file_path)
        except: pass 

    def start_hashing(self, path):
        self.calculated_hash = None
        algo_name = self.get_current_algo_name()
        self.row_file.set_subtitle(f"Вычисляю {algo_name}...")
        self.file_done_icon.set_visible(False)
        self.file_spinner.start()
        self.result_card.set_visible(False)
        self.update_button_state()
        thread = threading.Thread(target=self.compute_hash_thread, args=(path, algo_name))
        thread.daemon = True
        thread.start()

    def compute_hash_thread(self, path, algo_name):
        try:
            h = self.algo_map[algo_name]()
            with open(path, "rb") as f:
                while chunk := f.read(1024*1024): h.update(chunk)
            GLib.idle_add(self.on_hash_computed, h.hexdigest(), path, algo_name)
        except:
            GLib.idle_add(self.on_hash_error, path)

    def on_hash_computed(self, res, path, algo):
        if path == self.file_path and algo == self.get_current_algo_name():
            self.calculated_hash = res
            self.file_spinner.stop()
            self.file_done_icon.set_visible(True)
            self.row_file.set_subtitle(os.path.basename(path))
            self.update_button_state()
        return False

    def on_hash_error(self, path):
        if path == self.file_path:
            self.file_spinner.stop()
            self.row_file.set_subtitle("Ошибка чтения")
        return False

    def update_button_state(self):
        # Готовы, если есть расчет И (есть распарсенный хеш ИЛИ есть путь к файлу)
        has_ref = bool(self.manual_hash or self.hash_path)
        self.check_button.set_sensitive(bool(self.file_path and has_ref and self.calculated_hash))

    def on_verify_clicked(self, _):
        expected = self.manual_hash
        
        # Если в manual_hash пусто (файл не распарсился при выборе), пробуем прочитать сейчас
        if not expected and self.hash_path:
            try:
                with open(self.hash_path, "r", encoding="utf-8") as f:
                    content = f.read().strip()
                    if content: expected = content.splitlines()[0].split()[0].lower()
            except:
                self.show_toast("Ошибка чтения файла")
                return

        if not expected: return

        self.result_card.set_visible(True)
        for c in ["card-success", "card-error"]: self.result_card.remove_css_class(c)
        for c in ["success-text", "error-text"]: self.result_title.remove_css_class(c)

        if self.calculated_hash == expected:
            self.result_card.add_css_class("card-success")
            self.result_title.add_css_class("success-text")
            self.result_title.set_label("Суммы совпали")
            self.result_icon.set_from_icon_name("emblem-ok-symbolic")
            self.result_desc.set_label(f"Целостность данных подтверждена ({self.get_current_algo_name()})")
        else:
            self.result_card.add_css_class("card-error")
            self.result_title.add_css_class("error-text")
            self.result_title.set_label("Суммы различаются!")
            self.result_icon.set_from_icon_name("dialog-error-symbolic")
            self.result_desc.set_label("Данные не совпадают с эталоном")

class App(Adw.Application):
    def __init__(self):
        super().__init__(application_id="io.github.axawys.HashChecker", flags=Gio.ApplicationFlags.NON_UNIQUE)
    def do_activate(self):
        win = HashCheckerWin(application=self)
        win.present()

if __name__ == "__main__":
    app = App()
    app.run(None)
