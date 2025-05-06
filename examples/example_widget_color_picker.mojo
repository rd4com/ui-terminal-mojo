from module_ui import *

def main():
    var ui = UI() 
    var values = List[Fg](
        Fg.green, Fg.cyan, Fg.magenta, Fg.yellow
    )
    for _ in ui:
        for v in values:
            widget_color_picker(ui, v[])

