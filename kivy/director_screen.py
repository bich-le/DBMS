from kivymd.uix.screen import MDScreen
from kivymd.uix.datatables import MDDataTable
from kivy.metrics import dp
from kivy.clock import Clock
import mysql.connector

class DirectorScreen(MDScreen):
    all_employees_data = []
    data_table = None
    dialog = None

    def on_enter(self):
        self.ids.report_box.refresh()

        """Tự động load dữ liệu khi vào màn hình Employees"""
        if self.ids.screen_manager.current == "employees":
            self.load_all_employees()

    def on_screen_manager_current(self, instance, value):
        if value == "report":
            self.ids.report_box.refresh()

    def load_all_employees(self):
        """Tải danh sách nhân viên sắp xếp theo chức vụ"""
        try:
            conn = mysql.connector.connect(
                host="localhost",
                user="root",
                password="Nhan220405",
                database="PROJECT"
            )
            cursor = conn.cursor()
            
            # Query với sắp xếp theo thứ tự chức vụ
            cursor.execute("""
                SELECT 
                    emp_id,
                    emp_fullname, 
                    emp_position,
                    emp_phone,
                    emp_email,
                    DATE_FORMAT(emp_hire_date, '%d/%m/%Y')
                FROM EMPLOYEES
                ORDER BY 
                    CASE emp_position
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
            
        except Exception as e:
            print("Lỗi khi tải nhân viên:", e)
            # Hiển thị thông báo lỗi lên giao diện
            self.ids.placeholder.text = f"Lỗi khi tải dữ liệu: {str(e)}"
        finally:
            conn.close()

    def show_employee_table(self, data):
        """Hiển thị bảng dữ liệu"""
            # Xóa placeholder nếu có
        if hasattr(self.ids, 'placeholder'):
            self.ids.table_container.remove_widget(self.ids.placeholder)
        # Xóa bảng cũ nếu tồn tại
        if self.data_table:
            self.ids.table_container.remove_widget(self.data_table)
        
        # Tạo bảng mới
        self.data_table = MDDataTable(
            size_hint=(1, None),
            height=max(len(data) * dp(50), dp(300)),
            column_data=[
                ("ID", dp(30)),
                ("Họ tên", dp(50)),
                ("Chức vụ", dp(40)),
                ("SĐT", dp(40)),
                ("Email", dp(60)),
                ("Ngày vào", dp(40)),
            ],
            row_data=data,
            use_pagination=False,
            background_color_header="#1e88e5",
            background_color_cell="#e3f2fd",
            background_color_selected_cell="#b3e5fc",
        )
        self.ids.table_container.add_widget(self.data_table)
        print("Đã hiển thị bảng dữ liệu")  # Debug
    def get_row_color(self, table, index):
        """Xác định màu nền theo chức vụ"""
        row = table.row_data[index]
        position = row[2].lower()  # Cột chức vụ
        
        if 'director' in position:
            return "#e8f5e9"  # Xanh lá nhạt
        elif 'manager' in position:
            return "#e3f2fd"  # Xanh dương nhạt
        elif 'auditor' in position:
            return "#fff8e1"  # Vàng nhạt
        elif 'teller' in position:
            return "#fce4ec"  # Hồng nhạt
        return "#ffffff"  # Màu trắng mặc định
    def search_employees(self, query):
        """Tìm kiếm nhân viên"""
        query = query.strip().lower()
        
        if not query:  # Nếu ô tìm kiếm trống
            self.show_employee_table(self.all_employees_data)
            return
        
        # Lọc dữ liệu
        filtered_data = [
            row for row in self.all_employees_data
            if (query in str(row[0]).lower()) or  # Tìm theo ID
            (query in row[1].lower())          # Tìm theo tên
        ]
        
        self.show_employee_table(filtered_data)

    def refresh_employees(self):
        """Làm mới danh sách"""
        self.load_all_employees()

    def show_add_employee_dialog(self):
        """Hiển thị dialog thêm nhân viên mới"""
        # Triển khai form thêm nhân viên ở đây
        pass