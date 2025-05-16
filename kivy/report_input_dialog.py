from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.boxlayout import MDBoxLayout
from report_result_dialog import show_result_dialog  # hàm hiển thị kết quả
from kivy.metrics import dp
import mysql.connector  # dùng kết nối database thật

class ContentAllTransaction(MDBoxLayout):
    def __init__(self, date_from, date_to, **kwargs):
        super().__init__(**kwargs)
        self.orientation = "vertical"
        self.spacing = dp(10)
        self.padding = dp(20)
        self.adaptive_height = True
        self.add_widget(date_from)
        self.add_widget(date_to)
class ContentBranchTransaction(MDBoxLayout):
    def __init__(self, branch_input, date_from, date_to, **kwargs):
        super().__init__(**kwargs)
        self.orientation = "vertical"
        self.spacing = dp(10)
        self.padding = dp(20)
        self.adaptive_height = True  # ✅ Cho phép dialog co giãn theo nội dung

        self.add_widget(branch_input)
        self.add_widget(date_from)
        self.add_widget(date_to)

class ContentSuspiciousTransaction(MDBoxLayout):
    def __init__(self, suspicion_threshold, date_from, date_to, **kwargs):
        super().__init__(**kwargs)
        self.orientation = "vertical"
        self.spacing = dp(10)
        self.padding = dp(20)
        self.adaptive_height = True
        self.add_widget(suspicion_threshold)
        self.add_widget(date_from)
        self.add_widget(date_to)


class ContentAccountSummary(MDBoxLayout):
    def __init__(self, account_type, as_of_date, **kwargs):
        super().__init__(**kwargs)
        self.orientation = "vertical"
        self.spacing = dp(10)
        self.padding = dp(20)
        self.adaptive_height = True
        self.add_widget(account_type)
        self.add_widget(as_of_date)


class ContentCustomerSummary(MDBoxLayout):
    def __init__(self, branch_input, **kwargs):
        super().__init__(**kwargs)
        self.orientation = "vertical"
        self.spacing = dp(10)
        self.padding = dp(20)
        self.adaptive_height = True
        self.add_widget(branch_input)


