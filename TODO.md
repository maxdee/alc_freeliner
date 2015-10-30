# alc_Freeliner Developement #

#### TODO ####
 * more text modes?
 * more line modes.
 * fix keyboard handling (international)
 * iterator/easing should be before run through segs? somethign to do with trigger mode
 * triangle brush center wrong
 * prevent resizing of brush...

*** use check_this tag to mark spots to come back to


#### Ideas ####
  * cursor style and size, in different situations a different cursor could be used.
  * strokeWeight offset
  * trigger + segment selector.... (???)
  * rotate acording to clockwise? first segment pA.y>pB.y
  * template linking, link A->B, tweak and trigger affects both, Dont change the values that differ?
  * bumper system
  * Geometry hot swap, reload geometery according to xml file, but not resetting the templates.
  * Per distance repetition?

### Interface ###
  * Should preset templates be a single template or can be a combo relating to one item? Perhaps presets can be linked somehow.
  * latch!
  * midi?
  * geometry mod?
  * https://github.com/extrapixel/gif-animation
  * G4P + ^

### VJ specific ###
  * Mirroring render mode? makes a mirrored segmentGroup copy? or a mirrored accessor?
  * Moving geometry...

### FreeLEDing ###
  * LEDmap.xml maker, set segment text to `/leds start_addr end_addr`
  * ARTNET subclass
