package;

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
		var textformat = new TextFormat();
		textformat.font = "Lucida Grande";

		gui = new GUI();
		addChild(gui);

		gui.setBackground(gui.style.COLOR_WINDOW_BACKGROUND);
		gui.onRedraw();

		var text = new TextField();
		addChild(text);
		text.textColor = gui.style.COLOR_ERROR;
		text.defaultTextFormat = textformat;
		text.selectable = false;
		text.border = false;
		text.x = 5;
		text.y = 5;
		text.width = 512;
		text.text = "[ERROR]: You are so dumb!";

		var text2 = new TextField();
		addChild(text2);
		text2.textColor = gui.style.COLOR_SUCCESS;
		text2.defaultTextFormat = textformat;
		text2.selectable = false;
		text2.border = false;
		text2.x = 5;
		text2.y = 19;
		text2.width = 512;
		text2.text = "[SUCCESS]: You are a bloody genius :D";

		var text3 = new TextField();
		addChild(text3);
		text3.textColor = gui.style.COLOR_WARN;
		text3.defaultTextFormat = textformat;
		text3.selectable = false;
		text3.border = false;
		text3.x = 5;
		text3.y = 19 + (19 - 5);
		text3.width = 512;
		text3.text = "[WARNING]: I dunno :/";

		var text4 = new TextField();
		addChild(text4);
		text4.textColor = gui.style.COLOR_INFO;
		text4.defaultTextFormat = textformat;
		text4.selectable = false;
		text4.border = false;
		text4.x = 5;
		text4.y = 19 + (19 - 5) + (19 - 5);
		text4.width = 512;
		text4.text = "[INFO]: Just so you know...";

		var text4 = new TextField();
		addChild(text4);
		text4.textColor = gui.style.COLOR_TEXT;
		text4.defaultTextFormat = textformat;
		text4.selectable = false;
		text4.border = false;
		text4.x = 5;
		text4.y = 19 + (19 - 5) + (19 - 5) + (19 - 5);
		text4.width = 128;
		text4.height = 256;
		text4.multiline = true;
		text4.wordWrap = true;
		text4.text = "Lorem ipsum. That is a normal text. Nothing to see here!";

		stage.addEventListener(Event.RESIZE, gui.onResize);
	}
}
