from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.boxlayout import MDBoxLayout
from report_result_dialog import show_result_dialog  # hàm hiển thị kết quả
from kivy.metrics import dp
import mysql.connector  # dùng kết nối database thật

class ReportInputDialog:
    def __init__(self, report_type):
        self.report_type = report_type
        self.dialog = None

    def open(self):
        if self.report_type == "branch_transaction":
            self.dialog = self.build_branch_transaction_dialog()
            self.dialog.open()

    def build_branch_transaction_dialog(self):
        self.branch_input = MDTextField(
            hint_text="Branch ID (e.g., HN)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
            readonly=False,
            disabled=False,
        )

        self.date_from = MDTextField(
            hint_text="From Date (YYYY-MM-DD)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
            readonly=False,
            disabled=False,
        )

        self.date_to = MDTextField(
            hint_text="To Date (YYYY-MM-DD)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
            readonly=False,
            disabled=False,
        )


        content = MDBoxLayout(
            orientation="vertical",
            spacing=10,
            padding=20,
            adaptive_size=True
        )
        content.add_widget(self.branch_input)
        content.add_widget(self.date_from)
        content.add_widget(self.date_to)

        return MDDialog(
            title="Branch Transaction Report",
            type="custom",
            content_cls=content,
            buttons=[
                MDRaisedButton(text="Generate", on_release=self.generate_report),
            ],
        )

    def generate_report(self, *args):
        branch_id = self.branch_input.text.strip()
        date_from = self.date_from.text.strip()
        date_to = self.date_to.text.strip()

        # Gọi procedure thật trong MySQL
        try:
            conn = mysql.connector.connect(
                host="localhost", user="root", password="yourpassword", database="main"
            )
            cursor = conn.cursor()
            cursor.callproc("sp_branch_transaction_report", [branch_id, date_from, date_to])

            results = []
            for result in cursor.stored_results():
                results = result.fetchall()

            column_names = [desc[0] for desc in result.description]

            show_result_dialog("Branch Transaction Report", column_names, results)

        except Exception as e:
            show_result_dialog("Error", ["Error"], [[str(e)]])
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()

        self.dialog.dismiss()
