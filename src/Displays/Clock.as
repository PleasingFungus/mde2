package Displays {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import flash.display.Bitmap;
	import flash.display.Shape;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Clock extends FlxSprite {
		
		private var _fraction:Number;
		private var hand:FlxSprite;
		private var _handFraction:Number;
		private var on:Boolean;
		public function Clock(X:int, Y:int, Fraction:Number) {
			super(X, Y);
			_fraction = Fraction;
			init();
		}
		
		private function init():void {
			on = handIndicatesOn();
			var bitmapString:String = "Clock-" + fraction + "-" + on;
			var existed:Boolean = FlxG.checkBitmapCache(bitmapString);
			makeGraphic(RADIUS * 2, RADIUS * 2, mostlyOn ? COLOR_ON : COLOR_OFF, true, bitmapString);
			if (existed)
				return;
			
			drawTri();
			drawRects();
			
			var outline:FlxSprite = new FlxSprite( -1, -1, _outline);
			outline.color = 0xff7070a0;
			stamp(outline);
		}
		
		private function drawTri():void {
			var absAngle:Number = Math.PI * 2 * (1 - fraction);
			var segment:int = fraction * 4;
			if (segment == fraction * 4)
				return;
			
			var relAngle:Number;
			if (mostlyOff)
				relAngle = (Math.PI / 2) * (4 - segment) - absAngle; //360 or 270 degrees
			else
				relAngle = absAngle - (Math.PI / 2) * (3 - segment); //0 or 90 degrees
			
			var edgeLength:Number = RADIUS / Math.cos(relAngle / 2);
			
			var triangleShape:Shape = new Shape();
			var p:Point;
			triangleShape.graphics.lineStyle(1, minorColor());
			triangleShape.graphics.beginFill(minorColor());
			triangleShape.graphics.moveTo(RADIUS, RADIUS);
			switch (segment) {
				case 0: triangleShape.graphics.lineTo(RADIUS, RADIUS - edgeLength); break; //top
				case 1: triangleShape.graphics.lineTo(RADIUS - edgeLength, RADIUS); break; //left
				
				case 2: triangleShape.graphics.lineTo(RADIUS + edgeLength, RADIUS); break; //right
				case 3: triangleShape.graphics.lineTo(RADIUS, RADIUS - edgeLength); break; //top
			}
			triangleShape.graphics.lineTo(Math.cos(absAngle - Math.PI / 2) * edgeLength + RADIUS,
										  Math.sin(absAngle - Math.PI / 2) * edgeLength + RADIUS);
			triangleShape.graphics.lineTo(RADIUS, RADIUS);
			pixels.draw(triangleShape);
		}
		
		protected function drawRects():void {
			if (fraction < 0.25 || fraction > 0.75)
				return;
			if (mostlyOff)
				pixels.fillRect(new Rectangle(0, 0, RADIUS, RADIUS), COLOR_ON);
			else if (mostlyOn)
				pixels.fillRect(new Rectangle(RADIUS, 0, RADIUS, RADIUS), COLOR_OFF);
			else
				pixels.fillRect(new Rectangle(0, 0, RADIUS, RADIUS * 2), COLOR_ON);
		}
		
		public function set fraction(Fraction:Number):void {
			if (_fraction != Fraction) {
				_fraction = Fraction;
				init();
			}
		}
		
		public function get fraction():Number {
			return _fraction;
		}
		
		public function set handFraction(Fraction:Number):void {
			if (_handFraction != Fraction) {
				_handFraction = Fraction;
				initHand();
				if (handIndicatesOn() != on)
					init();
			}
		}
		
		public function get handFraction():Number {
			return _handFraction;
		}
		
		private function initHand():void {
			if (!hand) {
				hand = new FlxSprite( -1, -1, _hand);
				hand.color = 0xff7070a0;
			}
			hand.angle = 360 * handFraction;
		}
		
		override public function draw():void {
			super.draw();
			if (hand) {
				hand.x = x;
				hand.y = y;
				hand.draw();
			}
		}
		
		protected function get mostlyOn():Boolean {
			return _fraction > 0.5;
		}
		
		protected function get mostlyOff():Boolean {
			return _fraction < 0.5;
		}
		
		protected function handIndicatesOn():Boolean {
			return handFraction >= 1 - fraction;
		}
		
		protected function minorColor():uint {
			return mostlyOn ? COLOR_OFF : COLOR_ON;
		}
		
		protected function get COLOR_ON():uint {
			return on ? BRIGHT_COLOR_ON : DARK_COLOR_ON;
		}
		
		protected function get COLOR_OFF():uint {
			return on ? DARK_COLOR_OFF : BRIGHT_COLOR_OFF;
		}
		
		private const RADIUS:int = 16;
		private const DARK_COLOR_ON:uint = 0xfff0ea67;
		private const DARK_COLOR_OFF:uint = 0xff5482c4;
		private const BRIGHT_COLOR_ON:uint = 0xfffff85f;
		private const BRIGHT_COLOR_OFF:uint = 0xff143666;
		private const OUTER_COLOR:uint = 0xff7070a0;
		
		[Embed(source = "../../lib/art/outline.png")] private const _outline:Class;
		[Embed(source = "../../lib/art/hand.png")] private const _hand:Class;
		
	}

}