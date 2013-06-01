package Levels.ControlTutorials {
	import Components.Port;
	import Displays.DPort;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import Layouts.PortLayout;
	import Levels.Level;
	import Modules.*;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import Testing.Goals.WireTutorialGoal;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class WireTutorial extends Level {
		
		public function WireTutorial() {
			super(NAME, new WireTutorialGoal, false, [], [], [new ConstIn(12, 12, 1), new ConstIn(12, 20, 2), new DataWriter(22, 16)]);
			//info = "Modules are little blocky machines that do things. You interact with them by connecting their input & output 'ports' together with wires."
			//info += "\n\nOutput ports are on the right of modules & point out. They output values."
			//info += "\n\nInput ports are on the left & top of modules & point in. The values that you hook into these (with wires) determines what the module does & outputs."
			//info = "To place a wire, click & drag anywhere but on a module."
			//info += "\n\nModules have a limited number of connection points, arrow-shaped 'ports'.";
			//info += " There are two types of ports: outputs, which are always on the right & point outwards, and inputs, which are on modules' other sides & point inward."
			//info += " Outputs create values. Inputs determine what a module does."
			//info += " You can mouse over ports & wires to see their present value & more information."
			//info += "\n\nWires can be used to create circuits, connecting any number of inputs to a single output."
			//info += " You cannot connect more than one output to a circuit."
			info = "Draw wires to connect them, then press Test!";
			useModuleRecord = false;
		}
		
		override public function specialInfo():Vector.<FlxSprite> {
			var vec:Vector.<FlxSprite> = new Vector.<FlxSprite>;
			vec.push(makeOutputLine());
			vec.push(makeInputLine());
			return vec;
		}
		
		protected function makeOutputLine():FlxSprite {
			var outputGraphic:FlxSprite = new FlxSprite().loadGraphic(_output);
			var bg:FlxSprite = new FlxSprite().makeGraphic(400, outputGraphic.height, 0x0, true);
			
			var text:FlxText = new FlxText( -1, -1, bg.width, "This is an output port:");
			U.BODY_FONT.configureFlxText(text);
			bg.stamp(text, 0, (bg.height - text.height) / 2);
			
			bg.stamp(outputGraphic, text.x + text.textWidth + 15, 0);
			
			return bg;
		}
		
		protected function makeInputLine():FlxSprite {
			var inputGraphic:FlxSprite = new FlxSprite().loadGraphic(_inputs);
			var bg:FlxSprite = new FlxSprite().makeGraphic(400, inputGraphic.height, 0x0, true);
			
			
			var text:FlxText = new FlxText( -1, -1, bg.width, "These are input ports:");
			U.BODY_FONT.configureFlxText(text);
			bg.stamp(text, 0, (bg.height - text.height) / 2);
			
			bg.stamp(inputGraphic, text.x + text.textWidth + 15, 0);
			
			return bg;
		}
		
		[Embed(source = "../../../lib/art/help/output.png")] private const _output:Class;
		[Embed(source = "../../../lib/art/help/inputs.png")] private const _inputs:Class;
		
		public static const NAME:String = "Wire Tutorial";
	}

}