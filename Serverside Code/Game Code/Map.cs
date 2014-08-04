using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;

using PlayerIO.GameLibrary;

namespace Wargrounds {
	class JoinData {
		public int[] dir = new int[6];
		public JoinData() {

		}
	}

	public class Region {
		public int ID;
		public int size = 0;

		public Player owner;
		public int dice = 0;

		public bool[] join;// = new bool[Map.MAX_REGION_COUNT];

		public bool connectivityChecked = false;

		public bool hasDefenseBoost;

		public Region(int maxRegionCount) {
			join = new bool[maxRegionCount];
		}
	}

	public class Map
	{
		public int startType = 0;			// 0 == full map, 1 == land grab
		public const int padding = 6;
		//public int MAP_SIZE = 0;
		public int XMAX = 0;
		public int YMAX = 0;
		private int TILE_COUNT;
		private int sizeIndex;
		// we use bytes because sending int one by one (probably) caused thread aborts
		private byte[] tiles;
		private int[] num;
		private int[] rcel;
		public int MAX_REGION_COUNT;
		private int REGION_COUNT;		  // region count with reserve
		private int DESIRED_REGION_COUNT; // how many regions do we actually want
		private int playerCount = 8;
		private int MAX_REGION_DICE = 8;

		private JoinData[] join;
		private Region[] regions;

		private Random rand = new Random();

		Color[] colors;
			
		public Map() {

		}

		public void SetSize(int _sizeIndex) {
			sizeIndex = _sizeIndex;
			/*switch(sizeIndex) {
				case 0:	// small
					XMAX = YMAX = 16 + 2 * padding;
					MAX_REGION_COUNT = 24 + 8;
					break;
				case 1: // medium
					XMAX = YMAX = 20 + 2 * padding;
					MAX_REGION_COUNT = 32 + 12;
					break;
				case 2: // large
					XMAX = YMAX = 26 + 2 * padding;
					MAX_REGION_COUNT = 48 + 16;
					break;
				case 3: // huge
					XMAX = YMAX = 30 + 2 * padding;
					MAX_REGION_COUNT = 64 + 20;
					break;
				case 4: // gigantic
					XMAX = YMAX = 40 + 2 * padding;
					MAX_REGION_COUNT = 160;
					break;
			}
			initTiles();*/
		}

		private void initTiles() {
			TILE_COUNT = XMAX * YMAX;

			tiles = new byte[TILE_COUNT];
			num = new int[TILE_COUNT];
			rcel = new int[TILE_COUNT];

			join = new JoinData[TILE_COUNT];
			regions = new Region[MAX_REGION_COUNT + 1];

			colors = new Color[MAX_REGION_COUNT + 2];

			for (int i = 0; i < MAX_REGION_COUNT; ++i) {
				colors[i] = Color.FromArgb(rand.Next(255), rand.Next(255), rand.Next(255));
			}
			colors[MAX_REGION_COUNT] = Color.FromArgb(255, 255, 255);
			colors[MAX_REGION_COUNT + 1] = Color.FromArgb(0, 0, 0);

			for (int i = 0; i < TILE_COUNT; ++i) {
				num[i] = i;
			}
			for (int i = 0; i < TILE_COUNT; ++i) {
				join[i] = new JoinData();
				for (int d = 0; d < 6; ++d) {
					join[i].dir[d] = NextCell(i, d);
				}
			}
		}

