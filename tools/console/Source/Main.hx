package;

import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		build();
	}

	private function build()
	{
		// Paint the background
		graphics.beginFill(0x2F2F2F);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		graphics.endFill();

		// Add the statusbar
		var statusbar = new Statusbar();
		addChild(statusbar);
		statusbar.draw();
		statusbar.y = stage.stageHeight - statusbar.getBarHeight();
		
		var menubar = new Statusbar(20);
		addChild(menubar);
		menubar.draw();

		// Add Button
		var compileButton = new Button(64, 20, "Compile");
		addChild(compileButton);
		compileButton.draw();
		compileButton.x = stage.stageWidth - 110;
		compileButton.y = stage.stageHeight - 62;

		var buildButton = new Button(64, 20, "Build");
		addChild(buildButton);
		buildButton.draw();
		buildButton.x = stage.stageWidth - 180;
		buildButton.y = stage.stageHeight - 62;
	}
}
