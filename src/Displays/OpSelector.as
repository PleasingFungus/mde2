package Displays {
	import Modules.InstructionDemux;
	import org.flixel.*;
	import UI.MenuButton;
	import Values.OpcodeValue;
	import Values.Value;
	import UI.FlxBounded;
	import UI.TextButton;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class OpSelector extends FlxGroup implements FlxBounded {
		
		private var mux:InstructionDemux;
		
		private var x:int;
		private var y:int;
		private var maxWidth:int;
		private var maxHeight:int;
		
		private var bg:FlxSprite;
		private var onToggles:Vector.<TextButton>;
		private var offToggles:Vector.<TextButton>;
		private var buttonBGs:Vector.<FlxSprite>;
		private var orderedOps:Vector.<OpcodeValue>;
		public function OpSelector(X:int, Y:int, MaxHeight:int, Mux:InstructionDemux) {
			x = X;
			y = Y;
			maxHeight = MaxHeight;
			mux = Mux;
			
			super();
			init();
		}
		
		public function init():void {
			members = [];
			
			mux.getConfiguration();
			makeToggles();
			positionToggles();
			makeBG();
			addElements();
			setToggleStates();
		}
		
		protected function makeToggles():void {
			onToggles = new Vector.<TextButton>;
			offToggles = new Vector.<TextButton>;
			buttonBGs = new Vector.<FlxSprite>;
			orderedOps = new Vector.<OpcodeValue>;
			
			for each (var op:OpcodeValue in OpcodeValue.OPS) {
				if (U.state.level.expectedOps.indexOf(op) == -1)
					continue;
				
				onToggles.push(new TextButton( -1, -1, op.shortString(), toggleOn
											  /*, "Add " + op.shortString() + " to " + mux.name*/).setFormat(U.OPCODE_FONT.id, U.OPCODE_FONT.size, U.HIGHLIGHTED_COLOR).setParam(op).setScroll(0));
				offToggles.push(new TextButton( -1, -1, op.shortString(), toggleOff
											   /*, "Remove " + op.shortString() + " from " + mux.name*/).setFormat(U.OPCODE_FONT.id, U.OPCODE_FONT.size, U.SELECTION_COLOR).setParam(op).setScroll(0));
				//tooltips disabled due to poor layering with menu
				
				var buttonBG:FlxSprite = new FlxSprite( -1, -1).makeGraphic(onToggles[onToggles.length - 1].fullWidth + 2,
																			onToggles[onToggles.length - 1].fullHeight + 2);
				buttonBG.scrollFactor.x = buttonBG.scrollFactor.y = 0;
				buttonBGs.push(buttonBG);
				
				orderedOps.push(op);
			}
		}
		
		protected function positionToggles():void {
			var buttonHeight:int = onToggles[0].fullHeight;
			var innerHeight:int = maxHeight - BORDER_WIDTH * 2;
			var rows:int = Math.max(Math.floor((innerHeight - INNER_PAD) / (buttonHeight + INNER_PAD)), 1); //minim of INNER_PAD spacing between edges & buttons and buttons & buttons
			var innerSpacing:Number = (innerHeight - rows * buttonHeight) / (rows + 1); //calculate actual spacing
			
			var totalWidth:int = INNER_PAD;
			for each (var button:MenuButton in onToggles)
				totalWidth += button.fullWidth + INNER_PAD;
			
			var X:Number = x + BORDER_WIDTH + INNER_PAD;
			var Y:Number = y + BORDER_WIDTH + innerSpacing;
			maxWidth = 0;
			for (var buttonIndex:int = 0; buttonIndex < onToggles.length; buttonIndex++) {
				onToggles[buttonIndex].X = offToggles[buttonIndex].X = X;
				buttonBGs[buttonIndex].x = X - 1;
				onToggles[buttonIndex].Y = offToggles[buttonIndex].Y = Y;
				buttonBGs[buttonIndex].y = Y - 1;
				
				X += onToggles[buttonIndex].fullWidth;
				if (X >= x + BORDER_WIDTH + totalWidth / rows) {
					maxWidth = Math.max(X - x + BORDER_WIDTH + INNER_PAD, maxWidth);
					X = x + BORDER_WIDTH + INNER_PAD;
					Y += buttonHeight + innerSpacing;
				}
			}
			maxWidth = Math.max(X - x + BORDER_WIDTH + INNER_PAD, maxWidth);
		}
		
		protected function makeBG():void {
			bg = new FlxSprite(x, y).makeGraphic(maxWidth, maxHeight, 0xff666666, true);			
			bg.pixels.fillRect(new Rectangle(BORDER_WIDTH/2, BORDER_WIDTH/2, bg.width - BORDER_WIDTH, bg.height - BORDER_WIDTH), 0xff999999);
			bg.pixels.fillRect(new Rectangle(BORDER_WIDTH, BORDER_WIDTH, bg.width - BORDER_WIDTH*2, bg.height - BORDER_WIDTH*2), 0xff666666);
			bg.frame = 0;
			bg.scrollFactor.x = bg.scrollFactor.y = 0;
		}
		
		protected function addElements():void {
			add(bg);
			for each (var buttonBG:FlxSprite in buttonBGs)
				add(buttonBG);
			for each (var button:MenuButton in onToggles)
				add(button);
			for each (button in offToggles)
				add(button);
		}
		
		protected function setToggleStates():void {
			var canToggleOff:Boolean = mux.expectedOps.length > 1;
			
			for (var i:int = 0; i < onToggles.length; i++) {
				var op:OpcodeValue = orderedOps[i];
				var opEnabled:Boolean = mux.expectedOps.indexOf(op) != -1;
				
				onToggles[i].exists = !opEnabled;
				offToggles[i].exists = opEnabled;
				
				offToggles[i].disabled = !canToggleOff;
				offToggles[i].setFormat(U.OPCODE_FONT.id, U.OPCODE_FONT.size, canToggleOff ? U.SELECTION_COLOR : 0xc0c0c0);
				buttonBGs[i].color = opEnabled ? canToggleOff ? U.HIGHLIGHTED_COLOR : 0x404040 : U.SELECTION_COLOR;
			}
		}
		
		private function toggleOn(op:Value):void {
			mux.expectedOps.push(op);
			setToggleStates();
		}
		
		private function toggleOff(op:Value):void {
			var opIndex:int = mux.expectedOps.indexOf(op);
			mux.expectedOps.splice(opIndex, 1);
			setToggleStates();
		}
		
		public function overlapsPoint(p:FlxPoint):Boolean {
			return bg.overlapsPoint(p, true, FlxG.camera);
		}
		
		public function get basic():FlxBasic { return this; }
		
		protected const BORDER_WIDTH:int = 4;
		protected const INNER_PAD:int = 3;
		
	}

}