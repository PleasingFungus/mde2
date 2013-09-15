package UI {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ButtonFlasher extends FlashingRect {
		
		public function ButtonFlasher(button:MenuButton,
									  MaxColor:uint = 0xffffffff, MinColor:uint = 0xff808080,
									  Alpha:Number = 0.5, Period:Number = 2) {
			super(button.X, button.Y, button.fullWidth, button.fullHeight,
				  MaxColor, MinColor, Alpha, Period);
		}
		
	}

}