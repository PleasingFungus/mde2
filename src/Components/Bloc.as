package Components {
	import Components.Wire;
	import flash.geom.Point;
	import Layouts.PortLayout;
	import Components.WireHistory;
	import Modules.CustomModule;
	import Modules.Module;
	import Actions.BlocLiftAction;
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
			
			newLinks = new Vector.<Link>;
			for each (var module:Module in modules) {
				module.register();
				for each (var port:PortLayout in module.layout.ports)
					if (port.port.newLink) {
						newLinks.push(port.port.newLink);
						port.port.newLink = null;
					}
			}
			for each (var link:Link in links)
				Link.place(link);
			
			exists = true;
			return true;
		}
		
		public function remove(p:Point):Boolean {
			if (!rooted)
				return false;
			
			for each (var link:Link in links)
				Link.remove(link);
			for each (var newLink:Link in newLinks)
				Link.remove(newLink);
			var liftedModules:Vector.<Module> = new Vector.<Module>;
			for each (var module:Module in modules)
				if (!module.FIXED) {
					module.deregister();
					liftedModules.push(module);
				}
			modules = liftedModules;
			
			rooted = false;
			exists = false;
			origin = lastRootedLoc = p;
			return true;
		}
		
		public function unravel():void {
			if (rooted)
				exists = false;
			else
				destroy();
		}
		
		public function destroy():void {
			for each (var module:Module in modules)
				if (!module.FIXED)
					module.exists = false;
			exists = false;
		}
		
		public function mobilize():void {
			for each (var module:Module in modules)
				module.exists = true;
			for each (var link:Link in links)
				link.deleted = link.placed = false;
			exists = true;
		}
		
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
			
			var oldLoc:Point = origin;
			origin = p;
			
			return true;
		}
		
		public function lift():void {	
			new BlocLiftAction(this, U.pointToGrid(U.mouseLoc)).execute();
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
			var averageLoc:Point = new Point;
			for each (var moduleString:String in moduleStrings) {
				var module:Module = Module.fromString(moduleString, allowableTypes);
				if (module && module.writesToMemory > writersRemaining)
					module = null;
				
				modules.push(module);
				if (module) {
					nonNullModules.push(module);
					U.state.modules.push(module);
					averageLoc = averageLoc.add(module);
					writersRemaining -= module.writesToMemory;
				}
			}
			
			var links:Vector.<Link> = new Vector.<Link>;
			if (nonNullModules.length) {
				averageLoc.x = Math.round(averageLoc.x / nonNullModules.length);
				averageLoc.y = Math.round(averageLoc.y / nonNullModules.length);
				
				if (linkSection.length) {
					var linkStrings:Array = linkSection.split(U.SAVE_DELIM);
					for each (var linkString:String in linkStrings) {
						var link:Link = Link.fromString(linkString, modules);
						if (link)
							links.push(link);
					}
				}
			}
			
			var bloc:Bloc = new Bloc(nonNullModules, links, Rooted);
			bloc.origin = averageLoc;
			if (bloc.rooted)
				bloc.lastRootedLoc = bloc.origin;
			return bloc;
		}
	}

}