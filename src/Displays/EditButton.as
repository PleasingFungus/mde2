package Displays {
	import UI.GraphicButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class EditButton extends GraphicButton {
		
		public function EditButton(dModule:DModule) {
			super( -1, -1, _edit_large, function onClick():void {
				U.state.upperLayer.add(new InPlaceSlider(dModule));
			});
		}
		
		override public function draw():void {
			if (U.zoom < 0.5)
				return;
			
			var appropriateGraphic:Class = U.zoom >= 1 ? _edit_large : _edit_zoomed;
			if (rawGraphic != appropriateGraphic)
				loadGraphic(appropriateGraphic);
			super.draw();
		}
		
		override protected function isMoused():Boolean {
			return highlight.overlapsPoint(U.mouseFlxLoc, true, camera) && (!U.buttonManager || !U.buttonManager.moused);
		}
		
		
		[Embed(source = "../../lib/art/ui/edit_2m.png")] private const _edit_zoomed:Class;
		[Embed(source = "../../lib/art/ui/edit_2l.png")] private const _edit_large:Class;
		
	}

}