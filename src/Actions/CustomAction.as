package Actions {
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class CustomAction extends Action {
		
		public var exec:Function;
		public var revt:Function;
		
		public var param:Object;
		public var param2:Object;
		public function CustomAction(Execute:Function, Revert:Function, Param:Object = null, Param2:Object = null) {
			exec = Execute;
			revt = Revert;
			
			param = Param;
			param2 = Param2;
		}
		
		override public function execute():Action {
			var success:Boolean;
			
			if (param == null)
				success = exec();
			else if (param2 == null)
				success = exec(param);
			else
				success = exec(param, param2);
			
			if (success)
				return super.execute();
			return null;
		}
		
		override public function revert():Action {
			if (param == null)
				revt();
			else if (param2 == null)
				revt(param);
			else
				revt(param, param2);
			
			return super.revert();
		}
		
	}

}