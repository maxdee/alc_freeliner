| v |  for : PersegmentRender | Description |
|:---:|---|---|
| `0` | AllSegments | Renders all segments |
| `1` | SequentialSegments | Renders one segment per beat in order. |
| `2` | RunThroughSegments | Render all segments in order in one beat. |
| `3` | RandomSegment | Render a random segment per beat. |
| `4` | FastRandomSegment | Render a different segment per frame |
| `5` | SegmentBranch | Renders segment in branch level augmenting every beat |
| `6` | RunThroughBranches | Render throught all the branch levels in one beat. |
| `7` | ConstantSpeed | Runs through segments at a consistant speed. |
| `8` | MetaSegmentSelector | Use metapoints to select segments |
 
| q |  for : Painter | Description |
|:---:|---|---|
| `0` | #000000 | None |
| `1` | #FFFFFF | white |
| `2` | #FF0000 | red |
| `3` | #00FF00 | green |
| `4` | #0000FF | blue |
| `5` | #000000 | black |
| `6` | pallette 0 | Color of 0 index in colorPalette |
| `7` | pallette 1 | Color of 1 index in colorPalette |
| `8` | pallette 2 | Color of 2 index in colorPalette |
| `9` | pallette 3 | Color of 3 index in colorPalette |
| `10` | pallette 4 | Color of 4 index in colorPalette |
| `11` | pallette 5 | Color of 5 index in colorPalette |
| `12` | pallette 6 | Color of 6 index in colorPalette |
| `13` | pallette 7 | Color of 7 index in colorPalette |
| `14` | pallette 8 | Color of 8 index in colorPalette |
| `15` | pallette 9 | Color of 9 index in colorPalette |
| `16` | pallette 10 | Color of 10 index in colorPalette |
| `17` | pallette 11 | Color of 11 index in colorPalette |
| `18` | RepetitionColor | Cycles through colors of the pallette |
| `19` | QuarterRepetitionColor | Cycles through first 4 colors of the pallette |
| `20` | RandomPrimaryColor | Primary color that should change every beat. |
| `21` | PrimaryBeatColor | Cycles through primary colors on beat. |
| `22` | CustomStrokeColor | Custom stroke color for template. |
| `23` | CustomFillColor | Custom fill color for template. |
| `24` | MillisFade | HSB fade goes along with millis. |
| `25` | HSBLerp | HSB fade through beat. |
| `26` | HSBPhase | HSBFade with offset |
| `27` | ColorMap | Meta-freelining - use linked template position markers to pick colors from the colormap, set one with: colormap map.png |
| `28` | FlashyPrimaryColor | Random primary color every frame. |
| `29` | FlashyGray | Random shades of gray. |
| `30` | RGB | Random red green and blue value every frame. |
| `31` | Strobe | Strobes white |
| `32` | Flash | Flashes once per beat. |
| `33` | superflash | super version of the flash |
| `34` | moduloStrobe | strobe with a time modulo thing, use m misc value to adjust |
 
| e |  for : Painter | Description |
|:---:|---|---|
| `0` | Interpolator | Pics a position in relation to a segment |
| `1` | CenterSender | Moves between pointA and center |
| `2` | CenterSender | Moves between pointA and center |
| `3` | HalfWayInterpolator | Moves along segment, but halfway to center. |
| `4` | RandomExpandingInterpolator | Provides an expanding random position between segment and center. |
| `5` | RandomInterpolator | Provides random position between segment and center. |
| `6` | DiameterInterpolator | Rotates with segments as diameter. |
| `7` | RadiusInterpolator | Rotates with segments as Radius. |
| `8` | SegmentOffsetInterpolator | Prototype thing that offsets the position according to segments X position. |
| `9` | OppositInterpolator | invert direction every segment |
| `10` | NoisyInterpolator | noise along segment |
| `11` | RandomRadiusInterpolator | Rotates with segments as diameter. |
 
| a |  for : Painter | Description |
|:---:|---|---|
| `0` | PointBrush | Adjust its size with `w`. |
| `1` | line | Perpendicular line brush |
| `2` | circle | Brush witha circular appearance. |
| `3` | chevron | Chevron > shaped style brush |
| `4` | square | Square shaped brush |
| `5` | + | + shaped brush |
| `6` | triangle | Triangular brush. |
| `7` | sprinkle | ms paint grafiti style |
| `8` | custom | Template custom shape, add template to geometryGroup and press `ctrl-d` to set as custom shape. |
 
