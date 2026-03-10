from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var values = List[Fg](
        Fg.green, Fg.cyan, Fg.magenta, Fg.yellow
    )
    for _ in ui:
        for ref v in values:
            widget_color_picker(ui, v)
