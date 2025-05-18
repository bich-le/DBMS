from kivymd.uix.screen import MDScreen
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.list import TwoLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivy.metrics import dp
from kivy.uix.boxlayout import BoxLayout
import mysql.connector
from mysql.connector import Error
from kivymd.uix.label import MDLabel
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.toast import toast
from kivymd.uix.textfield import MDTextField
from datetime import datetime
from kivymd.uix.button import MDIconButton

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
                ORDER BY transactions.trans_time DESC
                LIMIT 100
            """)
            self.all_transactions_data = cursor.fetchall()
            self.show_transactions_table(self.all_transactions_data)
        except Error as e:
            print("Error loading transactions:", e)
            self.show_transaction_error(f"Error loading data: {str(e)}")
        finally:
            if conn.is_connected():
                cursor.close()
                conn.close()

    def show_transactions_table(self, data):
        container = self.ids.get('trans_table_container')
        if not container:
            return

        # Không dùng self._trans_placeholder nữa
        trans_placeholder = self.ids.get('trans_placeholder')

        container.clear_widgets()

        if not data:
            if trans_placeholder:
                trans_placeholder.text = "Không có dữ liệu giao dịch"
                container.add_widget(trans_placeholder)
            return

        self.data_trans_table = MDDataTable(
            size_hint=(1, None),
            height=min(len(data) * dp(50), dp(500)),
            column_data=[
                ("ID", dp(50)),
                ("Type", dp(20)),
                ("Customer Account", dp(50)),
                ("Related Account", dp(50)),
                ("Amount", dp(40)),
                ("Time", dp(60)),
                ("Status", dp(40)),
                ("Error Code", dp(40)),
            ],
            row_data=[(
                row['trans_id'],
                row['trans_type_id'],
                row['cus_account_id'],
                row['related_cus_account_id'] or "",
                f"{row['trans_amount']:,.0f}",
                row['trans_time'],
                '[color=#D50000]FAILED[/color]' if row['trans_status'].lower() == 'failed' else '[color=#00C853]SUCCESS[/color]',
                row['trans_error_code'] or ""
            ) for row in data],
            use_pagination=True,
            rows_num=10,
            background_color_header="#F2F2F2",
            background_color_cell="FFFFFF",
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

            content = MDBoxLayout(orientation="vertical", spacing=10, padding=(10, 10), size_hint_y=None)

            content.bind(minimum_height=content.setter('height'))

            info_data = {
                "ID": found['trans_id'],
                "Type": found.get('trans_type_id', 'N/A'),
                "Customer Account": found.get('cus_account_id', 'N/A'),
                "Related Account": found.get('related_cus_account_id', 'N/A'),
                "Amount": f"{found.get('trans_amount', 0):,.0f}",
                "Time": found.get('trans_time', 'N/A'),
                "Status": found.get('trans_status', 'N/A'),
                "Error Code": found.get('trans_error_code', 'None'),
            }
            for key, value in info_data.items():
                label = MDLabel(
                    text=f"{key}: {value}",
                    halign="left",
                    size_hint_y=None,
                    height=dp(30),  # hoặc: height=self.texture_size[1] + dp(10)
                )
                content.add_widget(label)
            dialog = MDDialog(
                title="Transaction Details",
                type="custom",
                content_cls=content,
                buttons=[
                    MDFlatButton(text="Close", on_release=lambda x: dialog.dismiss())
                ],
            )
            dialog.open()
        else:
            # Giao dịch không tìm thấy (không thay đổi ở đây)
            dialog = MDDialog(
                title="Not Found",
                text="No transaction found with the entered ID.",
                buttons=[
                    MDFlatButton(text="OK", on_release=lambda x: dialog.dismiss())
                ],
            )
            dialog.open()
    def show_add_transaction_dialog(self):
        if not hasattr(self, 'add_transaction_dialog'):
            content = BoxLayout(orientation='vertical', spacing='10dp', padding=('20dp', '20dp'), size_hint_y=None)
            content.bind(minimum_height=content.setter('height'))

            self.trans_type_id_field = MDTextField(hint_text="Transaction Type (TRF, POS ...)")
            content.add_widget(self.trans_type_id_field)

            self.cus_account_id_field = MDTextField(hint_text="Customer Account")
            content.add_widget(self.cus_account_id_field)

            self.related_cus_account_id_field = MDTextField(hint_text="Related Account (if any)")
            content.add_widget(self.related_cus_account_id_field)

            self.trans_amount_field = MDTextField(hint_text="Amount", input_type='number')
            content.add_widget(self.trans_amount_field)

            self.direction_field = MDTextField(hint_text="Direction (Debit/Credit)")
            content.add_widget(self.direction_field)

            self.trans_status_field = MDTextField(hint_text="Status (Successful/Failed)", text='Successful') # Default
            content.add_widget(self.trans_status_field)
            
            self.trans_error_code_field = MDTextField(hint_text="Error Code (if any)")
            content.add_widget(self.trans_error_code_field)
        
            self.trans_time_field = MDTextField(hint_text="Time (YYYY-MM-DD HH:MM:SS)", text=datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            content.add_widget(self.trans_time_field)

            self.last_updated_field = MDTextField(hint_text="Last Updated (YYYY-MM-DD HH:MM:SS)", text=datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            content.add_widget(self.last_updated_field)

            self.add_transaction_dialog = MDDialog(
                title="Add New Transaction",
                type="custom",
                content_cls=content,
                buttons=[
                    MDFlatButton(text="Cancel", on_release=self.close_add_transaction_dialog),
                    MDFlatButton(text="Add", on_release=self.add_new_transaction_to_db)
                ]
            )
        self.add_transaction_dialog.open()

    def close_add_transaction_dialog(self, instance):
        self.add_transaction_dialog.dismiss()

    def add_new_transaction_to_db(self, instance):
        trans_type_id = self.trans_type_id_field.text
        cus_account_id = self.cus_account_id_field.text
        related_cus_account_id = self.related_cus_account_id_field.text or None
        trans_amount = self.trans_amount_field.text
        direction = self.direction_field.text
        trans_status = self.trans_status_field.text
        trans_error_code = self.trans_error_code_field.text or None
        trans_time = self.trans_time_field.text
        last_updated = self.last_updated_field.text

        if not all([trans_type_id, cus_account_id, trans_amount, direction]):
            toast("Please fill in all required fields.")
            return

        conn = self.get_db_connection()
        if conn is None:
            return

        mycursor = conn.cursor()
        try:
            args = [
                trans_type_id, cus_account_id, related_cus_account_id,
                int(trans_amount), direction.capitalize(), trans_status,
                trans_error_code, trans_time, last_updated, None, None
            ]
            result_args = mycursor.callproc('AddTransaction', args)
            conn.commit()

            result_message = result_args[-2]  # p_result
            error_code = result_args[-1]      # p_error_code

            toast(result_message)
            if error_code == 'SUCCESS':
                toast("Transaction added successfully!")
                # Đóng dialog và refresh data an toàn
                def safe_close_and_refresh(dt):
                    if hasattr(self, 'add_transaction_dialog'):
                        self.add_transaction_dialog.dismiss()
                    self.load_all_transactions()
                    self.ids.screen_manager.current = 'transactions' # Quay về màn hình transactions

                from kivy.clock import Clock
                Clock.schedule_once(safe_close_and_refresh)
            else:
                print(f"Error adding transaction: {result_message} (Code: {error_code})")
                
        except mysql.connector.Error as err:
            print(f"Database error while adding transaction: {err}")
            toast(f"Database error: {err}")
        except ValueError:
            toast("Invalid value!")
        finally:
            if conn.is_connected():
                mycursor.close()
                conn.close()