| a |  for : LineSegment | Description |
|:---:|---|---|
| `0` | FunLine | Makes a line between pointA and a position. |
| `1` | FullLine | Draws a line on a segment, not animated. |
| `2` | MiddleLine | line that expands from the middle of a segment. |
| `3` | TrainLine | Line that comes out of point A and exits through pointB |
| `4` | Maypole | Draw a line from center to position. |
| `5` | SegToSeg | Draws a line from a point on a segment to a point on a different segment. Affected by `e` |
| `6` | AlphaLine | modulates alpha channel, made for LEDs |
| `7` | GradientLine | Stroke to fill gradient |
| `8` | MovingGradientLine | Moving Stroke to fill gradient |
 
| a |  for : MultiLineRender | Description |
|:---:|---|---|
| `0` | InterpolatorShape | shape delimited by positions determined by the interpolator |
| `1` | Filler | make a filled shape, for nice color fill |
| `2` | DashedLines | Dashing |
 
| a |  for : TextRenderMode | Description |
|:---:|---|---|
| `0` | TextWritter | Fit a bunch of text on a segment |
| `1` | ScrollingText | Scrolls text, acording to enterpolator |
| `2` | LeftAlignedText | Aligns text to the left |
| `3` | CenterAlignedText | Aligns text to center |
| `4` | RightAlignedText | Aligns text to right |
 
| a |  for : CircularSegment | Description |
|:---:|---|---|
| `0` | Elliptic | Makes a expanding circle with segment as final radius. |
 
| a |  for : FadedRenders | Description |
|:---:|---|---|
| `0` | FadedBrusher | same as brush but adds a faded edge |
| `1` | FadedBrusher | same as brush but adds a faded edge |
 
| a |  for : MetaFreelining | Description |
|:---:|---|---|
| `0` | PositionCollector | Save position markers into template, for use use with meta-freelining. |
| `1` | SegmentCommand | MetaFreelining, execute commands of commandSegments |
 
| b |  for : TemplateRenderer | Description |
|:---:|---|---|
| `0` | BrushSegment | Render mode for drawing with brushes |
| `1` | LineSegment | Draw lines related to segments |
| `2` | WrapLine | line from segment to segment |
| `3` | MultiLineRender | RenderModes that involve all segments. |
| `4` | TextRenderMode | Stuff that draws text |
| `5` | CircularSegment | Circles and stuff |
| `6` | FadedRenders | Render options with feathered edges, good for LEDs |
| `7` | MetaFreelining | Use freeliner to automate itself. |
 
| i |  for : TemplateRenderer | Description |
|:---:|---|---|
| `0` | single | only draw template once |
| `1` | EvenlySpaced | Render things evenly spaced |
| `2` | EvenlySpacedWithZero | Render things evenly spaced with a fixed one at the begining and end |
| `3` | ExpoSpaced | RenderMultiples but make em go faster |
| `4` | TwoFull | Render twice in opposite directions |
| `5` | TwoFull | Render twice in opposite directions |
 
| u |  for : TemplateRenderer | Description |
|:---:|---|---|
| `0` | Disabler | Never render |
| `1` | loop | always render |
| `2` | Triggerable | only render if triggered |
| `3` | Triggerable | only render if triggered |
| `4` | SweepingEnabler | render per geometry from left to right |
| `5` | SwoopingEnabler | render per geometry from right to left |
| `6` | EveryX | happens every x, set by miscValue |
| `7` | RandomEnabler | Maybe render |
| `8` | strobe enable | very crunchy render, affected by miscValue |
| `9` | MarkerEnabler | Use meta points to enablestuff |
 
| h |  for : TemplateRenderer | Description |
|:---:|---|---|
| `0` | linear | Linear movement |
| `1` | EaseInQuad | quad acceleration |
| `2` | EaseOutQuad | quad deceleration |
| `3` | EaseInOutQuad | quad acceleration & deceleration |
| `4` | EaseInCubic | cubic acceleration |
| `5` | EaseOutCubic | cubic deceleration |
| `6` | EaseInOutCubic | cubic acceleration & deceleration |
| `7` | EaseInQuart | quart acceleration |
| `8` | EaseOutQuart | quart acceleration |
| `9` | EaseInOutQuart | quart acceleration and deceleration |
| `10` | EaseSpringIn | like a reverse door stopper spring |
| `11` | EaseSpringOut | like a door stopper spring |
| `12` | EaseSpringInOut | like a weird door stopper spring |
| `1