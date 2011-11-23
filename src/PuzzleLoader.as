package
{
	import com.adobe.serialization.json.*;
	
	import flash.events.Event;
	import flash.net.*;
	
	public class PuzzleLoader
	{
		private var loader:URLLoader = new URLLoader();
		private var json:JSONDecoder;
		private var listener:GameState;
		
		public function PuzzleLoader()
		{
			loader.addEventListener(Event.COMPLETE, finishLoadPuzzle);
		}
		
		public function loadPuzzle(s:String, l:GameState):void {
			loader.load(new URLRequest(s));
			listener = l;
		}
		
		public function finishLoadPuzzle(e:Event):void {
			json = new JSONDecoder(e.target.data, false);
			trace(json.getValue().puzzle.tiles.length);
			listener.positionTiles(json.getValue().puzzle.width, json.getValue().puzzle.height, json.getValue().puzzle.tiles);
		}
	}
}

