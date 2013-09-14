package Infoboxes {
	import org.flixel.*;
	import Testing.Goals.GeneratedGoal;
	import UI.GraphicButton;
	import UI.HighlightText;
	import UI.MenuButton;
	import Controls.ControlSet;
	import Levels.Level;
	import Values.OpcodeValue;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DGoal extends Infobox {
		
		public var level:Level;
		private var title:FlxText;
		public function DGoal(level:Level) {
			this.level = level;
			super();
		}
		
		override protected function init():void {
			super.init();
			
			var X:int = bg.x + INNER_BORDER;
			var Y:int = bg.y + RAISED_BORDER_WIDTH * 3;
			var Width:int = bg.width - INNER_BORDER * 2 - 48/2;
			title = new FlxText(X, Y, Width, level.displayName);
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			Y += title.height + 8;
			add(title);
			
			setPageTop(Y);
			
			var addBodyText:Function = function addBodyText(text:String):void {
				var bodyText:FlxText = new FlxText(X, Y, Width, text);
				U.BODY_FONT.configureFlxText(bodyText);
				Y += bodyText.height + 8;
				page.add(bodyText);
			}
			
			addBodyText("GOAL: " + level.goal.description)
			
			var specialInfo:Vector.<FlxSprite> = level.specialInfo();
			if (specialInfo)
				for each (var infosprite:FlxSprite in specialInfo) {
					infosprite.x = X;
					infosprite.y = Y;
					page.add(infosprite);
					Y += infosprite.height + 8;
				}
			
			if (level.info)
				addBodyText((specialInfo ? "" : "INFO: ") + level.info);
			if (level.hints) {
				//TODO
			}
			
			if (level.expectedOps.length) {
				addBodyText("\nOps to support:");
				
				for each (var op:OpcodeValue in level.expectedOps) {
					var highlitText:HighlightText = op.highlitDescription.makeHighlightText(X, Y, Width);
					U.BODY_FONT.configureFlxText(highlitText);
					Y += highlitText.height + 8;
					page.add(highlitText);
				}
			}
			
			if (level.delay)
				addBodyText("Propagation delay enabled.");
			if (!level.canDrawWires)
				addBodyText("Wire-drawing disabled.");
			if (!level.canPickupModules)
				addBodyText("Normal module pickup disabled.");
			if (level.goal is GeneratedGoal) {
				var generatedGoal:GeneratedGoal = level.goal as GeneratedGoal;
				addBodyText("Testing: " + generatedGoal.testRuns + " random programs, time limit of " + generatedGoal.allowedTimePerInstr + " ticks per instruction");
			}
			if (level.writerLimit)
				addBodyText("Number of data writers allowed: " + level.writerLimit);
			
			nilScroll();
		}

	}

}