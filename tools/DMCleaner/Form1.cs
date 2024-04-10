using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace DMCleaner
{
	public partial class Form1 : Form
	{
		// Dictionary to store typepaths and their counts
		private Dictionary<string, int> typepathCounts = new Dictionary<string, int>();

		private HashSet<string> bannedSubtypes = new HashSet<string>()
		{
			"/atom",
			"/atom/movable",
			"/obj",
			"/obj/item",
			"/obj/structure",
			"/datum",
			"/obj/machinery"
		};

		public Form1()
		{
			InitializeComponent();
		}

		private void btnAnalyse_Click(object sender, EventArgs e)
		{
			typepathCounts.Clear();
			// Ask for the folder that we want to search
			string selectedFolder = GetSelectedFolder();

			if (selectedFolder != null)
			{
				// Search all files and count typepath references
				SearchTypepaths(selectedFolder);
				_ = CountTypepathReferences(selectedFolder)
					.ContinueWith(task =>
					{
						cbxCleanPaths.Items.Clear();
						foreach (var kvp in typepathCounts.OrderByDescending(x => x.Key))
						{
							if (kvp.Value > 0)
								continue;
							cbxCleanPaths.Items.Add($"{kvp.Key} ({kvp.Value})");
						}
					}, TaskContinuationOptions.ExecuteSynchronously);

				// DONT IMPLEMENT THIS SECTION
				// Find all unreferenced typepaths
				// Find all unreferenced procs
			}


		}

		private string GetSelectedFolder()
		{
			using (FolderBrowserDialog dialog = new FolderBrowserDialog())
			{
				DialogResult result = dialog.ShowDialog();
				if (result == DialogResult.OK && !string.IsNullOrWhiteSpace(dialog.SelectedPath))
				{
					return dialog.SelectedPath;
				}
			}
			return null;
		}

		private void SearchTypepaths(string folderPath)
		{
			try
			{
				// Search all files recursively
				string[] files = Directory.GetFiles(folderPath, "*.dm", SearchOption.AllDirectories);

				foreach (string file in files)
				{
					// Read the contents of the file
					string content = File.ReadAllText(file);

					// Find all typepath definitions and initialize their counts
					MatchCollection typepathMatches = Regex.Matches(content, @"^((\/\w+)+)\s*(?:\/\/.*)?(?:\/\*.*\*\/)?\s*$", RegexOptions.Multiline);
					foreach (Match match in typepathMatches)
					{
						string typepath = match.Groups[1].Value.Trim();
						// weird
						if (typepath.Contains("/var/"))
							continue;
						if (!typepathCounts.ContainsKey(typepath))
						{
							typepathCounts.Add(typepath, 0); // Initialize count to 0 if typepath is new
						}
					}
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show($"Error occurred while searching files: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private async Task CountTypepathReferences(string folderPath)
		{
			try
			{
				// Search all files recursively
				string[] codeFiles = Directory.GetFiles(folderPath, "*.dm", SearchOption.AllDirectories);
				string[] mapFiles = Directory.GetFiles(folderPath, "*.dmm", SearchOption.AllDirectories);

				// Find references to the typepath with a simple search
				string superRegex = $"(?!^)({string.Join("|", typepathCounts.Keys.OrderByDescending(x => x.Where(y => y == '/').Count()).Select(x => @$"{Regex.Escape(x)}\b"))})";
				Regex regex = new Regex(superRegex, RegexOptions.Compiled | RegexOptions.Multiline);

				// Find references to the typepath through typesof()
				string typesofText = $"typesof\\(([/\\w]+)\\)";
				Regex typesofRegex = new Regex(typesofText, RegexOptions.Compiled | RegexOptions.Multiline);

				// Find references to the typepath with a simple search
				string mapSeach = $"({string.Join("|", typepathCounts.Keys.OrderByDescending(x => x.Where(y => y == '/').Count()).Select(x => @$"{Regex.Escape(x)}\b"))})";
				Regex mapSearchRegex = new Regex(mapSeach, RegexOptions.Compiled | RegexOptions.Multiline);

				// Initialize progress bar
				using (var progressForm = new Form())
				{
					var progressBar = new ProgressBar { Dock = DockStyle.Fill };
					progressForm.Controls.Add(progressBar);
					progressForm.Size = new System.Drawing.Size(300, 50);
					progressForm.StartPosition = FormStartPosition.CenterParent;

					// Show the progress form
					progressForm.Show(this);

					// Counter for files processed
					int filesProcessed = 0;

					await Parallel.ForEachAsync(codeFiles, (file, cancelToken) =>
					{
						// Read the contents of the file
						string content = File.ReadAllText(file);

						foreach (Match match in regex.Matches(content))
						{
							var parts = match.Groups[1].Value.Substring(1).Split('/');
							var result = parts.Select((p, i) => "/" + string.Join("/", parts.Take(i + 1)));
							foreach (var subtype in result)
							{
								if (typepathCounts.ContainsKey(subtype))
									typepathCounts[subtype] += 1;
							}
						}

						foreach (Match subtypesMatch in typesofRegex.Matches(content))
						{
							if (bannedSubtypes.Contains(subtypesMatch.Groups[1].Value))
								continue;
							var parts = subtypesMatch.Groups[1].Value.Substring(1).Split('/');
							var result = parts.Select((p, i) => "/" + string.Join("/", parts.Take(i + 1)));
							foreach (var subtype in result)
							{
								if (typepathCounts.ContainsKey(subtype))
									typepathCounts[subtype] += 1;
							}
							// Heres the kicker, we need to add references to all our subtypes too!
							foreach (var something in typepathCounts)
							{
								if (!something.Key.StartsWith(subtypesMatch.Groups[1].Value))
									continue;
								typepathCounts[something.Key] += 1;
							}
						}

						Invoke(() =>
						{
							// Increment files processed counter
							filesProcessed++;
							// Update progress bar
							double progress = (double)filesProcessed / (codeFiles.Length + mapFiles.Length);
							progressBar.Value = (int)(progress * 100);
							progressBar.Refresh();
						});
						return ValueTask.CompletedTask;
					});
					await Parallel.ForEachAsync(mapFiles, (file, cancelToken) =>
					{
						// Read the contents of the file
						string content = File.ReadAllText(file);

						foreach (Match match in mapSearchRegex.Matches(content))
						{
							var parts = match.Groups[1].Value.Substring(1).Split('/');
							var result = parts.Select((p, i) => "/" + string.Join("/", parts.Take(i + 1)));
							foreach (var subtype in result)
							{
								if (typepathCounts.ContainsKey(subtype))
									typepathCounts[subtype] += 1;
							}
						}

						Invoke(() =>
						{
							// Increment files processed counter
							filesProcessed++;
							// Update progress bar
							double progress = (double)filesProcessed / (codeFiles.Length + mapFiles.Length);
							progressBar.Value = (int)(progress * 100);
							progressBar.Refresh();
						});
						return ValueTask.CompletedTask;
					});
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show($"Error occurred while counting typepath references: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void cbxCleanPaths_SelectedValueChanged(object sender, EventArgs e)
		{
			var text = cbxCleanPaths.SelectedItem?.ToString() ?? "/";
			text = text.Substring(0, text.IndexOf(' '));
			Clipboard.SetText(text);
		}

		private void btnClean_Click(object sender, EventArgs e)
		{
			// For each selected typepath, find all instances of it and start deleting until we reach the next typepath
			// Make sure to clean comments before, but not after we finish eating
		}
	}
}
