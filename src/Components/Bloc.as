package Components {
	import Components.Wire;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import Components.WireHistory;
	import Modules.CustomModule;
	import Modules.Module;
	import Actions.DelBlocAction;
	/**
	 * ...
	 * @author Nicholas "PleasingFungus" Feinberg
	 */
	public class Bloc {
		
		public var modules:Vector.<Module>;
		public var links:Vector.<Link>;
		private var newLinks:Vector.<Link>;
		public var connections:Vector.<Connection>;
		public var origin:Point;
		public var lastLoc:Point;
		public var lastRootedLoc:Point;
		public var rooted:Boolean;
		public var exists:Boolean;
		public function Bloc(modules:Vector.<Module>, links:Vector.<Link>, Rooted:Boolean = true) {
			this.modules = modules;
			this.links = links;
			connections = new Vector.<Connection>;
			rooted = Rooted;
			origin = getAverageLoc();
			exists = true;
		}
		
		public function validPosition(p:Point):Boolean {
			if (!moveTo(p))
				return false;
			
			for each (var module:Module in modules)
				if (!module.validPosition)
					return false;
			return true;
		}
		
		public function place(p:Point):Boolean {
			if (rooted)
				return false;
			
			moveTo(p);
			rooted = true;
			
			for each (var module:Module in modules)
				module.place();
			for each (var link:Link in links)
				link.placed = true;
			
			return true;
		}
		
		public function lift(p:Point):Boolean {
			if (!rooted)
				return false;
			
			for each (var link:Link in links)
				link.placed = false;
			
			var liftedModules:Vector.<Module> = new Vector.<Module>;
			for each (var module:Module in modules)
				if (!module.FIXED) {
					module.lift();
					liftedModules.push(module);
				}
			modules = liftedModules;
			
			rooted = false;
			origin = lastRootedLoc = p;
			return true;
		}
		
		public function unravel():void {
			if (rooted)
				exists = false;
			else if (lastRootedLoc)
				new DelBlocAction(this).execute();
			else
				unmake();
		}
		
		public function manifest(p:Point):Boolean {
			exists = true;
			
			place(p);
			
			for each (var module:Module in modules)
				if (!module.FIXED)
					module.manifest();
			for each (var link:Link in links)
				Link.place(link, true);
			
			return true;
		}
		
		public function demanifest():Boolean {
			for each (var link:Link in links)
				if (!link.deleted) //dubious
					Link.remove(link);
			
			for each (var module:Module in modules)
				if (!module.FIXED)
					module.demanifest();
			
			exists = false;
			return true;
		}
		
		public function unmake():Boolean {
			if (rooted || lastRootedLoc)
				return false; //can only unmake things that never truly were
			
			for each (var module:Module in modules)
				module.exists = false;
			exists = false;
			return true;
		}
		
		//public function destroy():void {
			//for each (var module:Module in modules)
				//if (!module.FIXED) {
					//module.disconnect();
					//module.exists = false;
				//}
			//exists = false;
		//}
		
		public function moveTo(p:Point):Boolean {
			if (origin.equals(p) || (lastLoc && lastLoc.equals(p)))
				return true;
			lastLoc = p;
				
			//shift modules/wires			
			var delta:Point = p.subtract(origin);
			
			for each (var module:Module in modules) {
				module.x += delta.x;
				module.y += delta.y;
			}
			
			origin = p;
			return true;
		}
		
		
		public function getLinks():Vector.<Link> {
			//get all links associated with all modules in the bloc
			var links:Vector.<Link> = new Vector.<Link>;
			for each (var module:Module in modules)
				for each (var link:Link in module.getLinks())
					if (!link.inVec(links))
						links.push(link);
			return links;
		}
		
		public function getExternalLinks():Vector.<Link> {
			var links:Vector.<Link> = new Vector.<Link>;
			for each (var module:Module in modules)
				for each (var link:Link in module.getLinks())
					if (!link.inVec(links) &&
						(modules.indexOf(link.source) != -1 || modules.indexOf(link.destination) == -1))
						links.push(link);
			return links;
		}
		
		public function getAverageLoc():Point {
			var averageLoc:Point = new Point;
			
			for each (var module:Module in modules)
				averageLoc = averageLoc.add(module);
			
			if (modules.length) {
				averageLoc.x = Math.round(averageLoc.x / modules.length);
				averageLoc.y = Math.round(averageLoc.y / modules.length);
			}
			return averageLoc;
		}
		
		public function toString():String {
			var moduleStrings:Vector.<String> = new Vector.<String>;
			for each (var module:Module in modules)
				moduleStrings.push(module.saveString());
			
			var linkStrings:Vector.<String> = new Vector.<String>;
			for each (var link:Link in links)
				linkStrings.push(link.saveString(modules));
			
			return [moduleStrings.join(U.SAVE_DELIM), linkStrings.join(U.SAVE_DELIM)].join(U.MAJOR_SAVE_DELIM);
		}
		
		public static function fromString(str:String, Rooted:Boolean = false):Bloc {
			var stringSections:Array = str.split(U.MAJOR_SAVE_DELIM);
			var moduleSection:String = stringSections[0];
			var linkSection:String = stringSections[1];
			
			var moduleStrings:Array = moduleSection.split(U.SAVE_DELIM);
			
			var allowableTypes:Vector.<Class> = U.state.level.allowedModules;
			var writersRemaining:int = U.state.level.writerLimit ? U.state.level.writerLimit - U.state.numMemoryWriters() : int.MAX_VALUE;
			
			var modules:Vector.<Module> = new Vector.<Module>;
			var nonNullModules:Vector.<Module> = new Vector.<Module>;
			for each (var moduleString:String in moduleStrings) {
				var module:Module = Module.fromString(moduleString, allowableTypes);
				if (module && module.writesToMemory > writersRemaining)
					module = null;
				
				modules.push(module);
				if (module) {
					nonNullModules.push(module);
					U.state.registerModule(module).exists = false; //register the module & nil out the dmodule generated - we'll make a better one in dbloc
					writersRemaining -= module.writesToMemory;
				}
			}
			
			var links:Vector.<Link> = new Vector.<Link>;
			if (nonNullModules.length && linkSection.length) {
				var linkStrings:Array = linkSection.split(U.SAVE_DELIM);
				for each (var linkString:String in linkStrings) {
					var link:Link = Link.fromString(linkString, modules);
					if (link) {
						Link.place(link);
						links.push(link);
					}
				}
			}
			
			var bloc:Bloc = new Bloc(nonNullModules, links, Rooted);
			if (bloc.rooted)
				bloc.lastRootedLoc = bloc.origin;
			return bloc;
		}
	}

}