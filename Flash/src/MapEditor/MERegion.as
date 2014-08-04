package MapEditor
{	
	import Game.Player;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class MERegion extends Sprite
	{
		public var ID:int;
		public var neighborRegions:Array = new Array();
		
		protected var colorID:int;
		protected var owner:Player;
		
		private var map:MEMap;
		private var tiles:Array = new Array();
		private static var sId:int = 1;
		private var diceText:TextField;
		
		private var centerX:int;
		private var centerY:int;
		private var top:int, bottom:int, left:int, right:int;
		
		private var terrainSprite:Sprite;
		private var regionMask:Sprite;
		private var borderSprite:Sprite;
		
		public static const hexSide:int = 10; //16x18
		public static const hexH:int = (int)(Math.sin(Math.PI / 6) * hexSide);
		public static const hexR:int = (int)(Math.cos(Math.PI / 6) * hexSide);
		public static const hexW:int = 2 * hexR;
		
		private var firstDraw:Boolean = true;
		
		
		// 0 - world, 1 - finished reagion, 2 - currently active region (editing)
		private var regionColors:Array = new Array(0xFFFFFF, 0x93AAFF, 0xFFAA00);
		
		private var IDLabel:TextField;
		
		public function MERegion(map:MEMap, colorID:int)
		{
			if (colorID > regionColors.length-1) throw new Error("colorID out of bounds");
			
			this.colorID = colorID;
			this.map = map;
			//ID = sId++;
			
			owner = new Player(1,"",1,1,1,0,0,0,0,0);
			
			terrainSprite = new Sprite();
			addChild(terrainSprite);
			regionMask = new Sprite();
			addChild(regionMask);
			this.mask = regionMask;
			
			borderSprite = new Sprite();
			addChild(borderSprite);
			
			IDLabel = new TextField();
			IDLabel.text = "XXX";
			IDLabel.defaultTextFormat = new TextFormat("Arial", 15, -1, true);
			IDLabel.mouseEnabled = false;
			//addChild(IDLabel);
		}
		
		public function update(timeDelta:Number):void {
		}
		
		public function getBoundRect():Rectangle {
			return new Rectangle(left * hexW - hexW / 2, top * (hexSide + hexH), (right - left) * hexW + hexW + hexW / 2, (bottom - top) * (hexSide + hexH) + (hexSide + 2*hexH));
		}
		
		public function AddTile(tileX:int, tileY:int, reDraw:Boolean=true):void {
			tiles.push(new Point(tileX, tileY));
			if (reDraw) this.DrawBackground();
			//this.DrawRegion();
		}
		
		public function removeTile(tileX:int, tileY:int):void {
			var p:Point = new Point(tileX, tileY);
			for (var i:int=0; i < this.tiles.length; i++) {
				if (this.tiles[i].equals(p)) {
					// if it's last item, just delete it
					if (i == this.tiles.length-1) {
						this.tiles.pop();
					} else {
						this.tiles[i] = this.tiles.pop();
					}
					break;
				}
			}
			this.DrawBackground();
		}
		
		public function Finalize():void {
			if(tiles.length > 0) {
				DrawBackground();
				DrawRegion();
			}
		}
		
		public function worldToMap(wx:int, wy:int):Point {
			wx += hexW / 2;
			wy /= (hexSide + hexH);
			if(wy % 2 == 1) {
				wx -= hexW / 2;
			}
			wx /= hexW;
			
			return new Point(wx, wy);
		}
		
		public function ContainsPoint(px:int, py:int):Boolean {
			px += hexW / 2;
			py /= (hexSide + hexH);
			if(py % 2 == 1) {
				px -= hexW / 2;
			}
			px /= hexW;
			
			for(var i:int = 0; i < tiles.length; ++i) {
				var tile:Point = tiles[i];
				if(px == tile.x && py == tile.y) {
					return true;
				} 
			}
			return false;
		}
		
		public function RedrawBorders():void {
			DrawRegion();
		}
		
		public function setActive():void {
			this.changeColor(2);
		}
		
		public function setInactive():void {
			this.changeColor(1);
		}
		
		/**
		 * Checks if region has any tiles.
		 * 
		 * @return boolean true if region has no tiles
		 */
		public function isEmpty():Boolean {
			return tiles.length == 0;
		}

		/**
		 * Returns all neighbours of this region - returns just IDs
		 * 
		 * @return Array List of IDs of neighb. regions
		 */
		public function getNeighbours():Array {
			var a:Array = new Array();
			
			if (tiles.length == 0) return a;
			
			var dir:int = 0; 
			var nID:int = -1;
			
			for (var i:int=0; i < this.tiles.length; i++) {
				for (dir=0; dir < 6; dir++) {
					nID = map.GetNeighborTile(this.tiles[i].x, this.tiles[i].y, dir);
					// void and world are not neighbours
					if(nID > 0 && nID != this.ID) {
						a[nID] = 1;
					}
				}
			}
			
			return a;
		}
	
		/*public function isEnclave():Boolean {
			// empty are considered not enclave
			if (tiles.length == 0) return false;
			
			var dir:int = 0; 
			var nID:int = -1;
			var lastID:int = -1;
			
			for (var i:int=0; i < tiles.length; i++) {
				for (dir=0; dir < 6; dir++) {
					nID = map.GetNeighborTile(tiles[i].x, tiles[i].y, dir);
					// not enclave if void or world found
					if (nID < 2) {return false;}
					
					if(nID != this.ID && nID != lastID) {
						if (lastID == -1) {
							lastID = nID;
						} else {
							return false;
						}
					}
				}
			}
			
			return true;
			
		}*/

		/**
		 * Returns number of tiles in "good chunk" in the region. 
		 * Good chunk is number of neighbouring tiles larger than 5 tiles.
		 * 
		 * @return int number of tiles in the chunk
		 */
		public function getGoodSize():int {
			var cnt:int = 0;
			var maxCnt:int = 0;
			var dir:int = 0;
			var tmp:int;
			// if region has less than 4 tiles it is considered "bad size"
			if (tiles.length < 4) return 1;
			
			for(var i:int = 0; i < tiles.length; i++) {
				cnt = 0;
				for (dir=0; dir < 6; dir++) {
					tmp = map.GetNeighborTile(tiles[i].x, tiles[i].y, dir);
					if (tmp == this.ID) cnt++;
				}
				// found tile bordering with at least 4 tile of the same region 
				if (cnt > maxCnt) maxCnt = cnt;
				if (maxCnt > 5) return maxCnt;
			}
			
			return maxCnt;
			
		}
		
		public function isOnePiece():Boolean {
			// empty and 1 tile regions are considered "one piece"
			if (tiles.length < 2) return true;
			
			var a:Array = tiles.concat();
			
			fungujPiece(a, a[0]);
			return a.length == 0;
		}
		
		/**
		 * Returns region's tiles. 
		 * 
		 */
		public function setNewID(id:int):void {
			// do nothing if new ID is the same as old ID
			if (this.ID == id) return;
			
			for each(var p:Point in this.tiles) {
				this.map.changeTileIDByXY(p.x, p.y, this.ID, id); 
			}
			this.ID = id;
			
			IDLabel.text = id.toString();
		}
		
		private function fungujPiece(a:Array, tile:Point):void {
			if (a.length == 0) return;

			var dir:int = 0;
			var p:Point;
			var len:int = a.length; 
			var tmp:int;
			
			for (var i:int=0; i < a.length; i++) {
				if (tile.equals(a[i])) {
					a.splice(i,1);	
					break;
				}
			}
			
			while (dir < 6 && len > 0) {
				p = map.GetNeighborTileCoor(tile.x, tile.y, dir);
				tmp = map.GetNeighborTile(tile.x, tile.y, dir);
				if(map.GetNeighborTile(tile.x, tile.y, dir) == this.ID) {
					
					for (i=0; i < a.length; i++) {
						if (p.equals(a[i])) {
							fungujPiece(a, p);
							len = a.length;
							break;
						}
					}
					
				}
				dir++;
			}
		}
										
		private function changeColor(c:int):Boolean {
			if (this.regionColors[c] == null) return false;
			this.colorID = c;
			this.Finalize();
			return true;
		}

		private function DrawRegion():void {
			// find first border hex
			var index:int;
			var dir:int;
			var tile:Point;
			var firstTile:Point;
			var firstDirection:int;
			return;
			for(index = 0; index < tiles.length; ++index) {
				tile = tiles[index];
				for(dir = 0; dir < 6; ++dir) {
					if(map.GetNeighborTile(tile.x, tile.y, dir) != ID) {
						firstTile = tile;
						firstDirection = dir;
						break;
					}
				}
				if(firstTile != null) {
					break;
				}
			}
			
			tile = new Point(firstTile.x, firstTile.y);
			
			var points:Array = new Array();
			points[0] = new Point(0, 0); 
			points[1] = new Point(hexR, hexH);
			points[2] = new Point(hexR, hexSide + hexH);
			points[3] = new Point(0, hexSide + 2*hexH);
			points[4] = new Point(- hexR, hexSide + hexH);
			points[5] = new Point(- hexR, hexH);
			
			var maskGraphics:Graphics = regionMask.graphics;
			var borderGraphics:Graphics = borderSprite.graphics;
			borderGraphics.clear();
			
			maskGraphics.clear();
			maskGraphics.beginFill(0xFFFFFF);
			borderGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[dir].x, tile.y * (hexSide + hexH) + points[dir].y);
			
			if(firstDraw) {
				maskGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[dir].x, tile.y * (hexSide + hexH) + points[dir].y);
			}
			do {
				borderGraphics.lineStyle(3, (G.borderColors[colorID] != null) ? G.borderColors[colorID] : 0xAAAAAA);
				
				dir = (dir + 1) % 6;
				
				if(firstDraw) {
					maskGraphics.lineTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[dir].x, tile.y * (hexSide + hexH) + points[dir].y);
				}
				borderGraphics.lineTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[dir].x, tile.y * (hexSide + hexH) + points[dir].y);
				
				if(map.GetNeighborTile(tile.x, tile.y, dir) == ID) {
					tile = moveTile(tile, dir);
					dir = (dir + 4) % 6;
				}
			} while (tile.x != firstTile.x || tile.y != firstTile.y || dir != firstDirection);
						
			maskGraphics.endFill();
			if (this.colorID == 2) {
				borderGraphics.clear();
			}
			//(&)firstDraw = false;
		}

		public function DrawBackground():void {
			terrainSprite.graphics.clear();
			
			// find bounds
			var left:int = 1000, right:int = 0, top:int = 1000, bottom:int = 0;
			var tile:Point;
			var points:Array = new Array();
			var drawBorder:Boolean = false;
			
			var borderGraphics:Graphics = borderSprite.graphics;
			borderGraphics.clear();
			borderGraphics.lineStyle(4, (G.borderColors[colorID] != null) ? G.borderColors[colorID] : 0xAAAAAA);
			
			var maskGraphics:Graphics = regionMask.graphics;
			maskGraphics.clear();
			maskGraphics.beginFill(0xFFFF00);
			
			var newX:int;
			var newY:int;
			
			for(var index:int = 0; index < tiles.length; ++index) {
				tile = tiles[index];
				if(tile.x * hexW - ((tile.y % 2 == 0) ? hexW / 2 : 0) < left) {
					left = tile.x * hexW - ((tile.y % 2 == 0) ? hexW / 2 : 0);
				}
				if(tile.x * hexW + hexW - ((tile.y % 2 == 0) ? hexW / 2 : 0) > right) {
					right = tile.x * hexW + hexW - ((tile.y % 2 == 0) ? hexW / 2 : 0);
				}
				if(tile.y * (hexSide + hexH) < top) {
					top = tile.y * (hexSide + hexH);
				}
				if(tile.y * (hexSide + hexH) + (hexSide + hexH + hexH) > bottom) {
					bottom = tile.y * (hexSide + hexH) + (hexSide + hexH + hexH);
				}

				
				points[0] = new Point(0, 0); 
				points[1] = new Point(hexR, hexH);
				points[2] = new Point(hexR, hexSide + hexH);
				points[3] = new Point(0, hexSide + 2*hexH);
				points[4] = new Point(- hexR, hexSide + hexH);
				points[5] = new Point(- hexR, hexH);
				
				IDLabel.x = hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[0].x - hexW / 2;
				IDLabel.y = tile.y * (hexSide + hexH) + points[0].y;
				IDLabel.text = ID.toString();

				maskGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[0].x, tile.y * (hexSide + hexH) + points[0].y);
				borderGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[0].x, tile.y * (hexSide + hexH) + points[0].y);
				
				for (var j:int=1; j < 6; j++) {
					newX = hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[j].x;
					newY = tile.y * (hexSide + hexH) + points[j].y;
					maskGraphics.lineTo(newX, newY);
					if (map.RegionsHaveSameOwner(map.GetNeighborTile(tile.x, tile.y, j-1), this.ID)) {
						borderGraphics.moveTo(newX, newY);						
					} else {
						borderGraphics.lineTo(newX, newY);
						
					}
				}
				if (!map.RegionsHaveSameOwner(map.GetNeighborTile(tile.x, tile.y, 5), this.ID)) {
					borderGraphics.lineTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[0].x, tile.y * (hexSide + hexH) + points[0].y);						
				}
				
			}

			if (this.colorID != 1) {
				borderGraphics.clear();
			}
			
			if (regionColors[this.colorID] != null) {
				var b:BitmapData = owner.race.regionImage.bitmapData.clone();
				
				var colorTransform:ColorTransform = new ColorTransform();
				colorTransform.redMultiplier = ((this.regionColors[this.colorID] & 0xFF0000) >> 16) / 255.0;
				colorTransform.greenMultiplier = ((this.regionColors[this.colorID] & 0xFF00) >> 8) / 255.0;
				colorTransform.blueMultiplier = (this.regionColors[this.colorID] & 0xFF) / 255.0;
				b.colorTransform(b.rect, colorTransform); 
				terrainSprite.graphics.beginBitmapFill(b);
				terrainSprite.graphics.drawRect(left, top, right - left, bottom - top);
			}
			else {
				terrainSprite.graphics.beginFill(0xDDDDDD);
				terrainSprite.graphics.drawRect(left, top, right - left, bottom - top);
			}
		}
		
		private function moveTile(tile:Point, dir:int):Point {
			var result:Point = new Point(tile.x, tile.y);
			switch(dir) {
				case 0: 
					result.x += (result.y % 2 == 1) ? 1 : 0;
					result.y--;
					break;
				case 1:
					result.x++;
					break;
				case 2:
					result.x += (result.y % 2 == 1) ? 1 : 0;
					result.y++;
					break;
				case 3:
					result.x -= (result.y % 2 == 1) ? 0 : 1;
					result.y++;
					break;
				case 4:
					result.x--;
					break;
				case 5:
					result.x -= (result.y % 2 == 1) ? 0 : 1;
					result.y--;
					break;
			}
			return result;
		}
			

/**************************************/
	}
}
