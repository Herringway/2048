module g2048.game;

struct Grid {
	import std.random : Random, unpredictableSeed;
	private uint[][] data;
	private size_t[] shuffleBuffer;
	private Random rng;
	this(uint size) @safe {
		import std.array : array;
		import std.range : iota;
		data = new uint[][](size, size);
		shuffleBuffer = iota!size_t(size*size).array;
		rng = Random(unpredictableSeed);
		advance();
		advance();
	}
	auto view() const pure @safe {
		return data;
	}
	bool moveRight() pure @safe {
		foreach (rowIdx, ref row; data) {
			foreach (colIdx, ref cell; row[1 .. $]) {
				auto to = Coordinates(rowIdx, colIdx + 1);
				auto from = Coordinates(rowIdx, colIdx);
				moveEmpty(from, to);
			}
		}
		foreach (rowIdx, ref row; data) {
			foreach_reverse (colIdx, ref cell; row[1 .. $]) {
				auto to = Coordinates(rowIdx, colIdx + 1);
				auto from = Coordinates(rowIdx, colIdx);
				mergeSame(from, to);
			}
		}
		return advance();
	}
	bool moveLeft() pure @safe {
		foreach (rowIdx, ref row; data) {
			foreach_reverse (colIdx, ref cell; row[0 ..$ - 1]) {
				auto to = Coordinates(rowIdx, colIdx);
				auto from = Coordinates(rowIdx, colIdx + 1);
				moveEmpty(from, to);
			}
		}
		foreach (rowIdx, ref row; data) {
			foreach (colIdx, ref cell; row[0 ..$ - 1]) {
				auto to = Coordinates(rowIdx, colIdx);
				auto from = Coordinates(rowIdx, colIdx + 1);
				mergeSame(from, to);
			}
		}
		return advance();
	}
	bool moveDown() pure @safe {
		foreach (rowIdx, ref row; data[1 .. $]) {
			foreach (colIdx, ref cell; row) {
				auto to = Coordinates(rowIdx + 1, colIdx);
				auto from = Coordinates(rowIdx, colIdx);
				moveEmpty(from, to);
			}
		}
		foreach_reverse (rowIdx, ref row; data[1 .. $]) {
			foreach (colIdx, ref cell; row) {
				auto to = Coordinates(rowIdx + 1, colIdx);
				auto from = Coordinates(rowIdx, colIdx);
				mergeSame(from, to);
			}
		}
		return advance();
	}
	bool moveUp() pure @safe {
		foreach_reverse (rowIdx, ref row; data[0 .. $ - 1]) {
			foreach (colIdx, ref cell; row) {
				auto to = Coordinates(rowIdx, colIdx);
				auto from = Coordinates(rowIdx + 1, colIdx);
				moveEmpty(from, to);
			}
		}
		foreach (rowIdx, ref row; data[0 .. $ - 1]) {
			foreach (colIdx, ref cell; row) {
				auto to = Coordinates(rowIdx, colIdx);
				auto from = Coordinates(rowIdx + 1, colIdx);
				mergeSame(from, to);
			}
		}
		return advance();
	}
	bool advance() pure @safe {
		import std.random : dice, randomShuffle;
		randomShuffle(shuffleBuffer, rng);
		foreach (location; shuffleBuffer) {
			const coordinates = Coordinates(location % data.length, location / data.length);
			if (getCell(coordinates) == 0) {
				getCell(coordinates) = cast(uint)((dice(rng, 0.9, 0.1) + 1) * 2);
				break;
			}
		}
		return true;
	}
	private ref uint getCell(Coordinates coords) pure @safe
		in(coords.x < data.length)
		in(coords.y < data[0].length)
	{
		return data[coords.x][coords.y];
	}
	private void mergeSame(Coordinates from, Coordinates to) pure @safe {
		if (getCell(from) == getCell(to)) {
			getCell(to) = getCell(from)*2;
			getCell(from) = 0;
		}
	}
	private void moveEmpty(Coordinates from, Coordinates to) pure @safe {
		if (getCell(to) == 0) {
			getCell(to) = getCell(from);
			getCell(from) = 0;
		}
	}
}

private struct Coordinates {
	size_t x;
	size_t y;
}
