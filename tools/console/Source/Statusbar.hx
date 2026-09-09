package;

import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.display.Sprite;

class Statusbar extends Sprite
{
    private var barHeight:Int = 24;

    public function new(barHeight:Int = 24)
    {
        super();
        this.barHeight = barHeight;
    }

    public function draw()
    {
        // Draw the statusbar fill
        var matrix = new Matrix();
        matrix.createGradientBox(barHeight, barHeight, Math.PI / 2);

        graphics.beginGradientFill(GradientType.LINEAR, [0x404040, 0x2F2F2F, 0x1F1F1F], [1, 1, 1], [0, 180, 255], matrix);
        graphics.drawRect(0, 0, stage.stageWidth, barHeight);
        graphics.endFill();

        // Draw the seperator
        graphics.lineStyle(0.5, 0x000000);
        graphics.drawRect(0, 0, stage.stageWidth, 1);
        graphics.lineStyle();
    }

    public function getBarHeight():Int
    {
        return barHeight;
    }
}