using gameengine.Data;
using gameengine.Input;
using gameengine.Scenes.Shared.Grid;
using gameengine.Scenes.Shared.UI;
using gameengine.Scenes.Shared.UI.Buttons.Colors;
using gameengine.Scenes.Shared.UI.Buttons.Page;
using gameengine.Scenes.Shared.UI.Buttons.Paint;
using gameengine.Scenes.Tile;
using Microsoft.Xna.Framework;
using System;
using System.Linq;

namespace gameengine.Scenes;

internal class TileScene : Scene
{
    private PaintButton[] _paintButtons = new PaintButton[20];
    private ColorOption[] _colorButtons = new ColorOption[16];
    private PageButton[] _pageButtons = new PageButton[6];
    private SelectedColorOption _selectedColorOption;
    private PaintOptionEnum _paintTileOption;
    private SpriteGrid _spriteGrid = new SpriteGrid();
    private FullSpriteGrid _fullSpriteGrid = new FullSpriteGrid();

    public TileScene(SceneManager sceneManager) : base(sceneManager)
    {
        _spriteGrid.CreateChessGrid();
        CreatePaintButtons();
        CreateColorButtons();
        CreatePageButtons();

        void CreatePaintButtons()
        {
            // Changing the order of these components will affect the index selection in Button_Clicked
            var components = new[]
            {
                UIComponentEnum.PencilTileButton,
                UIComponentEnum.EraserTileButton,
                UIComponentEnum.LineTileButton,
                UIComponentEnum.BucketTileButton,
                UIComponentEnum.RectangleTileButton,
                UIComponentEnum.CircleTileButton,
                UIComponentEnum.SelectionRectangleTileButton,
                UIComponentEnum.DeleteTileButton,
                UIComponentEnum.PixelSize1TileButton,
                UIComponentEnum.PixelSize2TileButton,
                UIComponentEnum.PixelSize3TileButton,
                UIComponentEnum.PixelSize4TileButton,
                UIComponentEnum.CopyTileButton,
                UIComponentEnum.PasteTileButton,
                UIComponentEnum.UndoTileButton,
                UIComponentEnum.RedoTileButton,
                UIComponentEnum.FlipHTileButton,
                UIComponentEnum.FlipVTileButton,
                UIComponentEnum.RotateLeftTileButton,
                UIComponentEnum.RotateRightTileButton,
            };

            int index = 0;
            var buttonSize = 32;
            var offsetX = 10;
            var offsetY = 10;
            foreach (var component in components)
            {
                int column = index % 4;
                int row = index / 4;
                int posX = offsetX + column * (buttonSize + 6);
                int posY = offsetY + row * (buttonSize + 6);
                GameEngineData.UIComponentBounds[component] = new Rectangle(posX, posY, buttonSize, buttonSize);
                _paintButtons[index] = PaintButtonTileFactory.CreatePaintButton(component);
                _paintButtons[index].Clicked += Button_Clicked;
                index++;
            }

            // Select pencil button
            _paintButtons[0].Selected = true;
            _paintTileOption = PaintOptionEnum.Pencil;

            // Select penSize 1
            _paintButtons[8].Selected = true;
            _paintButtons[9].Selected = false;
            _paintButtons[10].Selected = false;
            _paintButtons[11].Selected = false;
            _spriteGrid.PenSize(1);

            void Button_Clicked(object sender, EventArgs e)
            {
                var buttonType = ((PaintButton)sender).Type;

                switch (buttonType)
                {
                    case PaintOptionEnum.Pencil:
                        UnselectButtons();
                        _paintButtons[0].Selected = true;
                        _paintTileOption = PaintOptionEnum.Pencil;
                        break;
                    case PaintOptionEnum.Eraser:
                        UnselectButtons();
                        _paintButtons[1].Selected = true;
                        _paintTileOption = PaintOptionEnum.Eraser;
                        break;
                    case PaintOptionEnum.Line:
                        UnselectButtons();
                        _paintButtons[2].Selected = true;
                        _paintTileOption = PaintOptionEnum.Line;
                        break;
                    case PaintOptionEnum.Bucket:
                        UnselectButtons();
                        _paintButtons[3].Selected = true;
                        _paintTileOption = PaintOptionEnum.Bucket;
                        break;
                    case PaintOptionEnum.Rectangle:
                        UnselectButtons();
                        _paintButtons[4].Selected = true;
                        _paintTileOption = PaintOptionEnum.Rectangle;
                        break;
                    case PaintOptionEnum.Circle:
                        UnselectButtons();
                        _paintButtons[5].Selected = true;
                        _paintTileOption = PaintOptionEnum.Circle;
                        break;
                    case PaintOptionEnum.SelectionRectangle:
                        UnselectButtons();
                        _paintButtons[6].Selected = true;
                        _paintTileOption = PaintOptionEnum.SelectionRectangle;
                        break;
                    case PaintOptionEnum.Copy:
                        break;
                    case PaintOptionEnum.Paste:
                        break;
                    case PaintOptionEnum.Undo:
                        break;
                    case PaintOptionEnum.Redo:
                        break;
                    case PaintOptionEnum.PixelSize1:
                        _paintButtons[8].Selected = true;
                        _paintButtons[9].Selected = false;
                        _paintButtons[10].Selected = false;
                        _paintButtons[11].Selected = false;
                        _spriteGrid.PenSize(1);
                        break;
                    case PaintOptionEnum.PixelSize2:
                        _paintButtons[8].Selected = false;
                        _paintButtons[9].Selected = true;
                        _paintButtons[10].Selected = false;
                        _paintButtons[11].Selected = false;
                        _spriteGrid.PenSize(2); 
                        break;
                    case PaintOptionEnum.PixelSize3:
                        _paintButtons[8].Selected = false;
                        _paintButtons[9].Selected = false;
                        _paintButtons[10].Selected = true;
                        _paintButtons[11].Selected = false;
                        _spriteGrid.PenSize(3);
                        break;
                    case PaintOptionEnum.PixelSize4:
                        _paintButtons[8].Selected = false;
                        _paintButtons[9].Selected = false;
                        _paintButtons[10].Selected = false;
                        _paintButtons[11].Selected = true;
                        _spriteGrid.PenSize(4);
                        break;
                    case PaintOptionEnum.FlipH:
                        break;
                    case PaintOptionEnum.FlipV:
                        break;
                    case PaintOptionEnum.RotateLeft:
                        break;
                    case PaintOptionEnum.RotateRight:
                        break;
                }

                void UnselectButtons()
                {
                    var buttonList = new PaintOptionEnum[] {
                        PaintOptionEnum.Pencil, PaintOptionEnum.Bucket, PaintOptionEnum.Eraser,
                        PaintOptionEnum.Line, PaintOptionEnum.Rectangle,PaintOptionEnum.Circle,
                        PaintOptionEnum.SelectionRectangle, PaintOptionEnum.Delete
                    };

                    foreach (var paintButton in _paintButtons.Where(b => buttonList.Contains(b.Type)).ToList())
                    {
                        paintButton.Selected = false;
                    }
                }
            }
        }

        void CreateColorButtons()
        {
            int index = 0; 
            var buttonSize = 32;
            var offsetX = 10;
            var offsetY = 210;
            foreach (var colorButton in _colorButtons)
            {
                int column = index % 4;
                int row = index / 4;
                int posX = offsetX + column * (buttonSize + 6);
                int posY = offsetY + row * (buttonSize + 6);
                var enumButton = (UIComponentEnum)((int)UIComponentEnum.ColorOption1 + index);
                GameEngineData.UIComponentBounds[enumButton] = new Rectangle(posX, posY, buttonSize, buttonSize);
                _colorButtons[index] = new ColorOption(index + 1, enumButton);
                _colorButtons[index].Clicked += ColorButton_Clicked;
                index++;
            }

            GameEngineData.UIComponentBounds[UIComponentEnum.SelectedColorOption] = new Rectangle(offsetX, 366, 146, 16);

            // Select first color
            _colorButtons[0].Selected = true;
            _selectedColorOption = new SelectedColorOption(_colorButtons[0].ColorIndex, UIComponentEnum.SelectedColorOption);

            void ColorButton_Clicked(object sender, EventArgs e)
            {
                var colorSelected = ((ColorOption)sender).ColorIndex;
                UpdateColorButtons(colorSelected);

                void UpdateColorButtons(int colorSelected)
                {
                    foreach (var paintButton in _colorButtons)
                    {
                        if (colorSelected == paintButton.ColorIndex)
                        {
                            _selectedColorOption.ColorIndex = colorSelected;
                            paintButton.Selected = true;
                            continue;
                        }

                        paintButton.Selected = false;
                    }
                }
            }
        }

        void CreatePageButtons()
        {
            int index = 0;
            var buttonSize = 32;
            var offsetX = 820;
            var offsetY = 8;
            foreach (var pageButton in _pageButtons)
            {
                int posX = offsetX + index * buttonSize;
                int posY = offsetY;
                var enumPageButton = (UIComponentEnum)((int)UIComponentEnum.Page0TileButton + index);
                GameEngineData.UIComponentBounds[enumPageButton] = new Rectangle(posX, posY, buttonSize, buttonSize);
                _pageButtons[index] = new PageButton(index, enumPageButton);
                _pageButtons[index].Clicked += PageButton_Clicked;
                index++;
            }

            // Select page 0
            UnSelectPages();
            _pageButtons[0].Selected = true;

            void PageButton_Clicked(object sender, EventArgs e)
            {
                var page = ((PageButton)sender).Page;
                UnSelectPages();
                _pageButtons[page].Selected = true;
                TileData.UpdatePage(page);
            }

            void UnSelectPages()
            {
                foreach (var pageButton in _pageButtons)
                {
                    pageButton.Selected = false;
                }
            }
        }
    }

