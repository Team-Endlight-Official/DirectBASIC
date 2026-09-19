package guitk;

import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.display.Sprite;
import openfl.events.Event;

class GUIMenuBar extends Sprite
{
    public var style:GUIStyle = null;

    public function new()
    {
        super();
    }

    public function onRedraw()
    {
        var mat = new Matrix();
        mat.createGradientBox(24, 24, Math.PI / 2);

        graphics.beginGradientFill(GradientType.LINEAR, [style.COLOR_TOOLBAR_LIGHT, style.COLOR_TOOLBAR_MIDDLE, style.COLOR_TOOLBAR_DARK], [1, 1, 1], [0, 96, 255], mat);
        graphics.drawRect(0, 0, stage.stageWidth, 24);
        graphics.endFill();

        graphics.lineStyle(1, style.COLOR_BORDER_DARK);
        graphics.moveTo(0, 24);
        graphics.lineTo(stage.stageWidth, 24);
        graphics.lineStyle();

        trace("GUIMenuBar Redrawn!");
    }

    public function onResize(event:Event)
    {
        onRedraw();
        trace("GUIMenuBar Resized!");
    }
}