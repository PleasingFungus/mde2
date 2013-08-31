package Displays {
	import LevelStates.ActionStack;
	import org.flixel.FlxGroup;
	import UI.GraphicButton;
	import UI.ToolbarButton;
	import Controls.ControlSet;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DUndo extends FlxGroup {
		
		private var undoButton:GraphicButton;
		private var redoButton:GraphicButton;
		private var actions:ActionStack;
		public function DUndo(actions:ActionStack) {
			super();
			add(undoButton = new ToolbarButton(50, _undo_sprite, actions.undo, "Undo", "Undo", ControlSet.UNDO));
			add(redoButton = new ToolbarButton(90, _redo_sprite, actions.redo, "Redo", "Redo",  ControlSet.REDO));
			this.actions = actions;
		}
		
		override public function update():void {
			undoButton.exists = actions.actionStack.length > 0;
			undoButton.active = actions.canUndo(); 
			redoButton.exists = actions.reactionStack.length > 0;
			redoButton.active = actions.canRedo();
			var undoAlpha:Number = U.state.hasHeldState() ? 0.3 : 1;
			undoButton.setAlpha(undoAlpha);
			redoButton.setAlpha(undoAlpha);
			
			super.update();
			
		}
		
		[Embed(source = "../../lib/art/ui/undo.png")] private const _undo_sprite:Class;
		[Embed(source = "../../lib/art/ui/redo.png")] private const _redo_sprite:Class;
		
	}

}