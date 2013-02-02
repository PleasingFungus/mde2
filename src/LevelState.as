package  {
	import org.flixel.*;
	import Actions.Action;
	import Modules.Module;
	import Values.Value;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelState extends FlxState {
		
		protected var tick:int;
		
		public var lowerLayer:FlxGroup;
		public var midLayer:FlxGroup;
		public var upperLayer:FlxGroup;
		public var zoom:Number;
		
		public var actionStack:Vector.<Action>;
		public var reactionStack:Vector.<Action>;
		
		public var time:Time;
		public var modules:Vector.<Module>;
		public var memory:Vector.<Value>;
		
		public var level:Level;
		public function LevelState(level:Level ) {
			this.level = level;
		}
		
		override public function create():void {
			initLayers();
			FlxG.bgColor = 0xffe0e0e0;
			FlxG.mouse.show();
			
			actionStack = new Vector.<Action>;
			reactionStack = new Vector.<Action>;
			
			time = new Time;
			zoom = 1;
		}
		
		protected function initLayers():void {
			FlxG.state.add(lowerLayer = new FlxGroup());
			FlxG.state.add(midLayer = new FlxGroup());
			FlxG.state.add(upperLayer = new FlxGroup());
		}
		
		//override public function update():void {
			//super.update();
			//checkControls();
			//checkExistence();
			//forceScroll();
			//
			//tick++;
			//
			//checkModeList();
		//}
		//
		//protected function forceScroll(group:FlxGroup = null):void {
			//group = group ? group : upperLayer;
			//for each (var basic:FlxBasic in group.members)
				//if (basic is FlxObject) {
					//var obj:FlxObject = basic as FlxObject;
					//obj.scrollFactor.x = obj.scrollFactor.y = 0;
				//} else if (basic is FlxGroup)
					//forceScroll(basic as FlxGroup);
		//}
	}

}