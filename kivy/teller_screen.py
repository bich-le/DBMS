from kivymd.uix.screen import MDScreen
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.navigationdrawer import MDNavigationDrawer, MDNavigationDrawerMenu, MDNavigationDrawerItem
from kivymd.uix.screenmanager import MDScreenManager
from kivymd.uix.list import OneLineListItem
from kivymd.uix.list import OneLineListItem, TwoLineListItem
from kivymd.uix.card import MDCard
from kivy.metrics import dp
import mysql.connector
from mysql.connector import Error
from kivy.clock import Clock
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivymd.app import MDApp
from kivymd.uix.datatables import MDDataTable

from report_procedures import REPORT_PROCEDURE_MAP  
from kivy.lang import Builder
from report_box import ReportBox

Builder.load_string("""
<ReportBox>:
""")  # để Kivy nhận diện

class TellerScreen(MDScreen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.db_connection = None
        self.cursor = None
        self._first_load = True
        
    def on_pre_enter(self):
        self.connect_to_db()
        self.ids.screen_manager.current = "customers"
        if hasattr(self.ids, "report_box"):
            self.ids.report_box.refresh()
        
        if self._first_load:
            Clock.schedule_once(lambda dt: self.load_customers(), 0.1)
            self._first_load = False
        else:
            self.load_customers()
            
    def on_enter(self):
        if not self._first_load:
            self.load_customers()
        
    def navigate_to(self, screen_name):
        self.ids.screen_manager.current = screen_name
        
    def on_leave(self):
        self.close_db_connection()
    
    def connect_to_db(self):
        try:
            self.db_connection = mysql.connector.connect(
                host="localhost",
                user="root",
                password="Bichthebest3805",
                database="main"
            )
            self.cursor = self.db_connection.cursor(dictionary=True)
        except Error as e:
            print("Database connection error:", e)
            self.show_error_dialog("Không thể kết nối đến cơ sở dữ liệu")
    
    def close_db_connection(self):
        if self.cursor:
            self.cursor.close()
        if self.db_connection and self.db_connection.is_connected():
            self.db_connection.close()
    
    def load_customers(self, search_term=""):
        customer_list = self.ids.customer_list
        customer_list.clear_widgets()
        
        try:
            query = """
            SELECT cus_id, cus_first_name, cus_last_name, cus_phone_num, cus_email 
            FROM CUSTOMERS 
            WHERE cus_first_name LIKE %s OR cus_last_name LIKE %s OR cus_id LIKE %s
            """
            search_pattern = f"%{search_term}%"
            
            self.cursor.execute(query, (search_pattern, search_pattern, search_pattern))
            customers = self.cursor.fetchall()
            
            for customer in customers:
                item = TwoLineListItem(
                    text=f"{customer['cus_first_name']} {customer['cus_last_name']}",
                    secondary_text=f"ID: {customer['cus_id']} | {customer['cus_phone_num']}",
                    on_release=lambda x, c=customer: self.show_customer_details(c)
                )
                customer_list.add_widget(item)
                
        except Error as e:
            print("Error loading customers:", e)
            self.show_error_dialog("Lỗi khi tải danh sách khách hàng")
    
    def filter_customers(self, search_term):
        self.load_customers(search_term)
    
    def show_customer_details(self, customer):
        try:
            query = """
            SELECT c.*, b.branch_name 
            FROM CUSTOMERS c
            LEFT JOIN BRANCHES b ON c.branch_id = b.branch_id
            WHERE c.cus_id = %s
            """
            self.cursor.execute(query, (customer['cus_id'],))
            customer_details = self.cursor.fetchone()
            
            if not customer_details:
                raise ValueError("Customer not found")
            
            details = self.ids
            details.customer_name.text = f"{customer_details['cus_first_name']} {customer_details['cus_last_name']}"
            details.customer_id.text = f"ID: {customer_details['cus_id']}"
            details.customer_sex.text = customer_details['cus_sex']
            details.customer_address.text = customer_details['cus_address']
            details.customer_phone.text = customer_details['cus_phone_num']
            details.customer_join_date.text = customer_details['cus_join_date'].strftime('%d/%m/%Y')
            details.customer_email.text = customer_details.get('cus_email', 'N/A')
            
            if customer_details.get('cus_dob'):
                dob = customer_details['cus_dob'].strftime('%d/%m/%Y')
                details.customer_dob.text = f"{dob}"
            else:
                details.customer_dob.text = ""
                
            if customer_details.get('branch_name'):
                details.customer_branch.text = f"{customer_details['branch_name']}"
            else:
                details.customer_branch.text = ""
            
            self.load_customer_accounts(customer_details['cus_id'])
            
        except Error as e:
            print("Error loading customer details:", e)
            self.show_error_dialog("Lỗi khi tải thông tin khách hàng")
    
    def load_customer_accounts(self, customer_id):
        account_list = self.ids.account_list
        account_list.clear_widgets()
        
        try:
            query = """
            SELECT 
                ca.cus_account_id, 
                ca.cus_account_status, 
                cat.cus_account_type_name,
                COALESCE(sa.saving_acc_balance, ck.check_acc_balance, fd.deposit_amount) as balance,
                ca.opening_date
            FROM CUSTOMER_ACCOUNTS ca
            LEFT JOIN CUSTOMER_ACCOUNT_TYPES cat ON ca.cus_account_type_id = cat.cus_account_type_id
            LEFT JOIN SAVING_ACCOUNTS sa ON ca.cus_account_id = sa.cus_account_id
            LEFT JOIN CHECK_ACCOUNTS ck ON ca.cus_account_id = ck.cus_account_id
            LEFT JOIN FIXED_DEPOSIT_ACCOUNTS fd ON ca.cus_account_id = fd.cus_account_id
            WHERE ca.cus_id = %s
            """
            
            self.cursor.execute(query, (customer_id,))
            accounts = self.cursor.fetchall()
            
            for account in accounts:
                status_color = {
                    'Active': "#4CAF50",     # green
                    'Temporary Locked': "#FFC107",  # amber
                    'Locked': "#F44336"      # red
                }
                color_hex = status_color.get(account['cus_account_status'], "#9E9E9E")  # Gray mặc định

                
                balance = account['balance'] if account['balance'] is not None else 0
                opening_date = account['opening_date'].strftime('%d/%m/%Y') if account['opening_date'] else 'N/A'
                
                item = TwoLineListItem(
                    text=f"{account['cus_account_type_name']} Account",
                    secondary_text=f"Balance: {balance:,} VND | Status: {account['cus_account_status']}",
                    theme_text_color="Custom",
                    text_color=color_hex,
                    on_release=lambda x, a=account: self.show_account_details(a)
                )
                account_list.add_widget(item)
                
        except Error as e:
            print("Error loading accounts:", e)
            self.show_error_dialog("Lỗi khi tải danh sách tài khoản")
    
    def show_account_details(self, account):
        try:
            self.cursor.callproc('GetAccountDetailsById', (account['cus_account_id'],))

            # Sau khi gọi procedure, kết quả nằm trong một cursor phụ
            for result in self.cursor.stored_results():
                account_details = result.fetchone()
                
                if not account_details:
                    self.show_error_dialog("Không tìm thấy thông tin tài khoản")
                    return
                
            details_text = f"""
            Account Type: {account_details['cus_account_type_name']}
            Account Status: {account_details['cus_account_status']}
            Balance: {account_details['balance']:,} VND
            Opening Date: {account_details['opening_date'].strftime('%d/%m/%Y') if account_details['opening_date'] else 'N/A'}
            """
                        
            if account_details['interest_rate_id']:
                details_text += f"Interest rate: {account_details['interest_rate_val']}%\n"
                
            # Additional info for specific account types
            if account_details['cus_account_type_id'] == '02':  # Check account
                query = """
                SELECT transfer_limit, daily_transfer_limit 
                FROM CHECK_ACCOUNTS 
                WHERE cus_account_id = %s
                """
                self.cursor.execute(query, (account['cus_account_id'],))
                check_details = self.cursor.fetchone()
                if check_details:
                    details_text += f"""
                        Transfer Limit: {check_details['transfer_limit']:,} VND
                        Daily Transfer Limit: {check_details['daily_transfer_limit']:,} VND
                        """
            
            dialog = MDDialog(
                title=f"Account Detail {account['cus_account_id']}",
                text=details_text,
                buttons=[
                    MDFlatButton(
                        text="Close",
                        on_release=lambda x: dialog.dismiss()
                    ),
                ],
            )
            dialog.open()
            
        except Error as e:
            print("Error loading account details:", e)
            self.show_error_dialog("Lỗi khi tải thông tin tài khoản")
    
    def show_error_dialog(self, message):
        dialog = MDDialog(
            title="Lỗi",
            text=message,
        )

        dialog.buttons = [
            MDFlatButton(
                text="OK",
                on_release=lambda x: dialog.dismiss()
            ),
        ]

        dialog.open()
        
    def show_customer_table(self):
        try:
            self.cursor.execute("SELECT * FROM v_customer_summary")
            customers = self.cursor.fetchall()

            if not customers:
                self.show_error_dialog("Không có dữ liệu khách hàng")
                return
            
            # Tạo data table
            data_table = MDDataTable(
                use_pagination=True,
                size_hint=(1, None),
                height=dp(400),
                column_data=[
                    ("ID", dp(35)),
                    ("Name", dp(40)),
                    ("Phone Number", dp(30)),
                    ("Email", dp(40)),
                    ("Branch", dp(30)),
                    ("Number of Accounts", dp(20)),
                    ("Account Type", dp(40)),
                ],
                row_data=[
                    (
                        customer['cus_id'],
                        customer['customer_name'],
                        customer['cus_phone_num'],
                        customer['cus_email'],
                        customer['branch_name'],
                        str(customer['account_count']),
                        customer['account_types'],
                    )
                    for customer in customers
                ],
            )
            
            # Bọc trong layout
            layout = MDBoxLayout(
                orientation="vertical",
                padding=dp(10),
                spacing=dp(10),
                adaptive_height=True,
            )
            layout.add_widget(data_table)
            
            
            # Tạo dialog chứa data table
            self.table_dialog = MDDialog(
                title="Customer List",
                type="custom",
                content_cls=layout,
                size_hint=(0.95, None),
                height=dp(500),
                buttons=[
                    MDFlatButton(
                        text="Close",
                        on_release=lambda x: self.table_dialog.dismiss()
                    )
                ],
            )
            self.table_dialog.open()

        except Exception as e:
            print("Lỗi khi tải bảng khách hàng:", e)
            self.show_error_dialog("Lỗi khi tải bảng khách hàng")
            
    def call_report_procedure(self, report_id, cursor):
        """
        Gọi stored procedure tương ứng với report_id
        """
        procedure_name = REPORT_PROCEDURE_MAP.get(report_id)
        if procedure_name:
            try:
                cursor.callproc(procedure_name)
                print(f" Called procedure: {procedure_name}")
            except Exception as e:
                print(f"Failed {procedure_name}: {e}")
        else:
            print(f"Can not find procedure to report_id = {report_id}")
            