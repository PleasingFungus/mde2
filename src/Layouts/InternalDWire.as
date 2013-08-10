package Layouts {
	import Components.Wire;
	import Displays.DWire;
	import flash.geom.Rectangle;
	import Values.Value;
	import org.flixel.*;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalDWire extends DWire {
		
		protected var lastDashed:Boolean;
		
		protected var cachedPotentiallyBlockedLines:Vector.<FlxSprite>;
		
		public function InternalDWire(wire:InternalWire) {
			super(wire);
			if (wire.path.length > 1)
				buildCache();
		}
		
		override protected function buildSegs():void {
			var iWire:InternalWire = wire as InternalWire;
			
			if (iWire.dashed) //assumes a wire is always dashed or never dashed
				buildDashedSegs();
			else
				super.buildSegs();
		}
		
		private function buildDashedSegs():void {
			var w:int = getWidth();
			var cached:Boolean = FlxG.checkBitmapCache("hcontrolwire-"+w);
			hSeg = new FlxSprite().makeGraphic(U.GRID_DIM, w, 0xffffffff, true, "hcontrolwire-"+w);
			vSeg = new FlxSprite().makeGraphic(w, U.GRID_DIM, 0xffffffff, true, "vcontrolwire-"+w);
			
			if (!cached) {
				var dashLength:Number = U.GRID_DIM / 5;
				hSeg.pixels.fillRect(new Rectangle(dashLength, 0, dashLength, w), 0x0);
				hSeg.pixels.fillRect(new Rectangle(Math.ceil(dashLength * 3), 0, dashLength, w), 0x0);
				vSeg.pixels.fillRect(new Rectangle(0, dashLength, w, dashLength), 0x0);
				vSeg.pixels.fillRect(new Rectangle(0, Math.ceil(dashLength * 3), w, dashLength), 0x0);
				hSeg.frame = vSeg.frame = 0;
			}
			
			hSeg.height = vSeg.width = w + 4;
			hSeg.offset.y = vSeg.offset.x = -2;
			
			join = new FlxSprite; //currently unused
			
			lastZoom = U.zoom;
		}
		
		override protected function canBuildCache():Boolean {
			return cachesThisFrame < MAX_CACHES_PER_FRAME;
		}
		
		override public function outsideScreen():Boolean {
			return false; //if it's inside a module that's being drawn, it's inside the screen
		}
		
		override protected function buildCache():void {
			cachedPotentiallyBlockedLines = new Vector.<FlxSprite>;
			super.buildCache();
		}
		
		override protected function breakSublineAt(end:int, delta:Point, lastDelta:Point):Boolean {
			var iWire:InternalWire = wire as InternalWire;
			if (iWire.controlPointIndex == end)
				return true;
			return super.breakSublineAt(end, delta, lastDelta);
		}
		
		override protected function cacheSubline(start:int, end:int):void {
			var iWire:InternalWire = wire as InternalWire;
			if ((!iWire.truncatedByControlWireFromEnd && start >= iWire.controlPointIndex) || 
				(iWire.truncatedByControlWireFromEnd && end <= iWire.controlPointIndex))
				cachedPotentiallyBlockedLines.push(buildSubline(wire.path.slice(start, end+1)));
			else
				super.cacheSubline(start, end);
		}
		
		override protected function shiftSublines(delta:Point):void {
			super.shiftSublines(delta);
			for each (var cachedLine:FlxSprite in cachedPotentiallyBlockedLines) {
				cachedLine.x += delta.x * U.GRID_DIM;
				cachedLine.y += delta.y * U.GRID_DIM;
			}
		}
		
		override protected function drawCached():void {
			super.drawCached();
			var iWire:InternalWire = wire as InternalWire;
			if (iWire.controlTruncated)
				return;
			
			var segColor:uint = getColor();
			for each (var cachedLine:FlxSprite in cachedPotentiallyBlockedLines) {
				cachedLine.color = segColor;
				cachedLine.draw();
			}
		}
		
		override protected function drawDynamic():void {
			var iWire:InternalWire = wire as InternalWire;
			if (!iWire.exists)	
				return;
			
			checkZoom();
			
			var segColor:uint = getColor();
			hSeg.color = vSeg.color = join.color = segColor;
			
			if (iWire.dashed)
				iterWire(function drawWire(seg:FlxSprite):void {
					seg.draw();
				});
			else {			
				var start:int = 0;
				var end:int = iWire.path.length - 1;
				if (iWire.controlTruncated) {
					if (iWire.truncatedByControlWireFromEnd)
						start = iWire.controlPointIndex;
					else
						end = iWire.controlPointIndex; 
				}
				
				iterWire(function drawWire(seg:FlxSprite):void {
					seg.draw();
				}, start, end);
			}
		}
		
		override protected function getColor():uint {
			var iWire:InternalWire = wire as InternalWire;
			
			if (!iWire.getConnected())
				return U.UNCONNECTED_COLOR;
			
			var value:Value = iWire.getValue();
			if (value.unknown)
				return U.UNKNOWN_COLOR;
			if (value.unpowered)
				return U.UNPOWERED_COLOR;
			return U.DEFAULT_COLOR;
		}
		
		override protected function getBlitActive(c:uint):Boolean {
			return !lastDashed && c == 0x0 && (wire as InternalWire).getValue().toNumber() != 0; 
		}
		
		override protected function drawBlit():void {
			return;
			//var blitFraction:Number = (Math.floor(U.state.elapsed * BLIT_PERIOD * U.GRID_DIM) % U.GRID_DIM) / U.GRID_DIM;
			//for (var i:int = 0; i < wire.path.length - 1; i++) {
				//var p1:Point = wire.path[i];
				//var p2:Point = wire.path[i + 1];
				//if (i < sourcePoint) {
					//p1 = wire.path[i + 1];
					//p2 = wire.path[i];
				//}
				//
				//animationBlit.x = (p1.x + (p2.x - p1.x) * blitFraction) * U.GRID_DIM -1;
				//animationBlit.y = (p1.y + (p2.y - p1.y) * blitFraction) * U.GRID_DIM -1;
				//animationBlit.draw();
			//}
		}
	}

}