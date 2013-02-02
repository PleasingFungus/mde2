package Displays {
	import Modules.Module;
	import org.flixel.*;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DObjective extends FlxText {
		
		public var objective:Objective;
		public function DObjective(Objective_:Objective) {
			objective = Objective_;
			super(0, FlxG.height - 10, FlxG.width, objective.description);
			setFormat(U.FONT, 16, 0x0, 'center');
			y -= height;
		}
		
		override public function update():void {
			super.update();
			if (objective.validator(objective.referent))
				FlxG.switchState(new WinState);
		}
	}

}