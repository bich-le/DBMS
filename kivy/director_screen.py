from kivymd.uix.screen import MDScreen
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.list import TwoLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivy.metrics import dp
import mysql.connector
from mysql.connector import Error


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

    def show_transaction_details(self, transaction):
        try:
            content = (
                f"[b]Transaction ID:[/b] {transaction['trans_id']}\n"
                f"[b]Type:[/b] {transaction['trans_type_id']}\n"
                f"[b]Account ID:[/b] {transaction['cus_account_id']}\n"
                f"[b]Amount:[/b] {transaction.get('trans_amount', 'N/A')}\n"
                f"[b]Date:[/b] {transaction.get('trans_time', 'N/A')}"
            )

            dialog = MDDialog(
                title="Chi tiết giao dịch",
                text=content,
                buttons=[
                    MDFlatButton(text="ĐÓNG", on_release=lambda x: dialog.dismiss())
                ]
            )
            dialog.open()
        except Exception as e:
            print("Lỗi khi hiển thị chi tiết giao dịch:", e)

    def load_transactions(self, search_term=""):
        if not self.all_transactions_data:  # Nếu chưa có dữ liệu
            return
        
        search_term = search_term.strip().lower()
        
        if not search_term:  # Nếu không có từ tìm kiếm, hiển thị tất cả
            self.show_transactions_table(self.all_transactions_data)
            return
        
        # Lọc dữ liệu
        filtered = []
        for trans in self.all_transactions_data:
            if (search_term in str(trans.get('trans_id', '')).lower() or 
                search_term in str(trans.get('trans_type_id', '')).lower() or 
                search_term in str(trans.get('cus_account_id', '')).lower() or
                search_term in str(trans.get('related_cus_account_id', '')).lower()):
                filtered.append(trans)
        
        # Hiển thị kết quả đã lọc
        self.show_transactions_table(filtered)

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
