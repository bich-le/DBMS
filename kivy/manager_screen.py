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
from Employee_branch import *
from connection import create_connection  # Thêm dòng này ở đầu file

Builder.load_string("""
<ReportBox>:
""")  # để Kivy nhận diện

class ManagerScreen(MDScreen):
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
            Clock.schedule_once(lambda dt: self.ids.customers_screen.load_customers(), 0.1)

            self._first_load = False
        else:
            self.ids.customers_screen.load_customers()
            
    def on_enter(self):
        self.ids.report_box.refresh()
        if not self._first_load:
            self.ids.customers_screen.load_customers()
        
    def navigate_to(self, screen_name):
        self.ids.screen_manager.current = screen_name
        if screen_name == "branch_employees":
            self.ids.branch_employees_screen.load_employees()

        elif screen_name == "customers":
            self.ids.customers_screen.load_customers()
        
    def on_leave(self):
        self.close_db_connection()
    
    def connect_to_db(self):
        self.db_connection = create_connection()
        if self.db_connection:
            self.cursor = self.db_connection.cursor(dictionary=True)
            self.ids.customers_screen.cursor = self.cursor
            self.ids.customers_screen.db_connection = self.db_connection
            if hasattr(self.ids, "branch_employees_screen"):
                self.ids.branch_employees_screen.cursor = self.cursor
                self.ids.branch_employees_screen.db_connection = self.db_connection
        else:
            print("Database connection error!")
            self.show_error_dialog("Không thể kết nối đến cơ sở dữ liệu")
    
    def close_db_connection(self):
        if self.cursor:
            self.cursor.close()
        if self.db_connection and self.db_connection.is_connected():
            self.db_connection.close()

