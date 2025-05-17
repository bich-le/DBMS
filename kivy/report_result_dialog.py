from kivy.uix.scrollview import ScrollView
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.label import MDLabel
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDRaisedButton

def show_result_dialog(title, columns, rows):
    from kivymd.uix.datatables import MDDataTable
    from kivymd.uix.label import MDLabel
    from kivymd.uix.boxlayout import MDBoxLayout
    
    # Tạo layout chứa cả tiêu đề và bảng dữ liệu
    layout = MDBoxLayout(orientation="vertical", spacing=10, size_hint_y=None)
    layout.height = 500  # Chiều cao cố định
    
    # Thêm tiêu đề
    title_label = MDLabel(
        text=f"[size=20][b]{title}[/b][/size]",
        halign="center",
        markup=True,
        size_hint_y=None,
        height=50
    )
    layout.add_widget(title_label)
    
    # Thêm bảng dữ liệu
    table = MDDataTable(
        size_hint=(1, 1),
        column_data=[(col, 40) for col in columns],
        row_data=rows,
        rows_num=min(10, len(rows))  # Hiển thị tối đa 10 dòng
    )
    layout.add_widget(table)
    
    # Tạo dialog
    dialog = MDDialog(
        type="custom",
        content_cls=layout,
        size_hint=(0.9, 0.8),
        buttons=[
            MDRaisedButton(
                text="ĐÓNG",
                on_release=lambda x: dialog.dismiss()
            )
        ]
    )
    dialog.open()
    return dialog