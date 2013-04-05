package Displays {
	import org.flixel.*;
	import Testing.Goals.GeneratedGoal;
	import UI.GraphicButton;
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
			
			var X:int = bg.x + RAISED_BORDER_WIDTH * 3 + 6;
			var Y:int = bg.y + RAISED_BORDER_WIDTH * 3;
			var Width:int = bg.width - RAISED_BORDER_WIDTH * 6 - 12 - 24;
			title = new FlxText(X, Y, Width, level.name);
			U.TITLE_FONT.configureFlxText(title, 0xffffff, 'center');
			Y += title.height + 8;
			add(title);
			
			var addBodyText:Function = function addBodyText(text:String):void {
				var bodyText:FlxText = new FlxText(X, Y, Width, text);
				U.BODY_FONT.configureFlxText(bodyText);
				Y += bodyText.height + 8;
				page.add(bodyText);
			}
			
			for each (var paragraph:String in level.goal.description.split('\n'))
				if (paragraph.length)
					addBodyText(paragraph);
			
			if (level.expectedOps.length) {
				addBodyText("\nOps to support:");
				
				for each (var op:OpcodeValue in level.expectedOps) {
					var optext:String = op.toString();
					if (op.description)
						optext += ": " + op.description;
					addBodyText(optext);
				}
			}
			
			if (level.delay)
				addBodyText("\nPropagation delay enabled.");
			if (level.goal is GeneratedGoal)
				addBodyText("\nTesting: " + (level.goal as GeneratedGoal).testRuns + " random programs, time limit of " + level.goal.timeLimit + " cycles per test");
		}
		
		override protected function setVisible(o:FlxObject):void {
			o.visible = o.y > title.y + title.height + 2 && o.y + o.height < bg.y + bg.height - RAISED_BORDER_WIDTH * 3;
		}
	}

}