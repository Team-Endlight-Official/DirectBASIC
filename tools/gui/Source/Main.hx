package;

import guitk.GUISector;
import guitk.GUIMenuBar;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.events.Event;
import openfl.display.Sprite;
import guitk.GUI;

class Main extends Sprite
{
	private var gui:GUI;

	public function new()
	{
		super();
		gui = new GUI();
		addChild(gui);

		gui.setMinimumWindowSize(Std.int(1280 / 2), Std.int(720 / 2));
		gui.setBackground(gui.style.COLOR_WINDOW_BACKGROUND);

		var text = new TextField();
		text.defaultTextFormat = gui.style.TEXT_FORMAT_DEFAULT;
		text.textColor = gui.style.COLOR_ERROR;
		text.selectable = false;
		text.border = false;
		text.x = 5;
		text.y = 5 + 24;
		text.width = 512;
		text.text = "[ERROR]: You are so dumb!";
		addChild(text);

		var text2 = new TextField();
		text2.defaultTextFormat = gui.style.TEXT_FORMAT_DEFAULT;
		text2.textColor = gui.style.COLOR_SUCCESS;
		text2.selectable = false;
		text2.border = false;
		text2.x = 5;
		text2.y = 19 + 24;
		text2.width = 512;
		text2.text = "[SUCCESS]: You are a bloody genius :D";
		addChild(text2);

		var text3 = new TextField();
		text3.defaultTextFormat = gui.style.TEXT_FORMAT_DEFAULT;
		text3.textColor = gui.style.COLOR_WARN;
		text3.selectable = false;
		text3.border = false;
		text3.x = 5;
		text3.y = 19 + (19 - 5) + 24;
		text3.width = 512;
		text3.text = "[WARNING]: I dunno :/";
		addChild(text3);

		var text4 = new TextField();
		text4.defaultTextFormat = gui.style.TEXT_FORMAT_DEFAULT;
		text4.textColor = gui.style.COLOR_INFO;
		text4.selectable = false;
		text4.border = false;
		text4.x = 5;
		text4.y = 19 + (19 - 5) + (19 - 5) + 24;
		text4.width = 512;
		text4.text = "[INFO]: Just so you know...";
		addChild(text4);

		var text4 = new TextField();
		text4.defaultTextFormat = gui.style.TEXT_FORMAT_DEFAULT;
		text4.textColor = gui.style.COLOR_TEXT;
		text4.selectable = false;
		text4.border = false;
		text4.x = 5;
		text4.y = 19 + (19 - 5) + (19 - 5) + (19 - 5) + 24;
		text4.width = 128;
		text4.height = 256;
		text4.multiline = true;
		text4.wordWrap = true;
		text4.text = "Lorem ipsum. That is a normal text. Nothing to see here!";
		addChild(text4);

		var menubar = new GUIMenuBar();
		menubar.style = gui.style;
		addChild(menubar);
		stage.addEventListener(Event.RESIZE, menubar.onResize);

		var sector = new GUISector(gui.style, "Projects ");
		sector.sectorWidth = 200;
		sector.sectorHeight = 175;
		sector.x = 5;
		sector.y = 180;
		addChild(sector);
		stage.addEventListener(Event.RESIZE, sector.onResize);
	}
}
