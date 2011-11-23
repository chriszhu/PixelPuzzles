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
		
		//the line that this tile is currently a part of
		private var line:Line;
		
		private var enabled:Boolean = false;
		private var selected:Boolean = false;
		private var id:int = 0;
		private var isNode:Boolean = false;
		private var length:int = 0;
		private var nodeLength:int = 0;
		private var displayLength:FlxText;
		
		//current type of the tile
		private var type:int;
		//current state of the tile
		private var state:int;
		//position in grid of tiles (actual x position / width, actual y position / height)
		private var position:FlxPoint;
		
		//for easy looping
		private var i:int, j:int;
		
		public function Tile(tileNumberGroup:FlxGroup)
		{
			super(0, 0);

			state = Tile.kStateUnknown;
			type = Tile.kTypeUnknown;
			visible = false;
			
			//create display for text and add it to this tile's group
			displayLength = new FlxText(0, 0, 32);
			displayLength.alignment = "center";
			tileNumberGroup.add(displayLength);
		}
		
		public function setIsNode(newNode:Boolean):void {
			isNode = newNode;
		}
		
		public function getIsNode():Boolean {
			return isNode;
		}
		
		public function setNode(newNode:Tile):void {
			node = newNode;
		}
		
		public function getNode():Tile {
			return node;
		}
		
		public function setNodeLength(newNodeLength:int):void {
			nodeLength = newNodeLength;
			setNode(this);
			length = 1;
		}
		
		public function getNodeLength():int {
			return nodeLength;
		}
		
		public function setDisplayLength(newDisplayLength:int):void {
			//set display length text and position
			displayLength.text = "" + nodeLength;
			displayLength.x = this.x;
			displayLength.y = this.y;
		}
		
		public function setLength(newLength:int):void {
			length = newLength;
		}
		
		public function getLength():int {
			return length;
		}
		
		public function setID(newID:Number):void {
			id = newID;
		}
		
		public function getID():Number {
			return id;
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
		}
		
		public function getPosition():FlxPoint {
			return position;
		}
		
		public function updateImage():void {
			
			switch(state) {
				case Tile.kStateFilled:
					switch(type) {
						case Tile.kTypeTopToBottom:
							loadGraphic(ImgFilledTopToBottom);
							break;
						case Tile.kTypeTopToLeft:
							loadGraphic(ImgFilledTopToLeft);
							break;
						case Tile.kTypeTopToRight:
							loadGraphic(ImgFilledTopToRight);
							break;
						case Tile.kTypeLeftToRight:
							loadGraphic(ImgFilledLeftToRight);
							break;
						case Tile.kTypeBottomToLeft:
							loadGraphic(ImgFilledBottomToLeft);
							break;
						case Tile.kTypeBottomToRight:
							loadGraphic(ImgFilledBottomToRight);
							break;
						case Tile.kTypeLeftCap:
							loadGraphic(ImgFilledLeftCap);
							break;
						case Tile.kTypeRightCap:
							loadGraphic(ImgFilledRightCap);
							break;
						case Tile.kTypeTopCap:
							loadGraphic(ImgFilledTopCap);
							break;
						case Tile.kTypeBottomCap:
							loadGraphic(ImgFilledBottomCap);
							break;
						case Tile.kTypeSingle:
							loadGraphic(ImgFilledSingle);
							break;
						default:
							break;
					}
					break;
				case Tile.kStateUnfilled:
					switch(type) {
						case Tile.kTypeTopToBottom:
							loadGraphic(ImgUnfilledTopToBottom);
							break;
						case Tile.kTypeTopToLeft:
							loadGraphic(ImgUnfilledTopToLeft);
							break;
						case Tile.kTypeTopToRight:
							loadGraphic(ImgUnfilledTopToRight);
							break;
						case Tile.kTypeLeftToRight:
							loadGraphic(ImgUnfilledLeftToRight);
							break;
						case Tile.kTypeBottomToLeft:
							loadGraphic(ImgUnfilledBottomToLeft);
							break;
						case Tile.kTypeBottomToRight:
							loadGraphic(ImgUnfilledBottomToRight);
							break;
						case Tile.kTypeSingle:
							loadGraphic(ImgUnfilledSingle);
							break;
						case Tile.kTypeLeftCap:
							loadGraphic(ImgUnfilledLeftCap);
							break;
						case Tile.kTypeRightCap:
							loadGraphic(ImgUnfilledRightCap);
							break;
						case Tile.kTypeTopCap:
							loadGraphic(ImgUnfilledTopCap);
							break;
						case Tile.kTypeBottomCap:
							loadGraphic(ImgUnfilledBottomCap);
							break;
						default:
							break;
					}
					break;
				default:
					break;
			}
			
			if(state != Tile.kStateUnknown && type != Tile.kTypeUnknown) {
				visible = true;
			}
			else {
				visible = false;
			}
		}
		
		public function setEnabled(newEnabled:Boolean):void {
			enabled = newEnabled;
		}
		
		public function getEnabled():Boolean {
			return enabled;
		}
		
		public function setSelected(newSelected:Boolean):void {
			selected = newSelected;
			
			if(selected)
				scale = new FlxPoint(1.1, 1.1);
			else
				scale = new FlxPoint(1, 1);
		}
		
		public function getSelected():Boolean {
			return selected;
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
				if(isNode) {
					setType(Tile.kTypeSingle);
				}
				else {
					setType(Tile.kTypeUnknown);
				}
			}
		}
		
		public function addChild(p:FlxPoint):void {
			//see if we already have the new point as a child
			for(i=0,j=children.length;i<j;i++) {
				if(children[i].x == p.x && children[i].y == p.y) {
					removeChild(p);
					return;
				}
			}
			
			children.push(p);
			
			childrenUpdated();
		}
		
		public function removeChild(p:FlxPoint):void {
			for(i=0,j=children.length;i<j;i++) {
				if(children[i].x == p.x && children[i].y == p.y) {
					children.splice(i, 1);
					break;
				}
			}
			
			childrenUpdated();
		}
		
		public function getChildren():Array {
			return children;
		}
	}
}