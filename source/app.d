import std;
import g2048.game;

void main() {
	auto game = Grid(4);

	while(true) {
		printGrid(game);
		if (!game.oneStep(readInput())) {
			writeln("Game over!");
			break;
		}
	}
}

bool oneStep(Grid game, Input input) {
	final switch (input) {
		case Input.left:
			return game.moveLeft();
		case Input.right:
			return game.moveRight();
		case Input.up:
			return game.moveUp();
		case Input.down:
			return game.moveDown();
	}
}

void printGrid(in Grid grid) {
	enum Row {
		top,
		middle,
		bottom
	}

	static immutable dchar[] leftConnectorChars = [
		'┌',
		'├',
		'└'
	];
	static immutable dchar[] middleConnectorChars = [
		'┬',
		'┼',
		'┴'
	];
	static immutable dchar[] rightConnectorChars = [
		'┐',
		'┤',
		'┘'
	];
	void printRow(Row row, size_t cells, size_t width) {
		write(leftConnectorChars[row]);
		foreach (_; 0 .. cells) {
			writef!"%-(%s%)"("─".repeat(width));
			if (_ == cells - 1) {
				writeln(rightConnectorChars[row]);
			} else {
				write(middleConnectorChars[row]);
			}
		}
	}
	printRow(Row.top, grid.view[0].length, 10);
	foreach (idx, row; grid.view) {
		writefln!"│%(% 10d│%)│"(row);
		printRow(idx == grid.view.length - 1 ? Row.bottom : Row.middle, row.length, 10);
	}
}

enum Input {
	left,
	right,
	up,
	down
}

Input readInput() {
	ubyte[1] readBuffer;
	while (true) {
		stdin.rawRead(readBuffer[]);
		switch(readBuffer[0]) {
			case 'w':
				return Input.up;
			case 'a':
				return Input.left;
			case 's':
				return Input.down;
			case 'd':
				return Input.right;
			default: break;
		}
	}
}