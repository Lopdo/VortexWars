package Game
{
	import Game.Backgrounds.Background;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class Map extends Sprite
	{
		private var mapWidth:int;
		private var mapHeight:int;
		private var tiles:Array;
		
		private var regions:Array = new Array();
		private var regionID:int = 1;
		private var newDiceRegions:Array = new Array();
		private var lastRegionNewDice:int = -1;
		private var timeFromLastNewDice:Number = 0;
		
		private var contentTop:int, contentBottom:int, contentRight:int, contentLeft:int; 
		private var offsetX:int, offsetY:int;
		private var offsetXRatio:Number, offsetYRatio:Number;
		private var minOffsetX:int, minOffsetY:int, maxOffsetX:int, maxOffsetY:int;
		
		public function Map(w:int, h:int, t:Array)
		{
			mapWidth = w;
			mapHeight = h;
			tiles = t;
		}
		
		public function update(timeDelta:Number):void {
			for each(var r:Region in regions) {
				r.update(timeDelta);
			}
			
			if(newDiceRegions.length > 0) {
				if(timeFromLastNewDice > 0.25) {
					timeFromLastNewDice = 0;
					
					var index:int = 0;
					if(newDiceRegions.length > 1) {
						index = Math.random() * (newDiceRegions.length - 2);
						if(index >= lastRegionNewDice) {
							index++;
						}
					}
					lastRegionNewDice = index;
					
					// if we added last dice, we remove this region from array
					if(!newDiceRegions[index].addNewDice()) {
						newDiceRegions.splice(index, 1);
					}
					
					G.sounds.playSound("new_unit_placed");
				}
				timeFromLastNewDice += timeDelta;
			}
		}
		
		public function AddRegion(owner:Player, dice:int):void {
			var r:Region = new Region(owner, dice, this);
			addChild(r);
			r.ID = regionID++;
			regions[r.ID] = r;
			
			for(var i:int = 0; i < mapWidth * mapHeight; ++i) {
				if(tiles[i] == r.ID) {
					r.AddTile(i % mapWidth, i / mapWidth); 
				}
			}
		}
		
		public function getRegionCount():int {
			return regions.length;
		}
		
		public function Finalize(background:int):void {
			contentTop = contentLeft = 999999999;
			contentBottom = contentRight = 0;
			
			for each(var r:Region in regions) {
				r.Finalize();
				var rect:Rectangle = r.getBoundRect();
				if(contentTop > rect.y) contentTop = rect.y;
				if(contentBottom < rect.bottom) contentBottom = rect.bottom;
				if(contentLeft > rect.x) contentLeft = rect.x;
				if(contentRight < rect.right) contentRight = rect.right;
			}

			minOffsetX = - (contentRight - contentLeft - 550 + 100);
			maxOffsetX = 100;
			minOffsetY = - (contentBottom - contentTop - 590 + 200);
			maxOffsetY = 100;

			offsetX = minOffsetX + (maxOffsetX - minOffsetX) / 2;
			offsetY = minOffsetY + (maxOffsetY - minOffsetY) / 2;
			offsetXRatio = 0.5;
			offsetYRatio = 0.5;
			
			x = offsetX;
			y = offsetY;
			
			var backgroundSprite:Background = new Background(background, contentRight + 3000, contentBottom + 3000);
			backgroundSprite.x = -1024;
			backgroundSprite.y = -1008;
			addChildAt(backgroundSprite, 0);
		}
		
		public function setMapScale(scale:Number):void {
			var visibleWidth:int = mask.width / scale;
			var visibleHeight:int = mask.height / scale;
			
			var mapWidth:int = contentRight - contentLeft;
			var mapHeight:int = contentBottom - contentTop;
			
			var borderSize:int = 100 / scale;
			
			if(mapWidth + borderSize < visibleWidth) {
				var mapOffsetX:int = (visibleWidth - (mapWidth + borderSize)) / 2;
				maxOffsetX = minOffsetX = mapOffsetX - contentLeft + borderSize / 2;
				offsetXRatio = 0.5;
			}
			else {
				maxOffsetX = borderSize - contentLeft;
				minOffsetX = visibleWidth - (mapWidth + borderSize) - contentLeft;
			}
			if(mapHeight + borderSize < visibleHeight) {
				var mapOffsetY:int = (visibleHeight - (mapHeight + borderSize)) / 2;
				maxOffsetY = minOffsetY = mapOffsetY - contentTop + borderSize / 2;
				offsetYRatio = 0.5;
			}
			else {
				maxOffsetY = borderSize - contentTop;
				minOffsetY = visibleHeight - (mapHeight + borderSize) - contentTop;
			}
			
			x = minOffsetX + (maxOffsetX - minOffsetX) * offsetXRatio;
			y = minOffsetY + (maxOffsetY - minOffsetY) * offsetYRatio;
			
			offsetX = x;
			offsetY = y;

			offsetXRatio = (offsetX - minOffsetX) / (maxOffsetX - minOffsetX);
			offsetYRatio = (offsetY - minOffsetY) / (maxOffsetY - minOffsetY);
		}
		
		public function Move(deltaX:int, deltaY:int):void {
			offsetX += deltaX;
			offsetY += deltaY;
			
			if(offsetX < minOffsetX) offsetX = minOffsetX;
			if(offsetY < minOffsetY) offsetY = minOffsetY;
			if(offsetX > maxOffsetX) offsetX = maxOffsetX;
			if(offsetY > maxOffsetY) offsetY = maxOffsetY;
			
			x = offsetX;
			y = offsetY;
			
			offsetXRatio = (offsetX - minOffsetX) / (maxOffsetX - minOffsetX);
			offsetYRatio = (offsetY - minOffsetY) / (maxOffsetY - minOffsetY);
		}
		
		public function GetNeighborTile(x:int, y:int, dir:int):int {
			var nx:int = x;
			var ny:int = y;
			switch(dir) {
				case 0: 
					nx += (ny % 2 == 1) ? 1 : 0;
					ny--;
					break;
				case 1:
					nx++;
					break;
				case 2:
					nx += (ny % 2 == 1) ? 1 : 0;
					ny++;
					break;
				case 3:
					nx -= (ny % 2 == 1) ? 0 : 1;
					ny++;
					break;
				case 4:
					nx--;
					break;
				case 5:
					nx -= (ny % 2 == 1) ? 0 : 1;
					ny--;
					break;
			}
			if(nx < 0 || nx >= mapWidth || ny < 0 || ny >= mapHeight) {
				return -1;
			}
			else 
				return tiles[ny * mapWidth + nx];
		}
		
		public function RegionsHaveSameOwner(id1:int, id2:int):Boolean {
			if(id1 <= 0 || id2 <= 0) return false;
			
			return regions[id1].owner == regions[id2].owner;
		}
		
		public function UpdateBorders(r:Region):void {
			r.RedrawBorders();
			
			for each(var i:int in r.neighborRegions) {
				if(i > 0)
					regions[i].RedrawBorders();
			}
		}
	
		public function GetRegionUnderCursor(mx:int, my:int):Region {
			for each(var r:Region in regions) {
				if(r.ContainsPoint(mx - offsetX, my - offsetY))
					return r;
			}
			return null;
		}
		
		public function deselectAllRegions():void {
			for each(var r:Region in regions) {
				r.SetActive(false);
			}
		}
		
		public function getPlayersRegions(player:Player):Array {
			var result:Array = new Array();
			for each(var r:Region in regions) {
				if(r.owner == player) {
					result.push(r);
				}
			}
			return result;
		}
		
		public function finishDistribution():void {
			if(newDiceRegions.length > 0) {
				G.sounds.playSound("new_unit_placed");
			}
			while(newDiceRegions.length > 0) {
				// if we added last dice, we remove this region from array
				if(!newDiceRegions[0].addNewDice()) {
					newDiceRegions.splice(0, 1);
				}
			}
		}
		
		public function UpdateRegionDice(regionID:int, dice:int):int {
			var newDice:int = 0;
			if(regions[regionID]) {
				var n:int = regions[regionID].setNewDiceCount(dice); 
				newDice += n;
				if(n > 0) {
					newDiceRegions.push(regions[regionID]);
				}
			}
			else {
				G.client.errorLog.writeError("Map::UpdateRegionDice - region is null", "regionID: " + regionID, "", null);
			}
			timeFromLastNewDice = 1;
			return newDice; 
		}
		
		public function GetRegion(id:int):Region {
			return regions[id];
		}
		
		public function RemovePlayer(playerID:int):void {
			for each(var r:Region in regions) {
				if(r.owner && r.owner.ID == playerID) {
					r.setOwner(null);
				}
			}
			redraw();
		}
		
		public function redraw():void {
			for each(var r:Region in regions) {
				r.redraw();
			}
		}
		
		public function moreMovesPossible(player:Player):Boolean {
			for each(var r:Region in regions) {
				// check all player's regions
				if(r.owner && r.owner.ID == player.ID) {
					// that have enough dice to attack
					if(r.dice > 1) {
						// and have enemy neighbor to attack
						for each(var n:int in r.neighborRegions) {
							var nr:Region = GetRegion(n);
							if(nr && (nr.owner == null || nr.owner.ID != player.ID)) {
								return true;
							}
						}
					}
				} 
			}
			return false;
		}
		
		public function getNonFullRegionCount(owner:Player):int {
			var result:int = 0;
			for each(var r:Region in regions) {
				if(r.owner && r.owner.ID == owner.ID && r.dice < 8) {
					result++;
				}
			}
			return result;
		}
		
		public function dumpRegionsToString():String {
			var result:String = "";
			for each(var r:Region in regions) {
				result += r.ID + ": ";
				if(r.owner) {
					result += r.owner.ID + ", ";
				}
				else {
					result += "-1, ";
				}
			}
			return result;
		}
	}
}