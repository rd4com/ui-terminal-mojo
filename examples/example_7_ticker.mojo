from module_ui import *

fn main():

    # menu widget:
    var inputs = List[String]("Hello world", "let's try this ticker", "great !")

    var ui = UI()
    for _ in ui:
        widget_ticker(ui, inputs)
        tooltip(ui,"tooltip !")
        
        "Hello world !" in ui
        tooltip[bg=Bg.cyan](ui,"tooltip2 !")
        
        " " in ui
        Text("Hello world 2!") | Bg(0) | Fg.blue in ui
        blink(ui)
        
        " " in ui
        Text("Hello World !") in ui
        if ui[-1].hover():
            shake(ui)

        Text("Hello") | Bg.yellow in ui
        center[16](ui)
        Text("world") | Bg.yellow in ui
        ljust[16](ui)
        Text("!") | Bg.yellow in ui
        rjust[16](ui)
        
