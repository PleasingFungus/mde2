package Displays {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Layouts.Nodes.WideNode;
	import org.flixel.*;
	import Layouts.Nodes.InternalNode;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DNode extends FlxSprite {
		
		public var node:InternalNode;
		private var label:FlxText;
		private var lastValueString:String;
		private var delayFiller:FlxSprite;
		public function DNode(node:InternalNode) {
			this.node = node;
			super();
			makeSprite();
			label = new FlxText( -1, -1, width);
			U.NODE_FONT.configureFlxText(label, node.type.textColor, 'center');
		}
		
		protected function makeSprite():void {
			makeGraphic(U.GRID_DIM * node.dim.x, U.GRID_DIM * node.dim.y, 0xff202020, false, "node"+node.dim.x+','+node.dim.y);
			pixels.fillRect(new Rectangle(BORDER_WIDTH, BORDER_WIDTH, width - BORDER_WIDTH * 2, height - BORDER_WIDTH * 2), 0xffffffff);
			
			offset.x = width / 2;
			offset.y = height / 2;
			
			if (U.state && U.state.level.delay) {
				delayFiller = new FlxSprite( -1, -1).makeGraphic(width - BORDER_WIDTH * 2, height - BORDER_WIDTH * 2);
				delayFiller.color = U.UNKNOWN_COLOR;
				delayFiller.offset.x = offset.x - BORDER_WIDTH;
				delayFiller.offset.y = offset.y - BORDER_WIDTH;
			}
		}
		
		override public function draw():void {
			var l:Point = node.Loc;
			x = l.x * U.GRID_DIM;
			y = l.y * U.GRID_DIM;
			color = (node.parent.deployed && U.state && U.state.viewMode == U.state.VIEW_MODE_NORMAL && !U.buttonManager.moused && overlapsPoint(U.mouseFlxLoc)) ? U.HIGHLIGHTED_COLOR : node.type.bgColor;
			super.draw();
			
			var delay:int = node.inputDelay();
			if (delay) {
				var delayFraction:Number = delay / node.parent.delay;
				delayFiller.x = x;
				delayFiller.y = y + delayFiller.height * (1 - delayFraction) / 2;
				delayFiller.scale.y = delayFraction
				delayFiller.draw();
			}
			
			drawLabel();
		}
		
		public function drawLabel():void {
			label.x = x - 1 - offset.x;
			label.y = y + 1 - offset.y;
			var valueString:String = node.getValue().toString();
			if (valueString != lastValueString) {
				label.text = valueString;
				for (var i:int = valueString.length - 2; i > 0 && label.height > height; i--)
					label.text = valueString.substr(0, i) + "...";
				if (label.height > height)
					label.text = "...";
				lastValueString = valueString;
			}
			label.draw();
		}
		
		override public function overlapsPoint(fp:FlxPoint, InScreenSpace:Boolean = false, Camera:FlxCamera = null):Boolean {
			if (InScreenSpace || Camera)
				return super.overlapsPoint(fp, InScreenSpace, Camera);
			return fp.x >= x - offset.x && fp.y >= y - offset.y && fp.x < x - offset.x + width && fp.y < y - offset.y + height;
		}
		
		protected const BORDER_WIDTH:int = 2;
	}

}