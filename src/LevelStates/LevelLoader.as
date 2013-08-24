package LevelStates {
	import Components.Wire;
	import Modules.Module;
	import org.flixel.FlxG;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class LevelLoader {
		
		public var modules:Vector.<Module>;
		public var wires:Vector.<Wire>;
		public var clock:int;
		public var saveString:String;
		public function LevelLoader(SaveString:String, Modules:Vector.<Module>, Wires:Vector.<Wire>, Clock:int) {
			saveString = SaveString;
			modules = Modules;
			wires = Wires;
			clock = Clock;
		}
		
		private static function loadBinary(saveString:String):LevelLoader {
			var bytes:ByteArray = Base64.decodeToByteArray(saveString);
			
			bytes.inflate();
			
			var saveVersion:int = bytes.readInt();
			if (saveVersion != U.SAVE_VERSION) {
				C.log("Save version mismatch: save version " + saveVersion + " does not match game save version " + U.SAVE_VERSION + "!");
				return null;
			}
			
			//find lengths of all sections
			var moduleSectionLength:int = bytes.readInt();
			var moduleSectionEnd:int = bytes.position - 4 + moduleSectionLength;
			
			bytes.position = moduleSectionEnd;
			var wireSectionLength:int = bytes.readInt();
			var wireSectionEnd:int = bytes.position - 4 + wireSectionLength;
			
			bytes.position = wireSectionEnd;
			var miscLength:int = bytes.readInt(); //currently unused; added for future-compat
			//load misc data (first, so that clocks are constrained correctly)
			var clockPeriod:int = 1;
			if (miscLength)
				clockPeriod = bytes.readInt();
			if (bytes.position != bytes.length)
				throw new Error("Trailing data in save!");
			
			//load modules & wires, then add them (wires first, for historical reasons; may or may not still be needed)
			bytes.position = 4+4;
			var newModules:Vector.<Module> = Module.modulesFromBytes(bytes, moduleSectionEnd);
			if (bytes.position != moduleSectionEnd)
				throw new Error("Unread data in module load!");
			
			bytes.position += 4;
			var newWires:Vector.<Wire> = Wire.wiresFromBytes(bytes, wireSectionEnd);
			if (bytes.position != wireSectionEnd)
				throw new Error("Unread data in wire load!");
			
			return new LevelLoader(saveString, newModules, newWires, clockPeriod);
		}
		
		private static function loadOldFormat(saveString:String):LevelLoader {			
			var saveArray:Array = saveString.split(U.MAJOR_SAVE_DELIM);
			
			//ordering is key
			//misc info first
			var miscStringsString:String = saveArray[2];
			var clockPeriod:int = 1;
			if (miscStringsString.length) {
				var miscStrings:Array = miscStringsString.split(U.SAVE_DELIM);
				if (miscStrings.length)
					clockPeriod = C.safeInt(miscStrings[0]);
			}
			
			//load wires
			var wireStrings:String = saveArray[1];
			var wires:Vector.<Wire>;
			if (wireStrings.length)
				for each (var wireString:String in wireStrings.split(U.SAVE_DELIM))
					wires.push(Wire.fromString(wireString));
			
			//load modules
			var moduleStrings:String = saveArray[0];
			var modules:Vector.<Module>;
			if (moduleStrings.length)
				for each (var moduleString:String in moduleStrings.split(U.SAVE_DELIM))
					modules.push(Module.fromString(moduleString));
			
			return new LevelLoader(saveString, modules, wires, clockPeriod);
		}
		
		public static function loadSimple(saveString:String):LevelLoader {
			if (U.BINARY_SAVES && saveString.indexOf(U.MAJOR_SAVE_DELIM) == -1) 
				return loadBinary(saveString);
			else
				return loadOldFormat(saveString);
		}
		
		public static function loadSafe(saveString:String):LevelLoader {
			try {
				return loadSimple(saveString);
			} catch (error:Error) {
				C.log("Error in loading!");
				C.log(error);
				
				var loader:URLLoader = C.sendRequest(
					"http://pleasingfungus.com/mde2/error.php",
					{'lvl' : U.save.data[U.state.level.name],
					 'version' : U.VERSION,
					 'error' : error.message +"\n\n" + error.getStackTrace() },
					 function onLoad(e : Event):void {
						var response:String = loader.data;
						C.log(response);
					 }
				);
				loader.addEventListener(IOErrorEvent.IO_ERROR, function onIOError(e:Event):void {
					C.log(e);
				});
			}
			return null;
		}
	}

}