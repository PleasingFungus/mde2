package Layouts.Nodes {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class NodeType {
		
		public var textColor:uint;
		public var bgColor:uint;
		public var highlightTextColor:uint;
		public function NodeType(TextColor:uint = 0x0, BGColor:uint = 0x8b8bdb, HighlightTextColor:uint = int.MAX_VALUE) {
			textColor = TextColor;
			bgColor = BGColor;
			highlightTextColor = HighlightTextColor;
		}
		
		public static const DEFAULT:NodeType = new NodeType;
		//public static const INDEX:NodeType = new NodeType(0x0, 0x8bdbdb);
		//public static const TOGGLE:NodeType = new NodeType(0x0, 0xdb968b);
		//public static const STORAGE:NodeType = new NodeType(0x0, 0x8bdb8e);
		
	}

}