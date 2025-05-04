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
from kivy.lang import Builder
from kivy.uix.popup import Popup

from kivymd.app import MDApp
from kivymd.uix.screen import MDScreen
from kivymd.uix.button import MDRaisedButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.label import MDLabel
from kivymd.uix.screenmanager import MDScreenManager
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.button import MDRoundFlatButton

class MainScreen(MDScreen):
    pass

class SecondScreen(MDScreen):
    pass

class MyApp(MDApp):
    def build(self):
        self.theme_cls.primary_palette = "DeepPurple"
        sm = MDScreenManager()
        sm.add_widget(MainScreen(name="main"))
        sm.add_widget(SecondScreen(name="second"))
        return sm

if __name__ == '__main__':
    MyApp().run()