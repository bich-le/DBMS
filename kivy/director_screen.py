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
                ("ID", dp(50)),
                ("Loại", dp(20)),
                ("Tài khoản", dp(50)),
                ("Tài khoản liên quan", dp(50)),
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
        # screen = self.ids.screen_manager.get_screen('transactions')
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
                "Loại": found.get('trans_type_id', 'N/A'),
                "Tài khoản": found.get('cus_account_id', 'N/A'),
                "Tài khoản liên quan": found.get('related_cus_account_id', 'N/A'),
                "Số tiền": f"{found.get('trans_amount', 0):,.0f}",
                "Thời gian": found.get('trans_time', 'N/A'),
                "Trạng thái": found.get('trans_status', 'N/A'),
                "Mã lỗi": found.get('trans_error_code', 'Không có'),
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
                title="Chi tiết giao dịch",
                type="custom",
                content_cls=content,
                buttons=[
                    MDFlatButton(text="Đóng", on_release=lambda x: dialog.dismiss())
                ],
            )
            dialog.open()
        else:
            # Giao dịch không tìm thấy (không thay đổi ở đây)
            dialog = MDDialog(
                title="Không tìm thấy",
                text="Không tìm thấy giao dịch với ID đã nhập.",
                buttons=[
                    MDFlatButton(text="OK", on_release=lambda x: dialog.dismiss())
                ],
            )
            dialog.open()
    def show_add_transaction_dialog(self):
        if not hasattr(self, 'add_transaction_dialog'):
            content = BoxLayout(orientation='vertical', spacing='10dp', padding=('20dp', '20dp'), size_hint_y=None)
            content.bind(minimum_height=content.setter('height'))

            self.trans_type_id_field = MDTextField(hint_text="Loại giao dịch (TRF, ...)")
            content.add_widget(self.trans_type_id_field)

            self.cus_account_id_field = MDTextField(hint_text="Tài khoản khách hàng")
            content.add_widget(self.cus_account_id_field)

            self.related_cus_account_id_field = MDTextField(hint_text="Tài khoản liên quan (nếu có)")
            content.add_widget(self.related_cus_account_id_field)

            self.trans_amount_field = MDTextField(hint_text="Số tiền", input_type='number')
            content.add_widget(self.trans_amount_field)

            self.direction_field = MDTextField(hint_text="Hướng (Debit/Credit)")
            content.add_widget(self.direction_field)

            self.trans_status_field = MDTextField(hint_text="Trạng thái (Successful/Failed)", text='Successful') # Default
            content.add_widget(self.trans_status_field)
            
            self.trans_error_code_field = MDTextField(hint_text="Mã lỗi (nếu có)")
            content.add_widget(self.trans_error_code_field)
        
            self.trans_time_field = MDTextField(hint_text="Thời gian (YYYY-MM-DD HH:MM:SS)", text=datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            content.add_widget(self.trans_time_field)

            self.last_updated_field = MDTextField(hint_text="Lần cập nhật (YYYY-MM-DD HH:MM:SS)", text=datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            content.add_widget(self.last_updated_field)

            self.add_transaction_dialog = MDDialog(
                title="Thêm giao dịch mới",
                type="custom",
                content_cls=content,
                buttons=[
                    MDFlatButton(text="Hủy", on_release=self.close_add_transaction_dialog),
                    MDFlatButton(text="Thêm", on_release=self.add_new_transaction_to_db)
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
                toast("Vui lòng điền đầy đủ các trường bắt buộc.")
                return

            conn = self.get_db_connection()
            if conn is None:
                return

            mycursor = conn.cursor()
            try:
                mycursor.callproc('AddTransaction', [
                    trans_type_id, cus_account_id, related_cus_account_id,
                    int(trans_amount), direction.capitalize(), trans_status, 
                    trans_error_code, trans_time, last_updated, None, None  # Truyền None cho các tham số OUT
                ])
                
                # CÁCH ĐÚNG để lấy OUT params trong Python
                mycursor.execute("SELECT @_AddTransaction_10, @_AddTransaction_11")
                result = mycursor.fetchone()
                print("OUT params:", result)  # Giờ sẽ hiển thị đúng giá trị
                
                if result and result[1] == 'SUCCESS':
                    conn.commit()
                    toast("Thành công!")
                else:
                    conn.rollback()
                    toast(result[0] if result else "Lỗi không xác định")
                    
            except mysql.connector.Error as err:
                print("MySQL Error:", err)
                toast(f"Lỗi database: {err}")
            finally:
                if conn.is_connected():
                    mycursor.close()
                    conn.close()