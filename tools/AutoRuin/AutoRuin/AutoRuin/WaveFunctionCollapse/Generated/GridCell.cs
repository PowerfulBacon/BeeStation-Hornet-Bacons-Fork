using AutoRuin.WaveFunctionCollapse.States;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AutoRuin.WaveFunctionCollapse.Generated
{
	internal class GridCell
	{

		private static Random Random = new Random();

		/// <summary>
		/// Has this grid cell been observed?
		/// </summary>
		public bool Observed { get; private set; }

		/// <summary>
		/// The entropy value of this cell
		/// </summary>
		public int Entropy => Observed ? 0 : potentialCellStates.Count;

		/// <summary>
		/// The state of the cell, if unobserved.
		/// </summary>
		private ICellState cellState;

		/// <summary>
		/// The potential cell states we are in
		/// </summary>
		private List<ICellState> potentialCellStates;

		/// <summary>
		/// Observe the grid cell. Immediately removes all entropy.
		/// </summary>
		public ICellState Observe()
		{
			//If we have already been observed, return the cell state
			if (Observed)
				return cellState;
			//If we haven't been observed, observe the value
			cellState = potentialCellStates[Random.Next(potentialCellStates.Count)];
			Observed = true;
			potentialCellStates = null;
			return cellState;
		}

	}
}
