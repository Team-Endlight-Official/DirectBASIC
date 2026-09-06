package;

import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		var fps:FPS = new FPS(10, 10, 0x000000);
		addChild(fps);

		// for reference, this is going to become a small ide soon :)
	}
}
