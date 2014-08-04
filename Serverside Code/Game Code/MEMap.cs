using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds
{
	class MEMap
	{
		public int width, height;
		public byte[] tiles;
		private bool hasDeluxe;

		public enum MapResult {MAP_OK = 0, MAP_NOT_FULL, TOO_MANY_REGIONS, MAP_NOT_CONTINUOS, REGIONS_TOO_SMALL};

		public MEMap(int _width, int _height, byte[] _tiles, bool _hasDeluxe) {
			width = _width;
			height = _height;
			tiles = _tiles;
			hasDeluxe = _hasDeluxe;

			shrinkMap();
		}

		public MapResult checkMap() {
			// check for region count and empty spaces
			int maxRegionValue = hasDeluxe ? 250 : 40;
			foreach (byte tile in tiles) {
				if (tile == 255)
					return MapResult.MAP_NOT_FULL;

				if (tile > maxRegionValue)
					return MapResult.TOO_MANY_REGIONS;
			}

			List<MERegion> regions = new List<MERegion>();

			for(int x = 0; x < width; x++) {
				for (int y = 0; y < height; y++) {
					byte tile = tiles[width * y + x];
					if (tile != 0) {
						// check if region with this Id already exists
						MERegion found = null;
						foreach (MERegion region in regions) {
							if (region.Id == tile) {
								found = region;
								break;
							}
						}

						if (found == null) {
							found = new MERegion(this, tile);
							regions.Add(found);
						}

						found.addTile(x, y);
					}
				}
			}

			bool regionsOk = true;
			foreach (MERegion region in regions) {
				regionsOk &= region.checkConnectivity();
				if (!regionsOk)
					return MapResult.MAP_NOT_CONTINUOS;
			}

			regionsOk = true;
			foreach (MERegion region in regions) {
				regionsOk &= region.checkRegionSize();
				if (!regionsOk)
					return MapResult.REGIONS_TOO_SMALL;
			}

			// check map connectivity using regions
			List<MERegion> a = new List<MERegion>(regions.Count);

			regions.ForEach((item) =>
			{
				a.Add(new MERegion(item));
			});

			/*bool[] checkArr = new bool[255];
			for (int i = 0; i < 255; i++) {
				checkArr[i] = true;
			}*/
			
			floodfillStep(a, a[0]);

			if (a.Count != 0) {
				return MapResult.MAP_NOT_CONTINUOS;
			}
			
			return MapResult.MAP_OK;
		}

		private void floodfillStep(List<MERegion> a, MERegion me) {
			// remove current region from the array
			for (int i = 0; i < a.Count; i++) {
				if (a[i].Id == me.Id) {
					a.RemoveAt(i);
					break;
				}
			}
			
			if (a.Count == 0) return;
			
			bool[] nb = me.getNeighbours();
			// iterate over neighb - they are saved as keys so "i"=ID
			for (int i = 0; i < 255; i++) {
				//if (this.checkC_cnt == 0) break;
				if (nb[i] == false) continue;
				
				for(int r = a.Count - 1; r >= 0; r--) {
					if (r >= a.Count) continue;
					floodfillStep(a, a[r]);
				}
			}
		}

		private void shrinkMap() {
			// find map boundaries
			int minX = 200;
			int minY = 200;
			int maxX = 0;
			int maxY = 0;
			for (int i = 0; i < tiles.Length; i++) {
				int tileX = i % width;
				int tileY = i / width;
				if (tiles[i] != 0) {
					if (tileX < minX) minX = tileX;
					if (tileX > maxX) maxX = tileX;
					if (tileY < minY) minY = tileY;
					if (tileY > maxY) maxY = tileY;
				}
			}

			// align start of map to even number so it doesn't break (hex lines offsets
			if (minY % 2 == 1) minY--;
			int mapWidth = maxX - minX + 1;
			int mapHeight = maxY - minY + 1;

			byte[] croppedTiles = new byte[mapWidth * mapHeight];
			for (int i = 0; i < mapWidth * mapHeight; i++) {
				croppedTiles[i] = tiles[(i % mapWidth + minX) + (int)(i / mapWidth + minY) * width];
			}

			width = mapWidth;
			height = mapHeight;

			tiles = croppedTiles;
		}

		public int getNeighborTile(int x, int y, int dir) {
			int nx = x;
			int ny = y;
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
			if(nx < 0 || nx >= width || ny < 0 || ny >= height) {
				return -1;
			}
			else 
				return tiles[ny * width + nx];
		}

		public MECoord getNeighborTileCoor(int x, int y, int dir) {
			int nx = x;
			int ny = y;
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
			
			return new MECoord(nx,ny);
		}
	}
}
