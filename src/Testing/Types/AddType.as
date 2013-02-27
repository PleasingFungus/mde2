package Testing.Types {
	import Testing.Abstractions.AddAbstraction;
	import Testing.Abstractions.InstructionAbstraction;
	import org.flixel.FlxG;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class AddType extends InstructionType {
		
		public function AddType() {
			super("Add");
		}
		
		override public function can_produce(value:int):Boolean {
			return true;
		}
		
		override public function can_produce_with_one(value:int, arg:int):Boolean {
			var a2:int = value - arg;
			return a2 <= U.MAX_INT && a2 >= U.MIN_INT;
		}
		
		override public function can_produce_with_one_of(value:int, args:Vector.<int>):Boolean {
			for each (var arg:int in args) {
				var a2:int = value - arg;
				if (a2 <= U.MAX_INT && a2 >= U.MIN_INT)
					return true;
			}
			return false;
		}
		
		override public function can_produce_with(value:int, args:Vector.<int>):Boolean {
			for (var i:int = 0; i < args.length; i++) {
				var a1:int = args[i];
				for (var j:int = 0; j < args.length; j++) {
					if (j == i)
						continue;
					
					var a2:int = args[j];
					if (a1 + a2 == value)
						return true;
				}
			}
			return false;
		}
		
		override public function produce_unrestrained(value:int, depth:int):InstructionAbstraction {
			var minAddend:int = Math.max(U.MIN_INT, value - U.MAX_INT);
			var maxAddend:int = Math.max(U.MAX_INT, value - U.MIN_INT);
        
            var a1:int = C.randomRange(minAddend, maxAddend+1);
            var a2:int = value - a1;
			return new AddAbstraction(depth, a1, a2);
		}
		
		override public function produce_with_one(value:int, depth:int, arg:int):InstructionAbstraction {
			return new AddAbstraction(depth, arg, value - arg);
		}
		
		override public function produce_with(value:int, depth:int, args:Vector.<int>):InstructionAbstraction {
            var pairs:Array = [];
			for (var i:int = 0; i < args.length - 1; i++) {
				var a1:int = args[i];
				for (var j:int = i + 1; j < args.length; j++) {
					var a2:int = args[j];
					if (a1 + a2 == value)
                        pairs.push([a1, a2]);
				}
			}
            var pair:Array = C.randomChoice(pairs);
			var order:int = int(FlxG.random() * 2);
			
			return new AddAbstraction(depth, pair[order], pair[1 - order]);
		}
		
	}

}