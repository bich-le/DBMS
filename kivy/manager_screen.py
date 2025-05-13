# director_screen.py
from kivymd.uix.screen import MDScreen
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.navigationdrawer import MDNavigationDrawer, MDNavigationDrawerMenu, MDNavigationDrawerItem
from kivymd.uix.screenmanager import MDScreenManager
from kivy.lang import Builder
from report_box import ReportBox

Builder.load_string("""
<ReportBox>:
""")  # để Kivy nhận diện
class ManagerScreen(MDScreen):
    def on_pre_enter(self):
        self.ids.screen_manager.current = "customers"
        if hasattr(self.ids, "report_box"):
            self.ids.report_box.refresh()

    def navigate_to(self, screen_name):
        self.ids.screen_manager.current = screen_name



