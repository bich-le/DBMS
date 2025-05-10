# director_screen.py
from kivymd.uix.screen import MDScreen
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.navigationdrawer import MDNavigationDrawer, MDNavigationDrawerMenu, MDNavigationDrawerItem
from kivymd.uix.screenmanager import MDScreenManager

print("DirectorScreen imported successfully")
class DirectorScreen(MDScreen):
    def on_pre_enter(self):
        self.ids.screen_manager.current = "customers"  # Sửa lại id cho đúng

    def navigate_to(self, screen_name):
        self.ids.screen_manager.current = screen_name