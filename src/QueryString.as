﻿package
{
	import flash.external.*; //so we can use externalInterface
	
	public class QueryString {
		//instance variables
		public var _queryString:String;
		public var _all:String;
		public var _params:Object;
		public var _debug:String = "";

		public function QueryString() {
			readQueryString();
		}
		
		public function get getQueryString():String {
			return _queryString;
		}
		
		public function get url():String {
			return _all;
		}
		
		public function get path():String {
			var qIndex:int = _all.indexOf("?");
			if (qIndex != -1)
				return _all.slice(0, qIndex)
			return _all;
		}
		
		public function get parameters():Object {
			return _params;
		}

		private function readQueryString():void {
			_params = { };
			if (!ExternalInterface.available)
				return;
			
			_all = ExternalInterface.call("window.location.href.toString");
			_queryString = ExternalInterface.call("window.location.search.substring", 1);
			
			var allParams:Array = _queryString.split('&');
			//var length:uint = params.length;

			for (var i:int = 0, index:int = -1; i < allParams.length; i++) {
				var keyValuePair:String = allParams[i];
				if((index = keyValuePair.indexOf("=")) > 0) {
					var paramKey:String = keyValuePair.substring(0,index);
					var paramValue:String = keyValuePair.substring(index+1);
					_params[paramKey] = paramValue;
				}
			}
		}
	}
}