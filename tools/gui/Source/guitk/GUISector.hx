package guitk;

import openfl.text.TextField;
import openfl.geom.Point;
import openfl.events.Event;
import openfl.display.Sprite;

class GUISector extends Sprite
{
    public var style:GUIStyle = null;
    public var sectorWidth:Int = 100;
    public var sectorHeight:Int = 200;

    private var caption:String = "New Sector";
    private var captionField:TextField;

    public function new(style:GUIStyle, caption:String = "New Sector", sectorWidth:Int = 100, sectorHeight:Int = 200)
    {
        super();
        this.caption = caption;
        this.sectorWidth = sectorWidth;
        this.sectorHeight = sectorHeight;
        this.style = style;

        captionField = new TextField();
        captionField.defaultTextFormat = style.TEXT_FORMAT_DEFAULT;
        captionField.multiline = false;
        captionField.selectable = false;
        captionField.wordWrap = false;
        captionField.text = this.caption;
        captionField.border = false;
        captionField.x = 12;
        captionField.y = -(captionField.textHeight / 2);
        addChild(captionField);
    }

    public function onRedraw()
    {
        graphics.lineStyle(1.5, style.COLOR_TEXT);
        
        // Top
        var lineTopStart = new Point(0, 0);
        var lineTopMiddleStart = new Point(10, 0);
        var lineTopMiddleEnd = new Point(captionField.textWidth + captionField.textHeight + 4, 0);
        var lineTopEnd = new Point(sectorWidth, 0);

        graphics.moveTo(lineTopStart.x, lineTopStart.y);
        graphics.lineTo(lineTopMiddleStart.x, lineTopMiddleStart.y);

        graphics.moveTo(lineTopMiddleEnd.x, lineTopMiddleEnd.y);
        graphics.lineTo(lineTopEnd.x, lineTopEnd.y);

        // Sides and Bottom

        var lineBottomLeft = new Point(0, sectorHeight);
        var lineBottomRight = new Point(sectorWidth, sectorHeight);

        graphics.moveTo(lineTopStart.x, lineTopStart.y);
        graphics.lineTo(lineBottomLeft.x, lineBottomLeft.y);

        graphics.moveTo(lineTopEnd.x, lineTopEnd.y);
        graphics.lineTo(lineBottomRight.x, lineBottomRight.y);

        graphics.moveTo(lineBottomLeft.x, lineBottomLeft.y);
        graphics.lineTo(lineBottomRight.x, lineBottomRight.y);

        graphics.lineStyle();

        trace("GUIMenuBar Redrawn!");
    }

    public function onResize(event:Event)
    {
        onRedraw();
        trace("GUIMenuBar Resized!");
    }
}