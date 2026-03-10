from `ui-terminal-mojo` import *

def main():

    var ui = UI()
    ui.feature_help_overlay = False
    var themes = List[Fg](Fg.green, Fg.blue)
    for _ in ui:

        var all_screen = ui.start_measuring()
        var all_screen_b = all_screen.start_border()
        
        for o in range(2):
            var current_theme = themes[o]
            var small_measurement = ui.start_measuring()
            var b = small_measurement.start_border()
            
            for i in range(5):
                Text("*" * (i+1)) in ui
                if ui[-1].hover():
                    Text("^ Example") | current_theme.to_bg() in ui
            
            b^.end_border(ui, current_theme) #todo: end_border returns something to recolor it ?
            var small_measurement_measured = small_measurement^.stop_measuring()
            var cursor_in_small =  small_measurement_measured.hover()
            small_measurement_measured^.move_cursor_below()
            
            if cursor_in_small:
                Text("^ theses are 5 values") | current_theme.to_bg() in ui

        all_screen_b^.end_border(ui, Fg.magenta)
        var all_screen_measurement = all_screen^.stop_measuring()
        var cursor_in_all_screen = all_screen_measurement.hover()
        all_screen_measurement^.move_cursor_below()
        if cursor_in_all_screen:
            Text("^ theses are 10 values") | Fg.magenta in ui


