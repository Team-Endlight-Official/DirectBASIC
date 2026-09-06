package;

import openfl.text.TextFormat;
import openfl.text.TextField;
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
		this.graphics.beginFill(0x202020);
		this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		this.graphics.endFill();

		buildTitleBar();
		buildStatusBar();
	}

	private function buildTitleBar()
	{
		this.graphics.beginFill(0x303030);
		this.graphics.drawRect(0, 0, stage.stageWidth, 24);
		this.graphics.endFill();

		this.graphics.lineStyle(1, 0xFFFFFF, 0.45);
		this.graphics.drawRect(0, 0, stage.stageWidth, 24);
		this.graphics.lineStyle();

		var title = new TextField();
		title.text = "DirectBASIC Debug Console";
		title.x = 1;
		title.y = 3;
		title.width = 256;
		title.height = 32;
		title.selectable = false;

		var titleformat = new TextFormat();
		titleformat.bold = false;
		titleformat.color = 0xFAFAFA;
		titleformat.kerning = true;
		titleformat.size = 14;
		titleformat.font = "Arial";

		title.defaultTextFormat = titleformat;
		addChild(title);
	}

	private function buildStatusBar()
	{
		this.graphics.beginFill(0x323232);
		this.graphics.drawRect(2.5, stage.stageHeight - (20 + 2.5), stage.stageWidth - 5, 20);
		this.graphics.endFill();
	}
}
