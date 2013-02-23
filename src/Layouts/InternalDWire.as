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
		public function InternalDWire(wire:InternalWire) {
			super(wire);
		}
		
		override protected function buildSegs():void {
			var iWire:InternalWire = wire as InternalWire;
			lastDashed = iWire.control;
			
			if (!iWire.control) {
				super.buildSegs();
				return;
			}
			
			var w:int = 1 / U.state.zoom
			var cached:Boolean = FlxG.checkBitmapCache("hcontrolwire");
			hSeg = new FlxSprite().makeGraphic(U.GRID_DIM, w, 0xffffffff, true, "hcontrolwire");
			vSeg = new FlxSprite().makeGraphic(w, U.GRID_DIM, 0xffffffff, true, "vcontrolwire");
			
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
			
			join = new FlxSprite;
			animationBlit = new FlxSprite().makeGraphic(w, w);
			
			lastZoom = U.state.zoom;
		}
		
		override public function update():void {
			super.update();
			if (lastDashed != (wire as InternalWire).control)
				buildSegs();
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
		
		override protected function checkSource():void {
			sourcePoint = 0;
		}
	}

}