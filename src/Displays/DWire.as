package Displays {
	import Components.Port;
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
		
		protected var sourcePoint:int = -1;
		protected var lastZoom:Number;
		
		public var selected:Boolean;
		
		protected var hSeg:FlxSprite;
		protected var vSeg:FlxSprite;
		protected var join:FlxSprite;
		protected var animationBlit:FlxSprite;
		
		public function DWire(wire:Wire) {
			this.wire = wire;
			buildSegs();
		}
		
		protected function buildSegs():void {
			var w:int = getWidth();
			hSeg = new FlxSprite().makeGraphic(U.GRID_DIM, w);
			vSeg = new FlxSprite().makeGraphic(w, U.GRID_DIM);
			hSeg.height = vSeg.width = w + 4;
			hSeg.offset.y = vSeg.offset.x = -2;
			join = new FlxSprite().makeGraphic(w + 4, w + 4);
			if (U.BLIT_ENABLED)
				animationBlit = new FlxSprite().makeGraphic(w, w);
			
			lastZoom = U.zoom;
		}
		
		protected function getWidth():int {
			return 2 / U.zoom;
		}
		
		override public function update():void {
			visible = wire.exists;
			super.update();
		}
		
		protected function iterWire(perform:Function, start:int = 0, end:int = C.INT_NULL):void {
			if (start == C.INT_NULL)
				start = 0;
			else start += 1;
			if (end == C.INT_NULL)
				end = wire.path.length;
			else end += 1;
			
			for (var i:int = start; i < end; i++) {
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
			
			iterWire(function drawWire(seg:FlxSprite):void {
				seg.draw();
			});
			
			if (U.BLIT_ENABLED && getBlitActive(segColor))
				drawBlit();
		}
		
		protected function drawBlit():void {
			var blitFraction:Number = (Math.floor(U.state.elapsed * BLIT_PERIOD * U.GRID_DIM) % U.GRID_DIM) / U.GRID_DIM;
			for (var i:int = 0; i < wire.path.length - 1; i++) {
				var p1:Point = wire.path[i];
				var p2:Point = wire.path[i + 1];
				if (i < sourcePoint) {
					p1 = wire.path[i + 1];
					p2 = wire.path[i];
				}
				
				animationBlit.x = (p1.x + (p2.x - p1.x) * blitFraction) * U.GRID_DIM -1;
				animationBlit.y = (p1.y + (p2.y - p1.y) * blitFraction) * U.GRID_DIM -1;
				animationBlit.draw();
			}
		}
		
		protected function getColor():uint {
			if (!wire.deployed)
				return U.DEFAULT_COLOR;
			
			if (!U.buttonManager.moused && U.state.viewMode == U.state.VIEW_MODE_NORMAL && overlapsPoint(U.mouseFlxLoc))
				return U.HIGHLIGHTED_COLOR;
			
			if (selected)
				return U.SELECTION_COLOR;
			
			if (wire.getSource() == null || wire.connections.length < 2)
				return U.UNCONNECTED_COLOR;
			
			var value:Value = wire.getSource().getValue();
			if (value.unknown)
				return U.UNKNOWN_COLOR;
			if (value.unpowered)
				return U.UNPOWERED_COLOR;
			return U.DEFAULT_COLOR;
		}
		
		protected function getBlitActive(c:uint):Boolean {
			return c == 0x0 && wire.getSource().getValue().toNumber() != 0; 
		}
		
		protected function checkZoom():void {
			if (U.zoom != lastZoom)
				buildSegs();
		}
		
		protected function drawJoin(current:Point):void {
			var carriersAt:Vector.<Carrier> = U.state.grid.carriersAtPoint(current);
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
		
		override public function overlaps(o:FlxBasic, _:Boolean=false, __:FlxCamera=null):Boolean {
			if (!wire.exists) return false;
			
			willOverlap = false;
			iterWire(function checkOverlap(seg:FlxSprite):void {
				willOverlap = willOverlap || seg.overlaps(o);
			});
			return willOverlap;
		}
		
		protected const BLIT_PERIOD:Number = 1;
	}

}