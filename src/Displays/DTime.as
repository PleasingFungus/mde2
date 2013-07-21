package Displays {
	import Controls.ControlSet;
	import Controls.Key;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import UI.GraphicButton;
	import UI.MenuButton;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class DTime extends FlxGroup {
		
		public var x:int;
		public var y:int;
		
		private var timeText:FlxText;
		private var timeBox:FlxSprite;
		private var stepButton:GraphicButton;
		private var backstepButton:GraphicButton;
		private var playButton:GraphicButton;
		private var fastButton:GraphicButton;
		private var rewindButton:GraphicButton;
		private var rFastButton:GraphicButton;
		private var pauseButton:GraphicButton;
		private var stopButton:GraphicButton;
		
		private var playing:int;
		private var ticksPerSec:Number;
		
		private var derock:int;
		public function DTime(X:int, Y:int) {
			super();
			x = X;
			y = Y;
			ticksPerSec = 2;
			create();
		}
		
		public function create():void {
			var textWidth:int = 50;
			timeText = new FlxText(x -textWidth / 2, y, textWidth, U.state.time.toString());
			timeText.setFormat(U.LABEL_FONT.id, U.LABEL_FONT.size);
			
			var timeBorder:int = 2;
			timeBox = new FlxSprite(timeText.x - timeBorder, timeText.y);
			timeBox.makeGraphic(timeText.width + timeBorder * 2, timeText.height + timeBorder * 2, 0xff666666, true, "TIME BOX");
			timeBox.framePixels.fillRect(new Rectangle(timeBorder, timeBorder, timeText.width, timeText.height), 0xff202020);
			
			add(timeBox);
			add(timeText);
			
			stepButton = new GraphicButton(timeBox.x, y, _step_sprite, U.state.time.step, "Step forward 1 tick", ControlSet.TICK);
			stepButton.X -= stepButton.fullWidth;
			add(stepButton);
			
			timeBox.y = stepButton.Y + stepButton.fullHeight / 2 - timeBox.height / 2;
			timeText.y = timeBox.y + timeBorder;
			
			playButton = new GraphicButton(stepButton.X, stepButton.Y, _play_sprite, function play():void {
				if (!derock) return;
				
				ticksPerSec = 2;
				startPlaying();
				derock = 0;
			}, "Play at 1x speed", ControlSet.PLAY);
			playButton.X -= playButton.fullWidth;
			add(playButton);
			
			fastButton = new GraphicButton(playButton.X, playButton.Y, _fast_sprite, function play():void {
				if (!derock) return;
				
				ticksPerSec = 20;
				startPlaying();
				derock = 0;
			}, "Play at 10x speed", ControlSet.FAST);
			fastButton.X -= fastButton.fullWidth;
			add(fastButton);
			
			pauseButton = new GraphicButton(playButton.X, playButton.Y, _pause_sprite, function pause():void {
				if (!derock) return;
				
				playing = 0;
				derock = 0;
			}, "Pause", ControlSet.PAUSE);
			pauseButton.exists = false;
			add(pauseButton);
			
			stopButton = new GraphicButton(timeBox.x + timeBox.width, stepButton.Y, _stop_sprite, function reset():void {
				U.state.time.reset();
				playing = 0;
			}, "Reset time to 0", ControlSet.STOP);
			add(stopButton);
			
			backstepButton = new GraphicButton(stopButton.X + stopButton.fullWidth, stopButton.Y, _backstep_sprite, U.state.time.backstep, "Step back 1 tick", ControlSet.BACKTICK);
			add(backstepButton);
			
			rewindButton = new GraphicButton(backstepButton.X + backstepButton.fullWidth, backstepButton.Y, _back_sprite, function back():void {
				if (!derock) return;
				
				playing = -1;
				ticksPerSec = 2;
				timeSinceToggle = 0;
				derock = 0;
			}, "Reverse at 1x speed", ControlSet.PLAYBACK);
			add(rewindButton);
			rewindButton.exists = false;
			
			rFastButton = new GraphicButton(rewindButton.X + rewindButton.fullWidth, rewindButton.Y, _reverse_fast_sprite, function reverseFast():void {
				if (!derock) return;
				
				ticksPerSec = 20;
				playing = -1;
				derock = 0;
			}, "Reverse at 10x speed", ControlSet.BACKFAST);
			add(rFastButton);
			
			var min:int = int.MAX_VALUE;
			for each (var member:FlxBasic in members)
				if (member is MenuButton)
					min = Math.min((member as MenuButton).X, min);
			
			for each (member in members)
				if (member is FlxObject)
					(member as FlxObject).x += x - min;
				else if (member is MenuButton)
					(member as MenuButton).X += x - min;
		}
		
		override public function update():void {
			super.update();
			if (playing)
				run();
			timeText.text = U.state.time.toString();
			
			stopButton.exists = U.state.time.moment > 0;
			backstepButton.exists = U.state.time.moment > 0;
			
			
			playButton.exists = playing != 1 || ticksPerSec != 2;
			fastButton.exists = playing != 1 || ticksPerSec != 20;
			
			rewindButton.exists = (playing != -1 || ticksPerSec != 2) && U.state.time.moment > 0;
			rFastButton.exists = (playing != -1 || ticksPerSec != 20) && U.state.time.moment > 0;
			
			pauseButton.exists = playing != 0;
			if (!playButton.exists)
				pauseButton.X = playButton.X;
			else if (!fastButton.exists)
				pauseButton.X = fastButton.X;
			else if (!rewindButton.exists)
				pauseButton.X = rewindButton.X;
			else
				pauseButton.X = rFastButton.X;
			
			derock++;
		}
		
		protected var timeSinceToggle:Number;
		protected function run():void {
			timeSinceToggle += FlxG.elapsed;
			var timePerTick:Number = 1 / ticksPerSec;
			while (timeSinceToggle >= timePerTick) {
				if (playing > 0)
					U.state.time.step();
				else
					if (!U.state.time.backstep())
						playing = 0;
				timeSinceToggle -= timePerTick;
			}
		}
		
		public function startPlaying(speed:int = 1):void {
			playing = speed;
			timeSinceToggle = 0;
		}
		
		public function stop():void {
			startPlaying(0);
		}
		
		public function get isPlaying():Boolean { return playing != 0; }
		
		private const width:int = 274;
		
		[Embed(source = "../../lib/art/ui/skip.png")] private const _step_sprite:Class;
		[Embed(source = "../../lib/art/ui/skip_back.png")] private const _backstep_sprite:Class;
		[Embed(source = "../../lib/art/ui/play.png")] private const _play_sprite:Class;
		[Embed(source = "../../lib/art/ui/fast.png")] private const _fast_sprite:Class;
		[Embed(source = "../../lib/art/ui/back.png")] private const _back_sprite:Class;
		[Embed(source = "../../lib/art/ui/rfast.png")] private const _reverse_fast_sprite:Class;
		[Embed(source = "../../lib/art/ui/stop.png")] private const _stop_sprite:Class;
		[Embed(source = "../../lib/art/ui/pause.png")] private const _pause_sprite:Class;
	}

}