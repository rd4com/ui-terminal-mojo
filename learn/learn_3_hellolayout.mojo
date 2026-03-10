from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var counter = 0
    for frame in ui:
        var start_measurement = ui.start_measuring()
        Text(counter) | Fg.magenta in ui
        Text("increment") | Bg.cyan in ui
        if ui[-1].click():
            counter+=1
        var measurement = start_measurement^.stop_measuring()

        measurement^.move_cursor_after()
        "<- it is a counter" in ui
        "<- it is a button" in ui
