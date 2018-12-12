
# alcFreeliner #

The Aziz! Light Crew Freeliner is a live geometric animation software built with [Processing](https://www.processing.org). The documentation is a little sparse and the ux is rough but powerfull. Click the following image for a video demo.

[![IMAGE ALT TEXT](doc/videopic.png)](https://vimeo.com/246850149 "New Video")

[![IMAGE ALT TEXT](http://img.youtube.com/vi/ktxSKXwmmeU/0.jpg)](http://www.youtube.com/watch?v=ktxSKXwmmeU "Do you know Freeliner?")


## Installation & Launch ##
Here are some instructions on how to get started with freeliner.

1. Download and install Processing 3 from <https://processing.org/>, the latest version should be used.
2. Install these libraries:
	* [oscP5](http://www.sojamo.de/libraries/oscP5/) (available through Processing library Manager)
	* [Websockets](https://github.com/alexandrainst/processing_websockets) (available through Processing library Manager)
	* [ProcessingVideo](https://processing.org/reference/libraries/video/index.html) (available through Processing library Manager)
	* [SimpleHTTP] (http://diskordier.net/simpleHTTPServer/) (download from site)
	* [Spout] Optionaly for windows users
	* [Syphon] Optionaly for MacOS users
3. Open and run `alc_freeliner/freeliner_sketch` with Processing
4. Once running you can point your browser to `http://localhost:8000/index.html` to access the browser interface

### What is? ###

Also known as a!LcFreeliner. This software is feature-full geometric animation software built for live projection mapping. Development started in fall 2013.

It is made with Processing. It is licensed as GNU Lesser General Public License. A official release will occur once I have solidified the new architecture developed during this semester.

Using a computer mouse cursor the user can create geometric forms composed of line segments. These can be created in groups, also known as segmentGroup. To facilitate this task the software has features such as centering, snapping, nudging, fixed length segments, fixed angles, grids, and mouse sensitivity adjustment.

Templates hold data related to how a segmentGroup will be rendered. There is 26 TweakableTemplates, one per uppercase letter. The parameters are configurable via keys like ‘s’ for size, they can be set by typing a new numerical value or pressing ‘-‘ and ‘+’ (actually ‘-‘ and ‘=’).

Each segmentGroup can have multiple templates. The templateManager then combines segmentGroups with their templates to create RenderableTemplates which then get rendered.

### Philosophy ###

alcFreeliner must:
- Only require a computer with mouse, keyboard and display to run.
- Cross platform.
- Content Free, aside from fonts.
- Remain lightweight for old hardware.
- Focus on improvisation.

## How to freeLine ##
Point a projector at stuff, run the processing sketch. Navigate the space with your cursor, left click to add vertices, right click to remove them, and middle click to set their starting point.

The first few clicks puts down a special set of lines, they will display important info. The first three will display important info to make sense of this madness. Try to place them out of the way on a even surface so the text is legible. This is `[group : 0]` and thats all it does for now.

Now hit `n` to create a newItem and click around to place some lines. If you have made a closed shape, you can place a center. Now hit `A` to add renderer A.



##### Tweaking Parameters
Most lowercase keys are linked with a parameter. For example `q` is for colorMode. Once you press `q` you can change the colorMode by pressing `-` or `=` (aka `+`) or by typing in a number and pressing `enter`. Some parameters are simple toggles. For example `g` enables and disables the grid, but you can also alter the grid size by tweaking the value. The `.` works in a similar fashion where you can enable/disable snapping and adjust the snapping distance.
See (https://github.com/maxdee/alc_freeliner/blob/devel/freeliner_sketch/data/doc/autodoc.md) for a detailed list.

##### Tweaking parameters via OSC
Parameters related to rendering can be controlled via OSC. A message `/freeliner/tweak ABC q 2` will set templates A, B and C to red stroke. Typetag string string integer, the port can be set in the settings. You can find some PureData abstractions to get you started in `pd_patches`, great to quickly connect your midi controllers.

##### Snapping
The cursor can snap to various stuff. When snapping to points you can nudge them with the arrow keys, `shift` for bigger increments. Holding `ctrl` will momentarily disable snapping. If `ctrl` is pressed when snapped, you can right click drag the point. Snapping to segment middle you can use `backspace` to remove the segment. `.` toggles snapping and allows you to set the snapping distance.

##### Text Entry
`|` pipe begins a text entry and return key returns the text. This has a few uses. More later.

##### Toggle a template to groups with a template
Essentially adds a other template of your choice to any group who has the first template on the list.
Select two templates like `A` and `B`, press `ctrl-b`. All geometry that has `A` will now also have `B`.

##### Create a custom brush
Make a new segment group, set its center. Add a rendering template (`shift + a-z`) then hit (`ctrl + d`). That template will now have a custom brush corresponding to that segment group. You can then remove that template from the group and or remove all the segments of the group.

##### Copy parameters between templates
Unselect with `esc`, then select the template to copy, then select the template to paste into, and then press `ctrl-c`.   

##### Save and load
Now you can save a complete mapping, geometry and templates. Using `ctrl-s` and `ctrl-o` you can save and load the default files, `userdata/geometry.xml` and `userdata/templates.xml`.

##### Sequencing
16 step sequencing, may change. By tweaking the `>` character you can move through the steps. Steps are like items, they can have multiple templates. Press the `>` key then add a template or two then go to the next step with `=` (+) and onwards. It is recommended to use enabler mode 2.

##### Make Videos
The `*` character begins and stops a frame saving process. These `.tiff` images are saved in batches `capture/clip_N`. You can use Processing's movie maker tool to turn these into a video file. I recommend clearing `capture/` after making some clips.

##### Quitting
Freeliner can be quit with your systems shortcut to close a window, like `alt-f4` or with `cmd-w` on OSX.

##### Syphon
To use Syphon, install the Syphon Processing library and remove all the double slashes (`//`) in the `SyphonLayer.pde` file.

##### Spout
To use Spout, install the Spout Processing library and remove all the double slashes (`//`) in the `SpoutLayer.pde` file.

##### AutoDoc
Freeliner can now compile its own documentation. Due to the extendable nature of freeliner, extensions can get added to documentation automatically. Every template parameter.

## Current Bugs ##
Report one?

## SHOUTOUTS ##
* MrStar
* Zap
* Tats
* Quessy
* Jason Lewis
* BunBun
* ClaireLabs
* Bruno/Laika
* potluck crew
