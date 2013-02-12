package Testing {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelGoal {
		
		public var description:String;
		public var checkWin:Function;
		public var genMem:Function;
		public var onWin:Function;
		public var onLose:Function;
		public function LevelGoal(Description:String, CheckWin:Function, GenMem:Function = null,
								  OnWin:Function = null, OnLose:Function = null) {
			description = Description;
			checkWin = CheckWin;
			genMem = GenMem;
			onWin = OnWin;
			onLose = OnLose;
		}
		
	}

}