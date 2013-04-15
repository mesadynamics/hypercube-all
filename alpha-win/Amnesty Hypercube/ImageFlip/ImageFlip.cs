using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;

namespace ACControls
{
	/// <summary>
	/// Descrizione di riepilogo per ImageFlip.
	/// </summary>
	public class ImageFlip : System.Windows.Forms.UserControl
	{
		/// <summary> 
		/// Variabile di progettazione necessaria.
		/// </summary>
		private System.ComponentModel.Container components = null;
		private Image m_image = null;
		private Image m_store = null;
		private int m_height = 0;
		private int m_heightflip = 0;
		private int m_divider = 1;

		public ImageFlip()
		{
			// Chiamata richiesta da Progettazione form Windows.Forms.
			InitializeComponent();
			m_height = base.Height;
			m_heightflip = (m_height / 2);
		}

		/// <summary> 
		/// Pulire le risorse in uso.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if(components != null)
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Codice generato da Progettazione componenti
		/// <summary> 
		/// Metodo necessario per il supporto della finestra di progettazione. Non modificare 
		/// il contenuto del metodo con l'editor di codice.
		/// </summary>
		private void InitializeComponent()
		{
			components = new System.ComponentModel.Container();
		}
		#endregion




        [Category("Appearance"), Browsable(true), EditorBrowsable,
        Description("Set the control image")]
        public Image Image
        {
            get { return m_store; }
            set
            {
                m_store = value;
                this.InitControlImage();
            }
        }

        public Image FlippedImage
        {
            get { return m_image; }
        }

        [Category("Appearance"), Browsable(true), EditorBrowsable,
		Description("Set the height of flipped image, in fraction of original image") ]
		public int Divider
		{
			get { return m_divider; }
			set
			{
				if (value != 0)
				{
					m_divider = value;
					this.InitControlImage();
				}
			}
		}

		[Browsable(false)]
		public override Image BackgroundImage
		{
			get { return null; }
		}
		[Browsable(false)]
		public override string Text
		{
			get { return string.Empty; }
		}
		[Browsable(false)]
		public override Color BackColor
		{
			get { return Color.Transparent; }
		}

		/// <summary>
		/// Flip the image and set control bounds
		/// </summary>
		private void InitControlImage()
		{
			if (m_store != null)
			{
				FlipImage();
				base.SetBounds(base.Left, base.Top, m_image.Width, m_image.Height);
				base.Invalidate();
			}
		}

		/// <summary>
		/// Create a gradient image and return a buffer of bytes
		/// </summary>
		/// <param name="FlipHeight">Rectangle height</param>
		/// <returns>Buffer of bytes</returns>
		private byte[] GradientRectangle(int FlipHeight)
		{
			int bytes = m_store.Width * FlipHeight * 4;
			byte[] m_argbsource = new byte[bytes];
			Rectangle m_rectgradient = new Rectangle(0, 0, m_store.Width, FlipHeight);
			System.Drawing.Drawing2D.LinearGradientBrush m_brushgradient;
            m_brushgradient = new System.Drawing.Drawing2D.LinearGradientBrush(m_rectgradient, Color.FromArgb(120, Color.White), Color.FromArgb(0, Color.White), 90F);
			Bitmap m_bmpgradient = new Bitmap(m_store.Width, FlipHeight);
 			using(Graphics g = Graphics.FromImage(m_bmpgradient))
			{
                g.FillRectangle(m_brushgradient, 0, 0, m_store.Width, FlipHeight);
 			}
			BitmapData m_datasource = m_bmpgradient.LockBits(m_rectgradient, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
			IntPtr m_ptrsource = m_datasource.Scan0;
			System.Runtime.InteropServices.Marshal.Copy(m_ptrsource, m_argbsource, 0, bytes);

			return m_argbsource;
		}

		/// <summary>
		/// Flip the image and compose to original
		/// </summary>
		private void FlipImage()
		{
			//	Calculate new height
			m_heightflip = (m_store.Height / m_divider);
			m_height = (m_store.Height + m_heightflip);

			//	New image is self height plus a piece
			Bitmap m_double = new Bitmap(m_store.Width, m_height);

			Rectangle m_rectflip = new Rectangle(0, m_store.Height, m_store.Width, m_heightflip);

			using(Graphics g = Graphics.FromImage(m_double))
			{
				Image m_img = (Image)m_store.Clone();
				//	Draw normal image
				g.DrawImage(m_store, 0, 0, m_store.Width, m_store.Height);
				//	Flip the clone
				m_img.RotateFlip(RotateFlipType.Rotate180FlipX);
				//	Draw the flipped clone, cropping at flip height
				g.DrawImage(m_img, 0, m_store.Height, new Rectangle(0, 0, m_store.Width, m_heightflip), GraphicsUnit.Pixel);
				//	Remove this
				m_img.Dispose();
				
				//////////////////////////////////////////////////////////////////////////
				//	Apply transparent mask
				BitmapData m_datadestin = m_double.LockBits(m_rectflip, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

				//	Init the source and destination buffers
				int bytes = (m_store.Width * m_heightflip * 4);
				byte[] m_argbdestin = new byte[bytes];
				byte[] m_argbsource = GradientRectangle(m_heightflip);

				//	Point at destination, instead UNSAFE block
				IntPtr m_ptrdestin = m_datadestin.Scan0;
				System.Runtime.InteropServices.Marshal.Copy(m_ptrdestin, m_argbdestin, 0, bytes);

				// Set every transparency value to mask.  
                for (int counter = 3; counter < m_argbsource.Length; counter += 4)
                {
                    if (m_argbdestin[counter] > 0)
                        m_argbdestin[counter] = m_argbsource[counter];

                    /*
                    //if (m_argbdestin[counter] > 0)
                    {
                        float d = (float)m_argbsource[counter] / (float)255.0;
                        float bb = (float)m_argbdestin[counter - 3] * d;
                        float gb = (float)m_argbdestin[counter - 2] * d;
                        float rb = (float)m_argbdestin[counter - 1] * d;
                        m_argbdestin[counter - 3] = (byte)bb;
                        m_argbdestin[counter - 2] = (byte)gb;
                        m_argbdestin[counter - 1] = (byte)rb;
                        m_argbdestin[counter] = 255;
                    }*/
                  }

				// Copy the ARGB values back to the bitmap
				System.Runtime.InteropServices.Marshal.Copy(m_argbdestin, 0, m_ptrdestin, bytes);

				// Unlock the bits.
				m_double.UnlockBits(m_datadestin);
				//////////////////////////////////////////////////////////////////////////
			
			}
			//	Reassign modified image to paintable one.
			m_image = m_double;
		}

		//	Draw the modified image
		protected override void OnPaint(PaintEventArgs pevent)
		{
			if ( m_image != null ) 
			{
				pevent.Graphics.DrawImage ( m_image, 0, 0 );
			}
			base.OnPaint(pevent);
		}

		//	Set background trasparent for control
		protected override CreateParams CreateParams
		{
			get
			{
				CreateParams cp = base.CreateParams;
				cp.ExStyle |= 0x20;
				return cp;
			}
		}

		//	Avoid drawing back image or color
		protected override void OnPaintBackground(PaintEventArgs pevent)
		{
			//	Do nothing, it's trasparent
			//base.OnPaintBackground (pevent);
		}


	}
}
