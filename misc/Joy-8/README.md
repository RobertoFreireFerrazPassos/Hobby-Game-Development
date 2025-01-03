# Joy-8

Game engine for pixel art style

# Backlog

## How to create a local nugget package?

## Next

GamesData 
Transform map to list map

Menu map. Implement like sprite fusion and pico8

Layers. Bucket, pensive, eraser,...
Layers should dynamic. Add, delete, reorder

In game data. Group similar data in a class 

Maps
List<maps>

Map 
Name (string)
Int[,] grid = number of the tile 

Tile
Int[,] grid
Function to flat 2d grid to 1d number of the tile
Collision[numberofthetile] = collision

Collision
Type (rect, circular, triangle)
Values

For each sprite number in the sprite grid. Save in game data the behind sprite number to draw on the screen
This way. Everytime user clicks on a sprite, the user can see layers behind
Show like a breabcrumber for the sequence of sprite layers starting from the current layer

## MENU: New

Similar to RenameScene:

Text:
"Are you sure you want to start a new game? All unsaved changes will be lost."

Buttons:
No -> Go back to MenuScene
Yes -> GameData.NewGame(); and then Go back to MenuScene

## MENU: Save

Similar to RenameScene:

Text
"Saving game..."

try to save async while rendering this screen.
Timer minimum 3 seconds
Go back to MenuScene

## MENU: Load

Text: 
"Select a game to load:"

List:
'File name - Last date modified"

When user clicks on a item from the list, load game
if it fails, show "!" icon: "(!) File name - Last date modified"
if it succeeds, GameData.LoadGameData(); and then Go back to MenuScene

## MENU: Sprite

<p align="center">
  <img src="./gitimages/tilescene.png?raw=true">
</p>

- On the bottom of map, add 8 buttons to select the current page
- Clicking on a square of ,lthe map, it will make the current sprite.
- On the bottom of the page add zoom in and zoom out buttons (8x8, 16x16, 32x32 and 64x64) options
- It will show the number of the index for the sprite map
- On the map it will show the current square or squares ( in case of zoom out) selected
- Copy will copy the current pixels (8x8, 16x16, 32x32 or 64x64 depending on the zoom) and will paste only the pixels that fits the current pixels (8x8, 16x16, 32x32 or 64x64 depending on the zoom)
- If it is smaller than the current pixels, it will paste only part.
- If it is bigger than the current pixels, it will crop and only paste the part that it fits the sprite pixels
- All the paint/icons will work only within the current sprite pixels. Example: bucket
- On the bottom, add undo and redo buttons
- It will store a snapshot of vector2 position and grid (8x8, 16x16, 32x32 or 64x64 depending on the zoom)
- Del key, delete the current sprite pixels (8x8, 16x16, 32x32 or 64x64 depending on the zoom)
- Use arrows keys to move sprites inside the current spritePixels
- It should scale automatically

## MENU: Tile

add tiles map

## MENU: Tile Collision

Add flag and detection geometry

## MENU: Map

Draw Tiles in the map

## MENU: Sfx

## MENU: Songs

## MENU: Configuration

## MENU: Info

Explain each menu icon, shortcuts,...

## CHANGE
THIS WILL BE AN	 ASSET MANAGEMENT.
THERE WILL BE ANOTHER PROJECT TO RUN THE GAME, PROBABLY WITH C# INSTEAD OF LUA

REMOVE ALL THE MENU ICONS, ENUMS, UI COMPOENTS AND ANY RELATED CLASSES FOR ANIMATIONSCENE AND PLAYSCENE

ADD PUBLISHSCENE TO CREATE FILES TO THE FOLDER WHERE THE USER WILL CREATE A C# APPLICATION FOR THE GAME

## ErrorScene

Create ErrorScene

Text:
"Error Message:"

Text:
show the full multiline error message

## Utils:

### Read/Save Files:

Save file
Load file (Read txt)
Try catch for each read/save file
Use strategy pattern to reuse code to save int, datetime, array and etc
We will have one txt file for each thing (tile, sprite, map, and etc)

### SpriteBatchExtensions:

Draw text. Wrap up text based on a rectangle
And use "..." if necessary in the right end of the last line

### C# Script

https://github.com/dotnet/roslyn/blob/main/docs/wiki/Scripting-API-Samples.md