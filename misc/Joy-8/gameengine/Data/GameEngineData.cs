using gameengine.Scenes.Shared.UI;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using System.Collections.Generic;

namespace gameengine.Data;

internal static class GameEngineData
{
    public static Rectangle BaseBox { get; private set; } = new Rectangle(0, 0, 1024, 576);// Use this in UI Components or Scenes.
    public static (int X, int Y) BaseBoxCenter { get; private set; } = ((int)(BaseBox.Width / 2f), (int)(BaseBox.Height / 2f));// Use this in UI Components or Scenes.
    public static Rectangle BoxToDraw { get; private set; } // Don't use this in UI Components or Scenes.
    public static float ScaleX { get; private set; } // Don't use this in UI Components or Scenes.
    public static float ScaleY { get; private set; } // Don't use this in UI Components or Scenes.
    public static bool IsFocused { get; private set; }
    public static Dictionary<string, Texture2D> Images = new Dictionary<string, Texture2D>();
    public static Dictionary<char, Texture2D> MediumKeyBoardKeys = new Dictionary<char, Texture2D>();
    public static Dictionary<char, Texture2D> LargeKeyBoardKeys = new Dictionary<char, Texture2D>();
    public static Texture2D PixelTexture;
    public static Dictionary<UIComponentEnum, Rectangle> UIComponentBounds = new Dictionary<UIComponentEnum, Rectangle>();

    public static void UpdateIsFocused(bool isActive, bool isFullScreen)
    {
        IsFocused = isFullScreen || isActive;
    }

    public static void SetBoxToDraw()
    {
        var viewPort = FrameworkData.GraphicsDevice.Viewport;
        float screenAspectRatio = (float) viewPort.Width / viewPort.Height;
        float targetAspectRatio = (float) BaseBox.Width / BaseBox.Height;

        if (screenAspectRatio == targetAspectRatio)
        {
            BoxToDraw = new Rectangle(0, 0, BaseBox.Width, BaseBox.Height);
        } 
        else if (screenAspectRatio > targetAspectRatio)
        {
            float scaleWidth = viewPort.Height * targetAspectRatio;
            int offsetX = (viewPort.Width - (int)scaleWidth) / 2;
            BoxToDraw = new Rectangle(offsetX, 0, (int)scaleWidth, viewPort.Height);
        }
        else 
        {
            float scaleHeight = viewPort.Width / targetAspectRatio;
            int offsetY = (viewPort.Height - (int)scaleHeight) / 2;
            BoxToDraw = new Rectangle(0, offsetY, viewPort.Width, (int)scaleHeight);
        }

        ScaleX = (float) BoxToDraw.Width / BaseBox.Width;
        ScaleY = (float) BoxToDraw.Height / BaseBox.Height;
    }
}