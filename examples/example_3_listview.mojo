from `ui-terminal-mojo` import *

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ Features                                                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝
fn main():

    # menu widget:
    var mylist = List[SIMD[DType.uint8, 4]]()
    for i in range(100): mylist.append(i)
    var current_page = 0

    var ui = UI()
    for _ in ui:
        Text("list size:", len(mylist)) | Bg.yellow | Fg.red in ui

        "remove half" in ui
        if ui[-1].click():
            for _ in range(len(mylist)//2): _ = mylist.pop()
        "double size" in ui
        if ui[-1].click():
            for _ in range(len(mylist)): mylist.append(len(mylist))

        widget_paginate_list["list view:", elements_per_page=3](ui, mylist, current_page)
