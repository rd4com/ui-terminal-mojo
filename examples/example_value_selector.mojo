from `ui-terminal-mojo` import *

def main():
    var ui = UI()
    var selected = 0
    var selected_dtype = 0
    var values = List[String]("One", "Two", "Three")
    for _ in ui:
        widget_value_selector["Selection:", theme=Fg.magenta](ui, selected, values)
        widget_value_selector["DType:", theme=Fg.green](
            ui,
            selected_dtype,
            List[DType](DType.uint8, DType.float16)
        )
