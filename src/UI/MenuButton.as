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
		protected var mouseTime:Number;
		protected var mouseoverText:FloatText;
		
		public var camera:FlxCamera;
		
		public var fades:Boolean;
		public var callWithParam:Object;
		public var tooltip:String;
		public var tooltipCallback:Function;
		public var hotkey:Key;
		protected var holdTime:Number;
		
		public var selected:Boolean;
		protected var nextSelected:Boolean;
		protected var onSelect:Function;
		public var disabled:Boolean;
		
		public var associatedObjects:Vector.<FlxBasic>;
		
		public function MenuButton(X:int, Y:int, OnSelect:Function = null, Tooltip:String = null, Hotkey:Key = null) {
			super();
			
			x = X;
			y = Y;
			onSelect = OnSelect;
			tooltip = Tooltip;
			hotkey = Hotkey;
			if (hotkey) {
				if (tooltip)
					tooltip += "\n";
				else
					tooltip = "";
				tooltip += "Hotkey: "+hotkey.key;
			}
			
			associatedObjects = new Vector.<FlxBasic>;
			
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
			moused = isMoused();
			if (moused && U.buttonManager)
				U.buttonManager.moused = true;
			if (moused)
				if (!lastMoused)
					mouseTime = FlxG.elapsed;
				else
					mouseTime += FlxG.elapsed;
			updateMouseover();
				
			//if (!lastMoused && moused && onSelect != null)
				//C.sound.play(SEL_SOUND, 0.125);
			
			if (nextSelected) {
				selected = highlight.visible = true;
				nextSelected = false;
			}
			
			if (moused && FlxG.mouse.justPressed()) {
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
			
			for each (var obj:FlxBasic in associatedObjects)
				if (obj.exists && obj.active)
					obj.update();
		}
		
		protected function isMoused():Boolean {
			return highlight.overlapsPoint(FlxG.mouse, true, camera) && (!U.buttonManager || !U.buttonManager.moused);
		}
		
		protected function updateMouseover():void {
			if (!tooltip && tooltipCallback == null)
				return;
			
			var mouseoverVisible:Boolean = moused && mouseTime >= MOUSEOVER_TIME;
			if (!mouseoverVisible) {
				if (mouseoverText)
					mouseoverText.visible = false;
				return;
			}
			
			if (!mouseoverText)
				associatedObjects.push(
					mouseoverText = new FloatText(U.LABEL_FONT.configureFlxText(new FlxText( -1, -1, FlxG.width / 2 - 20, tooltip)))
				);
			if (tooltipCallback != null && tooltip != tooltipCallback()) {
				tooltip = tooltipCallback();
				mouseoverText.text.text = tooltip;
			}
			
			//var adjMouse:FlxPoint = new FlxPoint(FlxG.mouse.x + FlxG.camera.scroll.x * (coreGraphic.scrollFactor.x - 1), 
												 //FlxG.mouse.y + FlxG.camera.scroll.y * (coreGraphic.scrollFactor.y - 1));
			mouseoverText.x = FlxG.mouse.x - FlxG.camera.scroll.x - mouseoverText.width - 5;
			if (mouseoverText.x < 5)
				mouseoverText.x = FlxG.mouse.x - FlxG.camera.scroll.x + 20;
				
			mouseoverText.y = FlxG.mouse.y - FlxG.camera.scroll.y - mouseoverText.height;
			if (mouseoverText.y < 5)
				mouseoverText.y = FlxG.mouse.y - FlxG.camera.scroll.y + 28;
			
			mouseoverText.visible = true;
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
		
		public function setTooltipCallback(callback:Function):MenuButton {
			tooltipCallback = callback;
			return this;
		}
		
		public function setScroll(factor:int):MenuButton {
			coreGraphic.scrollFactor.x = coreGraphic.scrollFactor.y = factor;
			highlight.scrollFactor.x = highlight.scrollFactor.y = factor;
			return this;
		}
		
		
		override public function draw():void {
			highlight.visible = isHighlighted;
			super.draw();
		}
		
		override public function postDraw():void {
			super.postDraw();
			for each (var obj:FlxBasic in associatedObjects)
				if (obj.exists && obj.visible)
					obj.draw();
		}
		
		protected function get isHighlighted():Boolean {
			return selected || (moused && !disabled);
		}
		
		protected function forceRender():void {
			super.draw();
		}
		
		public static const FADE_TIME:Number = 0.27; //deep wisdom of the elder sages (trial & error)
		protected const REPEAT_TIME:Number = 0.25;
		protected const MOUSEOVER_TIME:Number = 0.5;
	}

}