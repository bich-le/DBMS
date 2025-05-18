from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.properties import StringProperty, ObjectProperty
from kivy.uix.gridlayout import GridLayout
from kivy.uix.textinput import TextInput
from kivy.uix.widget import Widget
from kivy.uix.floatlayout import FloatLayout
from kivy.graphics import Rectangle
from kivy.graphics import Color
from kivy.uix.popup import Popup

from kivymd.app import MDApp
from kivymd.uix.screen import MDScreen
from kivymd.uix.button import MDRaisedButton, MDRectangleFlatIconButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.label import MDLabel
from kivymd.uix.screenmanager import MDScreenManager
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.button import MDRoundFlatButton
from kivymd.uix.navigationdrawer import MDNavigationDrawer, MDNavigationDrawerMenu, MDNavigationDrawerItem

from kivymd.uix.dialog import MDDialog
from kivymd.uix.button import MDFlatButton
from kivymd.uix.screen import MDScreen
from kivy.lang import Builder
from kivy.metrics import dp
from kivymd.uix.datatables import MDDataTable

from director_screen import DirectorScreen
from teller_screen import TellerScreen
from manager_screen import ManagerScreen
from auditor_screen import AuditorScreen
import mysql.connector
import hashlib
from connection import create_connection

#Builder.load_file("director_screen.kv")
# test merge

class DrawerItem(MDNavigationDrawerItem):
    icon = StringProperty()
    text = StringProperty()

class MainScreen(MDScreen):
    dialog = None
    
    def login(self):
        username = self.ids.username.text
        password = self.ids.password.text
        app = MDApp.get_running_app()
        result = app.verify_login_and_get_position(username, password)
        if result:
            self.current_branch_id = result['branch_id']
            app.current_branch_id = result['branch_id']

        if result:
            status = result['status']
            position = result['emp_position_id']

            if status == 'Active':
                app.current_role = position.lower()
                app.root.transition.direction = "left"
                app.root.current = position.lower()
            elif status == 'Inactive':
                self.show_login_error_dialog("This account is Inactive.")
            elif status == 'Temporarily Suspended':
                self.show_login_error_dialog("This account has been Temporarily Suspended.")
            elif status == 'Permanently Suspended':
                self.show_login_error_dialog("This account has been Permanently Suspended.")
            else:
                self.show_login_error_dialog("Unknown account status.")
        else:
            print(result)
            self.show_login_error_dialog("Wrong login information.")
            
    def show_login_error_dialog(self, message):
        if self.dialog:
            self.dialog.dismiss()
        self.dialog = MDDialog(
            title="Login Failed",
            text=message,
            buttons=[
                MDFlatButton(
                    text="OK",
                    on_release=lambda x: self.dialog.dismiss()
                ),
            ],
        )
        self.dialog.open()

class MyApp(MDApp):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.current_role = "guest"  # Mặc định ban đầu

    def build(self):
        self.theme_cls.primary_palette = "DeepPurple"
        Builder.load_file("director_screen.kv")
        Builder.load_file("teller_screen.kv")
        Builder.load_file("manager_screen.kv")
        Builder.load_file("auditor_screen.kv")
        sm = MDScreenManager()
        sm.add_widget(MainScreen(name="main"))
        sm.add_widget(DirectorScreen(name="c"))
        sm.add_widget(TellerScreen(name="t"))
        sm.add_widget(ManagerScreen(name="m"))
        sm.add_widget(AuditorScreen(name="a"))
        return sm
    
    def hash_password(self,password):
        return hashlib.sha256(password.encode()).hexdigest()
    
    def verify_login_and_get_position(self, username, password):
        try:
            conn = create_connection()
            if not conn:
                print("Không thể kết nối CSDL")
                return None
            cursor = conn.cursor(dictionary=True)
            query = """
                SELECT e.emp_position_id, a.status, e.branch_id
                FROM EMPLOYEE_ACCOUNTS a
                JOIN EMPLOYEES e ON a.emp_id = e.emp_id
                WHERE a.username = %s AND a.password_hash = %s 
            """
            hashed_password = self.hash_password(password)
            cursor.execute(query, (username, hashed_password))
            result = cursor.fetchone()
            conn.close()
            return result


            result = cursor.fetchone()
            conn.close()
            return result  # sẽ trả về dict chứa emp_position_id và status nếu đúng
        except mysql.connector.Error as err:
            print("DB error:", err)
            return None
      

if __name__ == '__main__':
    MyApp().run()

