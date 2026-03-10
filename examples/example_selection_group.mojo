from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var selected = 0
    var values = List[String]("One", "Two", "Three")
    for _ in ui:
        widget_selection_group["Selection:", theme=Fg.magenta](
            ui,
            values,
            selected,
        )
