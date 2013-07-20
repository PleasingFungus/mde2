package  
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import flash.geom.Point;
	import flash.net.*;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import org.flixel.FlxPoint;
	import org.flixel.FlxRect;
	import org.flixel.FlxText;
	
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class C 
	{
		public static const INT_NULL:int = int.MIN_VALUE;
		
		private static var initialBuffer:String = null;
		private static var printReady:Boolean = false;
		public static function setPrintReady():void {
			if (printReady)
				return;
			
			printReady = true;
			if (initialBuffer) {
				log(initialBuffer);
				initialBuffer = null;
			}
		}
		
		public static function log(...args):void {
			var outStr:String = "";
			if (args.length > 1)
				for each (var o:Object in args.slice(0, args.length - 1))
					outStr += o + ", ";
			
			outStr += args[args.length - 1];
			if (printReady)
				FlxG.log(outStr);
			else if (initialBuffer)
				initialBuffer += "\n" + outStr;
			else
				initialBuffer = outStr;
		}
		
		public static function weightedChoice(weights:Array):int {
			var total:Number = 0;
			for each (var weight:Number in weights)
				total += weight;
			
			var roll:Number = FlxG.random() * total;
			for (var i:int = 0; i < weights.length; i++) {
				if (roll < weights[i])
					return i;
				roll -= weights[i];
			}
			
			return i; //error!
		}
		
		public static function randomChoice(options:Array):* {
			return options[int(FlxG.random() * options.length)];
		}
		
		public static function randomIntChoice(options:Vector.<int>):int {
			return options[int(FlxG.random() * options.length)];
		}
		
		public static function randomRange(min:int, max:int):int {
			var rand:Number = FlxG.random();
			var result:int = rand * (max - min) + min;
			return result;
		}
		
		//public static function randomVChoice(options:Vector):* {
			//return options[int(FlxG.random() * options.length)];
		//} //FIXME
		
		
		public static function renderTime(totalSeconds:int):String {
			var seconds:int = totalSeconds % 60;
			var minutes:int = totalSeconds / 60;
			return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
		}
		
		public static function decimalize(a:Number, sigfigs:int = 4):String {
			var suffix:String = '';
			if (a >= 10000000) {
				a /= 1000000;
				suffix = "M";
			} else if (a >= 10000) {
				a /= 1000;
				suffix = "K";
			}
			
			var str:String = a + '';
			var decimalIndex:int = str.indexOf('.');
			if (decimalIndex == sigfigs || decimalIndex == -1)
				str = str.substr(0, sigfigs);
			else
				str = str.substr(0, sigfigs + 1);
			
			return str + suffix;
		}
		
		public static function trim(s:String):String {
			return s ? s.replace(/^\s+|\s+$/gs, '') : s;
		}
		
		public static function replaceAll(string:String, pattern:String, replacement:String):String {
			do {
				var oldString:String = string;
				string = string.replace(pattern, replacement);
			} while (string != oldString);
			return string;
		}
		
		public static function replaceAllLinear(string:String, pattern:String, replacement:String):String {
			for (var index:int = string.indexOf(pattern); index != -1; index = string.indexOf(pattern, index + replacement.length))
				string = string.slice(0, index) + replacement + string.slice(index + pattern.length);
			return string;
		}
		
		
		public static function interpolateColors(a:uint, b:uint, aFraction:Number):uint {
			var alpha:int = ((a >> 24) & 0xff) * aFraction + ((b >> 24) & 0xff) * (1 - aFraction);
			var red:int = ((a >> 16) & 0xff) * aFraction + ((b >> 16) & 0xff) * (1 - aFraction);
			var green:int = ((a >> 8) & 0xff) * aFraction + ((b >> 8) & 0xff) * (1 - aFraction);
			var blue:int = ((a >> 0) & 0xff) * aFraction + ((b >> 0) & 0xff) * (1 - aFraction);
			return (alpha << 24) | (red << 16) | (green << 8 ) | blue;
		}
		
		public static function HSVToRGB(H:Number, S:Number, V:Number):uint {
			var Chroma:Number = S * V;
			var Hp:Number = H * 6;
			var X:Number = Chroma * (1 - Math.abs(Hp % 2 - 1));
			var R:Number, G:Number, B:Number;
			switch (Math.floor(Hp)) {
				case 0: 
					R = Chroma;
					G = X;
					B = 0;
					break;
				case 1:
					R = X;
					G = Chroma;
					B = 0;
					break;
				case 2:
					R = 0;
					G = Chroma;
					B = X;
					break;
				case 3:
					R = 0;
					G = X;
					B = Chroma;
					break;
				case 4:
					R = X;
					G = 0;
					B = Chroma;
					break;
				case 5:
					R = Chroma;
					G = 0;
					B = X;
					break;
			}
			
			var m:Number = V - Chroma;
			
			var r:int = (R + m) * 255;
			var g:int = (G + m) * 255;
			var b:int = (B + m) * 255;
			return 0xff000000 | (r << 16) | (g << 8) | b;
		}
		
		
		public static function innerAngle(a:Point, b:Point):Number {
			return Math.acos(dot(a, b) / Math.abs(a.length * b.length));
		}
		
		public static function dot(a:Point, b:Point):Number {
			return a.x * b.x + a.y * b.y;
		}
		
		public static function segmentedChance(overallChance:Number, periodLength:Number):Number {
			return 1 - Math.pow(1 - overallChance, 1 / periodLength);
		}
		
		public static function euclidDistance(a:Point, b:Point):int {
			return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
		}
		
		public static function buildIntVector(...ints):Vector.<int> {
			var vec:Vector.<int> = new Vector.<int>;
			for each (var int_:int in ints)
				vec.push(int_);
			return vec;
		}
		
		public static function buildIntSet(...ints):Vector.<int> {
			var vec:Vector.<int> = new Vector.<int>;
			for each (var int_:int in ints)
				if (vec.indexOf(int_) == -1)
					vec.push(int_);
			return vec;
		}
		
		public static function safeInt(s:String):int {
			var i:int = int(s);
			if (i.toString() != s)
				throw new Error("Invalid string for conversion to int!");
			return i;
		}
		
		public static function buildStringVector(...strings):Vector.<String> {
			var vec:Vector.<String> = new Vector.<String>;
			for each (var str:String in strings)
				vec.push(str);
			return vec;
		}
		
		//only supports single-line text
		public static function textOverlapsPoint(text:FlxText, p:Point):Boolean {
			var bounds:Rectangle = new Rectangle;
			
			bounds.y = text.y;
			bounds.height = text.height;
			bounds.width = text.textWidth;
			
			switch (text.alignment) {
				case 'left': 
					bounds.x = text.x;
					break;
				case 'right': 
					bounds.x = text.x + text.width - bounds.width;
					break;
				case 'center':
					bounds.x = text.x + (text.width - bounds.width) / 2;
					break;
				case 'justify': default:
					bounds.x = text.x;
					bounds.width = text.width;
					break;
			}
			
			return bounds.containsPoint(p);
		}
		
		public static function eratosthenes(lim:int):Array {
			// Create a list of consecutive integers from 2 to n: (2, 3, 4, ..., n).
			var primeList:Array = [];
			primeList.length = lim + 1; //technically 2 longer than needed
			//Initially, let p equal 2, the first prime number.
			var p:int = 2;
			while (p <= lim) {
				//Starting from p, count up in increments of p
				for (var mult:int = p*2; mult <= lim; mult += p)
					//and mark each of these numbers greater than p itself in the list. note that some of them may have already been marked.
					primeList[mult] = true;
				
				do {
					p++;	
				} while (p <= lim && primeList[p]);
			}
			
			var primes:Array = [];
			for (p = 1; p <= lim; p++)
				if (!primeList[p])
					primes.push(p);
			
			return primes;
		}
		
		public static var PRIMES_TO_255:Array = eratosthenes(255);
		
		private static var FACTORS:Dictionary = new Dictionary;
		public static function factorsOf(n:int):Array {
			if (n < 0) return null;
			
			var factors:Array = [1];
			if (n == 1) factors;
			
			if (FACTORS[n]) return FACTORS[n];
			
			var lim:int = n / 2;
			
			for (var f:int = 2; f <= lim; f++)
				if (n % f == 0)
					factors.push(f);
			factors.push(n);
			
			FACTORS[n] = factors;
			
			return factors;
		}
		
		public static function warmupFactors(lim:int):void {
			for (var i:int = 2; i <= lim; i++)
				factorsOf(i);
		}
		
		public static function manhattan(p1:Point, p2:Point):Number {
			return Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y);
		}
		
		public static const NUMBERS:Array = ["ZERO", "ONE", "TWO", "THREE", "FOUR",
											 "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
		
		
		public static function sendRequest(url:String, args:Object, callback:Function = null):URLLoader {
			var loader:URLLoader = new URLLoader;
			loader.addEventListener(Event.COMPLETE, callback != null ? callback : function _(e : Event):void { });
				
			var variables:URLVariables = new URLVariables;
			for (var key:String in args) 
				variables[key] = args[key];
			
			var request : URLRequest = new URLRequest(url); 
			request.method = URLRequestMethod.POST;
			request.data = variables;
			
			log("Sending request: " + request);
			
			try {
				loader.load(request); 
			} catch (error:Error) {
				log("Request failed: " + error);
			}
			
			return loader;
		}
		
		public static function encodeString(input:String):String {
			if (ExternalInterface.available)
				return ExternalInterface.call("encodeURIComponent", input);
			return null;
		}
		
		public static function decodeString(input:String):String {
			if (ExternalInterface.available)
				return ExternalInterface.call("decodeURIComponent", input);
			return null;
		}
		
		public static function stringToBase64(input:String):String {
			if (ExternalInterface.available)
				return ExternalInterface.call("btoa", input);
			return null;
		}
		
		public static function base64ToString(b64:String):String {
			if (ExternalInterface.available)
				return ExternalInterface.call("atob", b64);
			return null;
		}
	}

}