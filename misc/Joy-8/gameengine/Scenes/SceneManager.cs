using gameengine.Data;
using gameengine.Input;
using gameengine.Utils;

namespace gameengine.Scenes;

internal class SceneManager
{
    private Scene _currentScene;
    private bool _firstUpdate = false;
    public IntroScene IntroScene;
    public NewScene NewScene;
    public RenameScene RenameScene;
    public SaveScene SaveScene;
    public MenuScene MenuScene;
    public LoadScene LoadScene;
    public SpriteScene SpriteScene;
    public TileScene TileScene;
    public AnimationScene AnimationScene;
    public MapScene MapScene;
    public SfxScene SfxScene;
    public SongScene SongScene;
    public ConfigScene ConfigScene;
    public ColorPaletteScene ColorPaletteScene;
    public PlayScene PlayScene;

    public SceneManager()
    {
    }

    public void Update()
    {
        if (!_firstUpdate)
        {
            FirstUpdate();
        }

        if (KeyboardInput.IsEscPressed() && !(_currentScene is IntroScene))
            ChangeScene(MenuScene);

        if (!GameEngineData.IsFocused)
        {
            return;
        }

        _currentScene.BaseUpdate();
    }

    private void FirstUpdate()
    {
        IntroScene = new IntroScene(this);
        NewScene = new NewScene(this);
        RenameScene = new RenameScene(this);
        SaveScene = new SaveScene(this);
        MenuScene = new MenuScene(this);
        LoadScene = new LoadScene(this);
        SpriteScene = new SpriteScene(this);
        TileScene = new TileScene(this);
        AnimationScene = new AnimationScene(this);
        MapScene = new MapScene(this);
        SfxScene = new SfxScene(this);
        SongScene = new SongScene(this);
        ConfigScene = new ConfigScene(this);
        ColorPaletteScene = new ColorPaletteScene(this);
        PlayScene = new PlayScene(this);
        LoadGame();
        ChangeScene(IntroScene);
        _firstUpdate = true;
    }

    public void Draw()
    {
        _currentScene.BaseDraw();
    }

    public void ChangeScene(Scene scene)
    {
        _currentScene?.BaseExit();
        _currentScene = scene;
        _currentScene.BaseEnter();
    }

    public void LoadGame(string gameFileName = "")
    {
        if (string.IsNullOrWhiteSpace(gameFileName))
        {
            SetVariables();
            return;
        }

        SetVariables();

        void SetVariables()
        {
            ColorUtils.SetPalette(GameData.PaletteIndex);
        }
    }

    public void ReloadUIOnly()
    {
    }
}