class ReportInputDialog:
    def __init__(self, report_type):
        self.report_type = report_type
        self.dialog = None

    def open(self):
        if self.report_type == "branch_transaction":
            self.dialog = self.build_branch_transaction_dialog()
        elif self.report_type == "all_transaction":
            self.dialog = self.build_all_transaction_dialog()
        elif self.report_type == "suspicious_transaction":
            self.dialog = self.build_suspicious_transaction_dialog()
        elif self.report_type == "account_summary":
            self.dialog = self.build_account_summary_dialog()
        elif self.report_type == "customer_summary":
            self.dialog = self.build_customer_summary_dialog()
        else:
            # Có thể mở dialog báo lỗi hoặc dialog mặc định
            self.dialog = MDDialog(title="Error", text="Unknown report type", buttons=[])
        self.dialog.open()

    def build_branch_transaction_dialog(self):
        self.branch_input = MDTextField(
            hint_text="Branch ID (e.g., HN)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )

        self.date_from = MDTextField(
            hint_text="From Date (YYYY-MM-DD)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )

        self.date_to = MDTextField(
            hint_text="To Date (YYYY-MM-DD)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )

        content = ContentBranchTransaction(
            branch_input=self.branch_input,
            date_from=self.date_from,
            date_to=self.date_to,
        )

        return MDDialog(
            title="Branch Transaction Report",
            type="custom",
            content_cls=content,
            buttons=[
                MDRaisedButton(text="Generate", on_release=self.generate_report),
            ],
        )
    def build_all_transaction_dialog(self):
        self.date_from = MDTextField(hint_text="From Date (YYYY-MM-DD)", size_hint_y=None, height=dp(60), multiline=False)
        self.date_to = MDTextField(hint_text="To Date (YYYY-MM-DD)", size_hint_y=None, height=dp(60), multiline=False)

        content = ContentAllTransaction(date_from=self.date_from, date_to=self.date_to)

        return MDDialog(
            title="All Transaction History Report",
            type="custom",
            content_cls=content,
            buttons=[MDRaisedButton(text="Generate", on_release=self.generate_report)],
        )
    def build_suspicious_transaction_dialog(self):
        self.suspicion_threshold = MDTextField(
            hint_text="Suspicion Threshold (e.g., 1000000)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )
        self.date_from = MDTextField(
            hint_text="From Date (YYYY-MM-DD)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )
        self.date_to = MDTextField(
            hint_text="To Date (YYYY-MM-DD)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )

        content = ContentSuspiciousTransaction(
            suspicion_threshold=self.suspicion_threshold,
            date_from=self.date_from,
            date_to=self.date_to,
        )

        return MDDialog(
            title="Suspicious Transaction Report",
            type="custom",
            content_cls=content,
            buttons=[MDRaisedButton(text="Generate", on_release=self.generate_report)],
        )
    def build_account_summary_dialog(self):
        self.account_type = MDTextField(
            hint_text="Account Type (e.g., Savings, Checking)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )
        self.as_of_date = MDTextField(
            hint_text="As Of Date (YYYY-MM-DD)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )

        content = ContentAccountSummary(
            account_type=self.account_type,
            as_of_date=self.as_of_date,
        )

        return MDDialog(
            title="Account Summary Report",
            type="custom",
            content_cls=content,
            buttons=[MDRaisedButton(text="Generate", on_release=self.generate_report)],
        )


    def build_customer_summary_dialog(self):
        self.branch_input = MDTextField(
            hint_text="Branch ID (e.g., HN)",
            size_hint_y=None,
            height=dp(60),
            multiline=False,
        )

        content = ContentCustomerSummary(branch_input=self.branch_input)

        return MDDialog(
            title="Customer Summary Report",
            type="custom",
            content_cls=content,
            buttons=[MDRaisedButton(text="Generate", on_release=self.generate_report)],
        )


    def generate_report(self, *args):
        # Lấy dữ liệu từ form input
        if self.report_type == "branch_transaction":
            branch_id = self.branch_input.text.strip()
            date_from = self.date_from.text.strip()
            date_to = self.date_to.text.strip()
            proc_name = "sp_branch_transaction_report"
            params = [branch_id, date_from, date_to]

        elif self.report_type == "all_transaction":
            date_from = self.date_from.text.strip()
            date_to = self.date_to.text.strip()
            proc_name = "sp_all_transaction_report"
            params = [date_from, date_to]

        elif self.report_type == "suspicious_transaction":
            suspicion_threshold = self.suspicion_threshold.text.strip()
            date_from = self.date_from.text.strip()
            date_to = self.date_to.text.strip()
            proc_name = "sp_suspicious_transaction_report"
            params = [suspicion_threshold, date_from, date_to]

        elif self.report_type == "account_summary":
            account_type = self.account_type.text.strip()
            as_of_date = self.as_of_date.text.strip()
            proc_name = "sp_account_summary_report"
            params = [account_type, as_of_date]

        elif self.report_type == "customer_summary":
            branch_id = self.branch_input.text.strip()
            proc_name = "sp_customer_summary_report"
            params = [branch_id]

        else:
            # Nếu không xác định được báo cáo
            show_result_dialog("Error", ["Error"], [["Unknown report type"]])
            self.dialog.dismiss()
            return

        try:
            conn = mysql.connector.connect(
                host="localhost", user="dong", password="44444444", database="main"
            )
            cursor = conn.cursor()
            cursor.callproc(proc_name, params)

            results = []
            for result in cursor.stored_results():
                results = result.fetchall()
                column_names = [desc[0] for desc in result.description]

            show_result_dialog(self.dialog.title, column_names, results)

        except Exception as e:
            show_result_dialog("Error", ["Error"], [[str(e)]])

        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()

        if self.dialog:
            self.dialog.dismiss()

        