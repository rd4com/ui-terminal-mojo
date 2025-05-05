from module_ui import *

fn main():

    var ui = UI()
    var started = False
    for _ in ui:
        Text("Enjoy" if started else "Click to start") in ui
        if ui[-1].click():
            started = not started
            ui.cursor[1]+=2
        if started:
            ui[-1] |= Bg.green
            spinner2[speed=1](ui)
            widget_ticker(ui, List[String]("Mojo", "is", "awesome"))
            if ui[-1].hover():
                shake(ui)
        else:
            tooltip(ui, "ready!!!")
            shake(ui)
