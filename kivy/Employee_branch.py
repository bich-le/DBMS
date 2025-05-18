from kivymd.uix.list import TwoLineListItem
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.boxlayout import MDBoxLayout
from kivy.metrics import dp
from kivymd.app import MDApp
from mysql.connector import Error
from kivymd.uix.screen import MDScreen
from functools import partial

class BranchEmployeeScreen(MDScreen):
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
    
    def load_employees(self, search_term=""):
        print("EmployeeScreen.load_employees CALLED")
        employees_list = self.ids.employees_list
        employees_list.clear_widgets()
        
        try:
            # Get the current branch_id from the app
            app = MDApp.get_running_app()
            current_branch_id = getattr(app, 'current_branch_id', None)
            print("Current branch ID:", current_branch_id)
            
            query = """
            SELECT emp_id, emp_fullname, emp_phone_num, emp_email 
            FROM EMPLOYEES
            WHERE (emp_fullname LIKE %s OR emp_id LIKE %s)
            """
            params = [f"%{search_term}%", f"%{search_term}%"]
            
            # Add branch filter if available
            if current_branch_id:
                query += " AND branch_id = %s"
                params.append(current_branch_id)
                
            self.cursor.execute(query, tuple(params))
            employees = self.cursor.fetchall()

            for employee in employees:
                item = TwoLineListItem(
                    text=f"{employee['emp_fullname']}",
                    secondary_text=f"ID: {employee['emp_id']} | {employee['emp_phone_num']}",
                    on_release=partial(self.show_employee_details, employee)
                )
                employees_list.add_widget(item)

        except Error as e:
            print("Error loading employees:", e)
            self.show_error_dialog("Lỗi khi tải danh sách nhân viên")

    def filter_employees(self, search_term):
        self.load_employees(search_term)

    def show_employee_details(self, employee, *args):
        try:
            self.cursor.callproc("GetEmployeeDetailsById", (employee['emp_id'],))
            
            employee_details = None
            for result in self.cursor.stored_results():
                employee_details = result.fetchone()
                break

            if not employee_details:
                raise ValueError("Employee not found")
            
            details = self.ids
            details.employee_name.text = employee_details['emp_fullname']
            details.employee_id.text = f"ID: {employee_details['emp_id']}"
            details.employee_sex.text = employee_details['emp_sex']
            details.employee_address.text = employee_details['emp_address']
            details.employee_phone.text = employee_details['emp_phone_num']
            details.employee_join_date.text = employee_details['emp_join_date'].strftime('%d/%m/%Y')
            details.employee_email.text = employee_details.get('emp_email', 'N/A')
            details.employee_position.text = employee_details['emp_position_name']
            details.employee_dob.text = employee_details['emp_dob'].strftime('%d/%m/%Y') if employee_details.get('emp_dob') else ""
            details.employee_branch.text = employee_details.get('branch_name', '')

        except Error as e:
            print("Error loading employee details:", e)
            self.show_error_dialog("Lỗi khi tải thông tin nhân viên")

    def show_employee_table(self):
        try:
            # Get the current branch_id from the app
            app = MDApp.get_running_app()
            current_branch_id = getattr(app, 'current_branch_id', None)
            
            query = "SELECT * FROM v_employee_summary"
            params = []
            
            # Add branch filter if available
            if current_branch_id:
                query += " WHERE branch_id = %s"
                params.append(current_branch_id)
                
            self.cursor.execute(query, tuple(params))
            employees = self.cursor.fetchall()

            if not employees:
                self.show_error_dialog("Không có dữ liệu nhân viên")
                return
            branch_name = employees[0]['branch_name'] if employees and 'branch_name' in employees[0] else ""

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
                    ("Position", dp(30)),
                    ("Joined Date", dp(30)),
                    ('Address', dp(40)),
                ],
                row_data=[
                    (
                        employee['emp_id'],
                        employee['emp_fullname'],
                        employee['emp_phone_num'],
                        employee['emp_email'],
                        employee['branch_name'],
                        employee['emp_position_name'],
                        employee['emp_join_date'].strftime('%d/%m/%Y') if employee.get('emp_join_date') else "",
                        employee['emp_address'],
                    )
                    for employee in employees
                ],
            )

            layout = MDBoxLayout(
                orientation="vertical",
                padding=dp(10),
                spacing=dp(10),
                adaptive_height=True,
            )
            layout.add_widget(data_table)
            
            self.table_dialog = MDDialog(
                title=f"Employees in {branch_name}",
                type="custom",
                content_cls=layout,
                size_hint=(0.95, None),
                height=dp(500),
                buttons=[MDFlatButton(text="Close", on_release=lambda x: self.table_dialog.dismiss())],
            )
            self.table_dialog.open()

        except Exception as e:
            print("Lỗi khi tải bảng nhân viên:", e)
            self.show_error_dialog("Lỗi khi tải bảng nhân viên")

    def show_error_dialog(self, message):
        dialog = MDDialog(title="Lỗi", text=message)
        dialog.buttons = [MDFlatButton(text="OK", on_release=lambda x: dialog.dismiss())]
        dialog.open()