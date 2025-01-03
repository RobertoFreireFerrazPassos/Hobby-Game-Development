using gameengine.Data;
using gameengine.Input;
using gameengine.Utils;
using Microsoft.Xna.Framework;

namespace gameengine.Scenes.Shared.Grid;

internal class FullSpriteGrid
{
    private Rectangle _bounds;

    public FullSpriteGrid()
    {
        _bounds = TileData.GetMapBounds();
        GameEngineData.Images.Add(
                "fullspriteselectorborder",
                TextureUtils.CreateRectangleTexture(TileData.GetSelectorBorder(), 2));
    }

    public void Update()
    {
    }

    public void Draw()
    {
        var spriteBatch = FrameworkData.SpriteBatch;
        spriteBatch.DrawText_MediumFont(TileData.GetTileNumber().ToString("000"), new Vector2(_bounds.X + 5, _bounds.Y - 18), 2, 1f, 4f, -1);
        spriteBatch.DrawRectangle(new Rectangle(
                _bounds.X,
                _bounds.Y,
                _bounds.Width * TileData.Scale,
                _bounds.Height * TileData.Scale
            ), 1, 0.2f);
        for (int x = 0; x < _bounds.Width; x++)
        {
            for (int y = 0; y < _bounds.Height; y++)
            {
                spriteBatch.DrawRectangle(
                    new Rectangle(
                        _bounds.X + x * TileData.Scale,
                        _bounds.Y + y * TileData.Scale,
                        TileData.Scale,
                        TileData.Scale),
                    GameData.TilesGrid[TileData.GetPage() * _bounds.Width + x, y]);
            }
        }
    }

    public void DrawSelector()
    {
        var currentSpritePosition = TileData.CurrentSpritePosition;
        var spriteBatch = FrameworkData.SpriteBatch;
        var tileSquare = TileData.MinTileSize * TileData.Scale;
        var ofx = _bounds.X + (currentSpritePosition.X % TileData.Columns) * tileSquare;
        var ofy = _bounds.Y + currentSpritePosition.Y * tileSquare;
        spriteBatch.DrawImage(
            "fullspriteselectorborder",
            new Rectangle(ofx,ofy, tileSquare * TileData.GridSize / TileData.MinGridSize, tileSquare * TileData.GridSize / TileData.MinGridSize), 
            2, 0.5f);
    }

    public (Point, bool) ConvertMousePositionToGridCell()
    {
        var mousePosition = MouseInput.MousePosition();

        if (mousePosition.X - _bounds.X < 0 || mousePosition.Y - _bounds.Y < 0)
        {
            return (new Point(0, 0), false);
        }
        var tileSquare = TileData.MinTileSize * TileData.Scale;
        int x = (mousePosition.X - _bounds.X) / tileSquare;
        int y = (mousePosition.Y - _bounds.Y) / tileSquare;
        return (new Point(TileData.GetPage() * TileData.Columns + x, y), IsMouseInGrid(x, y));

        bool IsMouseInGrid(int x, int y)
        {
            return x >= 0 && x < TileData.Columns && y >= 0 && y < TileData.Rows;
        }
    }
}
