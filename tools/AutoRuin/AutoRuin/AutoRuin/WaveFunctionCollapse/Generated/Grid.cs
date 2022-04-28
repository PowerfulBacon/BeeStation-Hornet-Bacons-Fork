using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AutoRuin.WaveFunctionCollapse.Generated
{
	internal class Grid
	{

		/// <summary>
		/// The height of this grid
		/// </summary>
		public int Height { get; }

		/// <summary>
		/// The width of the grid
		/// </summary>
		public int Width { get; }

		/// <summary>
		/// The grid cells contained within this grid.
		/// </summary>
		public GridCell[,] GridCells { get; }

	}
}
