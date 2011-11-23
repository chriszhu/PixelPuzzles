package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	public class GameState extends FlxState
	{
		//information about the tiles
		private var maxNumTiles:int = 250;
		private var tiles:FlxGroup;
		private var tileNumbers:FlxGroup;
		private var tileWidth:int = 32;
		private var tileHeight:int = 32;
		private var currentTile:Tile;
		private var puzzleLoader:PuzzleLoader = new PuzzleLoader();
		
		//information about the current puzzle
		private var puzzleWidth:int;
		private var puzzleHeight:int;
		
		//for convenience in loops
		private var i:int, j:int;
		
		//which tile is selected in the grid
		private var controlPosition:FlxPoint = new FlxPoint(0, 0);
		
		override public function create():void {
			
			//show mouse
			FlxG.mouse.show();
			
			//create tiles
			tiles = new FlxGroup(maxNumTiles);
			tileNumbers = new FlxGroup(maxNumTiles);
			
			for(i=0;i<maxNumTiles;i++) {
				var t:Tile = new Tile(tileNumbers);
				tiles.add(t);
			}
			
			add(tiles);
			add(tileNumbers);
			
			puzzleLoader.loadPuzzle("puzzles/test.json", this);
		}
		
		public function positionTiles(width:int, height:int, jsonTiles:Array):void {
			var tileCounter:int = 0;
			
			for(i=0;i<height;i++) {
				for(j=0;j<width;j++) {
					var t:Tile = tiles.recycle() as Tile;
					
					t.setIsNode(jsonTiles[tileCounter].node);
					t.setID(jsonTiles[tileCounter].id);
					t.reset(j * tileWidth, i * tileHeight);
					t.setState(Tile.kStateUnfilled);
					t.color = jsonTiles[tileCounter].color;
					t.setPosition(new FlxPoint(j, i));
					
					if(t.getIsNode()) {
						t.setType(Tile.kTypeSingle);
						t.setNodeLength(jsonTiles[tileCounter].length);
						t.setDisplayLength(jsonTiles[tileCounter].length);
					}
					
					tileCounter++;
				}
			}
			
			puzzleWidth = width;
			puzzleHeight = height;
			currentTile = tiles.members[0];
		}
		
		override public function update():void {
			// see if arrow keys have been pressed
			if(FlxG.keys.justReleased("UP")) {
				updateControlPosition(new FlxPoint(0, -1));
			}
			else if(FlxG.keys.justReleased("DOWN")) {
				updateControlPosition(new FlxPoint(0, 1));
			}
			else if(FlxG.keys.justReleased("LEFT")) {
				updateControlPosition(new FlxPoint(-1, 0));
			}
			else if(FlxG.keys.justReleased("RIGHT")) {
				updateControlPosition(new FlxPoint(1, 0));
			}
			
			//enable/disable currently selected tile
			if(FlxG.keys.justReleased("SPACE")) {
				currentTile.setEnabled(!currentTile.getEnabled());
			}
			
			super.update();
		}
		
		public function updateControlPosition(newOffset:FlxPoint):void {
			trace("updateControlPosition: " + newOffset);
			var newPoint:FlxPoint = new FlxPoint(controlPosition.x + newOffset.x, controlPosition.y + newOffset.y);
			//make sure the new controlPosition lies within the grid of tiles
			if(newPoint.x >= puzzleWidth) {
				newPoint.x = puzzleWidth-1;
			}
			else if(newPoint.x < 0) {
				newPoint.x = 0;
			}
			if(newPoint.y >= puzzleHeight) {
				newPoint.y = puzzleHeight-1;
			}
			else if(newPoint.y < 0) {
				newPoint.y = 0;
			}
			
			if(controlPosition.x != newPoint.x || controlPosition.y != newPoint.y) {
				updateControlledTile(newPoint);
			}
		}
		
		public function updateControlledTile(newTilePosition:FlxPoint):void {
			trace("updateControlledTile: " + newTilePosition);
			var tileCount:int = 0;
			for(i=0;i<puzzleHeight;i++) {
				for(j=0;j<puzzleWidth;j++) {
					if(newTilePosition.x == j && newTilePosition.y == i && tileCount < tiles.length) {
						var newTile:Tile = tiles.members[tileCount];
						//don't go to new tile if:
						//	new tile is node and is different color than current tile
						if(currentTile.getEnabled() && newTile.getIsNode() && newTile.color != currentTile.color) {
							return;
						}
						//	new tile is node, is same color as current tile, but length of line is not correct
						if(currentTile.getEnabled() && newTile.getIsNode() && newTile.color == currentTile.color && newTile.getNodeLength() != currentTile.getLength()+1 && newTile.getNode() != currentTile.getNode()) {
							return;
						}
						//	length of line is too much
						if(currentTile.getEnabled() && !currentTile.getIsNode() && currentTile.getLength() >= currentTile.getNode().getNodeLength()) {
							return;
						}
						
						//if we're "erasing" the line that we're currently on
						if(currentTile.getEnabled() && newTile.getNode() == currentTile.getNode()) {
							newTile.removeChild(new FlxPoint(currentTile.getPosition().x - newTile.getPosition().x, currentTile.getPosition().y - newTile.getPosition().y));
							currentTile.removeChild(new FlxPoint(newTile.getPosition().x - currentTile.getPosition().x, newTile.getPosition().y - currentTile.getPosition().y));
							currentTile.setLength(0);
							
							controlPosition = newTilePosition;
							//deselect current tile
							currentTile.setSelected(false);
							//enable new tile based on current tile
							newTile.setEnabled(currentTile.getEnabled());
							//disable current tile
							currentTile.setEnabled(false);
							//select new tile
							newTile.setSelected(true);
							//set new currentTile
							currentTile = newTile;
							return;
						}
						
						if(currentTile.getEnabled()) {
							newTile.color = currentTile.color;
							
							//add tile's offset as child of currentTile and vice versa
							var curTilePos:FlxPoint = currentTile.getPosition();
							var newTilePos:FlxPoint = newTile.getPosition();
							
							//update length so we can display a number corresponding to it
							//also keep track of node throughout the line
							if(currentTile.getIsNode()) {
								newTile.setLength(2);
								newTile.setNode(currentTile);
							}
							else {
								newTile.setLength(currentTile.getLength()+1);
								newTile.setNode(currentTile.getNode());
							}
							
							currentTile.addChild(new FlxPoint(newTilePos.x - curTilePos.x, newTilePos.y - curTilePos.y));
							newTile.addChild(new FlxPoint(curTilePos.x - newTilePos.x, curTilePos.y - newTilePos.y));
						}
						controlPosition = newTilePosition;
						//deselect current tile
						currentTile.setSelected(false);
						//enable new tile based on current tile
						newTile.setEnabled(currentTile.getEnabled());
						//disable current tile
						currentTile.setEnabled(false);
						//select new tile
						newTile.setSelected(true);
						//set new currentTile
						currentTile = newTile;
						return;
					}
					tileCount++;
				}
			}
		}
	}
}