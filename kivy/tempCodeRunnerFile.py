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