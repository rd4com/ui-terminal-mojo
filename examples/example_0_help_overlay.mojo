from module_ui import *
from time import monotonic

fn main():
    var ui = UI()
    #ui.feature_help_overlay = False #True by default
    #ui.help_overlay_is_opened = False #starts open by default

    var counter = 0

    var edited = False
    var value = String("HelloWorld")

    var list = List[String]()
    var current = 0

    for _ in ui:
        #Todo: put the ui help overlay in ui.update
        #(ticker)
        "Hello world" in ui
        # 1. add button
        Text("increment")|Bg.yellow in ui
        if ui[-1].click(): counter += 1
        # 2. show result
        tag(ui, Bg.green, counter)
        # 3. add tooltip
        tooltip[pos=-2](ui, "Press Enter to increment the counter")
        # 4. add animations
        if counter == 1:
            spinner(ui)
        if counter == 2:
            spinner[speed=2](ui)
        if counter == 3:
            spinner[speed=3](ui)
        if counter == 4:
            spinner2[speed=4](ui)
        if counter == 5:
            shake(ui)
        # 5. add input
        input_buffer["edit:"](ui, value, edited)
        # 6. add button
        "add" in ui
        if ui[-1].click():
            list.append(value)
        # 7. add a widget
        widget_paginate_list["List:", 3](
            ui,
            list,
            current
        )
