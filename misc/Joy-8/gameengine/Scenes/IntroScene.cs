using gameengine.Data;
using Microsoft.Xna.Framework.Graphics;
using System.Collections.Generic;
using System;
using Microsoft.Xna.Framework;
using System.Linq;
using gameengine.Utils;
using gameengine.Utils.Objects;

namespace gameengine.Scenes;

internal class IntroScene : Scene
{
    private Timer _endTimer = new Timer(3f);
    private Blinking _blinking;
    private List<(Rectangle, Texture2D, float, int, bool, bool)> _drawnPositions;
    private const string _title = "Joy-8";
    private int randomXMov = 0;
    private int randomYMov = 0;

    public IntroScene(SceneManager sceneManager) : base(sceneManager)
    {
        var random = new Random();
        randomXMov = random.Next(0, 2) == 0 ? -1 : 1;
        randomYMov = random.Next(0, 2) == 0 ? -1 : 1;

        var allowedImages = new List<string>()
        {
            "add_button","bucket_button","circle_button","config_button","eraser_button",
            "copy_button","delete_button","double_left_arrow_button","double_right_arrow_button",
            "left_arrow_button","line_button","load_file_button","map_button","new_file_button",
            "paste_button","pencil_button","play_button","selected_button","color_palette_button",
            "rectangle_button","right_arrow_button","save_button","see_button","rename_button",
            "selection_rectangle_button","sfx_button","song_button","sprite_button",
            "flip_h_button","flip_v_button","rotate_left_button","rotate_right_button"
            ,"remove_button","undo_button","redo_button","pixel_dec_button","pixel_inc_button"
        };
        _drawnPositions = new List<(Rectangle, Texture2D, float, int, bool, bool)>();

        for (int i = 0; i < 2; i++)
        {
            foreach (var image in GameEngineData.Images.Where(i => allowedImages.Contains(i.Key)).Select(i => i.Value).ToList())
            {
                float randomScale = (float)(random.NextDouble() * 2 + 1);

                int newWidth = (int)(image.Width * randomScale);
                int newHeight = (int)(image.Height * randomScale);

                Rectangle? position = null;
                int margin = (int)(-100 * randomScale);

                for (int attempt = 0; attempt < 200; attempt++)
                {
                    int x = random.Next(GameEngineData.BaseBox.X + margin, GameEngineData.BaseBox.X + GameEngineData.BaseBox.Width - newWidth - margin);
                    int y = random.Next(GameEngineData.BaseBox.Y + margin, GameEngineData.BaseBox.Y + GameEngineData.BaseBox.Height - newHeight - margin);
                    Rectangle proposedRect = new Rectangle(x, y, newWidth, newHeight);

                    bool overlap = false;
                    foreach (var rect in _drawnPositions)
                    {
                        if (proposedRect.Intersects(rect.Item1))
                        {
                            overlap = true;
                            break;
                        }
                    }

                    if (!overlap)
                    {
                        position = proposedRect;
                        _drawnPositions.Add((proposedRect, image, randomScale, random.Next(0, 359), random.Next(0, 2) == 0, random.Next(0, 2) == 0));
                        break;
                    }
                }
            }
        }
    }

    public override void Update()
    {
        _endTimer.Update();
        _blinking.Update();

        if (!_endTimer.IsActive())
        {
            _sceneManager.ChangeScene(_sceneManager.MenuScene);
        }

        if (_blinking.IsBlinking())
        {
            for (int i = 0; i < _drawnPositions.Count; i++)
            {
                var tuple = _drawnPositions[i];
                var modifiedTuple = (
                    new Rectangle(
                        tuple.Item1.X + randomXMov,
                        tuple.Item1.Y + randomYMov,
                        tuple.Item1.Width,
                        tuple.Item1.Height
                    ),
                    tuple.Item2,
                    tuple.Item3,
                    tuple.Item4,
                    tuple.Item5,
                    tuple.Item6);
                _drawnPositions[i] = modifiedTuple;
            }
        }
    }

    public override void Draw()
    {
        var spriteBatch = FrameworkData.SpriteBatch;       

        foreach (var image in _drawnPositions)
        {
            spriteBatch.CustomDraw(image.Item2, image.Item1, 1, 0.3f, image.Item3, image.Item4, image.Item5, image.Item6);
        }

        spriteBatch.BoxToDrawBlackBorders(300);        
        DrawTitleInCenter(_title, 15f, -1);

        void DrawTitleInCenter(string text, float charSize, int offSetX)
        {
            var center = GameEngineData.BaseBoxCenter;
            var charTextureSize = FontAtlasUtils.LargeFont.CharWidth + offSetX;
            var charTextureHeight = FontAtlasUtils.LargeFont.CharHeight;

            float startX = center.X - ((text.Length - 1) * charTextureSize * charSize / 2f);
            float startY = center.Y - charTextureHeight * charSize / 2f;
            spriteBatch.DrawText_LargeFont(text, new Vector2(startX, startY), 3, 1f, charSize, offSetX);
            spriteBatch.DrawText_LargeFont(text, new Vector2(startX, startY + charTextureSize), 2, 1f, charSize, offSetX);
            spriteBatch.DrawText_LargeFont("Asset Management", new Vector2(startX + 40, startY + 84), 2, 1f, 4f, offSetX);
        }
    }

    public override void Exit()
    {
    }

    public override void Enter()
    {
        _endTimer.Enable();
        _blinking = new Blinking(0.03f);
    }
}