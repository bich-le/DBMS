def show_customer_details(self, customer):
    #     show_customer_details(self, customer)
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

from kivy.ceo_screen import DirectorScreen
import mysql.connector

Builder.load_file("director_screen.kv")

class MainScreen(MDScreen):
    dialog = None
    
    def login(self):
        username = self.ids.username.text
        password = self.ids.password.text
        app = MDApp.get_running_app()
        result = app.verify_login_and_get_position(username, password)
        if result:
            status = result['status']
            position = result['emp_position']

            if status == 'Active':
                app.root.transition.direction = "left"
                app.root.current = position.lower()
            elif status == 'Inactive':
                self.show_login_error_dialog("This account is inactive.")
            elif status == 'Suspended':
                self.show_login_error_dialog("This account has been suspended.")
            else:
                self.show_login_error_dialog("Unknown account status.")
        else:
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

class TellerScreen(MDScreen): pass
class ManagerScreen(MDScreen): pass
class AuditorScreen(MDScreen): pass
#class DirectorScreen(MDScreen): pass

class MyApp(MDApp):
    def build(self):
        self.theme_cls.primary_palette = "DeepPurple"
        sm = MDScreenManager()
        sm.add_widget(MainScreen(name="main"))
        sm.add_widget(TellerScreen(name="teller"))
        sm.add_widget(ManagerScreen(name="manager"))
        sm.add_widget(AuditorScreen(name="auditor"))
        sm.add_widget(DirectorScreen(name="director"))
        return sm
    
    def verify_login_and_get_position(self, username, password):
        try:
            conn = mysql.connector.connect(
                host="localhost",
                user="bich",
                password="1234",
                database="PROJECT"
            )
            cursor = conn.cursor(dictionary=True)
            query = """
                SELECT e.emp_position, a.status
                FROM EMPLOYEE_ACCOUNT a
                JOIN EMPLOYEES e ON a.emp_id = e.emp_id
                WHERE a.username = %s AND a.password_hash = %s 
            """
            cursor.execute(query, (username, password))
            result = cursor.fetchone()
            conn.close()
            return result  # sẽ trả về dict chứa emp_position và status nếu đúng
        except mysql.connector.Error as err:
            print("DB error:", err)
            return None
      

if __name__ == '__main__':
    MyApp().run()