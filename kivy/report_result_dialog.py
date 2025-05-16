from kivymd.uix.dialog import MDDialog
from kivymd.uix.label import MDLabel
from kivy.uix.scrollview import ScrollView
from kivymd.uix.boxlayout import MDBoxLayout

def show_result_dialog(title, columns, data):
    # Tạo nội dung bên trong một BoxLayout để scroll
    content = MDBoxLayout(orientation="vertical", spacing=5, padding=10, size_hint_y=None)
    content.bind(minimum_height=content.setter("height"))

    # Tiêu đề cột
    content.add_widget(MDLabel(text=" | ".join(columns), bold=True, halign="left", theme_text_color="Secondary"))

    for row in data:
        row_text = " | ".join(str(cell) for cell in row)
        content.add_widget(MDLabel(text=row_text, halign="left"))

    # Simple insight
    if data:
        total_txn = len(data)
        content.add_widget(MDLabel(text=f"\nTotal Transactions: {total_txn}", bold=True, theme_text_color="Custom"))

    # ScrollView chứa nội dung
    scroll_view = ScrollView(do_scroll_x=True, do_scroll_y=True, size_hint=(1, None), height=400)
    scroll_view.add_widget(content)

    dialog = MDDialog(
        title=title,
        type="custom",
        content_cls=scroll_view,
        buttons=[],
    )
    dialog.open()
