from `ui-terminal-mojo` import *

struct StyleCustom(StyledBorder):
    alias up_l = String("╔")
    alias up_r = String("╮")
    alias v = String("│")
    alias h = String("─")
    alias b_l = String("╚")
    alias b_r = String("╝")

def main():
    var ui = UI()
    var value = UInt8(0)
    for _ in ui:
        var all_screen = ui.start_measuring()
        var small_panel = ui.start_measuring()

        widget_percent_bar(ui, Int((100.0/15.0)*Int(value)))

        var all_b = start_border(ui)
        "Hello!" in ui
        widget_slider["Slide",Fg.blue,True](ui, value)
        all_b^.end_border_simple[StyleCustom](ui, Fg.cyan)
        ui.move_cursor_after(small_panel^.stop_measuring())
        all_b = start_border(ui)
        for i in range(value):
            Text(i) in ui
        all_b^.end_border_simple[StyleBorderCurved](ui, Fg.magenta)
        ui.move_cursor_below(all_screen^.stop_measuring())
