package guitk;

import openfl.events.Event;
import openfl.display.Sprite;

/**
 * Base class for the whole GUI logic loop.
 */
class GUI extends Sprite
{
    public var style:GUIStyle = GUIStyle.getDefault();

    public function setBackground(color:Int)
    {
        stage.color = color;
        //onRedraw();
    }

    public function onResize(event:Event):Void
    {
        if (numChildren < 1) return;

        for (i in 0...numChildren)
        {
            var child = getChildAt(i);
            if (child is GUIElement)
            {
                var element:GUIElement = cast child;
                element.onResize(event);
            }
            else return;
        }

        trace("Resized!");

        onRedraw();
    }

    public function onRedraw():Void
    {
        if (numChildren < 1) return;

        for (i in 0...numChildren)
        {
            var child = getChildAt(i);
            if (child is GUIElement)
            {
                var element:GUIElement = cast child;
                element.onRedraw();
            }
            else return;
        }

        trace("Redrawn!");
    }

    public function add(element:GUIElement)
    {
        element.style = style;
        addChild(element);
    }
}