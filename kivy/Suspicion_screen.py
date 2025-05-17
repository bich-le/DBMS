from kivymd.app import MDApp
from kivymd.uix.screen import MDScreen
from kivymd.uix.datatables import MDDataTable
from kivy.metrics import dp
import mysql.connector
from mysql.connector import Error
from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivymd.uix.datatables import MDDataTable
from kivymd.uix.menu import MDDropdownMenu  # Sử dụng menu mới nếu cần

class SuspicionScreen(MDScreen):
    print("SuspicionScreen CALLED")
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.db_connection = None
        self.cursor = None
        self.data_table = None
        self.connect_to_database()

    def connect_to_database(self):
        """Establish database connection"""
        try:
            self.db_connection = mysql.connector.connect(
                host="localhost",
                user="root",
                password="Bichthebest3805",
                database="main"
            )
            self.cursor = self.db_connection.cursor(dictionary=True)
            print("Successfully connected to database")
            return True
        except Error as e:
            print(f"Database connection error: {e}")
            self.show_error_dialog(f"Failed to connect to database: {e}")
            return False

    def load_data(self):
        print("SuspicionScreen.load_data CALLED")
        """Load data from SUSPICIONS table"""
        if not self.db_connection or not self.db_connection.is_connected():
            if not self.connect_to_database():
                return

        try:
            query = """
                SELECT s.suspicion_id, t.trans_id, fp.fraud_pattern_name, 
                       s.detected_time, s.severity_level, s.suspicion_status,
                       CONCAT(c.cus_first_name, ' ', c.cus_last_name) as customer_name,
                       ca.cus_account_id, t.trans_amount
                FROM SUSPICIONS s
                JOIN TRANSACTIONS t ON s.trans_id = t.trans_id
                JOIN FRAUD_PATTERNS fp ON s.fraud_pattern_id = fp.fraud_pattern_id
                JOIN CUSTOMER_ACCOUNTS ca ON t.cus_account_id = ca.cus_account_id
                JOIN CUSTOMERS c ON ca.cus_id = c.cus_id
                WHERE s.suspicion_status != 'Resolved'
                ORDER BY
                    CASE s.severity_level
                        WHEN 'High' THEN 1
                        WHEN 'Medium' THEN 2
                        WHEN 'Low' THEN 3
                        ELSE 4
                    END,
                    s.detected_time DESC
                LIMIT 1000
            """
            self.cursor.execute(query)
            rows = self.cursor.fetchall()
            print("Suspicion rows:", rows)
            
            # Remove old table if exists
            if self.data_table:
                self.ids.table_container_suspicion.remove_widget(self.data_table)

            # Create new data table
            self.data_table = MDDataTable(
                size_hint=(1, None),
                height=dp(600),
                column_data=[
                    ("ID", dp(10)),
                    ("Mã GD", dp(25)),
                    ("Khách hàng", dp(30)),
                    ("Tài khoản", dp(25)),
                    ("Số tiền", dp(25)),
                    ("Loại gian lận", dp(35)),
                    ("Mức độ", dp(20)),
                    ("Trạng thái", dp(25)),
                    ("Thời gian", dp(30))
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
                elevation=2,
                check=True,
                use_pagination=True,
                rows_num=10
            )
            self.data_table.bind(on_row_press=self.highlight_row)
            self.ids.table_container_suspicion.add_widget(self.data_table)
            
        except Error as e:
            print(f"Error loading data: {e}")
            self.show_error_dialog(f"Database error: {e}")

    def highlight_row(self, instance_table, instance_row):
        """Highlight rows based on severity level"""
        severity = instance_table.row_data[instance_row.index][6]  # Severity level column
        if severity == "High":
            instance_row.bg_color = (1, 0.8, 0.8, 1)  # Light red
        elif severity == "Medium":
            instance_row.bg_color = (1, 1, 0.8, 1)  # Light yellow
        elif severity == "Low":
            instance_row.bg_color = (0.8, 1, 0.8, 1)  # Light green

    def show_error_dialog(self, message):
        """Show error message dialog"""
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
        """Close database connection when leaving screen"""
        if self.cursor:
            self.cursor.close()
        if self.db_connection and self.db_connection.is_connected():
            self.db_connection.close()
            print("Database connection closed")
            
       