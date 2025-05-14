from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.dialog import MDDialog
from kivymd.app import MDApp
from kivy.uix.scrollview import ScrollView
from kivymd.uix.label import MDLabel


class ReportBox(MDBoxLayout):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.orientation = "vertical"
        self.padding = 20
        self.spacing = 15
        self.build_ui()

    def build_ui(self):
        app = MDApp.get_running_app()
        role = getattr(app, "current_role", "guest")  # Đọc chức vụ đã lưu sau đăng nhập

        self.add_widget(MDLabel(text=f"[b]Chức vụ: {role.capitalize()}[/b]", halign="center", markup=True, font_style="H6"))

        # Các báo cáo theo từng vai trò
        if role == "director":
            self.add_widget(MDRaisedButton(text="📋 Lịch sử giao dịch toàn hệ thống", on_release=self.show_all_transactions))
            self.add_widget(MDRaisedButton(text="🔍 Báo cáo nghi ngờ", on_release=self.show_suspicion))
            self.add_widget(MDRaisedButton(text="🧾 Giao dịch theo nhân viên", on_release=self.show_employee_transactions))
        elif role == "manager":
            self.add_widget(MDRaisedButton(text="🏦 Giao dịch chi nhánh", on_release=self.show_branch_transactions))
            self.add_widget(MDRaisedButton(text="📊 Tổng hợp tài khoản", on_release=self.show_account_summary))
        elif role == "teller":
            self.add_widget(MDRaisedButton(text="📝 Giao dịch chi nhánh", on_release=self.show_branch_transactions))
        elif role == "auditor":
            self.add_widget(MDRaisedButton(text="📉 Lịch sử thay đổi lãi suất", on_release=self.show_interest_changes))
        else:
            self.add_widget(MDLabel(text="❌ Không có quyền truy cập báo cáo", halign="center"))

    # Các hàm giả lập (bạn sẽ thay bằng gọi procedure thực tế)
    def show_all_transactions(self, instance):
        self.show_fake_dialog("Lịch sử toàn hệ thống")

    def show_suspicion(self, instance):
        self.show_fake_dialog("Báo cáo nghi ngờ")

    def show_employee_transactions(self, instance):
        self.show_fake_dialog("Giao dịch nhân viên")

    def show_branch_transactions(self, instance):
        self.show_fake_dialog("Giao dịch chi nhánh")

    def show_account_summary(self, instance):
        self.show_fake_dialog("Tổng hợp tài khoản")

    def show_interest_changes(self, instance):
        self.show_fake_dialog("Lịch sử lãi suất")

    def show_fake_dialog(self, title):
        dialog = MDDialog(
            title=title,
            text="(Giả lập)\nĐây là nơi bạn sẽ hiển thị dữ liệu từ stored procedure.",
            buttons=[],
        )
        dialog.open()
        
    def refresh(self):
        self.clear_widgets()
        self.build_ui()
