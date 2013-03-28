package Displays {
	import org.flixel.*;
	import Controls.ControlSet;
	import UI.MenuButton;
	import Values.FixedValue;
	import Values.Value;
	import UI.GraphicButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DMemory extends FlxGroup {
		
		private var bg:FlxSprite;
		private var moment:int;
		
		public var memory:Vector.<Value>;
		public var expectedMemory:Vector.<Value>;
		
		private var pages:Vector.<FlxGroup>;
		private var page:int;
		private var forwardButton:GraphicButton;
		private var backButton:GraphicButton;
		public function DMemory(Memory:Vector.<Value>, ExpectedMemory:Vector.<Value> = null) {
			memory = Memory;
			expectedMemory = ExpectedMemory;
			super();
			init();
		}
		
		public function init():void {
			moment = U.state.time.moment;
			makeBG();
			makePages();
			makeButtons();
		}
		
		protected function makeBG():void {
			var shade:FlxSprite = new FlxSprite;
			shade.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
			shade.alpha = 0.4;
			add(shade);
			
			var width:int = FlxG.width * WIDTH_FRACTION;
			var height:int = FlxG.height * HEIGHT_FRACTION;
			bg = new FlxSprite((FlxG.width - width) / 2, (FlxG.height - height) / 2).makeGraphic(width, height, 0xff202020);
			var raisedBorderWidth:int = 2;
			
			var light:FlxSprite = new FlxSprite().makeGraphic(width - raisedBorderWidth * 2, height - raisedBorderWidth * 2, 0xff666666)
			bg.stamp(light, raisedBorderWidth, raisedBorderWidth);
			
			var innerDark:FlxSprite = new FlxSprite().makeGraphic(width - raisedBorderWidth * 4, height - raisedBorderWidth * 4, 0xff202020)
			bg.stamp(innerDark, raisedBorderWidth * 2, raisedBorderWidth * 2);
			
			add(bg);
		}
		
		protected function makePages():void {
			pages = new Vector.<FlxGroup>;
			pages.push(add(makeMemoryPage(memory, "Current Memory")));
			if (expectedMemory)
				pages.push(add(makeMemoryPage(expectedMemory, "Expected Memory")));
		}
		
		protected function makeMemoryPage(memory:Vector.<Value>, pageName:String):FlxGroup {
			var BORDER:int = 10;
			var COL_WIDTH:int = 225;
			var COL_HEIGHT:int = bg.height - BORDER * 2;
			var ROW_HEIGHT:int = 20;
			var ROWS:int = COL_HEIGHT / (ROW_HEIGHT + BORDER / 2);
			var COLS:int = (bg.width - BORDER * 2) / (COL_WIDTH + BORDER);
			
			var memoryPage:FlxGroup = new FlxGroup;
			
			var row:int, col:int, skipped:Boolean;
			for (var memLine:int = 0; memLine < memory.length; memLine++) {
				var memValue:Value = memory[memLine];
				
				var hadSkipped:Boolean = skipped;
				skipped = !memValue || memValue == FixedValue.NULL;
				if (skipped && hadSkipped)
					continue;
				
				var text:String = skipped ? "<empty memory...>" : memLine + " : " + memValue;
				var memText:FlxText = new FlxText(bg.x + BORDER + col * (COL_WIDTH + BORDER),
												  bg.y + BORDER + row * (ROW_HEIGHT + BORDER / 2),
												  COL_WIDTH, text)
				memoryPage.add(U.BODY_FONT.configureFlxText(memText));
				
				row += 1;
				if (row >= ROWS) {
					row = 0;
					col += 1;
				}
			}
			//TODO: multiple pages of actual memory
			
			memoryPage.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + bg.width / 2, bg.y + bg.height - 40, bg.width / 2, pageName), 0xffffff, 'center'));
			
			return memoryPage;
		}
		
		protected function makeButtons():void {
			var kludge:DMemory = this;
			add(new GraphicButton(bg.x + bg.width / 2 - 16, bg.y + bg.height - 48, _close_sprite, function close():void { kludge.exists = false } ))
			add(forwardButton = new GraphicButton(bg.x + bg.width - 48, bg.y + bg.height - 48, _forward_sprite, function forward():void { kludge.page++; } ));
			add(backButton = new GraphicButton(bg.x + 16, bg.y + bg.height - 48, _back_sprite, function back():void { kludge.page--; } ));
		}
		
		private var tick:int;
		
		override public function update():void {
			super.update();
			U.buttonManager.moused = true;
			checkTime();
			checkPages();
			checkClick();
			checkControls();
			tick++;
		}
		
		protected function checkPages():void {
			for (var page:int = 0; page < pages.length; page++)
				pages[page].exists = page == this.page;
			forwardButton.exists = this.page < pages.length - 1;
			backButton.exists = this.page > 0;
		}
		
		protected function checkClick():void {
			if (tick && FlxG.mouse.justPressed() && !bg.overlapsPoint(FlxG.mouse, true))
				exists = false;
		}
		
		protected function checkControls():void {
			if (ControlSet.CANCEL_KEY.justPressed())
				exists = false;
		}
		
		protected function checkTime():void {
			if (moment != U.state.time.moment)
				init(); //NOTE: interacts poorly with anything that resets memory
		}
		
		private const WIDTH_FRACTION:Number = 3 / 4;
		private const HEIGHT_FRACTION:Number = 3 / 4;
		
		[Embed(source = "../../lib/art/ui/close.png")] private const _close_sprite:Class;
		[Embed(source = "../../lib/art/ui/forward.png")] private const _forward_sprite:Class;
		[Embed(source = "../../lib/art/ui/back_w.png")] private const _back_sprite:Class;
		
	}

}