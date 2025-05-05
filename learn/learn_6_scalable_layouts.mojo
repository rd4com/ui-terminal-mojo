
from module_ui import *
from time import perf_counter_ns

def main():
    var ui = UI()
    var content_center = UInt8(0)
    var content_menu_r = UInt8(0)
    var content_menu_l = UInt8(0)
    var center_h1 = String("center")
    var center_h1_edit = False
    for _ in ui:
        var all_screen = ui.start_measuring()
        var all_screen_border = start_border(ui)

        var top_center_bottom =ui.start_measuring()

        var header_border = start_border(ui)
        "header" in ui
        widget_slider["Content center"](ui, content_center)
        header_border^.end_border_simple[StyleBorderCurved](ui, Fg.blue)
        ui.move_cursor_below(top_center_bottom^.stop_measuring())

        top_center_bottom =ui.start_measuring()
        var center = ui.start_measuring()
        var menu_border = start_border(ui)
        "menu" in ui
        for i in range(Int(content_menu_l)):
            Text("#"*i) in ui
        menu_border^.end_border_simple[StyleBorderDouble](ui, Fg.yellow)

        ui.move_cursor_after(center^.stop_measuring())
        center = ui.start_measuring()
        center_h1 in ui
        for i in range(Int(content_center)):
            Text("*" * i) in ui
        ui.move_cursor_after(center^.stop_measuring())

        menu_border = start_border(ui)
        "menu" in ui
        for i in range(Int(content_menu_r)):
            Text("#"*i) in ui
            tooltip(ui, String("^size:",i))
        menu_border^.end_border_simple[StyleBorderDouble](ui, Fg.yellow)
        ui.move_cursor_below(top_center_bottom^.stop_measuring())

        var footer_border = start_border(ui)
        Text("footer")|Bg.green in ui
        widget_slider["Content menu l"](ui, content_menu_l)
        widget_slider["Content menu r"](ui, content_menu_r)
        input_buffer["Center:"](ui, center_h1, center_h1_edit)
        footer_border^.end_border_simple[StyleBorderSimple](ui, Fg.green)

        ui.move_cursor_below(all_screen^.stop_measuring())
        all_screen_border^.end_border_simple[StyleBorderDouble](ui, Fg.cyan)
