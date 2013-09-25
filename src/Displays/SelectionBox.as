package Displays {
	import flash.geom.Point;
	import Components.Bloc;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class SelectionBox extends FlxSprite {
		
		private var clickPoint:Point;
		private var displayLinks:Vector.<DLink>;
		private var displayModules:Vector.<DModule>;
		public var displayBloc:DBloc;
		public function SelectionBox(DisplayLinks:Vector.<DLink>, DisplayModules:Vector.<DModule>) {
			clickPoint = U.mouseLoc;
			displayLinks = DisplayLinks;
			displayModules = DisplayModules;
			super(clickPoint.x, clickPoint.y);
			
			makeGraphic(1, 1, 0xffffffff);
			color = U.SELECTION_COLOR;
			alpha = 0.6;
		}
		
		override public function update():void {
			if (FlxG.mouse.pressed())
				updateArea();
			else {
				createSelection();
				exists = false;
			}
			super.update();
		}
		
		private function updateArea():void {
			var mouseLoc:Point = U.mouseLoc;
			scale.x = Math.abs(mouseLoc.x - clickPoint.x);
			scale.y = Math.abs(mouseLoc.y - clickPoint.y);
			x = Math.min(mouseLoc.x, clickPoint.x) + scale.x / 2;
			y = Math.min(mouseLoc.y, clickPoint.y) + scale.y / 2;
		}
		
		private function createSelection():void {
			var area:FlxBasic = new FlxObject(x - scale.x / 2, y - scale.y / 2, scale.x, scale.y);
			
			var links:Vector.<DLink> = new Vector.<DLink>;
			for each (var link:DLink in displayLinks)
				if (link.link.mouseable && !link.link.FIXED && link.overlaps(area))
					links.push(link);
			
			var modules:Vector.<DModule> = new Vector.<DModule>;
			for each (var module:DModule in displayModules)
				if (module.module.exists && !module.module.FIXED && module.overlaps(area))
					modules.push(module);
			
			if (modules.length || links.length)
				displayBloc = DBloc.fromDisplays(links, modules);
		}
	}

}