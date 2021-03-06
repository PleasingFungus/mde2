package Infoboxes {
	import org.flixel.*;
	import Controls.ControlSet;
	import Testing.Goals.GeneratedGoal;
	import UI.FloatText;
	import UI.MenuButton;
	import UI.GraphicButton;
	import UI.TextTooltipParasite;
	import Values.FixedValue;
	import Values.InstructionValue;
	import Values.Value;
	import Controls.Key;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DMemory extends Infobox {
		
		private var moment:int;
		private var displayComments:Boolean;
		
		public var memory:Vector.<Value>;
		public var expectedMemory:Vector.<Value>;
		public function DMemory(Memory:Vector.<Value>, ExpectedMemory:Vector.<Value> = null) {
			memory = Memory;
			expectedMemory = ExpectedMemory;
			displayComments = U.state.viewingComments;
			super();
		}
		
		override protected function init():void {
			if (commentButton)
				commentButton.exists = false;
			if (randomButton)
				randomButton.exists = false;
			
			super.init();
			
			moment = U.state.time.moment;
			
			if (U.state.level.commentsEnabled)
				makeCommentButton();
			if (U.state.level.goal.randomizedMemory && U.state.editEnabled)
				makeRandomButton();
			
			addTimeText();
			addMemoryLines();
			nilScroll();
		}
		
		protected function addTimeText():void {
			var timeString:String = "Allowed ticks total: " + U.state.level.goal.timeLimit;
			if (FlxG.debug && U.state.level.goal is GeneratedGoal)
				timeString += " (over " + (U.state.level.goal.timeLimit / (U.state.level.goal as GeneratedGoal).allowedTimePerInstr) + " expected instruction executions)";
			timeString += ".";
			var timeText:FlxText = U.BODY_FONT.configureFlxText(new FlxText(bg.x, bg.y + bg.height + 2, bg.width, timeString), 0xffffff, 'center', 0x1);
			add(timeText);
		}
		
		protected function addMemoryLines():void {
			var LINE_NO_START:int = bg.x + INNER_BORDER;
			var COL_1_START:int = bg.x + INNER_BORDER * 2;
			var COL_2_START:int = bg.x + INNER_BORDER * 4 + COL_WIDTH;
			var TITLE_SPACING:int = 20;
			
			var Y:int = bg.y + INNER_BORDER;
			add(U.BODY_FONT.configureFlxText(new FlxText(LINE_NO_START, Y + 10, 60,
															  "Line"), U.LINE_NUM.color, 'left'));
			add(U.BODY_FONT.configureFlxText(new FlxText(COL_1_START, Y, COL_WIDTH,
															  U.state.editEnabled ? "Example Memory" : "Current Memory"), 0xffffff, 'center'));
			add(U.BODY_FONT.configureFlxText(new FlxText(COL_2_START, Y, COL_WIDTH - TITLE_SPACING,
															  "Expected Memory"), 0xffffff, 'center'));
			
			Y += ROW_HEIGHT * 2;
			setPageTop(Y);
			
			var skip:Boolean = true;
			Y -= ROW_HEIGHT * 1.5; //dumb hack for first line
			for (var memLine:int = 0; memLine < memory.length; memLine++) {
				var memValue:Value = memory[memLine];
				var expValue:Value = expectedMemory[memLine];
				var comment:String = (memValue is InstructionValue) ? (memValue as InstructionValue).comment : null;
				
				if (memValue != FixedValue.NULL || expValue != FixedValue.NULL) {
					if (skip) {
						page.add(U.BODY_FONT.configureFlxText(new FlxText(COL_1_START, Y, COL_WIDTH, "---"), 0xffffff, 'right' ));
						page.add(U.BODY_FONT.configureFlxText(new FlxText(COL_2_START, Y, COL_WIDTH, "---")));
						Y += ROW_HEIGHT * 1.5;
					}
					skip = false;
					
					page.add(U.BODY_FONT.configureFlxText(new FlxText(LINE_NO_START, Y, COL_WIDTH, memLine + "."), U.LINE_NUM.color));
					addMemText(memValue, COL_1_START, Y, 'right');
					
					if (displayComments) {
						if (comment && (memValue as InstructionValue).commentFormat) {
							page.add(U.BODY_FONT.configureFlxText((memValue as InstructionValue).commentFormat.makeHighlightText(COL_2_START, Y, COL_WIDTH),
																  0xffffff));
						} else {
							comment = comment ? comment : "---";
							page.add(U.BODY_FONT.configureFlxText(new FlxText(COL_2_START, Y, COL_WIDTH, comment)));
						}
					} else
						addMemText(expValue, COL_2_START, Y);
					Y += ROW_HEIGHT * 1.5;
				} else
					skip = true;
			}
		}
		
		private function addMemText(value:Value, X:int, Y:int, Align:String = 'left'):void {
			var text:FlxText = makeTextFor(value, X, Y, Align);
			page.add(text);
			if (!(value is InstructionValue))
				return;
			
			var tooltip:FlxText = (value as InstructionValue).operation.highlitDescription.makeHighlightText(X, Y, COL_WIDTH);
			U.BODY_FONT.configureFlxText(tooltip);
			var floatingTooltip:FloatText = new FloatText(tooltip);
			floatingTooltip.alpha = 0.9;
			add(new TextTooltipParasite(text, floatingTooltip));
			add(floatingTooltip);
		}
		
		private function makeTextFor(value:Value, X:int, Y:int, Align:String = 'left'):FlxText {
			if (value != FixedValue.NULL && value.toFormat()) {
				return U.BODY_FONT.configureFlxText(value.toFormat().makeHighlightText(X, Y, COL_WIDTH), 0xffffff, Align);
			} else {
				var valueText:String = value != FixedValue.NULL ? value.toString() : "---";
				return U.BODY_FONT.configureFlxText(new FlxText(X, Y, COL_WIDTH, valueText), 0xffffff, Align);
			}
		}
		
		private var commentButton:GraphicButton;
		protected function makeCommentButton():void {
			var kludge:DMemory = this;
			add(commentButton = new GraphicButton(bg.x + INNER_BORDER + bg.width / 2 - 16, bg.y + INNER_BORDER,
								  displayComments ? _code_sprite : _comment_sprite, function comment():void {
									  U.state.viewingComments = kludge.displayComments = !kludge.displayComments;
									  
									  var scroll:Number = scrollbar.scrollFraction;				
										scrollbar.scrollFraction = 0;
										checkScroll();
									  
									  init();	
									  
										scrollbar.scrollFraction = scroll;
										checkScroll();
									},
								  displayComments ? "View expected memory" : "View instruction info", new Key("C")));
			commentButton.setScroll(0);
		}
		
		private var randomButton:MenuButton;
		protected function makeRandomButton():void {
			var kludge:DMemory = this;
			randomButton = new GraphicButton(bg.x + INNER_BORDER + bg.width / 2 - 16 - 38, bg.y + INNER_BORDER, _random_sprite, function _():void {
				U.state.initialMemory = U.state.level.goal.genMem();
				memory = U.state.memory = U.state.initialMemory.slice();
				expectedMemory = U.state.level.goal.genExpectedMem();
				
				scrollbar.scrollFraction = 0;
				checkScroll();
				
				init();
			}, "Generate new example memory", new Key("R")).setScroll(0);
			add(randomButton);
		}
		
		
		
		private const COL_WIDTH:int = 255;
		private const ROW_HEIGHT:int = 20;
		
		[Embed(source = "../../lib/art/ui/info.png")] private const _comment_sprite:Class;
		[Embed(source = "../../lib/art/ui/code.png")] private const _code_sprite:Class;
		[Embed(source = "../../lib/art/ui/random.png")] private const _random_sprite:Class;
		
	}

}