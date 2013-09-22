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
		
		protected var cached:Boolean;
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
			if (!cached)
				return false;
			if (U.zoom != cachedZoom)
				return false;
			return true;
		}
		protected function canBuildCache():Boolean {
			return link.deployed && cachesThisFrame < MAX_CACHES_PER_FRAME && false; //TODO
		}
		
		protected function buildCache():void {
			//TODO
			//same as wire, but per jags, not per pre-path
			
			cached = true;
			cachedZoom = U.zoom;
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
			
			if (!hSeg || U.zoom != segZoom)
				setSegs();
			
			var color:uint = getColor();
			if (hSeg.color != color)
				hSeg.color = vSeg.color = color;
			
			var x:int, y:int;
			//the following is awful
			
			if (primaryHorizontal) {
				hSeg.y = start.y;
				for (x = start.x; x < midpoint.x; x += U.GRID_DIM) {
					hSeg.x = x;
					hSeg.draw();
				}
			 	
				vSeg.x = midpoint.x;
				var bottom:int = Math.max(start.y, end.y);
				for (y = Math.min(start.y, end.y); y < bottom; y += U.GRID_DIM) {
					vSeg.y = y;
					vSeg.draw();
				}
				
				hSeg.y = end.y;
				for (x = midpoint.x; x < end.x; x += U.GRID_DIM) {
					hSeg.x = x;
					hSeg.draw();
				}
			} else {
				vSeg.x = start.x;
				for (y = start.y; y < midpoint.y; y += U.GRID_DIM) {
					vSeg.y = y;
					vSeg.draw();
				}
			 	
				hSeg.y = midpoint.y;
				var right:int = Math.max(start.x, end.x);
				for (x = Math.min(start.x, end.x); x < right; x += U.GRID_DIM) {
					hSeg.x = x;
					hSeg.draw();
				}
				
				vSeg.x = end.x;
				for (y = midpoint.y; y < end.y; y += U.GRID_DIM) {
					vSeg.y = y;
					vSeg.draw();
				}
			}
		}
		
		protected function drawCached():void {
			 //TODO
		}
		
		protected function getColor():uint {
			if (!link.fullyPlaced) {
				if (!link.atValidEndpoint())
					return U.UNCONNECTED_COLOR;
				return 0xff000000;
			}
			return 0xff000000; //TODO
		}
		
		public function outsideScreen():Boolean {
			return !boundingBox.intersects(U.screenRect());
		}
		
		public function get boundingBox():Rectangle {
			var sourceLoc:Point = link.source.Loc;
			var destLoc:Point = link.destination.Loc;
			var width:int = getWidth();
			return new Rectangle(Math.min(sourceLoc.x, destLoc.x) * U.GRID_DIM - width, Math.min(sourceLoc.y, destLoc.y) * U.GRID_DIM - width,
								 Math.abs(sourceLoc.x - destLoc.x) * U.GRID_DIM + width * 2,
								 Math.abs(sourceLoc.y - destLoc.y) * U.GRID_DIM + width * 2); //TODO: cache?
		}
		
		override public function overlapsPoint(p:FlxPoint, _:Boolean=false, __:FlxCamera=null):Boolean {
			if (!link.exists) return false;
			
			if (cacheValid())
				return super.overlapsPoint(p, _, __);
			
			var bounds:Rectangle = boundingBox;
			return (p.x < bounds.x || p.y < bounds.y || p.x >= bounds.right || p.y >= bounds.bottom)
		}
		
		override public function overlaps(o:FlxBasic, _:Boolean=false, __:FlxCamera=null):Boolean {
			if (!link.exists) return false;
			
			if (cacheValid())
				return super.overlaps(o, _, __);
			
			var bounds:Rectangle = boundingBox;
			x = bounds.left;
			y = bounds.top;
			width = bounds.width;
			height = bounds.height;
			return super.overlaps(o, _, __);
		}
		
		
		protected const EXTRA_WIDTH:int = 4;
		protected static const MAX_CACHES_PER_FRAME:int = 15;
		protected static var cachesThisFrame:int;
		public static function updateStatic():void {
			cachesThisFrame = 0;
		}
	}

}