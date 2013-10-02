package LevelStates {
	import Components.Wire;
	import Components.Link;
	import Components.LinkPotential;
	import Modules.Module;
	import Levels.Level;
	import Menu.CrashState;
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
		public var linkPotentials:Vector.<LinkPotential>;
		public var clock:int;
		public var saveString:String;
		public function LevelLoader(SaveString:String, Modules:Vector.<Module>, Wires:Vector.<Wire>,
								    LinkPotentials:Vector.<LinkPotential>, Clock:int) {
			saveString = SaveString;
			modules = Modules;
			wires = Wires;
			linkPotentials = LinkPotentials;
			clock = Clock;
		}
		
		public function loadIntoLevel(level:Level):Level {
			level.modules = modules;
			level.links = LinkPotential.buildFromContext(linkPotentials, modules);
			return level;
		}
		
		private static function loadBinary(saveString:String):LevelLoader {
			var bytes:ByteArray = Base64.decodeToByteArray(saveString);
			
			bytes.inflate();
			
			var saveVersion:int = bytes.readInt();
			switch (saveVersion) {
				case 4: return loadPreLinks(saveString, bytes);
				case 5: return loadWithLinks(saveString, bytes);
				//case 6: return loadPortLinks(saveString, bytes);
				default:
					C.log("Save version mismatch: save version " + saveVersion + " does not match game save version " + U.SAVE_VERSION + "!");
					return null;
			}
		}
		
		private static function loadPreLinks(saveString:String, bytes:ByteArray):LevelLoader {
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
			if (miscLength && bytes.position != bytes.length)
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
			
			return new LevelLoader(saveString, newModules, newWires, new Vector.<LinkPotential>, clockPeriod);
		}
		
		private static function loadWithLinks(saveString:String, bytes:ByteArray):LevelLoader {
			//find lengths of all sections
			var moduleSectionLength:int = bytes.readInt();
			var moduleSectionEnd:int = bytes.position - 4 + moduleSectionLength;
			
			bytes.position = moduleSectionEnd;
			var wireSectionLength:int = bytes.readInt();
			var wireSectionEnd:int = bytes.position - 4 + wireSectionLength;
			
			
			bytes.position = wireSectionEnd;
			var linkSectionLength:int = bytes.readInt();
			var linkSectionEnd:int = bytes.position - 4 + linkSectionLength;
			
			bytes.position = linkSectionEnd;
			var miscLength:int = bytes.readInt(); //currently unused; added for future-compat
			//load misc data (first, so that clocks are constrained correctly)
			var clockPeriod:int = 1;
			if (miscLength && bytes.position != bytes.length)
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
			
			bytes.position += 4;
			var linkPotentials:Vector.<LinkPotential> = Link.linksFromBytes(bytes, linkSectionEnd);
			if (bytes.position != linkSectionEnd)
				throw new Error("Unread data in link load!");
			
			return new LevelLoader(saveString, newModules, newWires, linkPotentials, clockPeriod);
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
			
			return new LevelLoader(saveString, modules, wires, new Vector.<LinkPotential>, clockPeriod);
		}
		
		public static function loadSimple(saveString:String):LevelLoader {
			if (DEBUG.IGNORE_SAVES)
				return new LevelLoader(saveString, new Vector.<Module>, new Vector.<Wire>, new Vector.<LinkPotential>, 1);
			
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
				
				FlxG.switchState(new CrashState(error));
			}
			return null;
		}
	}

}