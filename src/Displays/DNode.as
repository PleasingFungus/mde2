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
		public function DNode(node:InternalNode) {
			this.node = node;
			super();
			makeSprite();
			label = new FlxText( -1, -1, width);
			U.NODE_FONT.configureFlxText(label, 0x0, 'center');
		}
		
		protected function makeSprite():void {
			makeGraphic(U.GRID_DIM * node.dim.x, U.GRID_DIM * node.dim.y, 0xff202020, false, "node"+node.dim.x+','+node.dim.y);
			var borderWidth:int = 2;
			pixels.fillRect(new Rectangle(borderWidth, borderWidth, width - borderWidth * 2, height - borderWidth * 2), 0xffffffff);
			
			offset.x = width / 2;
			offset.y = height / 2;
		}
		
		override public function draw():void {
			var l:Point = node.Loc;
			x = l.x * U.GRID_DIM;
			y = l.y * U.GRID_DIM;
			color = (node.parent.deployed && U.state.viewMode == U.state.VIEW_MODE_NORMAL && !U.buttonManager.moused && overlapsPoint(U.mouseFlxLoc)) ? 0xfff03c : 0x8b8bdb;
			super.draw();
			
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
		
	}

}