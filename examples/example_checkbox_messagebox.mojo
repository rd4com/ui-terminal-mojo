from module_ui import *

def main():
    var ui = UI()

    var value_checkbox = False
    var inline_message = Optional[String](None)

    for frame in ui:
        widget_checkbox(ui, "MyCheckBox1:",value_checkbox)
        animate_emojis[List[String]("🌍","🌎", "🌏")](ui)
        Text("Create")|Bg.cyan in ui
        if ui[-1].click():
            inline_message = String("Test")
        widget_inline_message_box(ui, inline_message)
