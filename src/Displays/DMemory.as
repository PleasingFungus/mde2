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
	public class DMemory extends Infobox {
		
		private var moment:int;
		
		public var memory:Vector.<Value>;
		public var expectedMemory:Vector.<Value>;
		public function DMemory(Memory:Vector.<Value>, ExpectedMemory:Vector.<Value> = null) {
			memory = Memory;
			expectedMemory = ExpectedMemory;
			super();
		}
		
		override protected function init():void {
			super.init();
			moment = U.state.time.moment;
			
			var COL_WIDTH:int = 225;
			var ROW_HEIGHT:int = 20;
			
			var Y:int = bg.y + INNER_BORDER;
			add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 2, Y, COL_WIDTH,
															  "Current Memory"), 0xffffff, 'center'));
			add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 2 + COL_WIDTH, Y, COL_WIDTH,
															  "Expected Memory"), 0xffffff, 'center'));
			
			Y += ROW_HEIGHT * 2;
			pageTop = Y;
			
			var skip:Boolean = false;
			for (var memLine:int = 0; memLine < memory.length; memLine++) {
				var memValue:Value = memory[memLine];
				var expValue:Value = expectedMemory[memLine];
				
				if (memValue != FixedValue.NULL || expValue != FixedValue.NULL) {
					if (skip)
						Y += ROW_HEIGHT;
					skip = false;
					
					page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER, Y, COL_WIDTH, memLine+".")));
					if (memValue != FixedValue.NULL)
						page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 2, Y, COL_WIDTH, memValue.toString()), 0xffffff, 'right' ));
					if (expValue != FixedValue.NULL)
						page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 4 + COL_WIDTH, Y, COL_WIDTH, expValue.toString())));
					Y += ROW_HEIGHT * 1.5;
				} else
					skip = true;
			}
		}
		
	}

}