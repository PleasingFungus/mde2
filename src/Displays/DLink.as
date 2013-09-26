package Displays {
	import Components.Link;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DLink extends FlxSprite {
		
		public var link:Link;
		public var selected:Boolean;
		
		protected var cachedLines:Vector.<FlxSprite>;
		protected var cachesByZoom:Array = [];
		protected var cachedStart:Point;
		protected var cachedEnd:Point;
		protected var cachedZoom:Number;
		
		protected static const hSegs:Array = [];
		protected static const vSegs:Array = [];
		protected static var hSeg:FlxSprite;
		protected static var vSeg:FlxSprite;
		protected static var segZoom:Number;
		public function DLink(link:Link) {
			this.link = link;
		}
		
		protected function buildSegsForZoom():void {
			var w:int = getWidth();
			hSegs[zoomIndex] = new FlxSprite().makeGraphic(U.GRID_DIM, w);
			vSegs[zoomIndex] = new FlxSprite().makeGraphic(w, U.GRID_DIM);
		}
		
		protected function setSegs():void {
			if (hSeg && U.zoom == segZoom)
				return;
			
			if (!hSegs[zoomIndex])
				buildSegsForZoom();
			
			hSeg = hSegs[zoomIndex];
			vSeg = vSegs[zoomIndex];
			segZoom = U.zoom;
		}
		
		protected function getWidth():int {
			return 2 / U.zoom;
		}
		
		protected function get zoomIndex():int {
			return Math.round(Math.log(U.zoom) / Math.LOG2E);
		}
		
		override public function draw():void {
			if (!link.exists || outsideScreen())
				return;
			
			if (!cacheValid()) {
				if (!canBuildCache()) {
					drawDynamic();
					return;
				}
				
				buildCache();
			}
			drawCached();
		}
		
		protected function cacheValid():Boolean {
			return cachedLines && U.zoom == cachedZoom && link.source.Loc.equals(cachedStart) && link.destination.Loc.equals(cachedEnd);
		}
		protected function canBuildCache():Boolean {
			return link.deployed && (cachesByZoom[zoomIndex] || cachesThisFrame < MAX_CACHES_PER_FRAME);
		}
		
		protected function buildCache():void {
			if (!cachedStart || !link.source.Loc.equals(cachedStart) || !link.destination.Loc.equals(cachedEnd))
				cachesByZoom = [];
			
			if (cachesByZoom[zoomIndex]) {
				cachedLines = cachesByZoom[zoomIndex];
				cachedZoom = U.zoom;
				return;
			}
			
			cachedLines = new Vector.<FlxSprite>;
			_bounds = null;
			
			var source:Point = link.source.Loc;
			var dest:Point = link.destination.Loc;
			var midpoint:Point = new Point(Math.floor((source.x + dest.x) / 2),
										   Math.floor((source.y + dest.y) / 2));
			var primaryHorizontal:Boolean = Math.abs(source.x - dest.x) >= Math.abs(source.y - dest.y);
			
			if (primaryHorizontal) {
				cachedLines.push(makeCachedLine(Math.min(source.x, midpoint.x), source.y, Math.abs(source.x - midpoint.x), true));
				cachedLines.push(makeCachedLine(midpoint.x, Math.min(source.y, dest.y), Math.abs(source.y - dest.y), false));
				cachedLines.push(makeCachedLine(Math.min(midpoint.x, dest.x), dest.y, Math.abs(dest.x - midpoint.x), true));
			} else {
				cachedLines.push(makeCachedLine(source.x, Math.min(source.y, midpoint.y), Math.abs(source.y - midpoint.y), false));
				cachedLines.push(makeCachedLine(Math.min(source.x, dest.x), midpoint.y, Math.abs(source.x - dest.x), true));
				cachedLines.push(makeCachedLine(dest.x, Math.min(midpoint.y, dest.y), Math.abs(dest.y - midpoint.y), false));
			}
			
			cachedZoom = U.zoom;
			cachedStart = link.source.Loc.clone();
			cachedEnd = link.destination.Loc.clone();
			cachesByZoom[zoomIndex] = cachedLines;
		}
		
		private function makeCachedLine(X:int, Y:int, Length:int, Horizontal:Boolean):FlxSprite {
			X *= U.GRID_DIM;
			Y *= U.GRID_DIM;
			Length *= U.GRID_DIM;
			var thickness:int = getWidth();
			var fullThickness:int = thickness + EXTRA_WIDTH;
			
			var line:FlxSprite = new FlxSprite(X - fullThickness/2, Y - fullThickness/2);
			
			var width:int, height:int;
			if (Horizontal) {
				width = Length + thickness;
				height = thickness;
				
			} else {
				height = Length + thickness;
				width = thickness;
			}
			
			line.makeGraphic(width, height, 0xffffffff, true);
			
			line.height += EXTRA_WIDTH;
			line.offset.y = - EXTRA_WIDTH / 2;
			line.width += EXTRA_WIDTH;
			line.offset.x = - EXTRA_WIDTH / 2;
			
			return line;
		}
		
		protected function drawCached():void {
			var color:uint = getColor();
			for each (var line:FlxSprite in cachedLines) {
				line.color = color;
				line.draw();
			}
		}
		
		protected function drawDynamic(drawFromOrigin:Boolean = false):void {
			var source:Point = link.source.Loc;
			var dest:Point = link.destination.Loc;
			var midpoint:Point = new Point(Math.floor((source.x + dest.x) / 2) * U.GRID_DIM,
										   Math.floor((source.y + dest.y) / 2) * U.GRID_DIM);
			var primaryHorizontal:Boolean = Math.abs(source.x - dest.x) >= Math.abs(source.y - dest.y);
			
			//order points so that you draw l/r or t/d on the primary axis
			var start:Point, end:Point;
			if ((primaryHorizontal && source.x <= dest.x) ||
			   (!primaryHorizontal && source.y <= dest.y)) {
				start = source;
				end = dest;
			} else {
				start = dest;
				end = source;
			}
			
			start.x *= U.GRID_DIM;
			start.y *= U.GRID_DIM;
			end.x *= U.GRID_DIM;
			end.y *= U.GRID_DIM;
			
			setSegs();
			var width:int = getWidth();
			
			var color:uint = getColor();
			if (hSeg.color != color)
				hSeg.color = vSeg.color = color;
			
			var x:int, y:int;
			//the following is awful
			
			if (primaryHorizontal) {
				hSeg.y = start.y - width/2;
				for (x = start.x; x < midpoint.x; x += U.GRID_DIM) {
					hSeg.x = x - width/2;
					hSeg.draw();
				}
			 	
				vSeg.x = midpoint.x - width/2;
				var bottom:int = Math.max(start.y, end.y);
				for (y = Math.min(start.y, end.y); y < bottom; y += U.GRID_DIM) {
					vSeg.y = y - width/2;
					vSeg.draw();
				}
				
				hSeg.y = end.y - width/2;
				for (x = midpoint.x; x < end.x; x += U.GRID_DIM) {
					hSeg.x = x - width/2;
					hSeg.draw();
				}
			} else {
				vSeg.x = start.x - width/2;
				for (y = start.y; y < midpoint.y; y += U.GRID_DIM) {
					vSeg.y = y - width/2;
					vSeg.draw();
				}
			 	
				hSeg.y = midpoint.y - width/2;
				var right:int = Math.max(start.x, end.x);
				for (x = Math.min(start.x, end.x); x < right; x += U.GRID_DIM) {
					hSeg.x = x - width/2;
					hSeg.draw();
				}
				
				vSeg.x = end.x - width/2;
				for (y = midpoint.y; y < end.y; y += U.GRID_DIM) {
					vSeg.y = y - width/2;
					vSeg.draw();
				}
			}
		}
		
		protected function getColor():uint {
			if (selected)
				return U.SELECTION_COLOR;
			
			if (link.hovering) {
				if (!link.atValidEndpoint())
					return U.UNCONNECTED_COLOR;
				return 0xff000000;
			}
			
			if (!U.buttonManager.moused && overlapsPoint(U.mouseFlxLoc))
				return U.HIGHLIGHTED_COLOR;
			return 0xff000000; //TODO
		}
		
		public function outsideScreen():Boolean {
			return !boundingBox.intersects(U.screenRect());
		}
		
		protected var _bounds:Rectangle;
		public function get boundingBox():Rectangle {
			if (cacheValid() && _bounds)
				return _bounds;
			
			var sourceLoc:Point = link.source.Loc;
			var destLoc:Point = link.destination.Loc;
			var width:int = getWidth();
			_bounds = new Rectangle(Math.min(sourceLoc.x, destLoc.x) * U.GRID_DIM - width, Math.min(sourceLoc.y, destLoc.y) * U.GRID_DIM - width,
									Math.abs(sourceLoc.x - destLoc.x) * U.GRID_DIM + width * 2,
									Math.abs(sourceLoc.y - destLoc.y) * U.GRID_DIM + width * 2);
			return _bounds;
		}
		
		override public function overlapsPoint(p:FlxPoint, _:Boolean=false, __:FlxCamera=null):Boolean {
			if (!link.exists) return false;
			
			if (!link.deployed)
				return false; //? not implemented
			
			//could check bbox here?
			//check wires
			for each (var line:FlxSprite in cachedLines)
				if (line.overlapsPoint(p, _, __))
					return true;
			return false;
		}
		
		override public function overlaps(o:FlxBasic, _:Boolean=false, __:FlxCamera=null):Boolean {
			if (!link.exists) return false;
			
			if (!link.deployed)
				return false; //? not implemented
			
			//could check bbox here?
			//check wires
			for each (var line:FlxSprite in cachedLines)
				if (line.overlaps(o, _, __))
					return true;
			return false;
		}
		
		
		protected const EXTRA_WIDTH:int = 8;
		protected static const MAX_CACHES_PER_FRAME:int = 15;
		protected static var cachesThisFrame:int;
		public static function updateStatic():void {
			cachesThisFrame = 0;
		}
	}

}