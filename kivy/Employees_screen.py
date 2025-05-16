from kivymd.uix.list import TwoLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.boxlayout import MDBoxLayout
from kivy.metrics import dp
from mysql.connector import Error


def load_employees(instance, search_term=""):
    employees_list = instance.ids.employees_list
    employees_list.clear_widgets()
    
    try:
        query = """
        SELECT emp_id, emp_fullname, emp_phone_num, emp_email 
        FROM EMPLOYEES
        WHERE emp_fullname LIKE %s OR emp_id LIKE %s
        """
        search_pattern = f"%{search_term}%"
        instance.cursor.execute(query, (search_pattern, search_pattern))
        employees = instance.cursor.fetchall()

        for employee in employees:
            item = TwoLineListItem(
                text=f"{employee['emp_fullname']}",
                secondary_text=f"ID: {employee['emp_id']} | {employee['emp_phone_num']}",
                on_release=lambda x, c=employee: show_employee_details(instance, c)
            )
            employees_list.add_widget(item)
            
    except Error as e:
        print("Error loading employees:", e)
        show_error_dialog(instance, "Lỗi khi tải danh sách nhân viên")


def filter_employees(instance, search_term):
    load_employees(instance, search_term)


def show_employee_details(instance, employee):
    try:
        query = """
        SELECT e.*, b.branch_name 
        FROM EMPLOYEES e
        LEFT JOIN BRANCHES b ON e.branch_id = b.branch_id
        WHERE e.emp_id = %s
        """
        instance.cursor.execute(query, (employee['emp_id'],))
        employee_details = instance.cursor.fetchone()
        
        if not employee_details:
            raise ValueError("Customer not found")

        details = instance.ids
        details.employee_name.text = employee_details['emp_fullname']
        details.employee_id.text = f"ID: {employee_details['emp_id']}"
        details.employee_sex.text = employee_details['emp_sex']
        details.employee_address.text = employee_details['emp_address']
        details.employee_phone.text = employee_details['emp_phone_num']
        details.employee_join_date.text = employee_details['emp_join_date'].strftime('%d/%m/%Y')
        details.employee_email.text = employee_details.get('emp_email', 'N/A')

        details.employee_dob.text = employee_details['emp_dob'].strftime('%d/%m/%Y') if employee_details.get('emp_dob') else ""
        details.employee_branch.text = employee_details.get('branch_name', '')

        #load_employee_accounts(instance, employee_details['cus_id'])

    except Error as e:
        print("Error loading employee details:", e)
        show_error_dialog(instance, "Lỗi khi tải thông tin nhân viên")


def show_employee_table(instance):
    try:
        instance.cursor.execute("SELECT * FROM v_employee_summary")
        employees = instance.cursor.fetchall()

        if not employees:
            show_error_dialog(instance, "Không có dữ liệu nhân viên")
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
            ],
            row_data=[
                (
                    employee['emp_id'],
                    employee['emp_fullname'],
                    employee['emp_phone_num'],
                    employee['emp_email'],
                    employee['branch_name']
                )
                for employee in employees
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
            title="Employee List",
            type="custom",
            content_cls=layout,
            size_hint=(0.95, None),
            height=dp(500),
            buttons=[MDFlatButton(text="Close", on_release=lambda x: instance.table_dialog.dismiss())],
        )
        instance.table_dialog.open()

    except Exception as e:
        print("Lỗi khi tải bảng nhân viên:", e)
        show_error_dialog(instance, "Lỗi khi tải bảng nhân viên")


def show_error_dialog(instance, message):
    dialog = MDDialog(title="Lỗi", text=message)
    dialog.buttons = [MDFlatButton(text="OK", on_release=lambda x: dialog.dismiss())]
    dialog.open()
