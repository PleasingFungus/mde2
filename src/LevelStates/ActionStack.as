package LevelStates {
	import Actions.Action;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class ActionStack {
		
		public var actionStack:Vector.<Action>;
		public var reactionStack:Vector.<Action>;
		public function ActionStack() {
			actionStack = new Vector.<Action>;
			reactionStack = new Vector.<Action>;
		}
		
		public function canUndo():Boolean {
			return actionStack.length > 0 && !U.state.hasHeldState();
		}
		
		public function canRedo():Boolean {
			return reactionStack.length > 0 && !U.state.hasHeldState();
		}
		
		
		public function undo():Action {
			if (!canUndo())
				return null;
			U.state.ensureNothingHeld();
			return actionStack.pop().revert();
		}
		
		public function redo():Action {
			if (!canRedo())
				return null;
			U.state.ensureNothingHeld();
			return reactionStack.pop().execute();
		}
		
		
		public function clearRedo():void {
			reactionStack = new Vector.<Action>;
		}
		
	}

}