		public bool GenerateMap(List<Player> players) {
			
			playerCount = players.Count;
			// find out dimensions and region count based on player count
			if (sizeIndex == 0) {
				// 12 - 24
				if (playerCount >= 6)
					DESIRED_REGION_COUNT = playerCount * 3;
				else if (playerCount >= 4)
					DESIRED_REGION_COUNT = playerCount * 4;
				else if (playerCount == 3)
					DESIRED_REGION_COUNT = 15;
				else
					DESIRED_REGION_COUNT = 12;
			}
			if (sizeIndex == 1) {
				// 20 - 32
				if (playerCount >= 6)
					DESIRED_REGION_COUNT = playerCount * 4;
				else if (playerCount >= 4)
					DESIRED_REGION_COUNT = playerCount * 5;
				else if (playerCount == 3)
					DESIRED_REGION_COUNT = 24;
				else
					DESIRED_REGION_COUNT = 20;
			}
			if (sizeIndex == 2) {
				// 30 - 48
				if (playerCount >= 6)
					DESIRED_REGION_COUNT = playerCount * 6;
				else if (playerCount >= 4)
					DESIRED_REGION_COUNT = playerCount * 7;
				else if (playerCount == 3)
					DESIRED_REGION_COUNT = 39;
				else
					DESIRED_REGION_COUNT = 30;
			}
			if (sizeIndex == 3) {
				//48 - 64
				if (playerCount >= 6)
					DESIRED_REGION_COUNT = playerCount * 8;
				else if (playerCount >= 4)
					DESIRED_REGION_COUNT = playerCount * 9;
				else if (playerCount == 3)
					DESIRED_REGION_COUNT = 48;
				else
					DESIRED_REGION_COUNT = 42;
			}
			if (sizeIndex == 4) {
				// 60 - 96
				if (playerCount >= 6)
					DESIRED_REGION_COUNT = playerCount * 12;
				else if (playerCount >= 4)
					DESIRED_REGION_COUNT = playerCount * 14;
				else if (playerCount == 3)
					DESIRED_REGION_COUNT = 72;
				else
					DESIRED_REGION_COUNT = 60;
			}

			REGION_COUNT = (int)(DESIRED_REGION_COUNT * 1.3);
			XMAX = YMAX = DESIRED_REGION_COUNT / 2 + 8 + 2 * padding;
			MAX_REGION_COUNT = REGION_COUNT;
			initTiles();
			//REGION_COUNT = DESIRED_REGION_COUNT;

			for(int i = 0; i < TILE_COUNT; ++i)
			{
				int randCel = rand.Next(TILE_COUNT);
				int prevVal = num[i];
				num[i] = num[randCel];
				num[randCel] = prevVal;
			}
			for(int i = 0; i < TILE_COUNT; ++i)
			{
				tiles[i] = 0;
				rcel[i] = 0;
			}
			byte reg22_areaIdx = 1;
			//rcel[rand.Next(CEL_MAX)] = 1;
			int randX = rand.Next(XMAX - 2 * padding) + padding;
			int randY = rand.Next(YMAX - 2 * padding) + padding;
			rcel[randY * XMAX + randX] = 1;
			while(true) {
				int foundIndex = -1;
				int foundVal = 9999;
				for (int x = padding; x < XMAX - padding; x++)
				{
					for (int y = padding; y < YMAX - padding; ++y) {
						int i = y * XMAX + x;
						if (tiles[i] <= 0)
						{
							if (num[i] <= foundVal)
							{
								if (rcel[i] != 0)
								{
									foundVal = num[i];
									foundIndex = i;
								}
							}
						}
					}
				}
				if(foundVal == 9999) {
					break;
				}
				int growCell = Grow(foundIndex, 8, reg22_areaIdx);
				if (growCell == 0)
				{
					break;
				}
				reg22_areaIdx++;
				if(reg22_areaIdx >= REGION_COUNT) {
					break;
				}
			}
			for(int i = 0; i < TILE_COUNT; ++i) {
				if(tiles[i] <= 0) {
					bool reg10 = false;
					byte reg16_someVal = 0;
					for (int d = 0; d < 6; ++d)
					{
						int n = join[i].dir[d];
						if (n >= 0)
						{
							if (tiles[n] == 0)
							{
								reg10 = true;
							}
							else
							{
								reg16_someVal = tiles[n];
							}
						}
					}
					if(!reg10) {
						tiles[i] = reg16_someVal;
					}
				}
			}
			
			int regionCount = buildRegionsFromTiles(true);
			
			Console.WriteLine("Regions generated: " + regionCount + " / " + DESIRED_REGION_COUNT);
			if(regionCount < DESIRED_REGION_COUNT) {
				Console.WriteLine("WARNING: Less than desired regions generated!");
				return false;
			}

			for (int i = 0; i < TILE_COUNT; ++i) {
				int tmp = tiles[i];
				if (tmp > 0) {
					for (int d = 0; d < 6; ++d) {
						int n = join[i].dir[d];
						if (n > 0) {
							int val = tiles[n];
							if (val != tmp && val != 0) {
								regions[tmp].join[val] = true;
							}
						}
					}
				}
			}

			for (int i = 0; i < TILE_COUNT; ++i) {
				if (regions[tiles[i]].size == 0) {
					tiles[i] = 0;
				}
			}

			while (regionCount > DESIRED_REGION_COUNT) {
				// find least neighbor count for all regions and start removing from smallest
				int smallest = 999;
				for (int i = 1; i < REGION_COUNT; i++) {
					if (regions[i].size == 0)
						continue;

					if (regions[i].size < smallest) {
						smallest = regions[i].size;
					}
				}
				for (int i = 1; i < REGION_COUNT; i++) {
					if (regions[i].size == 0)
						continue;

					if (regions[i].size == smallest) {
						regions[i].size = 0;
						regionCount--;
					}
					if (regionCount == DESIRED_REGION_COUNT) {
						break;
					}
				}
			}

			for (int i = 0; i < TILE_COUNT; ++i) {
				if (regions[tiles[i]].size == 0 && tiles[i] != 0) {
					tiles[i] = 0;
				}
			}

			// move non-empty regions to the beginning of array
			for (byte i = 1; i <= REGION_COUNT; i++) {
				if (regions[i].size == 0) {
					for(byte j = (byte)(i + 1); j < REGION_COUNT; j++) {
						if(regions[j].size > 0) {
							// swap tile values
							for(int k = 0; k < TILE_COUNT; ++k) {
								if(tiles[k] == i) {
									tiles[k] = j;
								}
								else if(tiles[k] == j) {
									tiles[k] = i;
								}
							}
							// fix region neighborhood
							for(int k = 1; k <= DESIRED_REGION_COUNT; ++k) {
								bool tmp = regions[k].join[i];
								regions[k].join[i] = regions[k].join[j];
								regions[k].join[j] = tmp;
							}
							// swap regions
							Region tmpRegion = regions[i];
							regions[i] = regions[j];
							regions[j] = tmpRegion;
						}
					}
				}
			}

			generateNeighborRegions();

			if(!AreRegionsConnected())
				return false;
			
			for (int i = 1; i <= DESIRED_REGION_COUNT; i++) {
				regions[i].ID = i;
			}

			if (startType == 0) {
				SetupRegionsFullMap(players);
			}

			return true;
		}

