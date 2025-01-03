using gameengine.Data;
using gameengine.Scenes.Shared.UI;

namespace gameengine.Scenes.Menu;

internal class SpriteMenuIcon : MenuIcon
{
    public SpriteMenuIcon() : base(MenuOptionEnum.Sprite, UIComponentEnum.SpriteMenu, GameEngineData.Images["sprite_button"])
    {
    }
}
