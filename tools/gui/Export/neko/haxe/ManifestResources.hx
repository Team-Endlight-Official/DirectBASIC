package;

import haxe.io.Bytes;
import haxe.io.Path;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if disable_preloader_assets
@:dox(hide) class ManifestResources {
	public static var preloadLibraries:Array<Dynamic>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;

	public static function init (config:Dynamic):Void {
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
	}
}
#else
@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

			if(!StringTools.endsWith (rootPath, "/")) {

				rootPath += "/";

			}

		}

		if (rootPath == null) {

			#if (ios || tvos)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif (emscripten || webassembly)
			rootPath = "";
			#elseif (console || sys)
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__assets_font_lucidagrande_ttf);
		
		#end

		var data, manifest, library, bundle;

		data = '{"name":null,"assets":"aoy4:sizei256356y4:typey4:FONTy9:classNamey37:__ASSET__assets_font_lucidagrande_ttfy2:idy32:assets%2Ffont%2Flucidagrande.ttfgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

	}


}

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_font_lucidagrande_ttf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("Export/neko/obj/tmp/manifest/default.json") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}

@:keep @:noCompletion #if display private #end class __ASSET__assets_font_lucidagrande_ttf extends lime.text.Font { public function new () { __fontPath = ManifestResources.rootPath + "assets/font/lucidagrande.ttf"; name = "Lucida Grande"; super (); }}


#else

@:keep @:expose('__ASSET__assets_font_lucidagrande_ttf') @:noCompletion #if display private #end class __ASSET__assets_font_lucidagrande_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "assets/font/lucidagrande.ttf"; #else ascender = null; descender = null; height = null; numGlyphs = null; underlinePosition = null; underlineThickness = null; unitsPerEM = null; #end name = "Lucida Grande"; super (); }}


#end

#if (openfl && !flash)

#if html5
@:keep @:expose('__ASSET__OPENFL__assets_font_lucidagrande_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__assets_font_lucidagrande_ttf extends openfl.text.Font { public function new () { name = "Lucida Grande"; super (); }}

#else
@:keep @:expose('__ASSET__OPENFL__assets_font_lucidagrande_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__assets_font_lucidagrande_ttf extends openfl.text.Font { public function new () { __fontPath = ManifestResources.rootPath + "assets/font/lucidagrande.ttf"; name = "Lucida Grande"; super (); }}

#end

#end
#end

#end