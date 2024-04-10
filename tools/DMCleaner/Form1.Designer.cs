namespace DMCleaner
{
	partial class Form1
	{
		/// <summary>
		///  Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		///  Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		///  Required method for Designer support - do not modify
		///  the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			btnAnalyse = new Button();
			btnClean = new Button();
			cbxCleanPaths = new CheckedListBox();
			SuspendLayout();
			// 
			// btnAnalyse
			// 
			btnAnalyse.Anchor = AnchorStyles.Top | AnchorStyles.Right;
			btnAnalyse.Location = new Point(611, 12);
			btnAnalyse.Name = "btnAnalyse";
			btnAnalyse.Size = new Size(177, 23);
			btnAnalyse.TabIndex = 0;
			btnAnalyse.Text = "Analyse Path";
			btnAnalyse.UseVisualStyleBackColor = true;
			btnAnalyse.Click += btnAnalyse_Click;
			// 
			// btnClean
			// 
			btnClean.Anchor = AnchorStyles.Top | AnchorStyles.Right;
			btnClean.Location = new Point(611, 41);
			btnClean.Name = "btnClean";
			btnClean.Size = new Size(177, 23);
			btnClean.TabIndex = 1;
			btnClean.Text = "Run Clean";
			btnClean.UseVisualStyleBackColor = true;
			btnClean.Click += btnClean_Click;
			// 
			// cbxCleanPaths
			// 
			cbxCleanPaths.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
			cbxCleanPaths.CheckOnClick = true;
			cbxCleanPaths.FormattingEnabled = true;
			cbxCleanPaths.Location = new Point(12, 12);
			cbxCleanPaths.Name = "cbxCleanPaths";
			cbxCleanPaths.Size = new Size(593, 418);
			cbxCleanPaths.TabIndex = 2;
			cbxCleanPaths.SelectedValueChanged += cbxCleanPaths_SelectedValueChanged;
			// 
			// Form1
			// 
			AutoScaleDimensions = new SizeF(7F, 15F);
			AutoScaleMode = AutoScaleMode.Font;
			ClientSize = new Size(800, 450);
			Controls.Add(cbxCleanPaths);
			Controls.Add(btnClean);
			Controls.Add(btnAnalyse);
			Name = "Form1";
			Text = "Form1";
			ResumeLayout(false);
		}

		#endregion

		private Button btnAnalyse;
		private Button btnClean;
		private CheckedListBox cbxCleanPaths;
	}
}
