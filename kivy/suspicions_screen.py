from kivymd.uix.screen import MDScreen
from kivymd.uix.datatables import MDDataTable
from kivy.metrics import dp
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from connection import create_connection
from mysql.connector import Error
from kivymd.uix.boxlayout import MDBoxLayout
from datetime import datetime

class SuspicionsScreen(MDScreen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.db_connection = None
        self.cursor = None
        self.data_table = None
        self.dialog = None
        self.connect_to_database()

    def connect_to_database(self):
        """Kết nối CSDL."""
        try:
            self.db_connection = create_connection()
            if self.db_connection and self.db_connection.is_connected():
                self.cursor = self.db_connection.cursor(dictionary=True)
                print("Kết nối CSDL thành công")
                return True
            else:
                print("Không thể kết nối CSDL")
                self.show_error_dialog("Không thể kết nối cơ sở dữ liệu.")
                return False
        except Exception as e:
            print(f"Lỗi kết nối CSDL: {e}")
            self.show_error_dialog(f"Lỗi kết nối CSDL: {e}")
            return False

    def refresh_data(self, *args):
        """Làm mới dữ liệu nghi ngờ."""
        self.load_data()

    def load_data(self):
        """Tải dữ liệu từ bảng SUSPICIONS."""
        if not self.db_connection or not self.db_connection.is_connected():
            if not self.connect_to_database():
                return

        try:
            query = """
                SELECT
                    s.suspicion_id,
                    t.trans_id,
                    CONCAT(c.cus_last_name, ' ', c.cus_first_name) AS customer_name,
                    ca.cus_account_id,
                    fp.fraud_pattern_name,
                    s.severity_level,
                    t.trans_amount,
                    t.trans_status,
                    s.suspicion_status,
                    s.detected_time
                FROM SUSPICIONS s
                JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
                LEFT JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
                LEFT JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
                JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
                WHERE s.suspicion_status != 'Resolved'
                ORDER BY
                    CASE s.severity_level
                        WHEN 'High' THEN 1
                        WHEN 'Medium' THEN 2
                        WHEN 'Low' THEN 3
                        ELSE 4
                    END,
                    s.suspicion_id DESC
                LIMIT 0, 1000;
            """
            self.cursor.execute(query)
            rows = self.cursor.fetchall()
            print("Rows:", len(rows))
            print("IDS SuspicionsScreen:", self.ids)
            print("IDS SuspicionsBox:", self.ids.suspicions_box.ids)
            print("Rows:", len(rows))

            # Xóa bảng cũ nếu có
            if self.data_table:
                self.ids.suspicions_box.ids.table_container_suspicion.remove_widget(self.data_table)
            # Xóa placeholder nếu có
            placeholder = self.ids.suspicions_box.ids.get('placeholder_suspicion')
            if placeholder and placeholder.parent:
                placeholder.parent.remove_widget(placeholder)

            print("IDS:", self.ids)
            print("table_container_suspicion" in self.ids)
            print("Children in table_container_suspicion:", len(self.ids.suspicions_box.ids.table_container_suspicion.children))

            # Tạo bảng mới
            self.data_table = MDDataTable(
                size_hint=(1, 1),
                column_data=[
                    ("ID", dp(20)),
                    ("Transaction ID", dp(40)),
                    ("Customer", dp(40)),
                    ("Customer Account", dp(40)),
                    ("Transaction Amount", dp(30)),
                    ("Fraud Pattern", dp(60)),
                    ("Severity level", dp(30)),
                    ("Status", dp(25)),
                    ("Detected time", dp(40))
                ],
                row_data=[
                    (
                        str(row['suspicion_id']),
                        row['trans_id'],
                        row['customer_name'] if row['customer_name'] else "N/A",
                        row['cus_account_id'] if row['cus_account_id'] else "N/A",
                        f"{row['trans_amount']:,.2f}" if row['trans_amount'] else "0",
                        row['fraud_pattern_name'],
                        row['severity_level'],
                        row['suspicion_status'],
                        row['detected_time'].strftime("%Y-%m-%d %H:%M") if row['detected_time'] else "N/A"
                    ) for row in rows
                ],
                elevation=1,
                check=True,
                use_pagination=True,
                rows_num=15
            )
            self.data_table.bind(on_row_press=self.highlight_row)
            self.ids.suspicions_box.ids.table_container_suspicion.add_widget(self.data_table)
            self.ids.suspicions_box.update_stats(rows)

        except Error as e:
            print(f"Error loading data: {e}")
            self.show_error_dialog(f"Database error: {e}")

    def highlight_row(self, instance_table, instance_row):
        index = instance_row.index
        if index < 0 or index >= len(instance_table.row_data):
            print("Invalid row index:", index)
            return
        severity = instance_table.row_data[index][6]  # Cột mức độ
        if severity == "High":
            instance_row.bg_color = (1, 0.8, 0.8, 1)  # Đỏ nhạt
        elif severity == "Medium":
            instance_row.bg_color = (1, 1, 0.8, 1)    # Vàng nhạt
        elif severity == "Low":
            instance_row.bg_color = (0.8, 1, 0.8, 1)  # Xanh nhạt

    def show_error_dialog(self, message):
        """Hiển thị dialog lỗi."""
        if self.dialog:
            self.dialog.dismiss()
        self.dialog = MDDialog(
            title="Lỗi",
            text=message,
            buttons=[
                MDFlatButton(
                    text="Đóng",
                    on_release=lambda x: self.dialog.dismiss()
                ),
            ],
        )
        self.dialog.open()

    def on_pre_leave(self, *args):
        """Đóng kết nối CSDL khi rời màn hình."""
        if self.cursor:
            self.cursor.close()
        if self.db_connection and self.db_connection.is_connected():
            self.db_connection.close()
            print("Database connection closed")

    def on_kv_post(self, base_widget):
        self.load_data()

    def search_suspicious_cases(self, search_text):
        """Tìm kiếm các giao dịch nghi ngờ theo từ khóa."""
        # Gọi lại load_data với điều kiện WHERE LIKE nếu search_text khác rỗng
        if not self.db_connection or not self.db_connection.is_connected():
            if not self.connect_to_database():
                return
        try:
            if search_text.strip():
                query = """
                    SELECT
                        s.suspicion_id, t.trans_id,
                        CONCAT(c.cus_last_name, ' ', c.cus_first_name) AS customer_name,
                        ca.cus_account_id, fp.fraud_pattern_name, s.severity_level,
                        t.trans_amount, t.trans_status, s.suspicion_status, s.detected_time
                    FROM SUSPICIONS s
                    JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
                    LEFT JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
                    LEFT JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
                    JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
                    WHERE s.suspicion_status != 'Resolved'
                        AND (t.trans_id LIKE %s OR ca.cus_account_id LIKE %s OR c.cus_first_name LIKE %s OR c.cus_last_name LIKE %s)
                    ORDER BY
                        CASE s.severity_level
                            WHEN 'High' THEN 1
                            WHEN 'Medium' THEN 2
                            WHEN 'Low' THEN 3
                            ELSE 4
                        END,
                        s.suspicion_id DESC
                    LIMIT 0, 1000;
                """
                like = f"%{search_text}%"
                self.cursor.execute(query, (like, like, like, like))
            else:
                self.load_data()
                return
            rows = self.cursor.fetchall()
            self.update_table(rows)
        except Error as e:
            self.show_error_dialog(f"Database error: {e}")

    def show_filter_dialog(self):
        """Hiển thị dialog lọc nâng cao (placeholder)."""
        self.dialog = MDDialog(
            title="Filter",
            text="Filter dialog is not implemented yet.",
            buttons=[
                MDFlatButton(
                    text="Close",
                    on_release=lambda x: self.dialog.dismiss()
                ),
            ],
        )
        self.dialog.open()

    def update_table(self, rows):
        """Cập nhật lại bảng với dữ liệu mới."""
        # Xóa bảng cũ nếu có
        if self.data_table:
            self.ids.suspicions_box.ids.table_container_suspicion.remove_widget(self.data_table)
        # Xóa placeholder nếu có
        placeholder = self.ids.suspicions_box.ids.get('placeholder_suspicion')
        if placeholder and placeholder.parent:
            placeholder.parent.remove_widget(placeholder)
        # Tạo bảng mới
        self.data_table = MDDataTable(
            size_hint=(1, 1),
            column_data=[
                ("ID", dp(20)),
                ("Mã GD", dp(40)),
                ("Khách hàng", dp(40)),
                ("Tài khoản", dp(40)),
                ("Số tiền", dp(30)),
                ("Loại gian lận", dp(60)),
                ("Mức độ", dp(30)),
                ("Trạng thái", dp(25)),
                ("Thời gian", dp(40))
            ],
            row_data=[
                (
                    str(row['suspicion_id']),
                    row['trans_id'],
                    row['customer_name'] if row['customer_name'] else "N/A",
                    row['cus_account_id'] if row['cus_account_id'] else "N/A",
                    f"{row['trans_amount']:,.2f}" if row['trans_amount'] else "0",
                    row['fraud_pattern_name'],
                    row['severity_level'],
                    row['suspicion_status'],
                    row['detected_time'].strftime("%Y-%m-%d %H:%M") if row['detected_time'] else "N/A"
                ) for row in rows
            ],
            elevation=1,
            check=True,
            use_pagination=True,
            rows_num=15
        )
        self.data_table.bind(on_row_press=self.highlight_row)
        self.ids.suspicions_box.ids.table_container_suspicion.add_widget(self.data_table)
        self.update_stats(rows)

    def update_stats(self, rows):
        """Cập nhật số lượng tổng, high, medium, low lên các card."""
        total = len(rows)
        high = sum(1 for row in rows if row['severity_level'] == "High")
        medium = sum(1 for row in rows if row['severity_level'] == "Medium")
        low = sum(1 for row in rows if row['severity_level'] == "Low")
        self.ids.suspicions_box.ids.total_count.text = str(total)
        self.ids.suspicions_box.ids.high_risk_count.text = str(high)
        self.ids.suspicions_box.ids.medium_risk_count.text = str(medium)
        self.ids.suspicions_box.ids.low_risk_count.text = str(low)

class SuspicionsBox(MDBoxLayout):
    def search_suspicious_cases(self, text):
        # Gọi lên SuspicionsScreen cha để xử lý logic
        if self.parent:
            self.parent.search_suspicious_cases(text)

    def show_filter_dialog(self):
        if self.parent:
            self.parent.show_filter_dialog()

    def update_stats(self, rows):
        total = len(rows)
        high = sum(1 for row in rows if row['severity_level'] == "High")
        medium = sum(1 for row in rows if row['severity_level'] == "Medium")
        low = sum(1 for row in rows if row['severity_level'] == "Low")

        # Đếm số lượng today
        today = datetime.now().date()
        total_today = sum(1 for row in rows if row.get('detected_time') and row['detected_time'].date() == today)
        high_today = sum(1 for row in rows if row['severity_level'] == "High" and row.get('detected_time') and row['detected_time'].date() == today)
        medium_today = sum(1 for row in rows if row['severity_level'] == "Medium" and row.get('detected_time') and row['detected_time'].date() == today)
        low_today = sum(1 for row in rows if row['severity_level'] == "Low" and row.get('detected_time') and row['detected_time'].date() == today)

        self.ids.total_count.text = str(total)
        self.ids.high_risk_count.text = str(high)
        self.ids.medium_risk_count.text = str(medium)
        self.ids.low_risk_count.text = str(low)

        # Cập nhật label +x today
        self.ids.total_count.parent.children[0].text = f"+{total_today} today"
        self.ids.high_risk_count.parent.children[0].text = f"+{high_today} today"
        self.ids.medium_risk_count.parent.children[0].text = f"+{medium_today} today"
        self.ids.low_risk_count.parent.children[0].text = f"+{low_today} today"
