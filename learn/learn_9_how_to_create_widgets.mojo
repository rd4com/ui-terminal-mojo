from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var numbers = List[UInt8](
        0, 1, 2, 3
    )
    for _ in ui:
        # var start_measuring = ui.start_measuring()
        my_custom_widget(ui, numbers)
        # var stop_measuring = start_measuring^.stop_measuring()
        # ui.move_cursor_after(stop_measuring^)
        "Widget moved the cursor below for user friendlyness" in ui
        # Text("But let's go -> !") | Bg.blue in ui

fn my_custom_widget(mut ui:UI, mut numbers: List[UInt8]):
    if len(numbers):
        #▶️ 📐start measuring our widget space:
        var start_measuring = ui.start_measuring()

        #start border (and include it in measurement)
        var border = start_border(ui)
        for n in numbers:
            #compose with another widget
            widget_slider["Value:"](ui, n[])
        #stop border (and include it in measurement)
        border^.end_border(ui, Fg.magenta)

        #⏹️ 📐stop measuring our widget space:
        var stop_measuring = start_measuring^.stop_measuring()

        #move the cursor below that space:
        ui.move_cursor_below(stop_measuring^)
