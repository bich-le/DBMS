from kivy.app import App
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.properties import StringProperty

class MainScreen(BoxLayout):
    my_text = StringProperty("Hello!")
    
    def change_text(self):
        self.my_text = "You clicked the button"

class MyApp(App):
    def build(self):
        return MainScreen()

MyApp().run()
