from `ui-terminal-mojo` import *
from time import perf_counter_ns

def main():
    var ui = UI()
    var value= UInt8(0)
    var notifs = List[Notification]()
    var current_value = String("Hello world")
    var is_edit = False
    for _ in ui:
        "Hello app" in ui

        var all_border_measuring = start_border(ui)

        var start_measuring = ui.start_measuring()
        var b = start_border(ui)
        widget_slider["Slide", preview_value=True](ui,value)
        input_buffer["Edit new:"](ui, current_value, is_edit)
        "Add" in ui
        if ui[-1].click():
            notifs.append(Notification(current_value, auto_fade_second=Int(value)))
        b^.end_border(ui, Fg.blue)
        ui.move_cursor_after(start_measuring^.stop_measuring())

        start_measuring = ui.start_measuring()
        b = start_border(ui)
        "Hello world" in ui
        if notifs: spinner2(ui)
        widget_notification_area(ui,notifs)
        if notifs:
            if len(notifs)>=4:
                b^.end_border(ui, Fg.cyan)
            else:
                b^.end_border[StyleBorderCurved](ui, Fg.green)
        else:
            b^.end_border(ui, Fg.green)
        ui.move_cursor_after(start_measuring^.stop_measuring())

        for i in range(value):
            Text(i) in ui
        all_border_measuring^.end_border[StyleBorderDouble](ui,Fg.magenta)
