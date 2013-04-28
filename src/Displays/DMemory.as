package Displays {
	import org.flixel.*;
	import Controls.ControlSet;
	import Testing.Goals.GeneratedGoal;
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
			setPageTop(Y);
			
			var skip:Boolean = false;
			for (var memLine:int = 0; memLine < memory.length; memLine++) {
				var memValue:Value = memory[memLine];
				var expValue:Value = expectedMemory[memLine];
				
				if (memValue != FixedValue.NULL || expValue != FixedValue.NULL) {
					if (skip)
						Y += ROW_HEIGHT * 1.5;
					skip = false;
					
					page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER, Y, COL_WIDTH, memLine + ".")));
					
					var memValText:String = memValue != FixedValue.NULL ? memValue.toString() : "---";
					page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 2, Y, COL_WIDTH, memValText), 0xffffff, 'right' ));
					
					var expValText:String = expValue != FixedValue.NULL ? expValue.toString() : "---";
					page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 4 + COL_WIDTH, Y, COL_WIDTH, expValText)));
					Y += ROW_HEIGHT * 1.5;
				} else {
					if (!skip) {
						page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 2, Y, COL_WIDTH, "---"), 0xffffff, 'right' ));
						page.add(U.BODY_FONT.configureFlxText(new FlxText(bg.x + INNER_BORDER * 4 + COL_WIDTH, Y, COL_WIDTH, "---")));
					}
						
					skip = true;
				}
			}
			
			var timeString:String = "Allowed ticks total: " + U.state.level.goal.timeLimit;
			if (U.state.level.goal is GeneratedGoal)
				timeString += " (over " + (U.state.level.goal.timeLimit / (U.state.level.goal as GeneratedGoal).allowedTimePerInstr) + " expected instruction executions)";
			timeString += ".";
			var timeText:FlxText = U.BODY_FONT.configureFlxText(new FlxText(bg.x, bg.y + bg.height + 2, bg.width, timeString), 0xffffff, 'center', 0x1);
			add(timeText);
		}
		
	}

}