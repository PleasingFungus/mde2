package Actions {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Action {
		
		public var hasExecuted:Boolean;
		public function Action() {
			hasExecuted = false;
		}
		
		public function execute():Action {
			if (!hasExecuted)
				U.state.actions.clearRedo(); //whenever you take a new action, kill "re-do" stack
			hasExecuted = true;
			
			U.state.actions.actionStack.push(this);
			finish();
			
			return this;
		}
		
		public function revert():Action {
			if (canRedo)
				U.state.actions.reactionStack.push(this);
			finish();
			return this;
		}
		
		public function finish():void {
			U.state.onStateChange();
		}
		
		public function get canRedo():Boolean {
			return true;
		}
	}

}