    public override void Update()
    {
        foreach (var paintButton in _paintButtons)
        {
            paintButton.Update();
        }

        foreach (var colorButton in _colorButtons)
        {
            colorButton.Update();
        }

        foreach (var pageButton in _pageButtons)
        {
            pageButton.Update();
        }
        
        _selectedColorOption.Update();
        _fullSpriteGrid.Update();

        var isMouseLeftPressed = MouseInput.LeftButton_Pressed();
        var isMouseLeftJustPressed = MouseInput.LeftButton_JustPressed();
        var isMouseLeftReleased = MouseInput.LeftButton_Released();
        var isMouseRightPressed = MouseInput.RightButton_Pressed();
        var isMouseRightJustPressed = MouseInput.RightButton_JustPressed();
        var isMouseRightReleased = MouseInput.RightButton_Released();

        UpdateGrid();
        UpdateFullSpriteGrid();

        void UpdateGrid()
        {
            var (mousePosInGrid, isMouseInGrid) = _spriteGrid.ConvertMousePositionToGridCell();
            var isMouseLeftPressedOnGrid = isMouseLeftPressed && isMouseInGrid;
            var isMouseLeftJustPressedOnGrid = isMouseLeftJustPressed && isMouseInGrid;
            var isMouseLeftReleasedOnGrid = isMouseLeftReleased && isMouseInGrid;
            var x = mousePosInGrid.X;
            var y = mousePosInGrid.Y;

            if (isMouseInGrid)
            {
                if (MouseInput.ScrollUp())
                {
                    _spriteGrid.ZoomIn();
                }
                else if (MouseInput.ScrollDown())
                {
                    _spriteGrid.ZoomOut();
                }
            }

            switch (_paintTileOption)
            {
                case PaintOptionEnum.Pencil:
                    if (isMouseLeftPressedOnGrid)
                    {
                        _spriteGrid.UpdateGameDataTilesGridWithPen(x, y, _selectedColorOption.ColorIndex);
                    }
                    break;
                case PaintOptionEnum.Eraser:
                    if (isMouseLeftPressedOnGrid)
                    {
                        _spriteGrid.UpdateGameDataTilesGridWithPen(x, y, 0);
                    }
                    break;
                case PaintOptionEnum.Bucket:
                    if (isMouseLeftJustPressedOnGrid)
                    {
                        _spriteGrid.Fill(new Point(x,y), _selectedColorOption.ColorIndex);
                    }
                    break;
                case PaintOptionEnum.Line:
                    _spriteGrid.TemporaryGrid.ResetGridColors();
                    if (isMouseLeftJustPressedOnGrid)
                    {
                        // Start Line Drawing
                        _spriteGrid.LineStartPoint = new Point(x, y);
                    }
                    else if (isMouseLeftReleasedOnGrid)
                    {
                        // Paint Line
                        if (_spriteGrid.LineStartPoint.HasValue)
                        {
                            _spriteGrid.ProcessLine(x, y, _selectedColorOption.ColorIndex);
                            _spriteGrid.LineStartPoint = null;
                        }
                    }
                    else if (isMouseRightJustPressed)
                    {
                        // End Line Drawing
                        _spriteGrid.LineStartPoint = null;
                    }

                    if (_spriteGrid.LineStartPoint.HasValue)
                    {
                        _spriteGrid.ProcessLine(x, y, _selectedColorOption.ColorIndex, true);
                    }
                    break;
            }
        }

        void UpdateFullSpriteGrid()
        {
            
            if (!isMouseLeftJustPressed)
            {
                return;
            }
            
            var (mousePosInFullSpriteGrid, isMouseInFullSpriteGrid) = _fullSpriteGrid.ConvertMousePositionToGridCell();

            if (!isMouseInFullSpriteGrid)
            {
                return;
            }

            var isMouseLeftPressedOnFullSpriteGrid = isMouseLeftPressed && isMouseInFullSpriteGrid;
            var isMouseLeftJustPressedOnFullSpriteGrid = isMouseLeftJustPressed && isMouseInFullSpriteGrid;
            var isMouseLeftReleasedOnFullSpriteGrid = isMouseLeftReleased && isMouseInFullSpriteGrid;
            var x = mousePosInFullSpriteGrid.X;
            var y = mousePosInFullSpriteGrid.Y;

            if (isMouseLeftJustPressedOnFullSpriteGrid)
            {
                TileData.UpdateCurrentSpritePosition(x, y);
            }
        }
    }

    public override void Draw()
    {
        _spriteGrid.DrawChessGrid();
        foreach (var paintButton in _paintButtons)
        {
            paintButton.Draw();
        }

        foreach (var colorButton in _colorButtons)
        {
            colorButton.Draw();
        }

        foreach (var pageButton in _pageButtons)
        {
            pageButton.Draw();
        }

        _selectedColorOption.Draw();
        _fullSpriteGrid.Draw();
        _fullSpriteGrid.DrawSelector();
        _spriteGrid.DrawSpriteGrid();
    }

    public override void Exit()
    {
    }

    public override void Enter()
    {
    }
}