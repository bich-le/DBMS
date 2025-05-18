from kivymd.uix.screen import MDScreen
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.navigationdrawer import MDNavigationDrawer, MDNavigationDrawerMenu, MDNavigationDrawerItem
from kivymd.uix.screenmanager import MDScreenManager
from report_box import ReportBox

from kivy.lang import Builder
Builder.load_string("""
<ReportBox>:
""")  # để Kivy nhận diện
Builder.load_file("interest_rates_screen.kv")

class AuditorScreen(MDScreen):
    def on_enter(self):
        self.ids.report_box.refresh()
    def on_pre_enter(self):
        if hasattr(self.ids, "report_box"):
            self.ids.report_box.refresh()

    def navigate_to(self, screen_name):
        self.ids.screen_manager.current = screen_name