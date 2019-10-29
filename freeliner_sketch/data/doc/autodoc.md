Generated on 2019/10/29 with freeliner version 0.4.8
### keys ###
| key | parameter | type | description | cmd |
|:---:|---|---|---|---|
| `(` | testChannel |on off + value |set the test channel, must use a fixture layer called fix | `fixtures testchan` |
| `)` | setChannel |action |set the start led of a fixture, if snapped to segment middle, sets the end of fixture on that segment | `fixtures setchan` |
| `,` | showTags |on off |showTags of all groups | `tools tags` |
| `-` | decrease |action |Decrease value of selectedKey. | `nope` |
| `.` | snapping |on off + value |enable/disable snapping or set the snapping distance | `tools snap` |
| `/` | showLines |on off |Showlines of all geometry. | `tools lines` |
| `0` | macro0 |macro |macro 0:  | `` |
| `1` | macro1 |macro |macro1  geom clone 2 A | ` geom clone 2 A` |
| `2` | macro2 |macro |macro2  tp translate $ 0.5 0.0, tw $ p 1 | ` tp translate $ 0.5 0.0, tw $ p 1` |
| `3` | macro3 |macro |macro3  tw $ b 1, tw $ q 8 | ` tw $ b 1, tw $ q 8` |
| `4` | macro4 |macro |macro 4:  | `` |
| `5` | macro5 |macro |macro 5:  | `` |
| `6` | macro6 |macro |macro 6:  | `` |
| `7` | macro7 |macro |macro 7:  | `` |
| `8` | macro8 |macro |macro 8:  | `` |
| `9` | macro9 |macro |macro 9:  | `` |
| `<` | sequencer |value |select sequencer steps to add or remove templates | `seq select` |
| `=` | increase |action |Increase value of selectedKey. | `nope` |
| `>` | play |on off |toggle auto loops and sequencer | `seq play` |
| `?` | ??? |action |~:) | `fl random` |
| `ctrl-a` | selectAll |action |Select ALL the templates. | `tp select *` |
| `ctrl-b` | add |action |Toggle second template on all geometry with first template. | `tp groupadd $` |
| `ctrl-c` | copy |action |Copy first selected template into second selected. | `tp copy $` |
| `ctrl-d` | customShape |value |Set a template's customShape. | `tp shape $` |
| `ctrl-i` | revMouseX |on off |Reverse the X axis of mouse, trust me its handy. | `tools revx` |
| `ctrl-l` | link |action |Link one template to an other unidirectionaly, used for meta freelining. | `tp link $` |
| `ctrl-o` | open |action |Open stuff | `fl open` |
| `ctrl-p` | priority |value |Change the geometry render order, if a group is selected, changes this groups render priority, or all groups with selected template. | `geom priority $` |
| `ctrl-q` | quit |action |quit freeliner! | `fl quit` |
| `ctrl-r` | reset |action |Reset template. | `tp reset $` |
| `ctrl-s` | save |action |Save stuff. | `fl save` |
| `ctrl-v` | paste |action |Paste copied template into selected template. | `tp paste $` |
| `ctrl-x` | swap |action |Completely swap template tag, with `AB` A becomes B and B becomes A. | `tp swap $` |
| `[` | fixedAngle |on off + value |enable/disable fixed angles for the mouse | `tools angle` |
| `]` | fixedLength |on off + value |enable/disable fixed length for the mouse | `tools ruler` |
| `^` | clear |action |clear sequencer | `seq clear $` |
| `a` | animation |value |animate stuff | `tw $ a` |
| `b` | renderMode |value |picks the renderMode | `tw $ b` |
| `c` | placeCenter |action |Place the center of geometry on next left click, right click uncenters the geometry, middle click sets scene center. | `geom center` |
| `d` | breakline |action |Detach line to new starting position. | `geom breakline` |
| `e` | enterpolator |value |Enterpolator picks a position along a segment | `tw $ e` |
| `f` | fill |value |Pick fill color | `tw $ f` |
| `g` | grid |on off + value |use snappable grid | `tools grid` |
| `h` | easing |value |Set the easing mode. | `tw $ h` |
| `i` | iteration |value |Iterate animation in different ways, `r` sets the amount. | `tw $ i` |
| `j` | reverse |value |Pick different reverse modes | `tw $ j` |
| `k` | strokeAlpha |value |Alpha value of stroke. | `tw $ k` |
| `l` | fillAlpha |value |Alpha value of fill. | `tw $ l` |
| `m` | miscValue |value |A extra value that can be used by modes. | `tw $ m` |
| `n` | new |action |make a new geometry group | `geom new` |
| `o` | rotation |value |Rotate stuff. | `tw $ o` |
| `p` | layer |value |Pick which layer to render on. | `tw $ p` |
| `q` | strokeColor |value |Pick the stroke Color. | `tw $ q` |
| `r` | polka |value |Number of iterations for the iterator, related to `i`. | `tw $ r` |
| `s` | size |value |Sets the brush size for `b-0` | `tw $ s` |
| `t` | tap |action |Tap tempo, tweaking nudges time. | `seq tap` |
| `u` | enabler |value |Enablers decide if a render happens or not. | `tw $ u` |
| `v` | segSelect |value |Picks which segments get rendered. | `tw $ v` |
| `w` | strokeWeight |value |Stroke weight. | `tw $ w` |
| `x` | beatMultiplier |value |Set how many beats the animation will take. | `tw $ x` |
| `y` | tracers |value |Set tracer level for tracer layer. | `post tracers` |
| `z` | looper |value |Set how many beats the loop will be. | `loop` |
| `|` | enterText |on off |enable text entry, type text and press return | `text` |
 
