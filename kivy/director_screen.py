from kivymd.uix.screen import MDScreen
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.list import TwoLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivy.metrics import dp
import mysql.connector
from mysql.connector import Error
from kivymd.uix.label import MDLabel
from kivy.uix.boxlayout import BoxLayout


class DirectorScreen(MDScreen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.all_employees_data = []
        self.all_transactions_data = []
        self.data_emp_table = None
        self.data_trans_table = None
        self._emp_placeholder = None
        self._trans_placeholder = None

    def on_enter(self):
        current_screen = self.ids.screen_manager.current
        if current_screen == "employees":
            self.load_all_employees()
        elif current_screen == "transactions":
            self.load_all_transactions()
        elif current_screen == "report":
            self.ids.report_box.refresh()

    def get_db_connection(self):
        try:
            return mysql.connector.connect(
                host="localhost",
                user="root",
                password="Nhan220405",
                database="main"
            )
        except Error as e:
            print("Database connection error:", e)
            return None

    def load_all_employees(self):
        conn = self.get_db_connection()
        if not conn:
            self.show_employee_error("Không thể kết nối database")
            return

        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
                SELECT 
                    emp_id,
                    emp_fullname, 
                    emp_position_id,
                    emp_phone_num,
                    emp_email,
                    DATE_FORMAT(emp_join_date, '%d/%m/%Y') as emp_join_date
                FROM employees
                ORDER BY 
                    CASE emp_position_id
                        WHEN 'Director' THEN 1
                        WHEN 'Manager' THEN 2
                        WHEN 'Auditor' THEN 3
                        WHEN 'Teller' THEN 4
                        ELSE 5
                    END,
                    emp_fullname
            """)
            self.all_employees_data = cursor.fetchall()
            self.show_employee_table(self.all_employees_data)
        except Error as e:
            print("Lỗi khi tải nhân viên:", e)
            self.show_employee_error(f"Lỗi khi tải dữ liệu: {str(e)}")
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()

    def show_employee_table(self, data):
        container = self.ids.get('emp_table_container')
        if not container:
            return

        if not self._emp_placeholder:
            self._emp_placeholder = self.ids.get('emp_placeholder')

        container.clear_widgets()

        if not data:
            if self._emp_placeholder:
                self._emp_placeholder.text = "Không có dữ liệu nhân viên"
                container.add_widget(self._emp_placeholder)
            return

        self.data_emp_table = MDDataTable(
            size_hint=(1, None),
            height=min(len(data) * dp(50), dp(500)),
            column_data=[
                ("ID", dp(30)),
                ("Họ tên", dp(50)),
                ("Chức vụ", dp(40)),
                ("SĐT", dp(40)),
                ("Email", dp(60)),
                ("Ngày vào", dp(40)),
            ],
            row_data=[(
                row['emp_id'],
                row['emp_fullname'],
                row['emp_position_id'],
                row['emp_phone_num'],
                row['emp_email'],
                row['emp_join_date']
            ) for row in data],
            use_pagination=True,
            rows_num=10,
            background_color_header="#1e88e5",
            background_color_cell="#e3f2fd",
        )
        container.add_widget(self.data_emp_table)









    def load_all_transactions(self):
        conn = self.get_db_connection()
        if not conn:
            self.show_transaction_error("Không thể kết nối database")
            return

        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
                SELECT 
                    trans_id, 
                    trans_type_id, 
                    cus_account_id, 
                    related_cus_account_id,
                    trans_amount,
                    DATE_FORMAT(trans_time, '%d/%m/%Y %H:%i:%s') as trans_time,
                    trans_status,
                    trans_error_code
                FROM transactions
                ORDER BY trans_time DESC
                LIMIT 100
            """)
            self.all_transactions_data = cursor.fetchall()
            self.show_transactions_table(self.all_transactions_data)
        except Error as e:
            print("Lỗi khi tải giao dịch:", e)
            self.show_transaction_error(f"Lỗi khi tải dữ liệu: {str(e)}")
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()

    def show_transactions_table(self, data):
        container = self.ids.get('trans_table_container')
        if not container:
            return

        if not self._trans_placeholder:
            self._trans_placeholder = self.ids.get('trans_placeholder')

        container.clear_widgets()

        if not data:
            if self._trans_placeholder:
                self._trans_placeholder.text = "Không có dữ liệu giao dịch"
                container.add_widget(self._trans_placeholder)
            return

        self.data_trans_table = MDDataTable(
            size_hint=(1, None),
            height=min(len(data) * dp(50), dp(500)),
            column_data=[
                ("ID", dp(30)),
                ("Loại", dp(40)),
                ("Tài khoản", dp(50)),
                ("Tài khoản liên quan", dp(60)),
                ("Số tiền", dp(40)),
                ("Thời gian", dp(60)),
                ("Trạng thái", dp(40)),
                ("Mã lỗi", dp(40)),
            ],
            row_data=[(
                row['trans_id'],
                row['trans_type_id'],
                row['cus_account_id'],
                row['related_cus_account_id'] or "",
                f"{row['trans_amount']:,.0f}",
                row['trans_time'],
                row['trans_status'],
                row['trans_error_code'] or ""
            ) for row in data],
            use_pagination=True,
            rows_num=10,
            background_color_header="#F2F2F2",
            background_color_cell="#EAE4D5",
        )
        container.add_widget(self.data_trans_table)

    
    def refresh_employees(self):
        self.load_all_employees()

    def refresh_transactions(self):
        self.load_all_transactions()

    def show_employee_error(self, message):
        container = self.ids.emp_table_container
        container.clear_widgets()
        self.ids.emp_placeholder.text = message
        container.add_widget(self.ids.emp_placeholder)

    def show_transaction_error(self, message):
        container = self.ids.trans_table_container
        container.clear_widgets()
        self.ids.trans_placeholder.text = message
        container.add_widget(self.ids.trans_placeholder)

        def search_transaction(self):
            query = self.ids.trans_search_field.text.strip()
            if not query:
                return

            found = None
            for transaction in self.all_transactions_data:
                if query in str(transaction['trans_id']):
                    found = transaction
                    break

            if found:
                # Hiển thị chi tiết giao dịch dạng từng dòng
                content = BoxLayout(orientation="vertical", spacing=10, size_hint_y=None)
                content.bind(minimum_height=content.setter('height'))

                info_lines = [
                    f"1. ID: {found['trans_id']}",
                    f"2. Loại: {found['trans_type_id']}",
                    f"3. Tài khoản: {found['cus_account_id']}",
                    f"4. Tài khoản liên quan: {found['related_cus_account_id'] or 'N/A'}",
                    f"5. Số tiền: {found['trans_amount']:,.0f}",
                    f"6. Thời gian: {found['trans_time']}",
                    f"7. Trạng thái: {found['trans_status']}",
                    f"8. Mã lỗi: {found['trans_error_code'] or 'Không có'}",
                ]

                for line in info_lines:
                    content.add_widget(MDLabel(text=line, halign="left"))

                dialog = MDDialog(
                    title="Chi tiết giao dịch",
                    type="custom",
                    content_cls=content,
                    buttons=[
                        MDFlatButton(text="Đóng", on_release=lambda x: dialog.dismiss())
                    ],
                )
                dialog.open()
            else:
                # Giao dịch không tìm thấy
                dialog = MDDialog(
                    title="Không tìm thấy",
                    text="Không tìm thấy giao dịch với ID đã nhập.",
                    buttons=[
                        MDFlatButton(text="OK", on_release=lambda x: dialog.dismiss())
                    ],
                )
                dialog.open()