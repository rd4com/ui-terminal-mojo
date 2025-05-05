
from module_ui import *

def main():
    var ui = UI()
    var value = UInt8(0)
    for _ in ui:
        widget_slider["MySlider", theme=Fg.magenta](ui, value)
