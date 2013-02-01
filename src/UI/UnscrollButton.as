package UI {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class UnscrollButton extends MenuButton {
		
		public function UnscrollButton(X:int, Y:int, desc:String, OnSelect:Function = null) {
			super(X, Y, desc, OnSelect);
		}
		
		override public function init(desc:String = null):void {
			super.init(desc);
			text.scrollFactor.x = text.scrollFactor.y = 0;
		}
		
		override protected function createHighlight():void {
			super.createHighlight();
			highlight.scrollFactor.x = highlight.scrollFactor.y = 0;
		}
	}

}