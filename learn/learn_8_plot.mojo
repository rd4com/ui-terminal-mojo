from module_ui import *

def main():
    var ui = UI()

    var value = UInt8(0)
    var values = WidgetPlotSIMDQueue()
    for i in range(values.size):
        # a value from ->0️⃣ to 7️⃣<-:
        values.append_3bit_value(i%8)

    for _ in ui:
        "Append sampled value" in ui
        if ui[-1].click():
            values.append_3bit_value(ui.time_counter.previous%8)

        "Append" in ui
        if ui[-1].click():
            values.append_3bit_value(value)
        if ui[-1].hover():
            "Click to append" in ui
        widget_slider["New value"](ui, value)
        if value>7:
            Text("Only `0 <= value <= 7`") | Bg.yellow in ui

        " " in ui

        widget_plot(ui, values)
        # widget_plot(ui, values, theme=Fg.cyan)
        Text(values.average_3bit()) | Fg.green in ui
