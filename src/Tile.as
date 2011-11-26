package
{
	import org.flixel.*;
	
	public class Tile extends FlxGroup
	{
		//images used for displaying different states of tile
		[Embed(source="images/filledTopCap.png")] protected var 			ImgFilledTopCap:Class;
		[Embed(source="images/filledLeftCap.png")] protected var 			ImgFilledLeftCap:Class;
		[Embed(source="images/filledRightCap.png")] protected var 			ImgFilledRightCap:Class;
		[Embed(source="images/filledBottomCap.png")] protected var 			ImgFilledBottomCap:Class;
		[Embed(source="images/filledLeftToRight.png")] protected var		ImgFilledLeftToRight:Class;
		[Embed(source="images/unfilledLeftToRight.png")] protected var		ImgUnfilledLeftToRight:Class;
		[Embed(source="images/filledTopToBottom.png")] protected var 		ImgFilledTopToBottom:Class;
		[Embed(source="images/unfilledTopToBottom.png")] protected var 		ImgUnfilledTopToBottom:Class;
		[Embed(source="images/filledTopToRight.png")] protected var 		ImgFilledTopToRight:Class;
		[Embed(source="images/unfilledTopToRight.png")] protected var 		ImgUnfilledTopToRight:Class;
		[Embed(source="images/filledTopToLeft.png")] protected var 			ImgFilledTopToLeft:Class;
		[Embed(source="images/unfilledTopToLeft.png")] protected var 		ImgUnfilledTopToLeft:Class;
		[Embed(source="images/unfilledBottomToRight.png")] protected var 	ImgUnfilledBottomToRight:Class;
		[Embed(source="images/filledBottomToRight.png")] protected var 		ImgFilledBottomToRight:Class;
		[Embed(source="images/filledBottomToLeft.png")] protected var 		ImgFilledBottomToLeft:Class;
		[Embed(source="images/unfilledBottomToLeft.png")] protected var 	ImgUnfilledBottomToLeft:Class;
		[Embed(source="images/singleFilled.png")] protected var 			ImgFilledSingle:Class;
		[Embed(source="images/singleUnfilled.png")] protected var 			ImgUnfilledSingle:Class;
		[Embed(source="images/fillingLeft.png")] protected var 				ImgUnfilledLeftCap:Class;
		[Embed(source="images/fillingRight.png")] protected var 			ImgUnfilledRightCap:Class;
		[Embed(source="images/fillingTop.png")] protected var 				ImgUnfilledTopCap:Class;
		[Embed(source="images/fillingBottom.png")] protected var 			ImgUnfilledBottomCap:Class;
		
		//state is either filled or unfilled
		//a filled tile is one that is within a line
		//an unfilled tile is one that has yet to be added to a line
		public static const kStateUnknown:int = -1;
		public static const kStateFilled:int = 0;
		public static const kStateUnfilled:int = 1;
		public static const kStateCount:int = 2;
		
		//type is the direction(s) in which the tile is connected to the tiles next to it in the line
		//for example, a tile at (0,0) connected to a tile at (0,1) and (1,0) would be kTypeBottomToRight
		public static const kTypeUnknown:int = -1;
		public static const kTypeTopToBottom:int = 0;
		public static const kTypeTopToLeft:int = 1;
		public static const kTypeTopToRight:int = 2;
		public static const kTypeLeftToRight:int = 3;
		public static const kTypeBottomToLeft:int = 4;
		public static const kTypeBottomToRight:int = 5;
		public static const kTypeLeftCap:int = 6;
		public static const kTypeRightCap:int = 7;
		public static const kTypeTopCap:int = 8;
		public static const kTypeBottomCap:int = 9;
		public static const kTypeSingle:int = 10;
		public static const kTypeCount:int = 11;
		
		//the image of the tile
		private var image:FlxSprite;
		//the text object that displays the endLength
		private var displayLength:FlxText;
		
		//the line that this tile is currently a part of
		private var line:Line;
		//whether this tile is at the end of a line
		private var isEnd:Boolean = false;
		//the length of the line connecting this end to another end
		private var endLength:int = 0;
		//tiles this tile is connected to in a line. max of 2. min of 0.
		private var children:Array = new Array();
		//current type of the tile
		private var type:int;
		//current state of the tile
		private var state:int;
		//position in grid of tiles (actual x position / width, actual y position / height)
		private var position:FlxPoint = new FlxPoint(0, 0);
		//for easy looping
		private var i:int, j:int;
		//size of the tile
		private var size:FlxPoint = new FlxPoint(32, 32);
		
		public function Tile(defaultState:int=Tile.kStateUnknown, defaultType:int=Tile.kTypeUnknown)
		{
			//two FlxObjects in this class: image and displayLength
			super(2);
			//set initial state and type
			state = defaultState;
			type = defaultType;
			//create image for tile
			image = new FlxSprite(0, 0);
			image.visible = false;
			add(image);
			//create display for text and add it to this tile's group
			displayLength = new FlxText(0, 0, size.x);
			displayLength.alignment = "center";
			add(displayLength);
		}
		
		//setters
		public function setLine(newLine:Line):void {
			line = newLine;
		}
		
		public function setIsEnd(newIsEnd:Boolean):void {
			isEnd = newIsEnd;
		}
		
		public function setEndLength(newEndLength:int):void {
			endLength = newEndLength;
		}
		
		public function setChildren(newChildren:Array):void {
			children = newChildren;
		}
		
		public function setState(newState:int):void {
			state = newState;
			updateImage();
		}
		
		public function setType(newType:int):void {
			type = newType;
			updateImage();
		}
		
		public function setPosition(newPosition:FlxPoint):void {
			position = newPosition;
			//set image's position based on grid position and size of tile
			image.x = size.x * position.x;
			image.y = size.y * position.y;
			//set displayLength's position based on grid position, size of tile, and size of font
			displayLength.x = image.x;
			displayLength.y = image.y + ((size.y * 0.5) - (displayLength.height * 0.5));
		}
		
		public function setColor(newColor:uint):void {
			image.color = newColor;
		}
		
		public function setDisplayLength(newDisplayLength:int):void {
			displayLength.text = "" + newDisplayLength;
		}
		
		public function setSize(newSize:FlxPoint):void {
			size = newSize;
			//update displayLength's width based on newSize
			displayLength.width = newSize.x;
			//update image's width and height based on newSize
			image.width = newSize.x;
			image.height = newSize.y;
		}
		
		//getters
		public function getLine():Line {
			return line;
		}
		
		public function getIsEnd():Boolean {
			return isEnd;
		}
		
		public function getEndLength():int {
			return endLength;
		}
		
		public function getChildren():Array {
			return children;
		}
		
		public function getState():int {
			return state;
		}
		
		public function getType():int {
			return type;
		}
		
		public function getPosition():FlxPoint {
			return position;
		}
		
		public function getColor():uint {
			return image.color;
		}
		
		public function getDisplayLength():int {
			return int(displayLength.text);
		}
		
		public function getSize():FlxPoint {
			return size;
		}
		
		public function overlapsPoint(point:FlxPoint):Boolean {
			return image.overlapsPoint(point);
		}
		
		public function isEqual(tile:Tile):Boolean {
			if((tile.getPosition().x != getPosition().x) ||
				(tile.getPosition().y != getPosition().y)) {
				return false;
			}
			return true;
		}
		
		public function updateImage():void {
			//set image based on state and type
			switch(state) {
				case Tile.kStateFilled:
					switch(type) {
						case Tile.kTypeTopToBottom:
							image.loadGraphic(ImgFilledTopToBottom);
							break;
						case Tile.kTypeTopToLeft:
							image.loadGraphic(ImgFilledTopToLeft);
							break;
						case Tile.kTypeTopToRight:
							image.loadGraphic(ImgFilledTopToRight);
							break;
						case Tile.kTypeLeftToRight:
							image.loadGraphic(ImgFilledLeftToRight);
							break;
						case Tile.kTypeBottomToLeft:
							image.loadGraphic(ImgFilledBottomToLeft);
							break;
						case Tile.kTypeBottomToRight:
							image.loadGraphic(ImgFilledBottomToRight);
							break;
						case Tile.kTypeLeftCap:
							image.loadGraphic(ImgFilledLeftCap);
							break;
						case Tile.kTypeRightCap:
							image.loadGraphic(ImgFilledRightCap);
							break;
						case Tile.kTypeTopCap:
							image.loadGraphic(ImgFilledTopCap);
							break;
						case Tile.kTypeBottomCap:
							image.loadGraphic(ImgFilledBottomCap);
							break;
						case Tile.kTypeSingle:
							image.loadGraphic(ImgFilledSingle);
							break;
						default:
							break;
					}
					break;
				case Tile.kStateUnfilled:
					switch(type) {
						case Tile.kTypeTopToBottom:
							image.loadGraphic(ImgUnfilledTopToBottom);
							break;
						case Tile.kTypeTopToLeft:
							image.loadGraphic(ImgUnfilledTopToLeft);
							break;
						case Tile.kTypeTopToRight:
							image.loadGraphic(ImgUnfilledTopToRight);
							break;
						case Tile.kTypeLeftToRight:
							image.loadGraphic(ImgUnfilledLeftToRight);
							break;
						case Tile.kTypeBottomToLeft:
							image.loadGraphic(ImgUnfilledBottomToLeft);
							break;
						case Tile.kTypeBottomToRight:
							image.loadGraphic(ImgUnfilledBottomToRight);
							break;
						case Tile.kTypeSingle:
							image.loadGraphic(ImgUnfilledSingle);
							break;
						case Tile.kTypeLeftCap:
							image.loadGraphic(ImgUnfilledLeftCap);
							break;
						case Tile.kTypeRightCap:
							image.loadGraphic(ImgUnfilledRightCap);
							break;
						case Tile.kTypeTopCap:
							image.loadGraphic(ImgUnfilledTopCap);
							break;
						case Tile.kTypeBottomCap:
							image.loadGraphic(ImgUnfilledBottomCap);
							break;
						default:
							break;
					}
					break;
				default:
					break;
			}
			
			if(state != Tile.kStateUnknown && type != Tile.kTypeUnknown) {
				image.visible = true;
			}
			else {
				image.visible = false;
			}
		}
		
		public function childrenUpdated():void {
			//determine type based on children
			if(children.length == 1) {
				var pos:FlxPoint = children[0];
				if(pos.x == 1) {
					setType(Tile.kTypeLeftCap);
				}
				else if(pos.x == -1) {
					setType(Tile.kTypeRightCap);
				}
				else if(pos.y == 1) {
					setType(Tile.kTypeTopCap);
				}
				else if(pos.y == -1) {
					setType(Tile.kTypeBottomCap);
				}
			}
			else if(children.length == 2) {
				var pos1:FlxPoint = children[0];
				var pos2:FlxPoint = children[1];
				
				if((pos1.x == -1 && pos2.y == -1) || (pos2.x == -1 && pos1.y == -1)) {
					setType(Tile.kTypeTopToLeft);
				}
				else if((pos1.x == 1 && pos2.y == -1) || (pos2.x == 1 && pos1.y == -1)) {
					setType(Tile.kTypeTopToRight);
				}
				else if((pos1.x == 1 && pos2.x == -1) || (pos1.x == -1 && pos2.x == 1)) {
					setType(Tile.kTypeLeftToRight);
				}
				else if((pos1.y == 1 && pos2.y == -1) || (pos1.y == -1 && pos2.y == 1)) {
					setType(Tile.kTypeTopToBottom);
				}
				else if((pos1.x == 1 && pos2.y == 1) || (pos2.x == 1 && pos1.y == 1)) {
					setType(Tile.kTypeBottomToRight);
				}
				else if((pos1.x == -1 && pos2.y == 1) || (pos2.x == -1 && pos1.y == 1)) {
					setType(Tile.kTypeBottomToLeft);
				}
			}
			else {
				if(isEnd) {
					setType(Tile.kTypeSingle);
				}
				else {
					setType(Tile.kTypeUnknown);
				}
			}
		}
		
		public function addChild(t:Tile):void {
			//get offset from this tile's position
			var p:FlxPoint = t.getPosition().subtract(getPosition());
			children.push(p);
			childrenUpdated();
		}
		
		public function removeChild(t:Tile):void {
			//get offset from this tile's position
			var p:FlxPoint = t.getPosition().subtract(getPosition());
			for(i=0,j=children.length;i<j;i++) {
				if(children[i].x == p.x && children[i].y == p.y) {
					children.splice(i, 1);
					break;
				}
			}
			
			childrenUpdated();
		}
		
		//sets all the variables of this tile back to their initial state
		public function reset():void {
			setLine(null);
			setState(Tile.kStateUnfilled);
		}
	}
}