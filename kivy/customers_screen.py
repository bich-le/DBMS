from kivymd.uix.list import TwoLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.boxlayout import MDBoxLayout
from kivy.metrics import dp
from mysql.connector import Error
from kivymd.uix.screen import MDScreen
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os
import base64

# Tạo key bí mật (lưu ở nơi an toàn, chỉ tạo 1 lần)
SECRET_KEY = AESGCM.generate_key(bit_length=128)  # hoặc 256

def encrypt_balance(balance: float, key: bytes = SECRET_KEY) -> str:
    aesgcm = AESGCM(key)
    nonce = os.urandom(12)
    plaintext = str(balance).encode()
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    # Ghép nonce + ciphertext để lưu trữ
    return base64.b64encode(nonce + ciphertext).decode()

def decrypt_balance(token: str, key: bytes = SECRET_KEY) -> float:
    data = base64.b64decode(token)
    nonce, ciphertext = data[:12], data[12:]
    aesgcm = AESGCM(key)
    plaintext = aesgcm.decrypt(nonce, ciphertext, None)
    return float(plaintext.decode())

class CustomerScreen(MDScreen):
    db_connection = None
    cursor = None
    
    def open_parent_nav_drawer(self):
        parent = self.parent
        while hasattr(parent, 'parent'):
            # Kiểm tra bằng tên thay vì isinstance
            if hasattr(parent, 'name') and parent.name in ('t', 'm','c'):  # 't' là tên TellerScreen, 'm' là ManagerScreen
                break
            parent = parent.parent
        
        if parent and hasattr(parent, 'ids') and 'nav_drawer' in parent.ids:
            parent.ids.nav_drawer.set_state("open")
        else:
            print(f"Parent thực tế: {getattr(parent, 'name', 'unknown')}")
            print(f"IDs có sẵn: {dir(parent.ids) if hasattr(parent, 'ids') else 'Không có ids'}")
            
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

            details.customer_dob.text = customer_details['cus_dob'].strftime('%d/%m/%Y') if customer_details.get('cus_dob') else ""
            details.customer_branch.text = customer_details.get('branch_name', '')

            self.load_customer_accounts(customer_details['cus_id'])

        except Error as e:
            print("Error loading customer details:", e)
            self.show_error_dialog( "Lỗi khi tải thông tin khách hàng")


    def load_customer_accounts(self, customer_id):
        account_list = self.ids.account_list
        account_list.clear_widgets()
        
        try:
            query = """
            SELECT 
                ca.cus_account_id, 
                ca.cus_account_status, 
                cat.cus_account_type_name,
                ca.cus_account_type_id,
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
                    'Active': "#4CAF50",
                    'Temporary Locked': "#FFC107",
                    'Locked': "#F44336"
                }
                color_hex = status_color.get(account['cus_account_status'], "#9E9E9E")
                balance = account['balance'] or 0
                opening_date = account['opening_date'].strftime('%d/%m/%Y') if account['opening_date'] else 'N/A'

                balance = account['balance'] or 0
                encrypted_balance = encrypt_balance(balance)
                decrypted_balance = decrypt_balance(encrypted_balance)
                item = TwoLineListItem(
                    text=f"{account['cus_account_type_name']} Account",
                    secondary_text=f"Status: {account['cus_account_status']}",
                    theme_text_color="Custom",
                    text_color=color_hex,
                    on_release=lambda x, a=account: self.show_account_details( a)
                )
                account_list.add_widget(item)

        except Error as e:
            print("Error loading accounts:", e)
            self.show_error_dialog( "Lỗi khi tải danh sách tài khoản")


    def show_account_details(self, account):
        try:
            self.cursor.callproc('GetAccountDetailsById', (account['cus_account_id'],))
            
            # Sau khi gọi procedure, kết quả nằm trong một cursor phụ
            for result in self.cursor.stored_results():
                account_details = result.fetchone()
                if not account_details:
                    self.show_error_dialog( "Không tìm thấy thông tin tài khoản")
                    return

            details_text = f"""
            Account Type: {account_details['cus_account_type_name']}
            Account Status: {account_details['cus_account_status']}
            Opening Date: {account_details['opening_date'].strftime('%d/%m/%Y') if account_details['opening_date'] else 'N/A'}
            """

            if account_details['interest_rate_id']:
                details_text += f"Interest rate: {account_details['interest_rate_val']}%\n"

            # Additional info for specific account types
            if account_details['cus_account_type_id'] == '02':
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
                buttons=[MDFlatButton(text="Close", on_release=lambda x: dialog.dismiss())],
            )
            dialog.open()

        except Error as e:
            print("Error loading account details:", e)
            self.show_error_dialog( "Lỗi khi tải thông tin tài khoản")


    def show_customer_table(self):
        try:
            self.cursor.execute("SELECT * FROM v_customer_summary")
            customers = self.cursor.fetchall()

            if not customers:
                self.show_error_dialog( "Không có dữ liệu khách hàng")
                return

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
                buttons=[MDFlatButton(text="Close", on_release=lambda x: self.table_dialog.dismiss())],
            )
            self.table_dialog.open()

        except Exception as e:
            print("Lỗi khi tải bảng khách hàng:", e)
            self.show_error_dialog( "Lỗi khi tải bảng khách hàng")


    def show_error_dialog(self, message):
        dialog = MDDialog(title="Lỗi", text=message)
        dialog.buttons = [MDFlatButton(text="OK", on_release=lambda x: dialog.dismiss())]
        dialog.open()
