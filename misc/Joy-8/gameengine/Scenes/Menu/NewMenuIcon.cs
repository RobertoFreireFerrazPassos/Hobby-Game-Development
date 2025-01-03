using gameengine.Data;
using gameengine.Scenes.Shared.UI;

namespace gameengine.Scenes.Menu;

internal class NewMenuIcon : MenuIcon
{
    public NewMenuIcon() : base(MenuOptionEnum.New, UIComponentEnum.NewMenu, GameEngineData.Images["new_file_button"])
    {
    }
}