package Layouts {
	import Components.Wire;
	import Displays.DWire;
	import flash.geom.Rectangle;
	import Values.Value;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class InternalDWire extends DWire {
		
		protected var lastDashed:Boolean;
		protected var altHSeg:FlxSprite;
		protected var altVSeg:FlxSprite;
		public function InternalDWire(wire:InternalWire) {
			super(wire);
		}
		
		override protected function buildSegs():void {
			var iWire:InternalWire = wire as InternalWire;
			
			super.buildSegs();
			
			var w:int = 1 / U.state.zoom;
			var cached:Boolean = FlxG.checkBitmapCache("hcontrolwire-"+w);
			altHSeg = new FlxSprite().makeGraphic(U.GRID_DIM, w, 0xffffffff, true, "hcontrolwire-"+w);
			altVSeg = new FlxSprite().makeGraphic(w, U.GRID_DIM, 0xffffffff, true, "vcontrolwire-"+w);
			
			if (!cached) {
				var dashLength:Number = U.GRID_DIM / 5;
				altHSeg.pixels.fillRect(new Rectangle(dashLength, 0, dashLength, w), 0x0);
				altHSeg.pixels.fillRect(new Rectangle(Math.ceil(dashLength * 3), 0, dashLength, w), 0x0);
				altVSeg.pixels.fillRect(new Rectangle(0, dashLength, w, dashLength), 0x0);
				altVSeg.pixels.fillRect(new Rectangle(0, Math.ceil(dashLength * 3), w, dashLength), 0x0);
				altHSeg.frame = altVSeg.frame = 0;
			}
			
			altHSeg.height = altVSeg.width = w + 4;
			altHSeg.offset.y = altVSeg.offset.x = -2;
		}
		
		override public function draw():void {
			var iWire:InternalWire = wire as InternalWire;
			
			checkZoom();
			
			var segColor:uint = getColor();
			hSeg.color = vSeg.color = altHSeg.color = altVSeg.color = join.color = segColor;
			
			iterWire(function drawWire(seg:FlxSprite):void {
				seg.draw();
			}, 0, iWire.controlPoint);
			
			var oHSeg:FlxSprite = hSeg;
			var oVSeg:FlxSprite = vSeg;
			hSeg = altHSeg;
			vSeg = altVSeg;
			
			if (iWire.controlPoint > 0 && iWire.controlPoint < iWire.path.length) {
				join.x = iWire.path[iWire.controlPoint].x * U.GRID_DIM - join.width / 2;
				join.y = iWire.path[iWire.controlPoint].y * U.GRID_DIM - join.height / 2;
				join.draw();
			}
			
			iterWire(function drawWire(seg:FlxSprite):void {
				seg.draw();
			}, iWire.controlPoint);
			
			hSeg = oHSeg;
			vSeg = oVSeg;
			
			if (U.BLIT_ENABLED && getBlitActive(segColor))
				drawBlit();
		}
		
		override protected function getColor():uint {
			var iWire:InternalWire = wire as InternalWire;
			
			if (!iWire.getConnected())
				return 0xff0000;
			
			var value:Value = iWire.getValue();
			if (value.unknown)
				return 0xc219d9;
			if (value.unpowered)
				return 0x1d19d9;
			return 0x0;
		}
		
		override protected function getBlitActive(c:uint):Boolean {
			return !lastDashed && c == 0x0 && (wire as InternalWire).getValue().toNumber() != 0; 
		}
	}

}