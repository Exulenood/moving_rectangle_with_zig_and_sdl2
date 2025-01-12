pub const Rectangle = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    speed: i32,

    pub fn init(x: i32, y: i32) Rectangle {
        return Rectangle{
            .x = x,
            .y = y,
            .width = 100,
            .height = 100,
            .speed = 10,
        };
    }

    pub fn move(self: *Rectangle, dx: i32, dy: i32) void {
        self.x += dx * self.speed;
        self.y += dy * self.speed;
    }
};
