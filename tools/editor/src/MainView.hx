package;

import openfl.geom.Point;
import openfl.system.System;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox
{
    public function new()
    {
        super();

        button1.onClick = function(e)
        {
            button1.text = "Compiling...";
        }

        button3.onClick = function(e)
        {
            parent.stage.nativeWindow.close();
            System.exit(0);
        }
    }
}