from `ui-terminal-mojo` import *
from time import perf_counter_ns


def main():
    var ui = UI()

    var time_fade_second = UInt8(0)
    var storage = List[Notification](
        Notification("Welcome to the ui !", auto_fade_second = 4)
    )
    var message = String("Hello world !")
    var is_edit = False
    for _ in ui:
        widget_notification_area(ui, storage)
        " " in ui

        "Add notification" in ui
        if ui[-1].click():
            storage.append(Notification(message, auto_fade_second=Int(time_fade_second)))
        "Add notification in green" in ui
        if ui[-1].click():
            storage.append(Notification(message, theme=Fg.green,auto_fade_second=Int(time_fade_second)))
        "Add notification (time extend on hover)" in ui
        if ui[-1].click():
            var tmp = Notification(message, theme=Fg.green,auto_fade_second=Int(time_fade_second))
            tmp.extend_fade_counter_on_hover = True
            storage.append(tmp^)

        input_buffer["Edit new:"](ui, message, is_edit)
        widget_slider["auto fade seconds"](ui, time_fade_second)
