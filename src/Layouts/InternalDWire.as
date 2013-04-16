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
		protected var altHSeg:FlxSprite;
		protected var altVSeg:FlxSprite;
		protected var blockage:FlxSprite;
		
		protected var cachedPotentiallyBlockedLines:Vector.<FlxSprite>;
		
		public function InternalDWire(wire:InternalWire) {
			super(wire);
		}
		
		override protected function buildSegs():void {
			var iWire:InternalWire = wire as InternalWire;
			
			super.buildSegs();
			
			var w:int = getWidth();
			var cached:Boolean = FlxG.checkBitmapCache("hcontrolwire-"+w);
			altHSeg = new FlxSprite().makeGraphic(U.GRID_DIM, w, 0xffffffff, true, "hcontrolwire-"+w);
			altVSeg = new FlxSprite().makeGraphic(w, U.GRID_DIM, 0xffffffff, true, "vcontrolwire-"+w);
			blockage = new FlxSprite().makeGraphic(join.width, join.height, 0xffff0000, true, "blockage-"+w);
			
			if (!cached) {
				var dashLength:Number = U.GRID_DIM / 5;
				altHSeg.pixels.fillRect(new Rectangle(dashLength, 0, dashLength, w), 0x0);
				altHSeg.pixels.fillRect(new Rectangle(Math.ceil(dashLength * 3), 0, dashLength, w), 0x0);
				altVSeg.pixels.fillRect(new Rectangle(0, dashLength, w, dashLength), 0x0);
				altVSeg.pixels.fillRect(new Rectangle(0, Math.ceil(dashLength * 3), w, dashLength), 0x0);
				//blockage.pixels.fillRect(new Rectangle(w, w, blockage.width - w * 2, blockage.height - w * 2), 0xff000000);
				altHSeg.frame = altVSeg.frame = blockage.frame = 0;
			}
			
			altHSeg.height = altVSeg.width = w + 4;
			altHSeg.offset.y = altVSeg.offset.x = -2;
		}
		
		override public function draw():void {
			var iWire:InternalWire = wire as InternalWire;
			
			checkZoom();
			
			var segColor:uint = getColor();
			hSeg.color = vSeg.color = altHSeg.color = altVSeg.color = join.color = segColor;
			
			if (iWire.dashed) {
				var oHSeg:FlxSprite = hSeg;
				var oVSeg:FlxSprite = vSeg;
				hSeg = altHSeg;
				vSeg = altVSeg;
				
				iterWire(function drawWire(seg:FlxSprite):void {
					seg.draw();
				});
			
				hSeg = oHSeg;
				vSeg = oVSeg;
			} else {			
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
		
		override protected function drawCached():void {
			var cachedLine:FlxSprite;
			
			if (!wire.path[0].equals(cachedLoc)) {
				var delta:Point = wire.path[0].subtract(cachedLoc);
				for each (var lineList:Vector.<FlxSprite> in [cachedLines, cachedPotentiallyBlockedLines])
					for each (cachedLine in lineList) {
						cachedLine.x += delta.x * U.GRID_DIM;
						cachedLine.y += delta.y * U.GRID_DIM;
					}
				cachedLoc = wire.path[0].clone();
			}
			
			var iWire:InternalWire = wire as InternalWire;
			var segColor:uint = getColor();
			
			//TODO:
				//draw...
			//if (iWire.fullControl
			//for each (cachedLine in cachedLines) {
				//cachedLine.color = segColor;
				//cachedLine.draw();
			//}
			
			join.color = segColor;
			drawJoins();
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