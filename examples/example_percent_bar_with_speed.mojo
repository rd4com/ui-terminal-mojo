from `ui-terminal-mojo` import *
from time import perf_counter_ns


def main():
    var ui = UI()
    var speed:UInt8 = 0
    var progress= Int(1)

    for _ in ui:
        "Speed from 0 to 2" in ui
        for i in range(3):
            Text(String("Set speed:", i)) | Bg(45+i) in ui
            if ui[-1].click():
                speed = i

        widget_percent_bar_with_speed(ui, progress, Int(speed))
        progress = (perf_counter_ns()//100000000)%100
