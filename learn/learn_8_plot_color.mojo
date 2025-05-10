from module_ui import *

def main():
    var ui = UI()

    var values = WidgetPlotSIMDQueue()
    for _ in ui:
        "Append sampled value" in ui
        if ui[-1].click():
            values.append_3bit_value(ui.time_counter.previous%8)

        var m = ui.start_measuring()
        var b = start_border(ui)
        var avg = values.average_3bit()
        widget_plot(ui, values, Fg.red if avg>=4 else Fg.green)
        Text(avg) | Fg.green in ui
        b^.end_border_simple(ui, Fg.red if avg>=4 else Fg.green)
        ui.move_cursor_below(m^.stop_measuring())
