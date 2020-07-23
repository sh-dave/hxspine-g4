package spine.g4;

enum abstract ShapeType(Int) to Int {
	var Point = 0x0000;
	var Line = 0x0001;
	var Filled = 0x0004;
}
