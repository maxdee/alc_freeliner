
# alcFreeliner #
Live ephemeral mapping software.

## How to freeLine ##

Point a projector at stuff, run the processing sketch. Navigate the space with your cursor, left click to add vertices, right click to remove them, and middle click to set their starting point.

The first few clicks puts down a special set of lines, they will display important info. The first three will display important info to make sense of this madness. Try to place them out of the way on a even surface so the text is legible. This is [group : 0] and thats all it does for now.

Now hit 'n' to create a newItem and click around to place some lines. If you have made a closed shape, you can place a center. Now hit 'A' to add renderer A.


###### Text Entry
'|' pipe begins a text entry and return key returns the text. This has a few use.


###### Toggle a renderer to groups with a renderer
Essentialy adds a other renderer of your choice to any group who has the first renderer on the list.
Have a renderer in focus, hit '|' to enable text input and enter a renderer, like 'N', and press return.


###### Create a custom brush
Make a new group, set its center. Unselect it and select a renderer then hit control D and set shape mode to 5. Control D sets the last selected group as the shape for the slected renderer.