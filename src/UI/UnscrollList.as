package UI {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class UnscrollList extends ButtonList {
		
		public function UnscrollList(X:int, Y:int, Buttons:Vector.<MenuButton>) {
			super(X, Y, Buttons);
		}
		
		override public function create():void {
			super.create();
			bg.scrollFactor.x = bg.scrollFactor.y = 0;
		}
	}

}