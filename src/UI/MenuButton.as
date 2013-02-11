package UI {
	import Controls.ControlSet;
	import Controls.Key;
	import flash.geom.Point;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MenuButton extends FlxGroup {
		
		protected var x:int;
		protected var y:int;
		protected var coreGraphic:FlxSprite;
		protected var graphicColor:uint = 0xffffffff;
		protected var highlight:FlxSprite;
		protected var highlightBorder:Point;
		
		public var moused:Boolean;
		
		public var camera:FlxCamera;
		
		public var fades:Boolean;
		public var callWithParam:Object;
		public var hotkey:Key;
		protected var holdTime:Number;
		
		public var selected:Boolean;
		protected var nextSelected:Boolean;
		protected var onSelect:Function;
		public var disabled:Boolean;
		
		public function MenuButton(X:int, Y:int, OnSelect:Function = null, Hotkey:Key = null) {
			super();
			
			x = X;
			y = Y;
			onSelect = OnSelect;
			hotkey = Hotkey;
			
			if (!highlightBorder)
				highlightBorder = new Point;
			init();
		}
		
		public function init():void {
			calculateGraphicLoc();
			createHighlight();
		}
		
		protected function calculateGraphicLoc():void {
			
		}
		
		protected function createHighlight():void {
			if (highlight) remove(highlight);
			var X:int = coreGraphic.x - highlightBorder.x;
			highlight = new FlxSprite(X, coreGraphic.y - highlightBorder.y);
			highlight.makeGraphic(coreGraphic.width + highlightBorder.x*2, coreGraphic.height + highlightBorder.y*2, 0x80ffffff);
			highlight.visible = selected;
			add(highlight);
		}
		
		public function select():void {
			nextSelected = true;
		}
		
		public function deselect():void {
			highlight.visible = selected = false;
		}
		
		override public function update():void {
			if (disabled)
				return;
			
			var lastMoused:Boolean = moused;
			moused = highlight.overlapsPoint(FlxG.mouse, true, camera);
			//if (!lastMoused && moused && onSelect != null)
				//C.sound.play(SEL_SOUND, 0.125);
			
			if (nextSelected) {
				selected = highlight.visible = true;
				nextSelected = false;
			}
			
			if (moused && FlxG.mouse.justPressed() && (!buttonClicked || !U.enforceButtonPriorities)) {
				buttonClicked = true;
				choose();
			} else if (!disabled && hotkey) {
				if (hotkey.justPressed()) {
					choose();
					holdTime = -REPEAT_TIME;
				} else if (hotkey.pressed()) {
					holdTime += FlxG.elapsed;
					if (holdTime >= REPEAT_TIME) {
						choose();
						holdTime -= REPEAT_TIME;
					}
				}
			}
		}
		
		protected function choose():void {
			if (onSelect != null) {
				if (fades)
					FlxG.fade(0xff000000, FADE_TIME, executeChoice);
				else
					executeChoice();
				//C.sound.playPersistent(choiceSound, 0.25);
			}
		}
		
		//protected function get choiceSound():Class {
			//return CHOOSE_SOUND;
		//}
		
		protected function executeChoice():void {
			if (callWithParam != null)
				onSelect(callWithParam);
			else
				onSelect();
		}
		
		public function get X():int {
			return highlight.x;
		}
		
		public function get Y():int {
			return highlight.y;
		}
		
		public function get fullWidth():int {
			return highlight.width;
		}
		
		public function get fullHeight():int {
			return highlight.height;
		}
		
		public function set Y(Y:int):void {
			highlight.y = y = Y;
			coreGraphic.y = Y + highlightBorder.y;
		}
		
		public function set X(X:int):void {
			highlight.x = x = X;
			coreGraphic.x = X + highlightBorder.x;
		}
		
		public function setParam(param:Object):MenuButton {
			callWithParam = param;
			return this;
		}
		
		public function setDisabled(disabled:Boolean):MenuButton {
			this.disabled = disabled;
			coreGraphic.color = disabled ? 0x606060 : graphicColor;
			return this;
		}
		
		public function setCamera(camera:FlxCamera):MenuButton {
			this.camera = camera;
			return this;
		}
		
		public function setSelected(Selected:Boolean):MenuButton {
			selected = Selected;
			return this;
		}
		
		
		override public function draw():void {
			highlight.visible = isHighlighted;
			super.draw();
		}
		
		protected function get isHighlighted():Boolean {
			return selected || (moused && !disabled);
		}
		
		protected function forceRender():void {
			super.draw();
		}
		
		public static var buttonClicked:Boolean;
		
		public static const FADE_TIME:Number = 0.27; //deep wisdom of the elder sages (trial & error)
		protected const REPEAT_TIME:Number = 0.25;
	}

}