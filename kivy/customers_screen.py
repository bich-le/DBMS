# customer_utils.py

from kivymd.uix.list import TwoLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.boxlayout import MDBoxLayout
from kivy.metrics import dp
from mysql.connector import Error


def load_customers(instance, search_term=""):
    customer_list = instance.ids.customer_list
    customer_list.clear_widgets()
    
    try:
        query = """
        SELECT cus_id, cus_first_name, cus_last_name, cus_phone_num, cus_email 
        FROM CUSTOMERS 
        WHERE cus_first_name LIKE %s OR cus_last_name LIKE %s OR cus_id LIKE %s
        """
        search_pattern = f"%{search_term}%"
        instance.cursor.execute(query, (search_pattern, search_pattern, search_pattern))
        customers = instance.cursor.fetchall()

        for customer in customers:
            item = TwoLineListItem(
                text=f"{customer['cus_first_name']} {customer['cus_last_name']}",
                secondary_text=f"ID: {customer['cus_id']} | {customer['cus_phone_num']}",
                on_release=lambda x, c=customer: show_customer_details(instance, c)
            )
            customer_list.add_widget(item)
            
    except Error as e:
        print("Error loading customers:", e)
        show_error_dialog(instance, "Lỗi khi tải danh sách khách hàng")


def filter_customers(instance, search_term):
    load_customers(instance, search_term)


def show_customer_details(instance, customer):
    try:
        query = """
        SELECT c.*, b.branch_name 
        FROM CUSTOMERS c
        LEFT JOIN BRANCHES b ON c.branch_id = b.branch_id
        WHERE c.cus_id = %s
        """
        instance.cursor.execute(query, (customer['cus_id'],))
        customer_details = instance.cursor.fetchone()
        
        if not customer_details:
            raise ValueError("Customer not found")

        details = instance.ids
        details.customer_name.text = f"{customer_details['cus_first_name']} {customer_details['cus_last_name']}"
        details.customer_id.text = f"ID: {customer_details['cus_id']}"
        details.customer_sex.text = customer_details['cus_sex']
        details.customer_address.text = customer_details['cus_address']
        details.customer_phone.text = customer_details['cus_phone_num']
        details.customer_join_date.text = customer_details['cus_join_date'].strftime('%d/%m/%Y')
        details.customer_email.text = customer_details.get('cus_email', 'N/A')

        details.customer_dob.text = customer_details['cus_dob'].strftime('%d/%m/%Y') if customer_details.get('cus_dob') else ""
        details.customer_branch.text = customer_details.get('branch_name', '')

        load_customer_accounts(instance, customer_details['cus_id'])

    except Error as e:
        print("Error loading customer details:", e)
        show_error_dialog(instance, "Lỗi khi tải thông tin khách hàng")


def load_customer_accounts(instance, customer_id):
    account_list = instance.ids.account_list
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
        
        instance.cursor.execute(query, (customer_id,))
        accounts = instance.cursor.fetchall()

        for account in accounts:
            status_color = {
                'Active': "#4CAF50",
                'Temporary Locked': "#FFC107",
                'Locked': "#F44336"
            }
            color_hex = status_color.get(account['cus_account_status'], "#9E9E9E")
            balance = account['balance'] or 0
            opening_date = account['opening_date'].strftime('%d/%m/%Y') if account['opening_date'] else 'N/A'

            item = TwoLineListItem(
                text=f"{account['cus_account_type_name']} Account",
                secondary_text=f"Balance: {balance:,} VND | Status: {account['cus_account_status']}",
                theme_text_color="Custom",
                text_color=color_hex,
                on_release=lambda x, a=account: show_account_details(instance, a)
            )
            account_list.add_widget(item)

    except Error as e:
        print("Error loading accounts:", e)
        show_error_dialog(instance, "Lỗi khi tải danh sách tài khoản")


def show_account_details(instance, account):
    try:
        instance.cursor.callproc('GetAccountDetailsById', (account['cus_account_id'],))
        
        # Sau khi gọi procedure, kết quả nằm trong một cursor phụ
        for result in instance.cursor.stored_results():
            account_details = result.fetchone()
            if not account_details:
                show_error_dialog(instance, "Không tìm thấy thông tin tài khoản")
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
        if account_details['cus_account_type_id'] == '02':
            query = """
            SELECT transfer_limit, daily_transfer_limit 
            FROM CHECK_ACCOUNTS 
            WHERE cus_account_id = %s
            """
            instance.cursor.execute(query, (account['cus_account_id'],))
            check_details = instance.cursor.fetchone()
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
        show_error_dialog(instance, "Lỗi khi tải thông tin tài khoản")


def show_customer_table(instance):
    try:
        instance.cursor.execute("SELECT * FROM v_customer_summary")
        customers = instance.cursor.fetchall()

        if not customers:
            show_error_dialog(instance, "Không có dữ liệu khách hàng")
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
        instance.table_dialog = MDDialog(
            title="Customer List",
            type="custom",
            content_cls=layout,
            size_hint=(0.95, None),
            height=dp(500),
            buttons=[MDFlatButton(text="Close", on_release=lambda x: instance.table_dialog.dismiss())],
        )
        instance.table_dialog.open()

    except Exception as e:
        print("Lỗi khi tải bảng khách hàng:", e)
        show_error_dialog(instance, "Lỗi khi tải bảng khách hàng")


def show_error_dialog(instance, message):
    dialog = MDDialog(title="Lỗi", text=message)
    dialog.buttons = [MDFlatButton(text="OK", on_release=lambda x: dialog.dismiss())]
    dialog.open()
