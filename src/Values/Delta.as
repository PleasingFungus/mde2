package Values {
	import Modules.Module;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Delta {
		
		public var moment:int;
		public var module:Module;
		public var oldValue:Value;
		public function Delta(Moment:int, Module_:Module, OldValue:Value) {
			moment = Moment;
			module = Module_;
			oldValue = OldValue;
		}
		
		public function revert():void {
			module.revertTo(oldValue);
		}
		
	}

}