		private int buildRegionsFromTiles(bool checkMinSize) {
			for (int i = 0; i <= REGION_COUNT; ++i) {
				regions[i] = new Region(MAX_REGION_COUNT + 1);
			}
			for (int i = 0; i < TILE_COUNT; ++i) {
				if (tiles[i] > REGION_COUNT) {
					return 0;
				}
				if (tiles[i] > 0) {
					regions[tiles[i]].size++;
				}
			}

			int regionCount = 0;
			for (int i = 1; i <= REGION_COUNT; ++i) {
				if (checkMinSize) {
					if (regions[i].size <= 5) {
						regions[i].size = 0;
					}
					else {
						regionCount++;
					}
				}
				else {
					if (regions[i].size > 0) {
						regionCount++;
					}
				}
				if (!checkMinSize) {
					// if there is empty region, remove it by moving following regions one back
					if (regions[i].size == 0) {
						bool shouldContinue = false;
						for (int n = 0; n < TILE_COUNT; ++n) {
							if (tiles[n] > i) {
								tiles[n]--;
							}
						}
						for (int j = i + 1; j <= REGION_COUNT; ++j) {
							regions[j - 1] = regions[j];
							if (regions[j - 1].size > 0) {
								shouldContinue = true;
							}
						}
						if (shouldContinue)
							i--;
					}
				}
			}

			return regionCount;
		}

