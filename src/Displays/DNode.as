package Displays {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import Layouts.Nodes.InternalNode;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DNode extends FlxSprite {
		
		public var node:InternalNode;
		private var label:FlxText;
		public function DNode(node:InternalNode) {
			this.node = node;
			super();
			makeSprite();
			label = new FlxText( -1, -1, width);
			U.NODE_FONT.configureFlxText(label, 0x0, 'center');
		}
		
		protected function makeSprite():void {
			makeGraphic(U.GRID_DIM * node.dim.x, U.GRID_DIM * node.dim.y, 0xff202020, false, "node");
			var borderWidth:int = 2;
			framePixels.fillRect(new Rectangle(borderWidth, borderWidth, width - borderWidth*2, height - borderWidth*2), 0xff8b8bdb);
			offset.x = width / 2;
			offset.y = height / 2;
		}
		
		override public function draw():void {
			var l:Point = node.Loc;
			x = l.x * U.GRID_DIM;
			y = l.y * U.GRID_DIM;
			super.draw();
			
			label.x = x - 1 - offset.x;
			label.y = y + 1 - offset.y;
			label.text = node.getLabel();
			//TODO: truncate
			label.draw();
		}
		
	}

}