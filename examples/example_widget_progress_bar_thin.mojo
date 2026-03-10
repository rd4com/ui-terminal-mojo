from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var value = UInt8(0)
    for _ in ui:
        widget_progress_bar_thin[width=5](ui, value)
        widget_progress_bar_thin[Fg.cyan,width=5](ui, value)
        widget_progress_bar_thin[Fg.blue, width=10](ui, value)
        widget_progress_bar_thin(ui, value)
        widget_progress_bar_thin[Fg.magenta, width=50](ui, value)
        widget_progress_bar_thin[width=100](ui, value)
        "Increment" in ui
        if ui[-1].click():
            value+=1
            value%=101
