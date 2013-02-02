package  {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelGoal {
		
		public var description:String;
		public var checkWin:Function;
		public var onWin:Function;
		public var onLose:Function;
		public function LevelGoal(Description:String, CheckWin:Function, OnWin:Function, OnLose:Function) {
			description = Description;
			checkWin = CheckWin;
			onWin = OnWin;
			onLose = OnLose;
		}
		
	}

}