
# example:
# mojo run -I build -D terminal_debug=True examples/example_debug_pannel.mojo

from `ui-terminal-mojo` import *

def main():

    var ui = UI()
    ui.feature_help_overlay = True
    for _ in ui:
        var all_screen = ui.start_measuring()
        var b = all_screen.start_border()
        
        for i in range(5):
            Text(i) in ui
        Text(all_screen.peek_dimensions()) in ui
        
        b^.end_border(ui, Fg.green)
        all_screen^.stop_measuring().move_cursor_below()
        
        spinner(ui)
        
        debug_pannel(ui)

