# director_screen.py
from kivymd.uix.screen import MDScreen
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.navigationdrawer import MDNavigationDrawer, MDNavigationDrawerMenu, MDNavigationDrawerItem
from kivymd.uix.screenmanager import MDScreenManager

from report_procedures import REPORT_PROCEDURE_MAP  
from kivy.lang import Builder
from report_box import ReportBox

Builder.load_string("""
<ReportBox>:
""")  # để Kivy nhận diện

class TellerScreen(MDScreen):
    def on_pre_enter(self):
        self.ids.screen_manager.current = "customers"
        if hasattr(self.ids, "report_box"):
            self.ids.report_box.refresh()

    def navigate_to(self, screen_name):
        self.ids.screen_manager.current = screen_name

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

