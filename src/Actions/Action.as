package Actions {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Action {
		
		public function Action() {
			U.level.reactionStack = new Vector.<Action>; //whenever you take a new action, kill "re-do" stack
		}
		
		public function execute():Action {
			U.level.actionStack.push(this);
			return this;
		}
		
		public function revert():Action {
			U.level.reactionStack.push(this);
			return this;
		}
	}

}