package;

import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.display.Sprite;

class Button extends Sprite
{
    private var caption:String = "New Button";
    private var captionField:TextField;
    private var buttonWidth:Int;
    private var buttonHeight:Int;

    public function new(width:Int = 128, height:Int = 32, caption:String = "New Button")
    {
        super();
        buttonWidth = width;
        buttonHeight = height;

        captionField = new TextField();
        var captionFormat = new TextFormat();
        captionFormat.align = CENTER;

        addChild(captionField);
        captionField.defaultTextFormat = captionFormat;
        captionField.selectable = false;
        captionField.textColor = 0xE0E0E0;
        captionField.border = false;
        captionField.x = 0;
        captionField.y = 0;
        captionField.height = height;
        captionField.width = width;
        
        setCaption(caption);
    }

    public function setCaption(caption:String)
    {
        this.caption = caption;
        captionField.text = this.caption;
    }

    public function draw()
    {
        // Draw the button fill
        var matrix = new Matrix();
        matrix.createGradientBox(buttonHeight, buttonHeight, Math.PI / 2);

        graphics.beginGradientFill(GradientType.LINEAR, [0x404040, 0x2F2F2F, 0x1F1F1F], [1, 1, 1], [0, 180, 255], matrix);
        graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 8, 8);
        graphics.endFill();

        graphics.lineStyle(0.5);
        graphics.lineGradientStyle(GradientType.LINEAR, [0xE2E2E2, 0x222222, 0x000000], [1, 1, 1], [0, 32, 255], matrix);
        graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 8, 8);
        graphics.lineStyle();
    }
}