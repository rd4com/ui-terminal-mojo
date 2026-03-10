from `ui-terminal-mojo` import *
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
        var all_screen_border = all_screen.start_border()

        var top_center_bottom =ui.start_measuring()

        var header_border = top_center_bottom.start_border()
        "header" in ui
        widget_slider["Content center"](ui, content_center)
        header_border^.end_border[StyleBorderCurved](ui, Fg.blue)
        top_center_bottom^.stop_measuring().move_cursor_below()

        top_center_bottom =ui.start_measuring()

        var center = ui.start_measuring()
        var menu_border = center.start_border()
        "menu" in ui
        for i in range(Int(content_menu_l)):
            Text("#"*i) in ui
        menu_border^.end_border[StyleBorderDouble](ui, Fg.yellow)
        center^.stop_measuring().move_cursor_after()

        center = ui.start_measuring()
        center_h1 in ui
        for i in range(Int(content_center)):
            Text("*" * i) in ui
        center^.stop_measuring().move_cursor_after()

        center = ui.start_measuring()
        menu_border = center.start_border()
        "menu" in ui
        for i in range(Int(content_menu_r)):
            Text("#"*i) in ui
            tooltip(ui, String("^size:",i))
        menu_border^.end_border[StyleBorderDouble](ui, Fg.yellow)
        center^.stop_measuring().move_cursor_below()
        top_center_bottom^.stop_measuring().move_cursor_below()

        var footer_measure = ui.start_measuring()
        var footer_border = footer_measure.start_border()
        Text("footer")|Bg.green in ui
        widget_slider["Content menu l"](ui, content_menu_l)
        widget_slider["Content menu r"](ui, content_menu_r)
        input_buffer["Center:"](ui, center_h1, center_h1_edit)
        footer_border^.end_border[StyleBorderSimple](ui, Fg.green)
        footer_measure^.stop_measuring().move_cursor_below()

        all_screen_border^.end_border[StyleBorderDouble](ui, Fg.cyan)
        all_screen^.stop_measuring().move_cursor_below()
