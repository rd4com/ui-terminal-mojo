from sys.info import simd_width_of


@fieldwise_init
struct QueueSIMD[dtype: DType, capacity: Int = simd_width_of[dtype]()](
    Copyable, Movable, Sized
):
    comptime storage_type = SIMD[Self.dtype, Self.capacity]
    var data: Self.storage_type
    # var more_values: List[Byte]
    var stored: Int

    fn __init__(out self):
        self.data = Self.storage_type(0)
        self.stored = 0

    fn pop_next(mut self, out ret: Scalar[Self.dtype]):
        debug_assert(Bool(self.stored), "error: pop_next an empty queue")
        ret = self.data[0]
        self.data = self.data.shift_left[1]()
        self.stored -= 1

    fn peek_next(mut self, out ret: Scalar[Self.dtype]):
        debug_assert(Bool(self.stored), "error: peek_next an empty queue")
        ret = self.data[0]

    fn append(mut self, value: Scalar[Self.dtype]):
        debug_assert(self.stored < Self.capacity, "error: append an full queue")
        self.data[self.stored] = value
        self.stored += 1

    fn __len__(self) -> Int:
        return self.stored

    fn __bool__(self) -> Bool:
        return Bool(self.stored)
