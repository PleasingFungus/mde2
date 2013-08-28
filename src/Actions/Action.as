package Actions {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Action {
		
		public function Action() {
			U.state.reactionStack = new Vector.<Action>; //whenever you take a new action, kill "re-do" stack
		}
		
		public function execute():Action {
			U.state.actionStack.push(this);
			finish();
			return this;
		}
		
		public function revert():Action {
			if (canRedo)
				U.state.reactionStack.push(this);
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