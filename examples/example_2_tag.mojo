from module_ui import *

fn main():
    var ui = UI()
    var counters = (10, 4)
    for _ in ui:
        "Here" in ui
        tag(ui, Bg.blue, counters[0])
        if ui[-2].click():
            counters[0]+=1
        tooltip[Bg.blue, pos=-2](ui, "click to increment")

        "There" in ui
        tag(ui, Bg.yellow, counters[1])
        if ui[-2].click(): counters[1]+=1
        tooltip[Bg.yellow, pos=-2](ui, "click to increment")
