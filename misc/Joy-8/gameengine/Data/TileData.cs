using Microsoft.Xna.Framework;

namespace gameengine.Data;

internal static class TileData
{
    #region Tile
    public static int GridSize;// Size in square
    public static int CellSize;// Size in pixels to draw
    public static Point PositionToDrawTile = new Point(166, 0); // Don't update this
    public static Point CurrentSpritePosition = new Point(0, 0); // In quadrants of 8x8 pixels. offsetPosition 1,2 -> position 8, 16.
    public static int MinGridSize = 8;
    public static int MaxGridSize = 64;
    #endregion 

    #region Map
    public static Point PositionToDrawMap { get; private set; } = new Point(750, 40);
    public static int MinTileSize { get; private set; } = 8;
    public static int Columns { get; private set; } = 8;
    public static int Rows { get; private set; } = 16;
    public static int Scale { get; private set; } = 4;
    public static int TotalPages { get; private set; } = 6;

    public static void UpdatePage(int page)
    {
        var newCurrentSpritePositionX = CurrentSpritePosition.X % Columns + page * Columns;
        CurrentSpritePosition = new Point(newCurrentSpritePositionX, CurrentSpritePosition.Y);
    }

    public static int GetPage()
    {
        return CurrentSpritePosition.X / Columns;
    }

    public static int GetTileNumber()
    {
        return CurrentSpritePosition.X % Columns + CurrentSpritePosition.Y * Columns + GetPage() * Rows * Columns;
    }

    public static void UpdateCurrentSpritePosition(int x, int y)
    {
        SetMaxZoom();
        CurrentSpritePosition = new Point(x, y);
    }

    public static Rectangle GetMapBounds()
    {
        return new Rectangle(
            PositionToDrawMap.X + 5,
            PositionToDrawMap.Y,
            Columns * MinTileSize,
            Rows * MinTileSize);
    }

    public static Rectangle GetSelectorBorder()
    {
        return new Rectangle(
            0,
            0,
            MinTileSize * Scale,
            MinTileSize * Scale);
    }
    #endregion

    #region Zoom
    public static int Zoom;

    public static void SetMaxZoom()
    {
        Zoom = 1;
        (GridSize, CellSize) = GetSizes(Zoom);
    }

    public static void SetSizes()
    {
        (GridSize, CellSize) = GetSizes(Zoom);
    }

    public static (int gridSize, int cellSize) GetSizes(int zoom)
    {
        switch (zoom)
        {
            case 1:
                return (8, 72);
            case 2:
                return (16, 36);
            case 3:
                return (32, 18);
            case 4:
                return (64, 9);
        }

        return (8, 72); // Default value. But it shouldn't happen since we will always have a integer zoom between 1 and 4.
    }

    public static bool IsValidZoomOut(int zoom)
    {
        switch (zoom)
        {
            case 1:
                return true; // this case will never happen. 1 is the minimum Zoom
            case 2:
                return CurrentSpritePosition.X % Columns <= 6 &&
                    CurrentSpritePosition.Y % Rows <= 14;
            case 3:
                return CurrentSpritePosition.X % Columns <= 4 &&
                    CurrentSpritePosition.Y % Rows <= 12;
            case 4:
                return CurrentSpritePosition.X % Columns == 0 &&
                    CurrentSpritePosition.Y % Rows <= 8;
        }

        return false;
    }
    #endregion
}