		private void generateNeighborRegions() {
			// reset neighbors
			for (int i = 0; i <= DESIRED_REGION_COUNT; ++i) {
				for (int j = 0; j < MAX_REGION_COUNT; ++j) {
					regions[i].join[j] = false;
				}
			}

			for (int i = 0; i < TILE_COUNT; ++i) {
				int tmp = tiles[i];
				if (tmp > 0) {
					for (int d = 0; d < 6; ++d) {
						int n = join[i].dir[d];
						if (n > 0) {
							int val = tiles[n];
							if (val != tmp && val != 0) {
								regions[tmp].join[val] = true;
							}
						}
					}
				}
			}
		}

		private void SetupRegionsFullMap(List<Player> players) {
			int[] randAreas = new int[DESIRED_REGION_COUNT + 1];
			for (int i = 1; i <= DESIRED_REGION_COUNT; i++) {
				randAreas[i] = i;
			}
			for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				int rndIdx = rand.Next(DESIRED_REGION_COUNT) + 1;
				int a = randAreas[i];
				randAreas[i] = randAreas[rndIdx];
				randAreas[rndIdx] = a;
			}
			for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				regions[randAreas[i]].owner = players[i % players.Count];
			}
			// distribute dice
			foreach (Player p in players) {
				p.stackedDice = (int)(DESIRED_REGION_COUNT / players.Count * 2.5);
			}
			// first add one dice to each region
			for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				regions[i].dice++;
				regions[i].owner.stackedDice--;
			}
			foreach (Player p in players) {
				DistributeNewDice(p, true);
			}
		}

		private int Grow(int pt, int cmax, byte areaIdx) {
			if(cmax < 3) {
				cmax = 3;
			}
			int[] next_f = new int[TILE_COUNT];
			for(int i = 0; i < TILE_COUNT; ++i) {
				next_f[i] = 0;
			}
			int reg6_origin = pt;
			int reg7_counter = 0;
			while(true) {
				tiles[reg6_origin] = areaIdx;
				++reg7_counter;
				for(int i = 0; i < 6; ++i) {
					int n = join[reg6_origin].dir[i];
					if(n >= 0) {
						next_f[n] = 1;
					}
				}
				int minVal = 9999;
				for(int i = 0; i < TILE_COUNT; ++i) {
					if(next_f[i] != 0) {
						if(tiles[i] <= 0) {
							if(num[i] <= minVal) {
								minVal = num[i];
								reg6_origin = i;
							}
						}
					}
				}
				if(minVal == 9999) {
					break;
				}
				if (reg7_counter >= cmax) { 
					break; 
				}
			}
			for(int i = 0; i < TILE_COUNT; ++i) {
				if(next_f[i] != 0) {
					if(tiles[i] <= 0) {
						tiles[i] = areaIdx;
						++reg7_counter;
						for(int d = 0; d < 6; ++d) {
							int n = join[i].dir[d];
							if(n >= 0) {
								rcel[n] = 1;
							}
						}
					}
				}
			}
			return reg7_counter;
		}

		private int NextCell(int cell, int dir) {
			int cellX = cell % XMAX;
			int cellY = cell / XMAX;
			bool offsetX = cellY % 2 == 1;
			int dirX = 0;
			int dirY = 0;
			switch(dir) {
				case 0:
					dirX = offsetX ? 1 : 0;
					dirY = -1;
					break;
				case 1:
					dirX = 1;
					break;
				case 2:
					dirX = offsetX ? 1 : 0;
					dirY = 1;
					break;
				case 3:
					dirX = offsetX ? 0 : -1;
					dirY = 1;
					break;
				case 4:
					dirX = -1;
					break;
				case 5:
					dirX = offsetX ? 0 : -1;
					dirY = -1;
					break;
			}
			int newX = cellX + dirX;
			int newY = cellY + dirY;
			if (newX < 0 || newY < 0 || newX >= XMAX || newY >= YMAX) {
				return -1;
			}
			return newY * XMAX + newX;
		}

		public void DebugDraw(Graphics g) {
			//Color[] colors = { Color.Red, Color.LightBlue, Color.LightGreen, Color.DarkGreen, Color.DarkBlue, Color.Violet, Color.Yellow, Color.Cyan };
			int side = 8;
			int h = (int)(Math.Sin(Math.PI / 6) * side);
			int r = (int)(Math.Cos(Math.PI / 6) * side);
			int w = 2 * r;

				for (int i = 0; i < TILE_COUNT; i++)
				{
					int x = i % XMAX;
					int y = i / XMAX;

					int offsetX = 10 + w * x + ((y % 2 == 1) ? w / 2 : 0);
					int offsetY = 50 + y * (side + h);
					System.Drawing.PointF[] points = new System.Drawing.PointF[6];
					points[0] = new PointF(offsetX, offsetY);
					points[1] = new PointF(r + offsetX, h + offsetY);
					points[2] = new PointF(r + offsetX, side + h + offsetY);
					points[3] = new PointF(offsetX, side + h + h + offsetY);
					points[4] = new PointF(- r + offsetX, side + h + offsetY);
					points[5] = new PointF(- r + offsetX, h + offsetY);

					if(tiles[i] > 0) {
						SolidBrush brush = new SolidBrush(colors[tiles[i] - 1]);
						g.FillPolygon(brush, points);
					}

					if(tiles[i] != 0 || x == 0 || y == 0 || x == XMAX - 1 || y == YMAX - 1)
						g.DrawString("" + tiles[i], new Font("Verdana", 6F), Brushes.White, offsetX - 6, offsetY + 2);
				}
		}

		private void CheckRegionsConnectedNeighbors(Region r) {
			if(r.connectivityChecked) return;

			r.connectivityChecked = true;
			for(int i = 0; i < MAX_REGION_COUNT; ++i) {
				if(r.join[i]) {
					CheckRegionsConnectedNeighbors(regions[i]);
				}
			}
		}

		public bool AreRegionsConnected() {
			for (int i = 1; i <= DESIRED_REGION_COUNT; i++) {
				regions[i].connectivityChecked = false;
			}

			CheckRegionsConnectedNeighbors(regions[1]);

			bool connected = true;
			for (int i = 1; i <= DESIRED_REGION_COUNT; i++) {
				connected &= regions[i].connectivityChecked;
			}

			if(!connected) {
				Console.WriteLine("Regions are not connected!");
			}

			return connected;
		}

		public byte[] GetTiles() {
			return tiles;
		}

		public int getSize() {
			return sizeIndex;
		}

		public int GetWidth() {
			return XMAX;
		}

		public int GetHeight() {
			return YMAX;
		}

		public int GetTileCount() {
			return TILE_COUNT;
		}

		public int GetRegionCount() {
			return DESIRED_REGION_COUNT;
		}

		public Region GetRegion(int i) {
			return regions[i+1];
		}

		public Region GetRegionByID(int i) {
			return regions[i];
		}

		public int GetPlayerStrength(Player player) {
			// reset check for all regions
			for(int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				regions[i].connectivityChecked = false;
			}

			int maxConnected = 0;
			for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				if(regions[i].owner == player && regions[i].connectivityChecked == false) {
					int localConnected = FindConnectedPlayerRegionsCount(regions[i]);
					if(localConnected > maxConnected) {
						maxConnected = localConnected;
					}
				}
			}

			return maxConnected;
		}

		private void addRegionToAvailableList(Region r, List<Region> availableRegions) {
			// add it only if is not there already
			if (availableRegions.Contains(r)) return;

			availableRegions.Add(r);
		}

		public int DistributeNewDice(Player owner, bool random) {
			int distributedDice = 0;

			List<Region> availableRegions = new List<Region>();
			List<Region> availableRegions2 = new List<Region>();
			List<Region> availableRegions3 = new List<Region>();
			if (random) {
				for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
					if (regions[i].owner == owner && regions[i].dice < MAX_REGION_DICE) {
						availableRegions.Add(regions[i]);
					}
				}
			}
			else {
				for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
					if (regions[i].owner == owner && regions[i].dice < MAX_REGION_DICE) {
						for (int j = 1; j < MAX_REGION_COUNT; ++j) {
							if (regions[i].join[j] && regions[j].owner != owner) {
								if (regions[j].owner != null) {
									if (regions[j].owner.stillPlaying) {
										addRegionToAvailableList(regions[i], availableRegions);
									}
									else {
										addRegionToAvailableList(regions[i], availableRegions2);
									}
								}
								else {
									addRegionToAvailableList(regions[i], availableRegions3);
								}
								//break;
							}
						}
					}
				}
			}

			List<Region> currentRegions = availableRegions;

			while (owner.stackedDice > 0) {
				if (currentRegions.Count == 0) {
					currentRegions = availableRegions2;
					if (currentRegions.Count == 0) {
						currentRegions = availableRegions3;
					}
				}
				if (currentRegions.Count == 0) {
					break;
				}
				int idx = rand.Next(currentRegions.Count);
				if(currentRegions[idx].dice == 8) {
					currentRegions.Remove(currentRegions[idx]);
					continue;
				}
				owner.stackedDice--;
				currentRegions[idx].dice++;
				distributedDice++;
			}

			return distributedDice;
		}

		public List<Region> GetPlayersRegions(Player owner) {
			List<Region> playersRegions = new List<Region>();
			for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				if (regions[i].owner == owner) {
					playersRegions.Add(regions[i]);
				}
			}
			return playersRegions;
		}

		private int FindConnectedPlayerRegionsCount(Region r) {
			if (r.connectivityChecked) return 0;

			int size = 1;
			r.connectivityChecked = true;

			for(int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				if(r.join[i] && regions[i].owner == r.owner) {
					size += FindConnectedPlayerRegionsCount(regions[i]);
				}
			}
			return size;
		}

		public int GetEmptyRegionsCount() {
			int result = 0;
			for (int i = 1; i <= DESIRED_REGION_COUNT; ++i) {
				if (regions[i].dice == 0) {
					result++;
				}
			}
			return result;
		}

		public void loadPremadeMap(int width, int height, byte[] mapData, List<Player> players) {
			XMAX = width;
			YMAX = height;
			REGION_COUNT = MAX_REGION_COUNT = DESIRED_REGION_COUNT = 251;

			initTiles();

			tiles = mapData;

			//REGION_COUNT = MAX_REGION_COUNT;

			DESIRED_REGION_COUNT = buildRegionsFromTiles(false);
			generateNeighborRegions();

			for (int i = 1; i <= DESIRED_REGION_COUNT; i++) {
				regions[i].ID = i;
			}

			if (startType == 0) {
				SetupRegionsFullMap(players);
			}
		}

		public String dumpRegionsToString() {
			String result = "";
			for (int i = 1; i <= DESIRED_REGION_COUNT; i++) {
				result += i + ": ";
				if (regions[i].owner != null) {
					result += regions[i].owner.Id + ", ";
				}
				else {
					result += "-1, ";
				}
			}
			return result;
		}
	}
}
