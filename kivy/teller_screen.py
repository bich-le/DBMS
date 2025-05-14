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

from report_procedures import REPORT_PROCEDURE_MAP  

class TellerScreen(MDScreen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.db_connection = None
        self.cursor = None
        self._first_load = True
        
    def on_pre_enter(self):
        self.connect_to_db()
        self.ids.screen_manager.current = "customers"
        
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
                user="bich",
                password="1234",
                database="PROJECT"
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
            details.customer_phone.text = customer_details['cus_phone_num']
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
            query = """
            SELECT 
                ca.*, 
                cat.cus_account_type_name, 
                COALESCE(sa.saving_acc_balance, ck.check_acc_balance, fd.deposit_amount) as balance,
                COALESCE(sa.interest_rate_id, ck.interest_rate_id, fd.interest_rate_id) as interest_rate_id,
                ir.interest_rate_val,
                ca.opening_date
            FROM CUSTOMER_ACCOUNTS ca
            LEFT JOIN CUSTOMER_ACCOUNT_TYPES cat ON ca.cus_account_type_id = cat.cus_account_type_id
            LEFT JOIN SAVING_ACCOUNTS sa ON ca.cus_account_id = sa.cus_account_id
            LEFT JOIN CHECK_ACCOUNTS ck ON ca.cus_account_id = ck.cus_account_id
            LEFT JOIN FIXED_DEPOSIT_ACCOUNTS fd ON ca.cus_account_id = fd.cus_account_id
            LEFT JOIN INTEREST_RATES ir ON ir.interest_rate_id = COALESCE(sa.interest_rate_id, ck.interest_rate_id, fd.interest_rate_id)
            WHERE ca.cus_account_id = %s
            """
            
            self.cursor.execute(query, (account['cus_account_id'],))
            account_details = self.cursor.fetchone()
            
            if not account_details:
                raise ValueError("Account not found")
            
            details_text = f"""
Loại tài khoản: {account_details['cus_account_type_name']}
Trạng thái: {account_details['cus_account_status']}
Số dư: {account_details['balance']:,} VND
Ngày mở: {account_details['opening_date'].strftime('%d/%m/%Y') if account_details['opening_date'] else 'N/A'}
"""
            
            if account_details['interest_rate_id']:
                details_text += f"Lãi suất: {account_details['interest_rate_val']}%\n"
                
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
Hạn mức chuyển: {check_details['transfer_limit']:,} VND
Hạn mức hàng ngày: {check_details['daily_transfer_limit']:,} VND
"""
            
            dialog = MDDialog(
                title=f"Chi tiết tài khoản {account['cus_account_id']}",
                text=details_text,
                buttons=[
                    MDFlatButton(
                        text="Đóng",
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
            