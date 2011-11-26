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
		//array of lines that tiles belong to
		private var lines:Array = new Array();
		
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
		
		public function positionTiles(width:int, height:int, tileWidth:int, tileHeight:int, jsonTiles:Array):void {
			//counter for incrementing through jsonTiles
			var tileCounter:int = 0;
			//loop through and create tiles based on width and height
			for(i=0;i<height;i++) {
				for(j=0;j<width;j++) {
					//create new tile
					var t:Tile = tiles.recycle() as Tile;
					//set variables based on json information
					t.setSize(new FlxPoint(tileWidth, tileHeight));
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
			//keep track of previousTile to detect changes
			previousTile = currentTile;
			//see if we just clicked on a tile
			if(FlxG.mouse.justPressed()) {
				//convert mouse coords to grid coords
				currentTile = getTileAtPosition(new FlxPoint(FlxG.mouse.screenX, FlxG.mouse.screenY));
			}
			//see if we are dragging over the grid
			else if(FlxG.mouse.pressed()) {
				//convert mouse coords to grid coords
				currentTile = getTileAtPosition(new FlxPoint(FlxG.mouse.screenX, FlxG.mouse.screenY));
				//see if the new tile is different than the previousTile
				if(currentTile && !currentTile.isEqual(previousTile)) {
					//this tile is draggable if:
					//	it is the last child of a pre-existing line OR
					//	it is an end cap that is not part of a line
					if(previousTile.getIsEnd() && !previousTile.getLine()) {
						//create a new line, set some info about it, and add it to our array of lines to keep track of them
						var l:Line = new Line();
						l.setColor(previousTile.getColor());
						l.setTargetLength(previousTile.getEndLength());
						lines.push(l);
						//add the previousTile as a child first
						l.addChild(previousTile);
						//then see if we can add the currentTile
						if(l.canAddChild(currentTile)) {
							l.addChild(currentTile);
						}
						//not a valid line anymore
						else {
							lines.pop().destroy();
						}
					}
					else if(previousTile.getLine() && (previousTile.getLine().getLastChild() == previousTile || previousTile.getLine().getFirstChild() == previousTile)) {
						//see if we can add the currentTile
						if(previousTile.getLine().canAddChild(currentTile)) {
							previousTile.getLine().addChild(currentTile);
						}
						//see if we can remove the currentTile
						else if(currentTile.getLine() && currentTile.getLine().canRemoveChild(previousTile)) {
							currentTile.getLine().removeChild();
							//see if the line only has one child
							if(currentTile.getLine().getLength() <= 1) {
								//grab the index of the line and remove it if it exists
								var lineIndex:int = getIndexOfLine(currentTile.getLine());
								if(lineIndex >= 0) {
									lines.splice(lineIndex, 1);
									currentTile.getLine().destroy();
								}
							}
						}
					}
				}
			}
		}
		
		public function getIndexOfLine(line:Line):int {
			//loop through lines and find the given line
			for(i=0, j=lines.length;i<j;i++) {
				if(lines[i] == line) {
					return i;
				}
			}
			return -1;
		}
		
		public function getTileAtPosition(point:FlxPoint):Tile {
			//loop through tiles and find out which one is colliding with given point
			for(i=0, j=tiles.length;i<j;i++) {
				if(tiles.members[i].overlapsPoint(point)) {
					return tiles.members[i];
				}
			}
			return currentTile;
		}
	}
}