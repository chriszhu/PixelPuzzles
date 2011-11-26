package
{
	import org.flixel.FlxPoint;

	public class Line
	{
		//array to keep track of all the tiles in this line
		private var tiles:Array = new Array();
		//length that the line needs to be in order to be considered a valid line
		private var targetLength:int = 0;
		//color of the line
		private var color:uint;
		//for easier looping
		private var i:int, j:int;
		//a completed line is one that has a number of tiles equal to its targetLength
		private var completed:Boolean = false;
		
		public function Line()
		{
		}
		
		//setters
		public function setTargetLength(newTargetLength:int):void {
			targetLength = newTargetLength;
		}
		
		public function setColor(newColor:uint):void {
			color = newColor;
		}
		
		//getters
		public function getLength():int {
			return tiles.length;
		}
		
		public function getChildren():Array {
			return tiles;
		}
		
		public function getTargetLength():int {
			return targetLength;
		}
		
		public function getColor():uint {
			return color;
		}
		
		public function getLastChild():Tile {
			return tiles[tiles.length-1];
		}
		
		public function getFirstChild():Tile {
			return tiles[0];
		}
		
		public function getCompleted():Boolean {
			return (tiles.length == targetLength);
		}
		
		public function mergeWithLine(mergeLine:Line):void {
			
		}
		
		public function addChild(t:Tile):void {
			//don't do anything special if it's the first child
			if(tiles.length > 0) {
				//add new tile to last tile's children
				getLastChild().addChild(t);
				//add last tile to new tile's children
				t.addChild(getLastChild());
			}
			//set some tile variables based on the line
			t.setLine(this);
			t.setColor(getColor());
			tiles.push(t);
			//check for completed line
			checkCompleted();
		}
		
		public function removeChild():void {
			//get last tile and pop it from this line's children
			var oldTile:Tile = tiles.pop();
			oldTile.removeChild(getLastChild());
			//remove last tile from 2nd to last tile's children
			getLastChild().removeChild(oldTile);
			oldTile.reset();
			//check for completed line
			checkCompleted();
		}
		
		public function destroy():void {
			while(tiles.length > 0) {
				//return each tile to its initial state
				tiles.pop().reset();
			}
		}
		
		//determines whether this line can add the given tile to its children
		public function canAddChild(t:Tile):Boolean {
			//a child is valid IF
			//	it has an offset of 1 in any direction on one axis from the original tile
			//	line is not completed
			//	it is an end cap with the same color and the end length is equal to the length of the line if the tile is added
			//	it has a state equal to Tile.kStateUnfilled and type equal to Tile.kTypeUnknown
			var offset:FlxPoint = t.getPosition().subtract(getLastChild().getPosition());
			offset.x = Math.abs(offset.x);
			offset.y = Math.abs(offset.y);
			if(offset.x == 1 && offset.y == 1) {
				return false
			}
			else if(getCompleted()) {
				return false
			}
			else if(t.getIsEnd() && t.getColor() == color && t.getEndLength() == getLength()+1) {
				return true;
			}
			else if(t.getState() == Tile.kStateUnfilled && t.getType() == Tile.kTypeUnknown) {
				return true;
			}
			return false;
		}
		
		//determines whether this line can remove the given tile from its children
		public function canRemoveChild(t:Tile):Boolean {
			//a child is valid IF
			//	it is the first child and the last child is an end
			//	it is a child of this line
			if(t == getFirstChild() && !getLastChild().getIsEnd()) {
				return false;
			}
			else if(t.getLine() == this) {
				if(t == getFirstChild()) {
					tiles.reverse();
				}
				return true;
			}
			return false;
		}
		
		//checks to see if this line is completed and updates the children to reflect that
		public function checkCompleted():void {
			var newCompleted:Boolean = false;
			if(tiles.length == targetLength && getLastChild().getIsEnd()) {
				newCompleted = true;
			}
			
			//update children if we need to
			if(newCompleted != completed) {
				completed = newCompleted;
				for(i=0,j=tiles.length;i<j;i++) {
					if(completed) {
						tiles[i].setState(Tile.kStateFilled);
					}
					else {
						tiles[i].setState(Tile.kStateUnfilled);
					}
				}
			}
		}
	}
}