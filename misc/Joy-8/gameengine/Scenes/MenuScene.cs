﻿using gameengine.Data;
using gameengine.Scenes.Menu;
using gameengine.Scenes.Shared.UI;
using gameengine.Utils;
using Microsoft.Xna.Framework;
using System;

namespace gameengine.Scenes;

internal class MenuScene : Scene
{
    public MenuIcon[] MenuIcons { get; set; }
    private Rectangle _line;

    public MenuScene(SceneManager sceneManager) : base(sceneManager)
    {
        MenuIcons = new MenuIcon[]
        {
            new NewMenuIcon(),
            new RenameMenuIcon(),
            new SaveMenuIcon(),
            new LoadMenuIcon(),
            new SpriteMenuIcon(),
            new TileMenuIcon(),
            new AnimationMenuIcon(),
            new MapMenuIcon(),
            new SfxMenuIcon(),
            new SongMenuIcon(),
            new ConfigMenuIcon(),
            new ColorPaletteMenuIcon(),
            new PlayGameMenuIcon()
        };

        var menuIconSize = 64;
        var numColumns = 4;
        var numRows = 4;

        var marginX = (GameEngineData.BaseBox.Width - menuIconSize * numColumns) / (numColumns + 1);
        var marginY = (GameEngineData.BaseBox.Height - menuIconSize * numRows) / (numRows + 1);

        var components = new[]
        {
            UIComponentEnum.NewMenu,
            UIComponentEnum.RenameMenu,
            UIComponentEnum.SaveMenu,
            UIComponentEnum.LoadMenu,
            UIComponentEnum.SpriteMenu,
            UIComponentEnum.AnimationMenu,
            UIComponentEnum.TileMenu,
            UIComponentEnum.MapMenu,
            UIComponentEnum.SfxMenu,
            UIComponentEnum.SongMenu,
            UIComponentEnum.ConfigMenu,
            UIComponentEnum.ColorPaletteMenu,
            UIComponentEnum.PlayGameMenu
        };

        int index = 0;
        foreach (var component in components)
        {
            int row = index / numColumns;
            int col = index % numColumns;
            int x = marginX + col * (menuIconSize + marginX);
            int y = marginY + row * (menuIconSize + marginY);
            GameEngineData.UIComponentBounds[component] = new Rectangle(x, y, menuIconSize, menuIconSize);
            index++;
        }

        foreach (var button in MenuIcons)
        {
            button.Clicked += Button_Clicked;
        }

        var baseBox = GameEngineData.BaseBox;
        _line = new Rectangle(10, 50, baseBox.Width - 20, 2);
    }

    public override void Update()
    {
        foreach (var menuIcon in MenuIcons)
        {
            menuIcon.Update();
        }
    }

    public override void Draw()
    {
        var spriteBatch = FrameworkData.SpriteBatch;
        spriteBatch.DrawText_MediumFont(GameData.Name, new Vector2(20, 30), 3, 1f, 5f, -1);
        spriteBatch.DrawText_MediumFont(GameData.Name, new Vector2(20, 32), 2, 1f, 5f, -1);
        spriteBatch.DrawRectangle(_line, 3);        
        
        foreach (var menuIcon in MenuIcons)
        {
            menuIcon.Draw();
        }
    }

    public override void Exit()
    {
    }

    public override void Enter()
    {
    }

    private void Button_Clicked(object sender, EventArgs e)
    {
        switch (((MenuIcon)sender).Option)
        {
            case MenuOptionEnum.New:
                _sceneManager.ChangeScene(_sceneManager.NewScene);
                break;
            case MenuOptionEnum.Rename:
                _sceneManager.ChangeScene(_sceneManager.RenameScene);
                break;
            case MenuOptionEnum.Save:
                _sceneManager.ChangeScene(_sceneManager.SaveScene);
                break;
            case MenuOptionEnum.Load:
                _sceneManager.ChangeScene(_sceneManager.LoadScene);
                break;
            case MenuOptionEnum.Sprite:
                _sceneManager.ChangeScene(_sceneManager.SpriteScene);
                break;
            case MenuOptionEnum.Tile:
                _sceneManager.ChangeScene(_sceneManager.TileScene);
                break;
            case MenuOptionEnum.Animation:
                _sceneManager.ChangeScene(_sceneManager.AnimationScene);
                break;
            case MenuOptionEnum.Map:
                _sceneManager.ChangeScene(_sceneManager.MapScene);
                break;
            case MenuOptionEnum.Sfx:
                _sceneManager.ChangeScene(_sceneManager.SfxScene);
                break;
            case MenuOptionEnum.Song:
                _sceneManager.ChangeScene(_sceneManager.SongScene);
                break;
            case MenuOptionEnum.Config:
                _sceneManager.ChangeScene(_sceneManager.ConfigScene);
                break;
            case MenuOptionEnum.ColorPalette:
                _sceneManager.ChangeScene(_sceneManager.ColorPaletteScene);
                break;
            case MenuOptionEnum.PlayGame:
                _sceneManager.ChangeScene(_sceneManager.PlayScene);
                break;
        }
    }
}