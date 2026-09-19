package guitk;

import openfl.text.TextFormat;

/**
 * Base class for the color scheme of the GUI.
 */
class GUIStyle
{
    public var COLOR_WINDOW_BACKGROUND:Int = 0x191A19;

    public var COLOR_MAIN_PANEL:Int = 0x22211F;
    public var COLOR_DARK_PANEL:Int = 0x1C1D1C;
    public var COLOR_RAISED_PANEL:Int = 0x2B2925;

    public var COLOR_GRADIENT_LIGHT:Int = 0x3A3731;
    public var COLOR_GRADIENT_MIDDLE:Int = 0x292722;
    public var COLOR_GRADIENT_DARK:Int = 0x1D1D1B;

    public var COLOR_BORDER_LIGHT:Int = 0x625B4F;
    public var COLOR_BORDER_MIDDLE:Int = 0x48443C;
    public var COLOR_BORDER_DARK:Int = 0x111211;

    public var COLOR_BUTTON_LIGHT:Int = 0x51483B;
    public var COLOR_BUTTON_MIDDLE:Int = 0x3B352C;
    public var COLOR_BUTTON_DARK:Int = 0x292722;

    public var COLOR_TOOLBAR_LIGHT:Int = 0x454039;
    public var COLOR_TOOLBAR_MIDDLE:Int = 0x302D27;
    public var COLOR_TOOLBAR_DARK:Int = 0x22221F;

    public var COLOR_TEXT:Int = 0xDED8CC;

    public var COLOR_ERROR:Int = 0xC96B5B;
    public var COLOR_INFO:Int = 0x8FAFC0;
    public var COLOR_WARN:Int = 0xD0A052;
    public var COLOR_SUCCESS:Int = 0xA8B86B;

    public var TEXT_FORMAT_DEFAULT:TextFormat = null;

    /**
     * Specifies a new GUI style for the GUI
     */
    public function new()
    {
        TEXT_FORMAT_DEFAULT = new TextFormat();
        TEXT_FORMAT_DEFAULT.font = "Lucida Grande";
        TEXT_FORMAT_DEFAULT.color = COLOR_TEXT;
    }

    /**
     * Returns the default GUI style that has the "Charcoal Caramel" theme.
     * @return Default GUIStyle.
     */
    public static function getDefault():GUIStyle
    {
        return new GUIStyle();
    }
}