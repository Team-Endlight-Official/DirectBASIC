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
    }

    public function setMinimumWindowSize(width:Int, height:Int)
    {
        stage.window.setMinSize(width, height);
    }

    public function setMaximumWindowSize(width:Int, height:Int)
    {
        stage.window.setMaxSize(width, height);
    }
}