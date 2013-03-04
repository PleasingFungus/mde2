package UI {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class UnscrollList extends ButtonList {
		
		public function UnscrollList(X:int, Y:int, Buttons:Vector.<MenuButton>, OnDeath:Function = null) {
			super(X, Y, Buttons, OnDeath);
		}
		
		override public function create():void {
			super.create();
			bg.scrollFactor.x = bg.scrollFactor.y = 0;
		}
	}

}