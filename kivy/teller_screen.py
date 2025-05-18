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

from customers_screen import *

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
                password="Dance!11230592",
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
        load_customers(self, search_term)
    
    def filter_customers(self, search_term):
        self.load_customers(search_term)
    
    def show_customer_details(self, customer):
        show_customer_details(self, customer)
    
    def load_customer_accounts(self, customer_id):
        load_customer_accounts(self, customer_id)
    
    def show_account_details(self, account):
        show_account_details(self, account)
    
    def show_error_dialog(self, message):
        show_error_dialog(self, message)
        
    def show_customer_table(self):
        show_customer_table(self)
        
        
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
            