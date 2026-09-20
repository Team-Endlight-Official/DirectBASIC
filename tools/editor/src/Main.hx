package ;

import openfl.Lib;
import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;

class Main
{
    public static function main()
    {
        Toolkit.init();

        var app = new HaxeUIApp();
        app.ready(function()
        {
            app.addComponent(new MainView());

            Lib.application.window.setMinSize(800, 600);

            app.start();
        });
    }
}
