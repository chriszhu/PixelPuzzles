package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class GameState extends FlxState
	{
		//array of tiles
		private var tiles:FlxGroup;
		//maximum number of tiles
		private var maxNumTiles:int = 250;
		//puzzle loader for loading puzzles via json files
		private var puzzleLoader:PuzzleLoader = new PuzzleLoader();
		//information about the current puzzle
		private var puzzleWidth:int;
		private var puzzleHeight:int;
		//for convenience in loops
		private var i:int, j:int;
		//which tile is selected in the grid
		private var controlPosition:FlxPoint = new FlxPoint(0, 0);
		//current and previous tile selected, used in update method
		private var currentTile:Tile = null;
		private var previousTile:Tile = null;
		
		override public function create():void {
			//show mouse
			FlxG.mouse.show();
			//create tiles array
			tiles = new FlxGroup(maxNumTiles);
			for(i=0;i<maxNumTiles;i++) {
				//create tile
				var t:Tile = new Tile();
				tiles.add(t);
			}
			add(tiles);
			//load test puzzle for now
			puzzleLoader.loadPuzzle("puzzles/test.json", this.positionTiles);
		}
		
		public function positionTiles(width:int, height:int, jsonTiles:Array):void {
			//counter for incrementing through jsonTiles
			var tileCounter:int = 0;
			//loop through and create tiles based on width and height
			for(i=0;i<height;i++) {
				for(j=0;j<width;j++) {
					//create new tile
					var t:Tile = tiles.recycle() as Tile;
					//set variables based on json information
					t.setState(Tile.kStateUnfilled);
					t.setPosition(new FlxPoint(j, i));
					t.setIsEnd(jsonTiles[tileCounter].node);
					t.setColor(jsonTiles[tileCounter].color);
					//if it's an end piece, set some additional info
					if(t.getIsEnd()) {
						t.setType(Tile.kTypeSingle);
						t.setEndLength(jsonTiles[tileCounter].length);
						t.setDisplayLength(jsonTiles[tileCounter].length);
					}
					
					tileCounter++;
				}
			}
			
			puzzleWidth = width;
			puzzleHeight = height;
		}
		
		override public function update():void {
			super.update();
			//trace("mouse position: " + FlxG.mouse.screenX + " --- " + FlxG.mouse.screenY);
			//see if we just clicked on a tile
			if(FlxG.mouse.justPressed()) {
				trace("just pressed");
				//convert mouse coords to grid coords
				currentTile = getTileAtPosition(new FlxPoint(FlxG.mouse.screenX, FlxG.mouse.screenY));
			}
			//see if we are dragging over the grid
			else if(FlxG.mouse.pressed()) {
				trace("pressed");
				//convert mouse coords to grid coords
				currentTile = getTileAtPosition(new FlxPoint(FlxG.mouse.screenX, FlxG.mouse.screenY));
				if(currentTile && previousTile) {
					trace("current tile position: " + currentTile.getPosition().toString() + " --- previous: " + previousTile.getPosition().toString());
				}
				//see if the new tile is different than the previousTile
				if(previousTile && currentTile && previousTile != currentTile) {
					trace("different tiles!");
					//change color of new tile to previousTile
					currentTile.setColor(previousTile.getColor());
					//add child to previousTile and currentTile
					previousTile.addChild(currentTile.getPosition());
					currentTile.addChild(previousTile.getPosition());
				}
			}
			
			//keep track of previousTile to detect changes
			previousTile = currentTile;
		}
		
		public function getTileAtPosition(point:FlxPoint):Tile {
			//loop through tiles and find out which one is colliding with given point
			for(i=0, j=tiles.length;i<j;i++) {
				if(tiles.members[i].overlapsPoint(point)) {
					return tiles.members[i];
				}
			}
			return null;
		}
	}
}