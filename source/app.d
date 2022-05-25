import std;
import core.sys.windows.windows;
import g2048.game;

void main() {
	auto game = Grid(5);

	outer: while(true) {
		printGrid(game);
		foreach (event; readEvent()) {
			if (event.isInput) {
				final switch (game.oneStep(event.input)) {
					case GameState.exiting:
						break outer;
					case GameState.lost:
						writeln("Game over!");
						break outer;
					case GameState.running:
						break;
				}
			}
		}
		writef!"\x1B[%dF"(game.view.length * 2 + 1);
	}
}

GameState oneStep(Grid game, Input input) {
	final switch (input) {
		case Input.left:
			return game.moveLeft() ? GameState.running : GameState.lost;
		case Input.right:
			return game.moveRight() ? GameState.running : GameState.lost;
		case Input.up:
			return game.moveUp() ? GameState.running : GameState.lost;
		case Input.down:
			return game.moveDown() ? GameState.running : GameState.lost;
		case Input.quit:
			return GameState.exiting;
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
		write("│");
		foreach (colour, num; zip(row.colours, row)) {
			writef!"\x1B[38;5;%dm% 10d\x1B[0m│"(colour, num);
		}
		writeln();
		printRow(idx == grid.view.length - 1 ? Row.bottom : Row.middle, row.length, 10);
	}
}

auto colours(const uint[] nums) {
	return nums.map!(x => x.colour);
}

auto colour(uint num) {
	switch (num) {
		case 2^^1: return 1;
		case 2^^2: return 2;
		case 2^^3: return 3;
		case 2^^4: return 4;
		case 2^^5: return 5;
		case 2^^6: return 6;
		case 2^^7: return 7;
		case 2^^8: return 8;
		case 2^^9: return 9;
		case 2^^10: return 10;
		case 2^^11: return 11;
		default: return 255;
	}
}

enum Input {
	left,
	right,
	up,
	down,
	quit
}

enum GameState {
	running,
	lost,
	exiting
}

struct Event {
	bool isInput;
	Input input;
}

Event[] readEvent() {
	Event[] result;
	version(Windows) {
		INPUT_RECORD[32] buf;
		DWORD numEvents;
		enforce(ReadConsoleInputW(GetStdHandle(STD_INPUT_HANDLE), buf.ptr, buf.length, &numEvents), "Unable to read events");
		foreach (event; buf[0 .. numEvents]) {
			switch (event.EventType) {
				case KEY_EVENT:
					auto keyEvent = event.KeyEvent;
					if (!keyEvent.bKeyDown) {
						switch (keyEvent.wVirtualKeyCode) {
							case VK_LEFT:
								result ~= Event(true, Input.left);
								break;
							case VK_UP:
								result ~= Event(true, Input.up);
								break;
							case VK_DOWN:
								result ~= Event(true, Input.down);
								break;
							case VK_RIGHT:
								result ~= Event(true, Input.right);
								break;
							case 'Q':
								result ~= Event(true, Input.quit);
								break;
							default: break;
						}
					}
					break;
				default: break;
			}
		}
	}
	return result;
}
