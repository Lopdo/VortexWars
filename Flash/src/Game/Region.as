package Game
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class Region extends Sprite
	{
		public var owner:Player;
		public var dice:int;
		public var ID:int;
		
		private var map:Map;
		private var tiles:Array = new Array();
		private static var sId:int = 1;
		private var diceText:TextField;
		
		public var neighborRegions:Array = new Array();

		private var centerX:int;
		private var centerY:int;
		private var top:int, bottom:int, left:int, right:int;
		
		private var terrainSprite:Sprite;
		private var regionMask:Sprite;
		private var selectedSprite:Sprite;
		private var borderSprite:Sprite;
		private var army:Army;
		
		private var newDice:int;
		
		private const hexSide:int = 10; //16x18
		private const hexH:int = (int)(Math.sin(Math.PI / 6) * hexSide);
		private const hexR:int = (int)(Math.cos(Math.PI / 6) * hexSide);
		private const hexW:int = 2 * hexR;
		
		private var firstDraw:Boolean = true;
		
		private var selectColors:Array = new Array(0xFF0000, 0x93AAFF, 0xFFFF00, 0x01FF27, 0xE1069B, 0xFFB655, 0x3ACDFF, 0xDD8C55);
		
		private var status:int = 0;
		
		private var selected:Boolean = false;
		
		private var pulseTimer:Number = 0;
		private var singlePulseTimer:Number = 0;
		
		private const STATUS_PULSING:int = 1;
		private const STATUS_SINGLE_PULSE:int = 2;
		private const STATUS_HOVER:int = 3;
		private const STATUS_HOVER_FADEOUT:int = 4;
		private const STATUS_PULSING_AND_HOVER:int = 5;
		
		private var tileRenderOffsetTop:int;
		private var tileRenderOffsetLeft:int;
		
		public function Region(owner:Player, dice:int, map:Map)
		{
			this.owner = owner;
			this.dice = dice;
			this.map = map;
			
			//this.cacheAsBitmap = true;
			
			terrainSprite = new Sprite();
			addChild(terrainSprite);
			regionMask = new Sprite();
			addChild(regionMask);
			this.mask = regionMask;
			
			selectedSprite = new Sprite();
			selectedSprite.alpha = 0.8;
			selectedSprite.visible = false;
			addChild(selectedSprite);
			borderSprite = new Sprite();
			addChild(borderSprite);
			army = new Army(owner, dice);
		}
		
		public function setDefenseBoost(active:Boolean):void {
			if(army) {
				army.setDefenseBoost(active);
			}
		}
		
		public function update(timeDelta:Number):void {
			army.update(timeDelta);
			
			if(status == STATUS_PULSING) {
				selectedSprite.visible = true;
				
				pulseTimer += 5*timeDelta;
				selectedSprite.alpha = 0.4 * (1 - Math.cos(pulseTimer)) / 2;
			}
			if(status == STATUS_SINGLE_PULSE) {
				selectedSprite.visible = true;
				
				singlePulseTimer += 7*timeDelta;
				if(singlePulseTimer < 2*Math.PI) {
					selectedSprite.alpha = 0.8 * (1 - Math.cos(singlePulseTimer)) / 2;
				}
				else {
					selectedSprite.alpha = 0;
					status = 0;
					selectedSprite.visible = false;
				}
			}
			if(status == STATUS_HOVER_FADEOUT) {
				selectedSprite.visible = true;
				selectedSprite.alpha -= timeDelta;
				if(selectedSprite.alpha < 0) {
					selectedSprite.alpha = 0;
					status = 0;
					selectedSprite.visible = false;
				}
			}
			if(status == STATUS_HOVER || status == STATUS_PULSING_AND_HOVER) {
				selectedSprite.alpha = 0.6;
				selectedSprite.visible = true;
				
				if(status == STATUS_HOVER)
					status = STATUS_HOVER_FADEOUT;
				else 
					status = STATUS_PULSING;
			}
		}
		
		public function startSinglePulse():void {
			if(selected) return;
			
			singlePulseTimer = 0;
			status = STATUS_SINGLE_PULSE;
		}
		
		public function startHover():void {
			if(selected) return;
			
			if(status == STATUS_PULSING)
				status = STATUS_PULSING_AND_HOVER;
			else 
				status = STATUS_HOVER;
		} 
		
		public function startPulsing():void {
			pulseTimer = 0;
			
			status = STATUS_PULSING;
		}
		
		public function stopPulsing():void {
			if(status == STATUS_PULSING) {
				status = STATUS_HOVER_FADEOUT;
			}
		}
		
		public function getBoundRect():Rectangle {
			return new Rectangle(left * hexW - hexW / 2, top * (hexSide + hexH), (right - left) * hexW + hexW + hexW / 2, (bottom - top) * (hexSide + hexH) + (hexSide + 2*hexH));
		}
		
		public function setDice(dice:int):void {
			this.dice = dice;
			army.setArmyStrength(dice);
		}
		
		public function setNewDiceCount(dice:int):int {
			if(this.dice == dice) return 0;
			
			newDice = dice - this.dice;
			if(newDice < 0) {
				var a:int = 0;
			}
			return newDice;
		}
		
		public function addNewDice():Boolean {
			if(owner == null) return false;
			
			owner.stackedDice--;
			newDice--;
			dice++;
			army.increasePower(dice);
			
			return newDice > 0;
		}
		
		public function updateArmySize():void {
			army.increasePower(dice);
		}
		
		public function AddTile(tileX:int, tileY:int):void {
			tiles.push(new Point(tileX, tileY));
		}
		
		public function Finalize():void {
			// find top and left limit of the region, move sprite there and set offset to render tiles from 0,0
			var leftmost:int = 100000;
			var topmost:int = 100000;
			for(var i:int = 0; i < tiles.length; i++) {
				var tile:Point = tiles[i];
				if(tile.x < leftmost) 
					leftmost = tile.x;
				if(tile.y < topmost)
					topmost = tile.y;
			}
			x = hexW * leftmost + ((topmost % 2 == 1) ? hexW / 2 : 0), 
			y = topmost * (hexSide + hexH);
			
			if(tiles.length > 0) {
				DrawBackground();
				DrawRegion();
				FindArmyCenter();
				army.setArmyStrength(dice);
				army.x = hexW * centerX + ((centerY % 2 == 1) ? hexW / 2 : 0) - army.width / 2;
				army.y = centerY * (hexSide + hexH) + (hexSide + 2*hexH) / 2 - army.height / 2;
				// add it here instead of constructor so all army Sprites are above all terrain sprites
				parent.addChild(army);
			}
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
		
		public function SetActive(active:Boolean):void {
			selected = active;
			status = 0;
			
			selectedSprite.alpha = 0.8;
			selectedSprite.visible = active;
			
			army.setActive(active);
			
			if(active == false) 
				stopHighlightingAttackableRegions();
		}
		
		public function startHighlightingAttackableRegions():void {
			if(dice < 2) return;
			//start pulsing enemy neighbors
			for each(var nIdx:int in neighborRegions) {
				var r:Region = map.GetRegion(nIdx);
				if(r && r.owner != owner && dice) {
					r.startPulsing();
				}
			}
		}
		
		public function stopHighlightingAttackableRegions():void {
			//start pulsing enemy neighbors
			for each(var nIdx:int in neighborRegions) {
				var r:Region = map.GetRegion(nIdx);
				if(r && r.owner != owner) {
					r.stopPulsing();
				}
			}
		}
		
		public function IsMyRegion():Boolean {
			if(owner == null) return false;
			
			return owner.ID == G.user.ID;
		}
		
		public function CanAttack(otherRegion:Region):Boolean {
			if(dice < 2) return false;
			
			for each(var r:int in neighborRegions) {
				if(r == otherRegion.ID) {
					return true;
				}
			}
			
			return false;
		}
		
		public function setOwner(newOwner:Player):void {
			owner = newOwner;
			army.setOwner(owner);
			
			//DrawBackground();
			//DrawRegion();
		}
		
		public function redraw():void {
			DrawBackground();
			DrawRegion();
		}
		
		public function RedrawBorders():void {
			DrawRegion();
		}
		
		private function FindArmyCenter():void {
			top = left = 100;
			right = bottom = -1;
			var tile:Point;
			var i:int;
			for(i = 0; i < tiles.length; ++i) {
				tile = tiles[i];
				if(tile.x < left) {
					left = tile.x;
				}
				if(tile.x > right) {
					right = tile.x;
				}
				if(tile.y < top) {
					top = tile.y;
				}
				if(tile.y > bottom) {
					bottom = tile.y;
				}
			}
			var cX:int = (right + left) / 2 - this.x;
			var cY:int = (bottom + top) / 2 - this.y;
			
			var maxNeighbors:int = 0;
			var bestCenters:Array = new Array();
			// find all tiles that have most neighbor tiles from same region
			for(i = 0; i < tiles.length; ++i) {
				tile = tiles[i];
				var dir:int;
				var neighborsCount:int = 0;
				for(dir = 0; dir < 6; ++dir) {
					var n:int = map.GetNeighborTile(tile.x, tile.y, dir);
					if(n == ID) {
						neighborsCount++;
					}
					else {
						AddNeighbor(n);
					}
				}
				
				// if all neighbor tiles are same, expand search
				if(neighborsCount == 6) {
					for(dir = 0; dir < 6; ++dir) {
						for(var dir2:int  = 0; dir2 < 6; ++dir2) {
							var tile2:Point = moveTile(tile, dir);
							if(map.GetNeighborTile(tile2.x, tile2.y, dir2) == ID) {
								neighborsCount++;
							}
						}
					}
				}
				
				if(neighborsCount > maxNeighbors) {
					bestCenters.length = 0;
					maxNeighbors = neighborsCount;
				}
				if(neighborsCount == maxNeighbors) {
					bestCenters.push(tile);
				}
			}
			
			// find most central tile 
			var minDist:int = 999999;
			var bestCenter:Point;
			for(i = 0; i < bestCenters.length; ++i) {
				var dist:int = Math.abs(cX - bestCenters[i].x) + Math.abs(cY - bestCenters[i].y);
				if(dist < minDist) {
					minDist = dist;
					bestCenter = bestCenters[i];
				}
			}
			
			centerX = bestCenter.x;
			centerY = bestCenter.y;
		}
		
		private function AddNeighbor(nID:int):void {
			var found:Boolean = false;
			for(var i:int = 0; i < neighborRegions.length; ++i) {
				if(neighborRegions[i] == nID) {
					found = true;
					break;
				}
			}
			if(!found) {
				neighborRegions.push(nID);
			}
		}
		
		private function DrawRegion():void {
			// find first border hex
			var index:int;
			var dir:int;
			var tile:Point;

			//trace("draw region: " + ID);
			
			var points:Array = new Array();
			points[0] = new Point(0 - this.x, 0 - this.y); 
			points[1] = new Point(hexR - this.x, hexH - this.y);
			points[2] = new Point(hexR - this.x, hexSide + hexH - this.y);
			points[3] = new Point(0 - this.x, hexSide + 2*hexH - this.y);
			points[4] = new Point(- hexR - this.x, hexSide + hexH - this.y);
			points[5] = new Point(- hexR - this.x, hexH - this.y);
			
			var maskGraphics:Graphics = regionMask.graphics;
			var borderGraphics:Graphics = borderSprite.graphics;
			var selectedGraphics:Graphics = selectedSprite.graphics;
			borderGraphics.clear();
			selectedGraphics.clear();
			
			selectedGraphics.beginFill((owner != null) ? selectColors[owner.colorID] : 0x808080);
			maskGraphics.beginFill(0xFFFFFF);
			for(index = 0; index < tiles.length; ++index) {
				tile = tiles[index];
				borderGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[0].x, tile.y * (hexSide + hexH) + points[0].y);
				selectedGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[0].x, tile.y * (hexSide + hexH) + points[0].y);
				if(firstDraw) {
					maskGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[0].x, tile.y * (hexSide + hexH) + points[0].y);
				}
				
				for(dir = 0; dir < 6; ++dir) {
					selectedGraphics.lineTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[(dir + 1) % 6].x, tile.y * (hexSide + hexH) + points[(dir + 1) % 6].y);
					if(firstDraw) {
						maskGraphics.lineTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[(dir + 1) % 6].x, tile.y * (hexSide + hexH) + points[(dir + 1) % 6].y);
					}
					
					borderGraphics.moveTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[dir].x, tile.y * (hexSide + hexH) + points[dir].y);
					if(map.GetNeighborTile(tile.x, tile.y, dir) != ID) {
						var thinLine:Boolean = map.RegionsHaveSameOwner(map.GetNeighborTile(tile.x, tile.y, dir), ID); 
						borderGraphics.lineStyle(thinLine ? 2 : 6, (owner != null) ? G.borderColors[owner.colorID] : 0xAAAAAA);
						
						borderGraphics.lineTo(hexW * tile.x + ((tile.y % 2 == 1) ? hexW / 2 : 0) + points[(dir + 1) % 6].x, tile.y * (hexSide + hexH) + points[(dir + 1) % 6].y);
					}
				}
				borderGraphics.endFill();
			}
			
			firstDraw = false;
		}

		private function DrawBackground():void {
			//trace("draw background: " + ID);
			terrainSprite.graphics.clear();
			
			// find bounds
			var left:int = 100000, right:int = 0, top:int = 100000, bottom:int = 0;
			var tile:Point;
			for(var index:int = 0; index < tiles.length; ++index) {
				tile = tiles[index];
				if(tile.x * hexW + ((tile.y % 2 == 1) ? hexW / 2 : 0) < left) {
					left = tile.x * hexW + ((tile.y % 2 == 1) ? hexW / 2 : 0);
				}
				if(tile.x * hexW + hexW + ((tile.y % 2 == 1) ? hexW / 2 : 0) > right) {
					right = tile.x * hexW + hexW + ((tile.y % 2 == 1) ? hexW / 2 : 0);
				}
				if(tile.y * (hexSide + hexH) < top) {
					top = tile.y * (hexSide + hexH);
				}
				if(tile.y * (hexSide + hexH) + (hexSide + hexH + hexH) > bottom) {
					bottom = tile.y * (hexSide + hexH) + (hexSide + hexH + hexH);
				}
			}
			
			if(owner) {
				var b:BitmapData = owner.race.regionImage.bitmapData.clone();
				
				var colorTransform:ColorTransform = new ColorTransform();
				colorTransform.redMultiplier = ((G.colors[owner.colorID] & 0xFF0000) >> 16) / 255.0;
				colorTransform.greenMultiplier = ((G.colors[owner.colorID] & 0xFF00) >> 8) / 255.0;
				colorTransform.blueMultiplier = (G.colors[owner.colorID] & 0xFF) / 255.0;
				b.colorTransform(b.rect, colorTransform); 
				terrainSprite.graphics.beginBitmapFill(b);
				var offsetX:int = (x) % b.width;
				var offsetY:int = (y) % b.height;
				terrainSprite.x = - offsetX;
				terrainSprite.y = - offsetY;
				terrainSprite.graphics.drawRect(-2 * hexW, 0, right - left + 2 * hexW + offsetX, bottom - top + offsetY);
			}
			else {
				terrainSprite.graphics.beginFill(0xDDDDDD);
				terrainSprite.graphics.drawRect(-2 * hexW, 0, right - left + 2 * hexW - terrainSprite.x, bottom - top - terrainSprite.y);
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
	}
	
}
