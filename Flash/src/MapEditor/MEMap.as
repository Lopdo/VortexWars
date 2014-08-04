package MapEditor
{
	import IreUtils.ResList;
	
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class MEMap extends Sprite
	{
		private var MAP_MAX_SIZE:int = 200;
		private var MAX_REGIONS:int = 255;
		private const WORLD_ID:int = -1;
		
		public var mapWidth:int;
		public var mapHeight:int;
		private var tiles:Array = new Array(MAP_MAX_SIZE*MAP_MAX_SIZE);
		private var croppedTiles:Array;
		
		protected var world:MERegion;
		
		private var regions:Array = new Array();
		private var currentRegionIndex:int = 1;	// index of currently active/editing region in region array

		private var contentTop:int, contentBottom:int, contentRight:int, contentLeft:int; 
		private var offsetX:int, offsetY:int;
		private var offsetXRatio:Number, offsetYRatio:Number;
		private var minOffsetX:int, minOffsetY:int, maxOffsetX:int, maxOffsetY:int;
		
		private var checkC:Array;
		private var checkC_cnt:int;
		
		public function MEMap(maxRegions:int, maxSize:int)
		{
			MAX_REGIONS = maxRegions;
			MAP_MAX_SIZE = maxSize;
			
			for(var i:int = 0; i < MAP_MAX_SIZE*MAP_MAX_SIZE; i++) {
				tiles[i] = 0;
			}
			world = new MERegion(this, 0);
			world.ID = WORLD_ID;
			this.addChild(world);
		}
		
		public function update(timeDelta:Number):void {
			world.update(timeDelta);
			for each(var r:MERegion in regions) {
				if (r == null) continue;
				r.update(timeDelta);
			}			
		}
		
		public function tilesAsByteArray():ByteArray {
			var result:ByteArray = new ByteArray();
			for each(var t:int in croppedTiles) {
				result.writeByte(t);
			}
			return result;
		}
		
		public function getTileIDByCoor(wx:int, wy:int):int {
			var newCoor:Point = world.worldToMap(wx - offsetX, wy - offsetY);
			if (newCoor.x < 0 || newCoor.y < 0 || newCoor.x >= MAP_MAX_SIZE || newCoor.y >= MAP_MAX_SIZE) {
				return -2;	// if we're out of bounds, return -2
			}
			return this.tiles[newCoor.y * MAP_MAX_SIZE + newCoor.x] == null ? -2 : this.tiles[newCoor.y * MAP_MAX_SIZE + newCoor.x];
		}
		
		/**
		 * Changes tile ID from oldID to newID - but only if oldID equals the tileID 
		 * 
		 * @return Boolean true if success
		 */
		public function changeTileIDByXY(x:int, y:int, oldID:int, newID:int): Boolean {
			if (this.tiles[y * MAP_MAX_SIZE + x] == oldID) {
				this.tiles[y * MAP_MAX_SIZE + x] = newID;
				return true;
			}
			return false;
		}
		
		/**
		 * Adds tile to the world region - the base region for all regions
		 *  
		 * @params wx,wy - coordinates real world, not in map
		 */
		public function addTileToWorld(wx:int, wy:int):void {
			var checkID:int = this.getTileIDByCoor(wx,wy);
			if (checkID == 0) {
				var newCoor:Point = world.worldToMap(wx - offsetX, wy - offsetY);
				this.tiles[newCoor.y * MAP_MAX_SIZE + newCoor.x] = world.ID;
				this.world.AddTile(newCoor.x, newCoor.y, false);						
			}
		}
		
		public function redrawWorld():void {
			world.DrawBackground();
		}
		
		/**
		 * Remove/erase tile from the world region
		 * 
		 * @params wx,wy - coordinates real world, not in map
		 */
		public function removeTileFromWorld(wx:int, wy:int):void {
			var checkID:int = this.getTileIDByCoor(wx,wy);
			if (checkID == world.ID) {
				var newCoor:Point = world.worldToMap(wx - offsetX, wy - offsetY);
				this.tiles[newCoor.y * MAP_MAX_SIZE + newCoor.x] = 0;
				this.world.removeTile(newCoor.x, newCoor.y);						
			}			
		}
		
		/**
		 * Adds tile to the current region and returns true if successful.
		 * 
		 * @return Boolean true if tile successfully added  
		 * 
		 */
		public function addTileToCurrentRegion(wx:int, wy:int, overdraw:Boolean):Boolean {
			var newCoor:Point = world.worldToMap(wx - offsetX, wy - offsetY);
			var checkID:int = this.getTileIDByCoor(wx,wy);
			var status:Boolean = false;
			
			var currentRegion:MERegion = this.regions[this.currentRegionIndex];

			// if NOT clicked on world or clicked on myself, exit 
			if (checkID != WORLD_ID || (currentRegion != null && checkID == currentRegion.ID)) return false;
			
			
			if (currentRegion == null) {
				currentRegion = new MERegion(this, 2);
				currentRegion.ID = this.currentRegionIndex;
				this.regions[this.currentRegionIndex] = currentRegion;
				this.addChild(currentRegion);
			}
			
			// painting directly on empty world map
			if (checkID == this.world.ID) {
				this.tiles[newCoor.y * MAP_MAX_SIZE + newCoor.x] = currentRegion.ID;
				this.world.removeTile(newCoor.x, newCoor.y);	// remove world tile
				currentRegion.AddTile(newCoor.x, newCoor.y);
				status = true;
				
			} else if (checkID !== world.ID && overdraw) {	// DEPRECATED! if the tile is part of another region, check if we can overdraw
				var originalRegion:MERegion = this.GetRegion(checkID);
				originalRegion.removeTile(newCoor.x, newCoor.y);			
				this.tiles[newCoor.y * MAP_MAX_SIZE + newCoor.x] = currentRegion.ID;
				currentRegion.AddTile(newCoor.x, newCoor.y);
				status = true;
			}
			
			return status;
		}

		/**
		 * Removes tiles from currently active/editing region and returns true if this was the last tile.
		 * 
		 * @return Boolean true if last tile of the region was removed
		 * 
		 */
		public function removeTileFromCurrentRegion(wx:int, wy:int):Boolean {
			var checkID:int = this.getTileIDByCoor(wx,wy);
			var currentRegion:MERegion = this.regions[this.currentRegionIndex];
			var last:Boolean = false;
			
			if (currentRegion != null && checkID == currentRegion.ID) {
				var newCoor:Point = world.worldToMap(wx - offsetX, wy - offsetY);
				currentRegion.removeTile(newCoor.x, newCoor.y);
				// if region contains no tiles, delete it
				if (currentRegion.isEmpty()) {
					this.removeChild(currentRegion);
					currentRegion = null;
					this.regions[this.currentRegionIndex] = null;
					// remove region from regions list
					this.regions.splice(this.currentRegionIndex,1);
					this.prepareForSave();	// order regions IDs so that index=ID 
					this.currentRegionIndex = this.regions.length < 1 ? 1 : this.regions.length; 
					last = true;
				}
				
				this.tiles[newCoor.y * MAP_MAX_SIZE + newCoor.x] = world.ID;
				this.world.AddTile(newCoor.x, newCoor.y);
								
			}  
			
			return last;
		}
		
		/**
		 * Saves current region = change it's color and returns false if fail
		 * 
		 * @return Boolean false if fail
		 */
		public function saveCurrentRegion(errors:Array):Boolean {
			if (null == this.regions[this.currentRegionIndex]) return true;
			
			return saveRegion(currentRegionIndex, errors);
		}
		
		public function saveRegion(index:int, errors:Array):Boolean {
			errors.length = 0;
			
			if (this.regions[index] && this.regions[index].isOnePiece()) {
				var cntNb:int = this.regions[index].getGoodSize();
				if (cntNb > 3) {
					if (cntNb < 6) {
						errors.push("W:It is better to have a wider region. Make at least one full circle.");
					}
					this.regions[index].setInactive();
					this.currentRegionIndex = this.regions.length;
					return true;
				} else {
					errors.push("Region cannot be linear. Add some tiles to make it wider.");
					return false;
				}
			} else {
				errors.push("Region is not continuous. Remove all separated parts.");				
				return false;				
			}
		}
			
		/**
		 * Selects region for editing and return true if success.
		 * 
		 * @return Boolean true if region is selected for editing
		 */
		public function selectRegionToEdit(wx:int, wy:int):Boolean {
			
			var ind:int = GetRegionIndexUnderCursor(wx, wy);
			
			if (ind == 0) return false;
			var region:MERegion = this.regions[ind];
			
			if (null != region && region.ID > world.ID) {
				var err:Array=new Array();
				if (this.saveCurrentRegion(err)) {
					region.setActive();
					this.currentRegionIndex = ind;
					return true;
				}
			}
			
			return false;
		}

		/**
		 * Checks if neither of the currentregion nor neighbours is enclave.
		 * 
		 * @return true if enclave found between neighbours or self
		 */
		/*public function foundEnclave():Boolean {
			var nlist:Array = this.regions[this.currentRegionID].getNeighbours();
			for (var index:String in nlist) {
				if (this.regions[index].isEnclave()) return true;
			}
			return false;
		}*/	
		
		public function loadMap(w:int, h:int, data:ByteArray):Boolean {
			clearMap();
			
			//this.mapWidth = w; 
			//this.mapHeight = h;
			//this.tiles.length = 0;
			var row:int = 0;
			var tileValue:int = 0;
			
			var tileOffsetX:int = MAP_MAX_SIZE / 2 - w / 2;
			var tileOffsetY:int = MAP_MAX_SIZE / 2 - h / 2;
			if(tileOffsetY % 2) tileOffsetY--;
			
			for(var i:int = 0; i < w * h; ++i) {
				var tileOldX:int = i % w;
				var tileOldY:int = i / w;
				var tileNewX:int = tileOldX + tileOffsetX;
				var tileNewY:int = tileOldY + tileOffsetY;
				
				tileValue = data[i] == 255 ? -1 : data[i];
				tiles[tileNewX + tileNewY * MAP_MAX_SIZE] = tileValue;

				if (tileValue > 0) {
					if(this.regions[tileValue] == null) {
						this.regions[tileValue] = new MERegion(this, 1);
						this.regions[tileValue].ID = tileValue;
						this.addChild(this.regions[tileValue]);
					}
					
					this.regions[tileValue].AddTile(tileNewX, tileNewY);
				} else if (tileValue == WORLD_ID) {
					world.AddTile(tileNewX, tileNewY);
				}
			}
			
			this.currentRegionIndex = this.regions.length > 0 ? this.regions.length : 1; 

			this.Finalize();
			
			this.prepareForSave();
			
			return true;			
		}
		
		/**
		 * Clears the whole map. 
		 * 
		 */
		public function clearMap():void {
			
			clearRegions();
			
			removeChild(world);
			world = null;

			for(var i:int = 0; i < MAP_MAX_SIZE*MAP_MAX_SIZE; ++i) {
				tiles[i] = 0; 
			}
			
			world = new MERegion(this, 0);
			world.ID = WORLD_ID;
			addChild(world);
			
			this.currentRegionIndex = 1;
		}
		
		/**
		 * Clears regions in the map. 
		 * 
		 */
		public function clearRegions():void {
			if (this.regions.length < 1) return;
			
			for each(var r:MERegion in this.regions) {
				removeChild(r);
			}
			
			for (var i:int=0; i < this.tiles.length; ++i) {
				if (this.tiles[i] > 0) {
					this.tiles[i] = WORLD_ID;
					this.world.AddTile(i % MAP_MAX_SIZE, i / MAP_MAX_SIZE, false);
				} 				
			}
			
			this.Finalize();
			this.regions.length = 0;
			this.currentRegionIndex = 1;
		}
		
		public function Finalize():void {
			contentTop = -(MERegion.hexH); 
			contentLeft = -MERegion.hexR;
			contentBottom = MAP_MAX_SIZE * (MERegion.hexH + MERegion.hexSide) + MERegion.hexH + MERegion.hexSide;
			contentRight = MAP_MAX_SIZE * MERegion.hexW+MERegion.hexR;
			
			world.Finalize();

			minOffsetX = - (contentRight - contentLeft - 570);
			maxOffsetX = 0;
			minOffsetY = - (contentBottom - contentTop - 600);
			maxOffsetY = 0;
			
			//minOffsetX = -contentRight + 50;
			//maxOffsetX = 450;
			//minOffsetY = -contentBottom + 50;
			//maxOffsetY = 500;

			offsetX = minOffsetX + (maxOffsetX - minOffsetX) / 2;
			offsetY = minOffsetY + (maxOffsetY - minOffsetY) / 2;
			
			x = offsetX;
			y = offsetY;
			
			offsetXRatio = 0.5;
			offsetYRatio = 0.5;
			
			graphics.beginBitmapFill(ResList.GetArtResource("map_bg_0").bitmapData);
			graphics.drawRect(-600, -600, contentRight + 1200, contentBottom + 1200);
			graphics.endFill();
			// border of active map
			graphics.lineStyle(2, 0xFFFFFF);
			graphics.drawRect(contentLeft, contentTop, contentRight, contentBottom);
			
			/*graphics.lineStyle(1, 0x777777);
			var centerX:int = (contentRight-MERegion.hexW-contentLeft) / 2;
			var centerY:int = contentBottom / 2; 
			graphics.moveTo(centerX, contentTop);
			graphics.lineTo(centerX, contentBottom);
			graphics.moveTo(contentLeft, centerY);
			graphics.lineTo(contentRight + contentLeft, centerY);*/
			
		}
		
		public function setMapScale(scale:Number):void {
			var visibleWidth:int = mask.width / scale;
			var visibleHeight:int = mask.height / scale;
			
			var mapWidth:int = contentRight - contentLeft;
			var mapHeight:int = contentBottom - contentTop;
			
			maxOffsetX = - contentLeft;
			minOffsetX = visibleWidth - (mapWidth) - contentLeft;
			maxOffsetY = - contentTop;
			minOffsetY = visibleHeight - (mapHeight) - contentTop;
			
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
		
		public function moveToPoint(newX:int, newY:int):void {
			offsetX = 275 - newX;
			offsetY = 300 - newY;
			
			x = offsetX;
			y = offsetY;
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
			if(nx < 0 || nx >= MAP_MAX_SIZE || ny < 0 || ny >= MAP_MAX_SIZE) {
				return -1;
			}
			else 
				return tiles[ny * MAP_MAX_SIZE + nx];
		}

		public function GetNeighborTileCoor(x:int, y:int, dir:int):Point {
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
			
			return new Point(nx,ny);
		}
		
		public function RegionsHaveSameOwner(id1:int, id2:int):Boolean {
			if(id1 <= 0 || id2 <= 0) return false;
			
			return id1 == id2;
		}
		
		public function UpdateBorders(r:MERegion):void {
			r.RedrawBorders();
			
			for each(var i:int in r.neighborRegions) {
				if(i > 0)
					regions[i].RedrawBorders();
			}
		}
		
		public function GetRegionIndexUnderCursor(mx:int, my:int):int {
			for (var i:int=1; i < regions.length; ++i) {
				if (regions[i] == null) continue;
				if(regions[i].ContainsPoint(mx - offsetX, my - offsetY))
					return i;
			}
			/*for each(var r:MERegion in regions) {
				if(r.ContainsPoint(mx - offsetX, my - offsetY))
					return r;
			}*/
			return 0;
		}
		
		public function GetRegion(id:int):MERegion {
			if (id==-1) return this.world;
			
			for (var i:int=0; i < this.regions.length; i++) {
				if (this.regions[i] != null && this.regions[i].ID == id) return this.regions[i]; 
			}
			return null;
		}
		
		/**
		 * Checks if map is continuous - no islands
		 * 
		 * @return Boolean true if continuous
		 */
		public function checkContinuity():Boolean {
			if (this.regions.length < 3) return true;
			
			checkC = new Array();
			// index checkC by IDs so it's easier to search
			for each(var r:MERegion in this.regions) {
				if (r == null) continue;
				checkC[r.ID] = 1;
			}
			
			this.checkC_cnt = this.checkC.length-2;
			
			// find first valid region
			var first:MERegion = null;
			for(var i:int = 0; i < checkC_cnt; i++) {
				if(regions[i] != null) {
					first = regions[i]; 
					break;
				}
			}
			if(first)
				funguj(first);
			
			return this.checkC_cnt == 0;	
		}
		
		private function funguj(me:MERegion):void {
			checkC[me.ID] = 0;
			this.checkC_cnt--;
			
			if (this.checkC_cnt == 0) return;
			
			var nb:Array = me.getNeighbours();
			// iterate over neighb - they are saved as keys so "i"=ID
			for (var i:int=0;i < nb.length; i++) {
				if (this.checkC_cnt == 0) break;
				if (nb[i] == null) continue;
				
				if (checkC[i] != 0) {
					funguj(GetRegion(i));
				}
			}
		}
		/**
		 * Checks if all tiles of the world region are occupied
		 * by regions.
		 * 
		 */
		public function checkFullWorld():Boolean {
			var result:Boolean = true;
			
			for (var i:int=0; i < tiles.length; i++) {
				if (tiles[i] == world.ID) {
					result = false;
					break;
				}
			}
			return result;
		}
		
		/**
		 * Returns number of regions in the map.
		 * 
		 * @return int number of regions
		 */
		public function getRegionCount():int {
			if (this.regions.length == 0) return 0;
			
			var cnt:int = 0;
			for each(var r:MERegion in this.regions) {
				cnt++;
			}
			
			return cnt;
		}
		/**
		 * Checks if number of region is more than 8 and less than MAX
		 * 
		 */
		public function checkRegionCount():Boolean {
			var cnt:int = getRegionCount();
			return cnt > 7 && cnt <= this.MAX_REGIONS; 
		}
		
		private function sortRegionsById(a:MERegion, b:MERegion):int {
			if(a.ID < b.ID)
				return -1;
			else
				return 1;
		}
		
		public function prepareForSave():void {
			//if (this.regions.length == 0) return;
			if(!G.user.hasDeluxeEditor()) {
				mapWidth = MAP_MAX_SIZE;
				mapHeight = MAP_MAX_SIZE;
				
				croppedTiles = tiles;
				return;
			}
			
			var newRegions:Array = new Array();
			var cnt:int = 1;
			
			this.regions.sort(sortRegionsById);
			
			for each(var r:MERegion in this.regions) {
				if(r) {
					r.setNewID(cnt);
					newRegions[cnt++] = r;
				}
			}
			
			this.regions = newRegions;
			
			// find map boundaries
			var minX:int = MAP_MAX_SIZE;
			var minY:int = MAP_MAX_SIZE;
			var maxX:int = 0;
			var maxY:int = 0;
			var atLeastOneHexPresent:Boolean = false;
			for(var i:int = 0; i < MAP_MAX_SIZE*MAP_MAX_SIZE; i++) {
				var tileX:int = i % MAP_MAX_SIZE;
				var tileY:int = i / MAP_MAX_SIZE;
				if(tiles[i] != 0) {
					atLeastOneHexPresent = true;
					if(tileX < minX) minX = tileX;
					if(tileX > maxX) maxX = tileX;
					if(tileY < minY) minY = tileY;
					if(tileY > maxY) maxY = tileY;
				}
			} 
			if(!atLeastOneHexPresent) {
				minX = minY = 0;
				maxX = maxY = 10;
			}
			// align start of map to even number so it doesn't break (hex lines offsets
			if(minY % 2) minY--;
			mapWidth = maxX - minX + 1;
			mapHeight = maxY - minY + 1;
			
			croppedTiles = new Array(mapWidth * mapHeight);
			for(i = 0; i < mapWidth * mapHeight; i++) {
				croppedTiles[i] = tiles[(i % mapWidth + minX) + int(i / mapWidth + minY) * MAP_MAX_SIZE];
			}
		}
	}
}