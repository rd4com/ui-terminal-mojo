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


        widget_percent_bar(ui, Int((100.0/15.0)*Int(value)))

        var small_panel = ui.start_measuring()
        var small_panel_border = small_panel.start_border()
        "Hello!" in ui
        widget_slider["Slide",Fg.blue,True](ui, value)
        small_panel_border^.end_border[StyleCustom](ui, Fg.cyan)
        small_panel^.stop_measuring().move_cursor_after()
        
        var small_panel2 = ui.start_measuring()
        var small_panel_border2 = small_panel2.start_border()
        for i in range(value):
            Text(i) in ui
        small_panel_border2^.end_border[StyleBorderCurved](ui, Fg.magenta)
        small_panel2^.stop_measuring().move_cursor_below()

        all_screen^.stop_measuring().move_cursor_below()
