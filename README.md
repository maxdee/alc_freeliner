
# alcFreeliner #

The new v0.3 is for Processing 3. Needs testing and fixing on OSX.
Check the processingTwo branch is still cool.

### What is? ###

Also know as a!LcFreeliner. This software is feature-full geometric animation software built for live projection mapping. Development started in fall 2013.

It is made with Processing. It is licensed as GNU Lesser General Public License. A official release will occur once I have solidified the new architecture developed during this semester.

Using a computer mouse cursor the user can create geometric forms composed of line segments. These can be created in groups, also known as segmentGroup. To facilitate this task the software has features such as centering, snapping, nudging, fixed length segments, fixed angles, grids, and mouse sensitivity adjustment.

Templates hold data related to how a segmentGroup will be rendered. There is 26 TweakableTemplates, one per uppercase letter. The parameters are configurable via keys like ‘s’ for size, they can be set by typing a new numerical value or pressing ‘-‘ and ‘+’ (actually ‘-‘ and ‘=’).

Each segmentGroup can have multiple templates. The templateManager then combines segmentGroups with their templates to create RenderableTemplates which then get rendered .

### Philosophy ###

alcFreeliner must:
- Be operable via mouse and keyboard. For other control methods (midi controlers) go with OSC.
- Cross platform.
- Content Free, aside from fonts I guess.
- Remain lightweight for old hardware.
- Focus on improvisation.

## How to freeLine ##

Point a projector at stuff, run the processing sketch. Navigate the space with your cursor, left click to add vertices, right click to remove them, and middle click to set their starting point.

The first few clicks puts down a special set of lines, they will display important info. The first three will display important info to make sense of this madness. Try to place them out of the way on a even surface so the text is legible. This is `[group : 0]` and thats all it does for now.

Now hit 'n' to create a newItem and click around to place some lines. If you have made a closed shape, you can place a center. Now hit 'A' to add renderer A.

##### Tweaking Parameters
Most lowercase keys are linked with a parameter. For example `q` is for colorMode. Once you press `q` you can change the colorMode by pressing `-` or `=` (aka `+`) or by typing in a number and pressing `enter`. Some parameters are simple toggles. For example `g` enables and disables the grid, but you can also alter the grid size by tweaking the value. The `.` works in a similar fashion where you can enable/disable snapping and adjust the snapping distance.

###### Tweaking parameters via OSC
Parameters related to rendering can be controlled via OSC. A message `/freeliner/tweak ABC q 2` will set templates A, B and C to red stroke. Typetag string string integer, the port can be set in the settings. You can find some PureData abstractions to get you started in `pd_patches`, great to quickly connect your midi controllers.

##### Snapping
The cursor can snap to various stuff. When snapping to points you can nudge them with the arrow keys, `shift` for bigger increments. Holding `ctrl` will momentarily disable snapping. If `ctrl` is pressed when snapped, you can right click drag the point. Snapping to segment middle you can use `backspace` to remove the segment. `.` toggles snapping and allows you to set the snapping distance.

##### Text Entry
`|` pipe begins a text entry and return key returns the text. This has a few uses. More later.

##### Toggle a renderer to groups with a renderer
Essentially adds a other renderer of your choice to any group who has the first renderer on the list.
Have a renderer in focus, hit `|` to enable text input and enter a renderer, like `N`, and press return.

##### Create a custom brush
Make a new segment group, set its center. Add a rendering template (`shift + a-z`) then hit (`ctrl + d`). That template will now have a custom brush corresponding to that segment group. You can then remove that template from the group and or remove all the segments of the group.

##### Copy parameters between templates
Unselect with `esc`, then select the template to copy, then select the template to paste into, and then press `ctrl-c`.  

##### Save Geometry
The `@` character saves your current segment groups, with the exception of group 0. The `#` character will load whatever is in `data/groups.xml`. Its a good idea to make a copy of this file because accidentally hitting `@` will overwrite the file.

##### Make Videos
The `*` character begins and stops a frame saving process. These `.tiff` images are saved in batches `capture/clip_N`. You can use Processing's movie maker tool to turn these into a video file. I recommend clearing `capture/` after making some clips.

## Current Bugs ##
  * The fill or stroke modes (`q and f`) get stuck at 0, change the shapeSize to get your stroke or fill back.
  * Only one closed shape per items, due to segment sorting.
