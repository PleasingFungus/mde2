/*
*** FlxInputText v0.9, Input text field extension for Flixel ***

IMPORTANT: You need to modify the FlxText class so that the _textField member is protected instead of private.
New members:
getText()
setMaxLength()

backgroundColor
borderColor
backgroundVisible
borderVisible

forceUpperCase
filterMode
customFilterPattern


Copyright (c) 2009 Martin Sebastian Wain
License: Creative Commons Attribution 3.0 United States
(http://creativecommons.org/licenses/by/3.0/us/)

(A tiny "single line comment" reference in the source code is more than sufficient as attribution :)
 */

package UI {
	import org.flixel.*;
	import flash.events.Event;
	import flash.text.TextFieldType;

	//@desc Input field class that "fits in" with Flixel's workflow
	public class FlxInputText extends FlxText {

		static public const NO_FILTER:uint = 0;
		static public const ONLY_ALPHA:uint = 1;
		static public const ONLY_NUMERIC:uint = 2;
		static public const ONLY_ALPHANUMERIC:uint = 3;
		static public const CUSTOM_FILTER:uint = 4;

		//@desc Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
		// (Remember to append "FlxInputText." as a prefix to those constants)
		public var filterMode:uint = NO_FILTER;

		//@desc This regular expression will filter out (remove) everything that matches. This is activated by setting filterMode = FlxInputText.CUSTOM_FILTER.
		public var customFilterPattern:RegExp = /[]*/g;

		//@desc If this is set to true, text typed is forced to be uppercase
		public var forceUpperCase:Boolean = false;

		//@desc Same parameters as FlxText
		public function FlxInputText(X:Number, Y:Number, Width:uint, Height:uint, Text:String,
									 Color:uint = 0x000000, Font:String = null, Size:uint = 8,
									 Justification:String = null) {
			super(X, Y, Width, Text);
			setFormat(Font, Size, Color, Justification);
			_textField.height = Height;
			_textField.multiline = _textField.wordWrap = false;
			
			_textField.selectable = true;
			_textField.type = TextFieldType.INPUT;
			_textField.background = true;
			_textField.backgroundColor = (~Color) ^ 0x888888;
			_textField.alwaysShowSelection = true;
			_textField.border = true;
			_textField.borderColor = Color;
			_textField.x = x;
			_textField.y = y;
			//_textField.visible = false;
			calcFrame();

			FlxG.stage.addChild(_textField);
		}

		//@desc Boolean flag in case render() is called BEFORE onEnterFrame() (_textField would be always hidden)
		// NOTE: I don't think it's necessary, but I'll leave it just in case.
		//@param Direction True is Right, False is Left (see static const members RIGHT and LEFT)
		//private var nextFrameHide:Boolean = false;

		/*override public function render():void {
			_textField.x=x;
			_textField.y=y;
			_textField.visible = true;
			//nextFrameHide = false;
		}  */
		
		public function die():void {
			FlxG.stage.removeChild(_textField);
		}
		
		protected var frameListener:Function;

		//@desc Text field background color
		public function set backgroundColor(Color:uint):void { _textField.backgroundColor = Color; }
		//@desc Text field border color
		public function set borderColor(Color:uint):void { _textField.borderColor = Color; }
		//@desc Shows/hides background
		public function set backgroundVisible(Enabled:Boolean):void { _textField.background = Enabled; }
		//@desc Shows/hides border
		public function set borderVisible(Enabled:Boolean):void { _textField.border = Enabled; }

		//@desc Text field background color
		public function get backgroundColor():uint { return _textField.backgroundColor; }
		//@desc Text field border color
		public function get borderColor():uint { return _textField.borderColor; }
		//@desc Shows/hides background
		public function get backgroundVisible():Boolean { return _textField.background; }
		//@desc Shows/hides border
		public function get borderVisible():Boolean { return _textField.border; }

		//@desc Set the maximum length for the field (e.g. "3" for Arcade type hi-score initials)
		//@param Length The maximum length. 0 means unlimited.
		public function setMaxLength(Length:uint):void
		{
			_textField.maxChars = Length;
		}

		//@desc Get the text the user has typed
		public function getText():String
		{
			return _textField.text;
		}


		public function set multiline(value:Boolean):void
		{
			_textField.multiline = value;
			_textField.wordWrap = value;
		}

		public function get multiline():Boolean
		{
			return _textField.multiline;
		}
		
		/*public function toggleSelect():void {
			_textField.backgroundColor ^= 0xffffff;
			//color ^= 0xffffffff;
			color = (color ? 0x000000 : 0xffffff)
		} */
		
		public function selectAll():void {
			_textField.setSelection(0, _textField.text.length);
		}
		
		
	}

}