import std;
import core.thread;
import g2048.game;
import safersdl;
import std.experimental.logger;

enum backgroundColour = Colour(64, 64, 160, 255);

enum width = 800;
enum height = 800;

Grid game;
GameState state;

void main() {
	graphics.initialize("2048", width, height, width, height);
	loadAssets();
	input.initialize();
	auto logic = new Fiber(&gameLogic);
	auto draw = new Fiber(&drawGame);
	while(logic.state != Fiber.State.TERM) {
		graphics.startFrame();
		logic.call();
		draw.call();
		graphics.flip();
		graphics.waitForNextFrame();
	}
}

void loadAssets() {
	graphics.loadFont("DejaVuSerif.ttf");
}

void reset() {
	game = Grid(4);
}

void gameLogic() {
	reset();
	while (true) {
		if (input.update() || input.isPressed(KeyboardKey.escape)) {
			break;
		}
		if (input.isPressed(KeyboardKey.leftArrow)) {
			state = game.moveLeft() ? GameState.running : GameState.lost;
		} else if (input.isPressed(KeyboardKey.rightArrow)) {
			state = game.moveRight() ? GameState.running : GameState.lost;
		} else if (input.isPressed(KeyboardKey.upArrow)) {
			state = game.moveUp() ? GameState.running : GameState.lost;
		} else if (input.isPressed(KeyboardKey.downArrow)) {
			state = game.moveDown() ? GameState.running : GameState.lost;
		}
		Fiber.yield();
	}
}
void drawGame() {
	while (true) {
		graphics.setColor(backgroundColour);
		graphics.drawRect(0, 0, width, height);
		enum sqWidth = width / 5;
		enum sqAlignX = width / 4;
		enum sqHeight = height / 5;
		enum sqAlignY = height / 4;
		foreach (x, row; game.view) {
			foreach (y, num; row) {
				const sqX = cast(int)(sqAlignY * y) + (sqAlignY - sqHeight) / 2;
				const sqY = cast(int)(sqAlignX * x) + (sqAlignX - sqWidth) / 2;
				const textX = cast(int)(sqAlignY * y) + sqAlignY / 2;
				const textY = cast(int)(sqAlignX * x) + sqAlignX / 2;
				graphics.setColor(colour(num));
				graphics.drawRect(cast(int)sqX, sqY, sqWidth, sqHeight);
				graphics.setColor(Colour(0, 0, 0, 255));
				graphics.drawInt(num, textX, textY);
			}
		}
		Fiber.yield();
	}
}

Colour colour(uint num) {
	switch (num) {
		case 2^^1: return Colour(170, 0, 0, 255);
		case 2^^2: return Colour(0, 170, 0, 255);
		case 2^^3: return Colour(170, 85, 0, 255);
		case 2^^4: return Colour(0, 0, 170, 255);
		case 2^^5: return Colour(170, 0, 170, 255);
		case 2^^6: return Colour(0, 170, 170, 255);
		case 2^^7: return Colour(170, 170, 170, 255);
		case 2^^8: return Colour(85, 85, 85, 255);
		case 2^^9: return Colour(255, 85, 85, 255);
		case 2^^10: return Colour(85, 255, 85, 255);
		case 2^^11: return Colour(255, 255, 85, 255);
		default: return Colour(0, 0, 0, 255);
	}
}

enum GameState {
	running,
	lost
}
