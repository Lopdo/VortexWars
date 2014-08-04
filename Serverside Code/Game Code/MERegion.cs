using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Wargrounds
{
	class MERegion
	{
		private List<MECoord> tiles;

		public int Id;
		private MEMap map;

		public MERegion(MEMap _map, int _Id) {
			map = _map;
			Id = _Id;

			tiles = new List<MECoord>();
		}

		// copy constructor
		public MERegion(MERegion source) {
			map = source.map;
			Id = source.Id;
			tiles = source.tiles;
		}

		public void addTile(int x, int y) {
			tiles.Add(new MECoord(x, y));
		}

		public bool checkRegionSize() {
			int count = 0;
			int maxCount = 0;
			int dir = 0;
			int tmp;
			// if region has less than 4 tiles it is considered "bad size"
			if (tiles.Count < 4) return false;
			
			foreach(MECoord tile in tiles) {
				count = 0;
				for (dir = 0; dir < 6; dir++) {
					tmp = map.getNeighborTile(tile.x, tile.y, dir);
					if (tmp == Id) count++;
				}
				// found tile bordering with at least 4 tile of the same region 
				if (count > maxCount) maxCount = count;
				if (maxCount >= 4) return true;
			}
			
			return false;
		}

		public bool checkConnectivity() {
			// empty and 1 tile regions are considered "one piece"
			if (tiles.Count < 2) return true;

			List<MECoord> a = new List<MECoord>(tiles.Count);

			tiles.ForEach((item) =>
			{
				a.Add(new MECoord(item.x, item.y));
			});

			floodfillStep(a, a[0]);
			return a.Count == 0;
		}

		private void floodfillStep(List<MECoord> a, MECoord tile) {
			if (a.Count == 0) return;

			int dir = 0;
			MECoord p;
			int len = a.Count; 
			int tmp;
			
			// remove current tile from the arrau
			for (int i = 0; i < a.Count; i++) {
				if (a[i].x == tile.x && a[i].y == tile.y) {
					a.RemoveAt(i);
					break;
				}
			}
			
			// search for neighbour tiles that are from same region and call recursively on them
			while (dir < 6 && len > 0) {
				p = map.getNeighborTileCoor(tile.x, tile.y, dir);
				tmp = map.getNeighborTile(tile.x, tile.y, dir);
				if(map.getNeighborTile(tile.x, tile.y, dir) == Id) {
					for (int i = 0; i < a.Count; i++) {
						if (a[i].x == p.x && a[i].y == p.y) {
							floodfillStep(a, p);
							len = a.Count;
							break;
						}
					}
				}
				dir++;
			}
		}

		public bool[] getNeighbours() {
			bool []a = new bool[255];
			
			int dir = 0; 
			int nID = -1;
			
			for (int i = 0; i < tiles.Count; i++) {
				for (dir = 0; dir < 6; dir++) {
					nID = map.getNeighborTile(this.tiles[i].x, this.tiles[i].y, dir);
					// void and world are not neighbours
					if(nID > 0 && nID != Id) {
						a[nID] = true;
					}
				}
			}
			
			return a;
		}
	}
}
