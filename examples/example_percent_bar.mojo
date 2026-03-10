from `ui-terminal-mojo` import *
from time import perf_counter_ns

def main():
    var ui = UI()
    var selected = 100
    var selected2 = 100
    for _ in ui:
        selected = Int(perf_counter_ns()/100000000)%100
        selected2 = Int(perf_counter_ns()/1000000000)%100
        widget_percent_bar(ui, selected)
        widget_percent_bar[theme=Fg.blue](ui, selected2)
        # widget_percent_bar[theme=Fg.magenta](ui, 100)
