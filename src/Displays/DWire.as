package Displays {
	import flash.geom.Point;
	import org.flixel.*;
	import Components.Wire;
	import Components.Carrier;
	import Values.Value;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DWire extends FlxSprite {
		
		public var wire:Wire;
		
		private var hSeg:FlxSprite;
		private var vSeg:FlxSprite;
		private var join:FlxSprite;
		
		public function DWire(wire:Wire) {
			this.wire = wire;
			buildSegs();
		}
		
		protected function buildSegs():void {
			var w:int = 1 / U.state.zoom
			hSeg = new FlxSprite().makeGraphic(U.GRID_DIM, w);
			vSeg = new FlxSprite().makeGraphic(w, U.GRID_DIM);
			hSeg.height = vSeg.width = w + 4;
			hSeg.offset.y = vSeg.offset.x = -2;
			join = new FlxSprite().makeGraphic(w + 4, w + 4);
		}
		
		override public function update():void {
			visible = wire.exists;
			
			super.update();
		}
		
		protected function iterWire(perform:Function):void {
			for (var i:int = 0; i < wire.path.length; i++) {
				var next:Point, current:Point, last:Point;
				
				if (i) last = wire.path[i - 1]; else last = null;
				if (i < wire.path.length - 1) next = wire.path[i + 1] else next = null;
				current = wire.path[i];
				
				if (!last)
					continue;
				
				if (last.x != current.x) {
					hSeg.y = U.GRID_DIM * current.y - hSeg.height / 2;
					if (last.x < current.x)
						hSeg.x = U.GRID_DIM * last.x;
					else
						hSeg.x = U.GRID_DIM * current.x;
					perform(hSeg);
				} else {
					vSeg.x = U.GRID_DIM * current.x - vSeg.width / 2;
					if (last.y < current.y)
						vSeg.y = U.GRID_DIM * last.y;
					else
						vSeg.y = U.GRID_DIM * current.y;
					perform(vSeg);
				}
			}
		}
		
		override public function draw():void {
			checkZoom();
			
			var segColor:uint = getColor();
			hSeg.color = vSeg.color = join.color = segColor;
			hSeg.alpha = vSeg.alpha = join.alpha = wire.FIXED ? 0.5 : 1;
			
			drawJoin(wire.path[0]);
			drawJoin(wire.path[wire.path.length - 1]);
			iterWire(function drawWire(seg:FlxSprite):void {
				seg.draw();
			});
		}
		
		protected function getColor():uint {
			if (wire.getSource() == null || wire.connections.length < 2)
				return 0xff0000;
			
			var value:Value = wire.getSource().getValue();
			if (value.unknown)
				return 0xc219d9;
			if (value.unpowered)
				return 0x1d19d9;
			return 0x0;
		}
		
		private function checkZoom():void {
			if (hSeg.width != 1 / U.state.zoom)
				buildSegs();
		}
		
		private function drawJoin(current:Point):void {
			var carriersAt:Vector.<Carrier> = U.state.carriersAtPoint(current);
			if (!carriersAt || carriersAt.length < 2)
				return;
			
			for each (var carrier:Carrier in carriersAt)
				if (wire.connections.indexOf(carrier) != -1) {
					join.x = current.x * U.GRID_DIM - join.width / 2;
					join.y = current.y * U.GRID_DIM - join.height / 2;
					join.draw();
					break;
				}
		}
		
		protected var willOverlap:Boolean;
		override public function overlapsPoint(p:FlxPoint, _:Boolean=false, __:FlxCamera=null):Boolean {
			if (!wire.exists) return false;
			
			willOverlap = false;
			iterWire(function checkOverlap(seg:FlxSprite):void {
				willOverlap = willOverlap || seg.overlapsPoint(p);
			});
			return willOverlap;
		}
	}

}