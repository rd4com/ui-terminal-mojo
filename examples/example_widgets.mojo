
from module_ui import *

def main():
    var ui = UI()
    var App = String("MyApp")
    var is_edit = False
    var checkbox_value = True
    var slider_value = UInt8(8)
    var selected_dtype = 0
    var selected = 0
    for _ in ui:
        input_buffer["Edit:"](ui, App, is_edit)
        widget_checkbox(ui, "MyCheckBox", checkbox_value)
        if checkbox_value:
            if selected_dtype == 0:
                Text(SIMD[DType.uint8, 4](slider_value)) in ui
            else:
                Text(SIMD[DType.float16, 4](slider_value)) in ui
            "" in ui
        widget_value_selector["DType:", theme=Fg.green](
            ui, 
            selected_dtype, 
            List[DType](DType.uint8, DType.float16)
        )
        widget_slider["Slide"](ui, slider_value)
        widget_selection_group["Selection", theme=Fg.blue](
            ui, 
            List[String]("One", "Two", "Three"), 
            selected
        )
