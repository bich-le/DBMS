from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.boxlayout import BoxLayout
from kivy.properties import StringProperty
from kivy.uix.gridlayout import GridLayout
from kivy.uix.textinput import TextInput

class MainScreen(BoxLayout):
    my_text = StringProperty("Hello!")
    
    def change_text(self):
        self.my_text = "You clicked the button"
        
class MyGrid(GridLayout):
    def __init__(self,**kwargs):
        super(MyGrid,self).__init__(**kwargs)
        self.cols = 2
        self.add_widget(Label(text = "FName: "))
        self.fname = TextInput(multiline= False)
        self.add_widget(self.fname)
        
        self.add_widget(Label(text = "LName: "))
        self.lname = TextInput(multiline= False)
        self.add_widget(self.lname)
        
        self.add_widget(Label(text = "Email: "))
        self.email = TextInput(multiline= False)
        self.add_widget(self.email)

class MyApp(App):
    def build(self):
        return MyGrid()

if __name__ == '__main__':
    MyApp().run()
