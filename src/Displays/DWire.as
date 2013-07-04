package Displays {
	import adobe.utils.ProductManager;
	import Components.Port;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Modules.BabyLatch;
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
		
		protected var cachedLines:Vector.<FlxSprite>;
		protected var cachedLoc:Point;
		//protected var cachedPath:Vector.<Point>; //assume wire path is unchanging once deployed
		
		public function DWire(wire:Wire) {
			this.wire = wire;
			buildSegs();
		}
		
		protected function buildSegs():void {
			var w:int = getWidth();
			hSeg = new FlxSprite().makeGraphic(U.GRID_DIM, w);
			vSeg = new FlxSprite().makeGraphic(w, U.GRID_DIM);
			hSeg.height = vSeg.width = w + EXTRA_WIDTH;
			hSeg.offset.y = vSeg.offset.x = -EXTRA_WIDTH/2;
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
			if (outsideScreen())
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
			if (!cachedLines)
				return false;
			if (U.zoom != lastZoom)
				return false;
			/*if (wire.path.length != cachedPath.length)  //assume wire path is unchanging once deployed
				return false;
			for (var i:int = 0; i < wire.path.length; i++)
				if (!wire.path[i].equals(cachedPath[i]))
					return false;
			*/
			return true;
		}
		
		public function outsideScreen():Boolean {
			return !boundingBox.intersects(U.screenRect());
		}
		
		protected function canBuildCache():Boolean {
			return wire.deployed && cachesThisFrame < MAX_CACHES_PER_FRAME;
		}
		
		protected function buildCache():void {
			checkZoom();
			cachedLines = new Vector.<FlxSprite>;
			_bounds = null;
			
			var sublineStart:int = 0;
			var lastDelta:Point = wire.path[1].subtract(wire.path[0]);
			for (var end:int = 1; end < wire.path.length - 1; end++) {
				var delta:Point = wire.path[end+1].subtract(wire.path[end]);
				if (breakSublineAt(end, delta, lastDelta)) {
					cacheSubline(sublineStart, end);
					sublineStart = end;
				}
				lastDelta = delta;
			}
			cacheSubline(sublineStart, end);
			
			cachedLoc = wire.path[0].clone();
			/*cachedPath = new Vector.<Point>;  //assume wire path is unchanging once deployed
			for each (var point:Point in wire.path)
				cachedPath.push(point.clone());
			*/
		}
		
		protected function breakSublineAt(end:int, delta:Point, lastDelta:Point):Boolean {
			return !delta.equals(lastDelta);
		}
		
		protected function cacheSubline(start:int, end:int):void {
			cachedLines.push(buildSubline(wire.path.slice(start, end+1)));
		}
		
		protected function buildSubline(path:Vector.<Point>):FlxSprite {
			var p:Point;
			
			var topLeft:Point = new Point(int.MAX_VALUE, int.MAX_VALUE);
			var bottomRight:Point = new Point(int.MIN_VALUE, int.MIN_VALUE);
			for each (p in path) {
				topLeft.x = Math.min(p.x, topLeft.x);
				topLeft.y = Math.min(p.y, topLeft.y);
				bottomRight.x = Math.max(p.x, bottomRight.x);
				bottomRight.y = Math.max(p.y, bottomRight.y);
			}
			
			var width:Number = getWidth();
			
			var subline:FlxSprite = new FlxSprite().makeGraphic((bottomRight.x - topLeft.x) * U.GRID_DIM + width,
																(bottomRight.y - topLeft.y) * U.GRID_DIM + width, 0x0, true);
			for (var i:int = 0; i < path.length - 1; i++) {
				p = path[i];
				var nextP:Point = path[i + 1];
				var horizontal:Boolean = p.x != nextP.x;
				var seg:FlxSprite = horizontal ? hSeg : vSeg;
				seg.color = 0xffffffff;
				var x:int = (Math.min(p.x, nextP.x) - topLeft.x) * U.GRID_DIM - seg.offset.x + width/2;
				if (!horizontal)
					x -= seg.width / 2;
				var y:int = (Math.min(p.y, nextP.y) - topLeft.y) * U.GRID_DIM - seg.offset.y + width/2;
				if (horizontal)
					y -= seg.height / 2;
				subline.stamp(seg, x, y);
			}
			
			if (topLeft.y == bottomRight.y) {
				subline.height = width + EXTRA_WIDTH;
				subline.offset.y = - EXTRA_WIDTH / 2;
			} else if (topLeft.x == bottomRight.x) {
				subline.width = width + EXTRA_WIDTH;
				subline.offset.x = - EXTRA_WIDTH / 2;
			}
			
			subline.x = topLeft.x * U.GRID_DIM - width / 2 + subline.offset.x;
			subline.y = topLeft.y * U.GRID_DIM - width / 2 + subline.offset.y;
			
			return subline;
		}
		
		protected function drawCached():void {
			if (!wire.path[0].equals(cachedLoc)) {
				var delta:Point = wire.path[0].subtract(cachedLoc);
				shiftSublines(delta);
				cachedLoc = wire.path[0].clone();
			}
			
			var segColor:uint = getColor();
			for each (var cachedLine:FlxSprite in cachedLines) {
				cachedLine.color = segColor;
				cachedLine.draw();
			}
			
			join.color = segColor;
			drawJoins();
			
			if (U.BLIT_ENABLED && wire.deployed && getBlitActive(segColor))
				drawBlit();
		}
		
		protected function shiftSublines(delta:Point):void {
			for each (var cachedLine:FlxSprite in cachedLines) {
				cachedLine.x += delta.x * U.GRID_DIM;
				cachedLine.y += delta.y * U.GRID_DIM;
			}
		}
		
		protected function drawDynamic():void {
			checkZoom();
			
			var segColor:uint = getColor();
			hSeg.color = vSeg.color = join.color = segColor;
			
			drawJoins();
			
			iterWire(function drawWire(seg:FlxSprite):void {
				seg.draw();
			});
			
			if (U.BLIT_ENABLED && wire.deployed && getBlitActive(segColor))
				drawBlit();
		}
		
		protected function drawBlit():void {
			var blitFraction:Number = (Math.floor(U.state.elapsed * BLIT_PERIOD * U.GRID_DIM) % U.GRID_DIM) / U.GRID_DIM;
			for (var i:int = 0; i < wire.path.length - 1; i++) {
				var p:Point = wire.path[i];
				var np:Point = wire.path[i + 1];
				var delta:Point = new Point(Math.abs(p.x - np.x), Math.abs(p.y - np.y));
				var dir:int = U.state.currentGrid.lineDirection(p, np);
				if (!dir)
					continue;
				
				if (dir > 0) {
					animationBlit.x = (Math.min(p.x, np.x) + delta.x * blitFraction) * U.GRID_DIM - 1/U.zoom;
					animationBlit.y = (Math.min(p.y, np.y) + delta.y * blitFraction) * U.GRID_DIM - 1/U.zoom;
				} else {
					animationBlit.x = (Math.max(p.x, np.x) - delta.x * blitFraction) * U.GRID_DIM - 1/U.zoom;
					animationBlit.y = (Math.max(p.y, np.y) - delta.y * blitFraction) * U.GRID_DIM - 1/U.zoom;
				}
				animationBlit.draw();
			}
		}
		
		protected function getColor():uint {
			if (!wire.deployed) {
				var potentialConnections:Vector.<Carrier> = wire.getPotentialConnections();
				switch (potentialConnections.length) {
					case 0: return U.UNCONNECTED_COLOR;
					case 1: return U.HALFCONNECTED_COLOR;
					default: return U.DEFAULT_COLOR;
				}
				//return U.DEFAULT_COLOR;
			}
			
			if (!U.buttonManager.moused && U.state.viewMode == U.state.VIEW_MODE_NORMAL && overlapsPoint(U.mouseFlxLoc))
				return U.HIGHLIGHTED_COLOR;
			
			if (selected)
				return U.SELECTION_COLOR;
			
			if (wire.getSource() == null || wire.connections.length < 2) {
				if (wire.connections.length)
					return U.HALFCONNECTED_COLOR;
				return U.UNCONNECTED_COLOR;
			}
			
			var value:Value = wire.getSource().getValue();
			if (value.unknown)
				return U.UNKNOWN_COLOR;
			if (value.unpowered)
				return U.UNPOWERED_COLOR;
			return U.DEFAULT_COLOR;
		}
		
		protected function getBlitActive(c:uint):Boolean {
			return U.zoom > 1/4 && U.DEFAULT_COLOR == c && wire.source && wire.source.getValue().toNumber() != 0; 
		}
		
		protected function checkZoom():void {
			if (U.zoom != lastZoom)
				buildSegs();
		}
		
		protected function drawJoins():void {
			if (wire.deployed) {
				drawJoin(wire.start);
				drawJoin(wire.end);
			}
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
		
		private var _bounds:Rectangle
		protected function get boundingBox():Rectangle {
			if (_bounds && wire.deployed)
				return _bounds;
			
			var topLeft:Point = new Point(int.MAX_VALUE, int.MAX_VALUE);
			var bottomRight:Point = new Point(int.MIN_VALUE, int.MIN_VALUE);
			for each (var p:Point in wire.path) {
				topLeft.x = Math.min(p.x, topLeft.x);
				topLeft.y = Math.min(p.y, topLeft.y);
				bottomRight.x = Math.max(p.x, bottomRight.x);
				bottomRight.y = Math.max(p.y, bottomRight.y);
			}
			
			var width:int = (bottomRight.x - topLeft.x) * U.GRID_DIM;
			var height:int = (bottomRight.y - topLeft.y) * U.GRID_DIM;
			if (!width)
				width = getWidth();
			else if (!height)
				height = getWidth();
			_bounds = new Rectangle(topLeft.x * U.GRID_DIM, topLeft.y * U.GRID_DIM, width, height);
			return _bounds;
		}
		
		protected var willOverlap:Boolean;
		override public function overlapsPoint(p:FlxPoint, _:Boolean=false, __:FlxCamera=null):Boolean {
			if (!wire.exists) return false;
			
			if (cacheValid()) {
				if (p.x < boundingBox.x || p.y < boundingBox.y || p.x >= boundingBox.right || p.y >= boundingBox.bottom)
					return false;
				for each (var subline:FlxSprite in cachedLines)
					if (subline.overlapsPoint(p, _, __))
						return true;
				return false;
			}
			
			//FIXME
			/*var topLeft:Point = new Point(int.MAX_VALUE, int.MAX_VALUE);
			var bottomRight:Point = new Point(int.MIN_VALUE, int.MIN_VALUE);
			for each (var pathPoint:Point in path) {
				topLeft.x = Math.min(pathPoint.x, topLeft.x);
				topLeft.y = Math.min(pathPoint.y, topLeft.y);
				bottomRight.x = Math.max(pathPoint.x, bottomRight.x);
				bottomRight.y = Math.max(pathPoint.y, bottomRight.y);
			}
			
			if (p.x < topLeft.x * U.GRID_DIM || p.y < topLeft.y * U.GRID_DIM ||
				p.x > bottomRight.x * U.GRID_DIM || p.y > topLeft.y * U.GRID_DIM)
				return false;*/
			
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
		protected const EXTRA_WIDTH:int = 4;
		protected static const MAX_CACHES_PER_FRAME:int = 15;
		protected static var cachesThisFrame:int;
		public static function updateStatic():void {
			cachesThisFrame = 0;
		}
	}

}