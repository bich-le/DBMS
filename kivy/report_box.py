from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.app import MDApp
from kivymd.uix.list import MDList, OneLineIconListItem, IconLeftWidget
from kivymd.uix.label import MDLabel
from kivy.uix.scrollview import ScrollView
from kivy.metrics import dp
from kivymd.uix.dialog import MDDialog
from report_input_dialog import ReportInputDialog


class ReportBox(MDBoxLayout):
    def __init__(self, **kwargs):
        super().__init__(orientation="vertical", padding=20, spacing=15, **kwargs)
        self.build_ui()

    def build_ui(self):
        app = MDApp.get_running_app()
        role = getattr(app, "current_role", "guest")  # Đọc chức vụ đã lưu sau đăng nhập

        # Tiêu đề role
        # Chào theo chức vụ
        role_names = {
            "c": "CEO",
            "a": "AUDITOR",
            "m": "MANAGER",
            "t": "TELLER",
            "guest": "GUEST"
        }
        role_label = role_names.get(role, role.upper())

        welcome_box = MDBoxLayout(
            md_bg_color=(0.95, 0.95, 0.95, 1),
            padding=(10, 10),
            size_hint_y=None,
            height=dp(50),
            radius=[12],
        )

        welcome_label = MDLabel(
            text=f"[b]Welcome, {role_label}![/b]",
            theme_text_color="Primary",
            halign="center",
            font_style="H6",
            markup=True,
        )
        welcome_box.add_widget(welcome_label)
        self.add_widget(welcome_box)

        
        # ScrollView chứa MDList (list hiện đại, cuộn được)
        scroll = ScrollView()
        self.mdlist = MDList()
        scroll.add_widget(self.mdlist)
        self.add_widget(scroll)

        # Xác định danh sách báo cáo theo role cùng icon phù hợp
        reports = []
        if role == "c":  # CEO
            reports = [
                ("file-document-outline", "All Transaction History Report", self.show_all_transactions),
                ("bank-outline", "Branch Transaction Report", self.show_branch_transactions),
                ("alert-circle-outline", "Suspicious Transaction Report", self.show_suspicion),
                ("account-group-outline", "Customer Summary by Branch Report", self.show_customer_summary),
                ("clipboard-text-outline", "Account Summary Report", self.show_account_summary),
            ]
        elif role == "a":  # Auditor
            reports = [
                ("file-document-outline", "All Transaction History Report", self.show_all_transactions),
                ("bank-outline", "Branch Transaction Report", self.show_branch_transactions),
                ("alert-circle-outline", "Suspicious Transaction Report", self.show_suspicion),
                ("account-group-outline", "Customer Summary by Branch Report", self.show_customer_summary),
                ("clipboard-text-outline", "Account Summary Report", self.show_account_summary),
            ]
        elif role == "m":  # Manager
            reports = [
                ("bank-outline", "Branch Transaction Report", self.show_branch_transactions),
                ("alert-circle-outline", "Suspicious Transaction Report", self.show_suspicion),
                ("account-group-outline", "Customer Summary by Branch Report", self.show_customer_summary),
                ("clipboard-text-outline", "Account Summary Report", self.show_account_summary),
            ]
        elif role == "t":  # Teller
            reports = [
                ("clipboard-text-outline", "Account Summary Report", self.show_account_summary),
            ]
        else:
            self.mdlist.add_widget(
                MDLabel(text="No report access available for your role.", halign="center")
            )
            return

        # Tạo từng item danh sách với icon bên trái
        for icon_name, label, callback in reports:
            item = OneLineIconListItem(text=label, on_release=callback)
            icon = IconLeftWidget(icon=icon_name)
            item.add_widget(icon)
            self.mdlist.add_widget(item)

    # Các hàm giả lập (bạn sẽ thay bằng gọi procedure thực tế)
    def show_all_transactions(self, instance):
        self.show_fake_dialog("All Transaction History Report")

    def show_suspicion(self, instance):
        self.show_fake_dialog("Suspicious Transaction Report")

    def show_branch_transactions(self, instance):
        dialog = ReportInputDialog("branch_transaction")
        dialog.open()

    def show_account_summary(self, instance):
        self.show_fake_dialog("Account Summary Report")

    def show_customer_summary(self, instance):
        self.show_fake_dialog("Customer Summary by Branch Report")

    def show_fake_dialog(self, title):
        dialog = MDDialog(
            title=title,
            text="(Mockup)\nThis is where data from a stored procedure will be shown.",
            buttons=[],
        )
        dialog.open()

    def refresh(self):
        self.clear_widgets()
        self.build_ui()
