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
        self.set_default_size(500, 480)
        
        self.file_path = None
        self.hash_path = None
        self.calculated_hash = None
        self.is_dialog_open = False 

        # Карта алгоритмов для hashlib
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

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.toast_overlay.set_child(main_box)
        main_box.append(Adw.HeaderBar())

        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18)
        content_box.set_margin_top(20); content_box.set_margin_bottom(20)
        content_box.set_margin_start(20); content_box.set_margin_end(20)
        main_box.append(content_box)

        # --- Группа настроек ---
        settings_group = Adw.PreferencesGroup(title="Настройки алгоритма")
        content_box.append(settings_group)

        # Выбор алгоритма
        self.algo_row = Adw.ComboRow(title="Алгоритм хеширования")
        # Создаем модель данных для выпадающего списка
        algo_model = Gtk.StringList.new(self.available_algos)
        self.algo_row.set_model(algo_model)
        # Устанавливаем SHA-256 (индекс 0) по умолчанию
        self.algo_row.set_selected(0)
        self.algo_row.connect("notify::selected", self.on_algo_changed)
        settings_group.add(self.algo_row)

        # --- Группа выбора файлов ---
        files_group = Adw.PreferencesGroup(title="Выбор файлов")
        content_box.append(files_group)

        # Строка файла для проверки
        self.row_file = Adw.ActionRow(title="Файл для проверки", subtitle="Не выбран")
        self.row_file.add_prefix(Gtk.Image.new_from_icon_name("document-open-symbolic"))
        
        self.file_status_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        self.file_spinner = Gtk.Spinner()
        self.file_done_icon = Gtk.Image.new_from_icon_name("emblem-ok-symbolic")
        self.file_done_icon.add_css_class("success-icon")
        self.file_done_icon.set_visible(False)
        
        btn_file = Gtk.Button(icon_name="document-open-symbolic", css_classes=["flat"])
        btn_file.connect("clicked", self.on_choose_file)
        
        self.file_status_box.append(self.file_spinner)
        self.file_status_box.append(self.file_done_icon)
        self.file_status_box.append(btn_file)
        
        self.row_file.add_suffix(self.file_status_box)
        files_group.add(self.row_file)

        # Строка эталонного хеша
        self.row_hash = Adw.ActionRow(title="Файл с хешем", subtitle="Не выбран")
        self.row_hash.add_prefix(Gtk.Image.new_from_icon_name("edit-paste-symbolic"))
        btn_hash = Gtk.Button(icon_name="document-open-symbolic", css_classes=["flat"])
        btn_hash.connect("clicked", self.on_choose_hash)
        self.row_hash.add_suffix(btn_hash)
        files_group.add(self.row_hash)

        # Кнопка Сверить
        self.check_button = Gtk.Button(label="Сверить хеш-суммы", css_classes=["suggested-action", "pill"])
        self.check_button.set_halign(Gtk.Align.CENTER)
        self.check_button.set_size_request(200, 44)
        self.check_button.set_sensitive(False)
        self.check_button.connect("clicked", self.on_verify_clicked)
        content_box.append(self.check_button)

        # Карточка результата
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

    def show_toast(self, message):
        GLib.idle_add(self._do_show_toast, message)

    def _do_show_toast(self, message):
        toast = Adw.Toast.new(message)
        toast.set_timeout(1)
        self.toast_overlay.add_toast(toast)
        return False

    def on_algo_changed(self, *args):
        # Если файл уже выбран, пересчитываем хеш с новым алгоритмом
        if self.file_path:
            self.start_hashing(self.file_path)

    def on_choose_file(self, _):
        if self.is_dialog_open: return
        self.is_dialog_open = True
        dialog = Gtk.FileDialog(title="Выберите файл для проверки")
        dialog.open(self, None, self.on_file_selected)

    def on_file_selected(self, dialog, result):
        self.is_dialog_open = False
        try:
            file = dialog.open_finish(result)
            if file:
                path = file.get_path()
                self.file_path = path
                self.start_hashing(path)
        except: pass 

    def start_hashing(self, path):
        self.calculated_hash = None
        algo_name = self.get_current_algo_name()
        
        self.row_file.set_subtitle(f"Вычисляю {algo_name}...")
        self.file_done_icon.set_visible(False)
        self.file_spinner.start()
        self.result_card.set_visible(False)
        self.update_button_state()

        self.show_toast(f"Вычисляю {algo_name}...")
        # Передаем название алгоритма в поток
        thread = threading.Thread(target=self.compute_hash_thread, args=(path, algo_name))
        thread.daemon = True
        thread.start()

    def on_choose_hash(self, _):
        if self.is_dialog_open: return
        self.is_dialog_open = True
        dialog = Gtk.FileDialog(title="Выберите файл с хешем")
        dialog.open(self, None, self.on_hash_selected)

    def on_hash_selected(self, dialog, result):
        self.is_dialog_open = False
        try:
            file = dialog.open_finish(result)
            if file:
                self.hash_path = file.get_path()
                self.row_hash.set_subtitle(os.path.basename(self.hash_path))
                self.result_card.set_visible(False)
                self.update_button_state()
        except: pass

    def compute_hash_thread(self, path_to_process, algo_name):
        try:
            # Динамически выбираем функцию хеширования
            hash_func = self.algo_map[algo_name]()
            with open(path_to_process, "rb") as f:
                while chunk := f.read(1024 * 1024):
                    hash_func.update(chunk)
            res = hash_func.hexdigest()
            # Добавляем проверку текущего алгоритма, чтобы избежать гонки потоков
            GLib.idle_add(self.on_hash_computed, res, path_to_process, algo_name)
        except Exception:
            GLib.idle_add(self.on_hash_error, path_to_process)

    def on_hash_computed(self, hash_res, processed_path, processed_algo):
        # Проверяем, не изменил ли пользователь файл или алгоритм за время работы потока
        if processed_path == self.file_path and processed_algo == self.get_current_algo_name():
            self.calculated_hash = hash_res
            self.file_spinner.stop()
            self.file_done_icon.set_visible(True)
            self.row_file.set_subtitle(os.path.basename(processed_path))
            self.show_toast(f"{processed_algo} вычислен!")
            self.update_button_state()
        return False

    def on_hash_error(self, path):
        if path == self.file_path:
            self.file_spinner.stop()
            self.row_file.set_subtitle("Ошибка чтения файла")
        self.show_toast("Ошибка при расчете хеша")
        return False

    def update_button_state(self):
        ready = bool(self.file_path and self.hash_path and self.calculated_hash)
        self.check_button.set_sensitive(ready)

    def on_verify_clicked(self, _):
        try:
            with open(self.hash_path, "r", encoding="utf-8") as f:
                content = f.read().strip()
                if not content:
                    self.show_toast("Файл с хешем пуст")
                    return
                # Берем первую строку, первое слово.
                # Работает для стандартных файлов .md5, .sha1, .sha256
                expected_hash = content.splitlines()[0].split()[0].lower()
        except:
            self.show_toast("Не удалось прочитать файл хеша")
            return

        self.result_card.set_visible(True)
        for c in ["card-success", "card-error"]: self.result_card.remove_css_class(c)
        for c in ["success-text", "error-text"]: self.result_title.remove_css_class(c)

        if self.calculated_hash == expected_hash:
            self.result_card.add_css_class("card-success")
            self.result_title.add_css_class("success-text")
            self.result_title.set_label("Суммы совпали")
            self.result_icon.set_from_icon_name("emblem-ok-symbolic")
            self.result_desc.set_label(f"Целостность данных ({self.get_current_algo_name()}) подтверждена")
        else:
            self.result_card.add_css_class("card-error")
            self.result_title.add_css_class("error-text")
            self.result_title.set_label("Суммы различаются!")
            self.result_icon.set_from_icon_name("dialog-error-symbolic")
            self.result_desc.set_label(f"Файл изменен. Алгоритм: {self.get_current_algo_name()}")

class App(Adw.Application):
    def __init__(self):
        super().__init__(application_id="io.github.axawys.HashChecker", flags=Gio.ApplicationFlags.NON_UNIQUE)
    def do_activate(self):
        win = HashCheckerWin(application=self)
        win.present()

if __name__ == "__main__":
    app = App()
    app.run(None)