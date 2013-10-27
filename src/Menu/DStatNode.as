package Menu {
	import Displays.DNode;
	import Layouts.Nodes.InternalNode;
	import org.flixel.FlxSprite;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DStatNode extends DNode {
		
		private var statNode:StatNode;
		public function DStatNode(node:InternalNode) {
			super(node);
			statNode = node as StatNode;
		}
		
		override public function drawLabel():void {
			drawIcon();
			super.drawLabel();
		}
		
		private var _icon:FlxSprite;
		private function drawIcon():void {
			if (!_icon)
				makeIcon();
			_icon.x = x - offset.x + (width - _icon.width) / 2;
			_icon.y = y - offset.y + (height - _icon.height) / 2;
			_icon.draw();
		}
		
		private function makeIcon():void {
			_icon = new FlxSprite( -1, -1, iconGraphic);
			_icon.color = U.HIGHLIGHTED_COLOR;
			_icon.alpha = 0.6;
		}
		
		private function get iconGraphic():Class {
			switch (statNode.statType) {
				case StatNode.MODULE: return _module;
				case StatNode.TIME: return _time;
				default: throw new Error("Invalid stat type!");
			}
		}
		
		
		[Embed(source = "../../lib/art/ui/modulerec.png")] private const _module:Class;
		[Embed(source = "../../lib/art/ui/timerec.png")] private const _time:Class;
	}

}