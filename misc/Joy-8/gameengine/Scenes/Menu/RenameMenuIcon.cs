using gameengine.Data;
using gameengine.Scenes.Shared.UI;

namespace gameengine.Scenes.Menu;

internal class RenameMenuIcon : MenuIcon
{
    public RenameMenuIcon() : base(MenuOptionEnum.Rename, UIComponentEnum.RenameMenu, GameEngineData.Images["rename_button"])
    {
    }
}
