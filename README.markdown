# fg-canvas-html

### An HTML/CSS Renderer for FlightGear

## Introduction

This is a work-in-progress implementation of an HTML/CSS rendering engine for
FlightGear, supporting a (minimal, but hopefully useful) subset of HTML 5 and
CSS 3, intended for use in custom aircraft avionics and/or GUIs.

## Features & Support Status

### General

- HTML parsing: not supported yet. HTML document can be constructed using the
  hyperscript API available from the `html.H` submodule.
- CSS parsing: supported, see `html.CSS.loadStylesheet`. CSS is also read from
  each element's `style` property.

### Element types

- All HTML5 text elements are available, but not all of them work as they
  should. Normal flow text elements should work fine though.
- Links are available, but currently not clickable. Support is planned in the
  near future.
- Images are not available yet; support is planned in the near future.
- Tables are not available yet; support may be added in the future.
- Videos, canvas, and other embeds, will not be supported, due to limitations
  of the platform: video playback is not feasible from a performance
  perspective, and there is no way of loading video data into FlightGear
  anyway; canvas elements are only useful when combined with JavaScript, which
  will not be implemented (see below).

### CSS


- units: `px`, `em`, `rem`, `%`, `mm`, `cm`, `in`, `pt`, `vw`, `vh`
- colors: `rgb(r, g, b)`, `rgba`(r, g, b, a)`, `#ABC`, `#AABBCC`, #ABCD`,
  `#AABBCCDD`, 16 basic named colors. Support for extended CSS colors planned
  in the future.
- selectors:
  - all-selector (`*`)
  - element name selector (`name`)
  - class selector (`.class`)
  - ID selector (`#id`)
  - descendant-of selector (`ancestor descendant`)
  - child-of selector (`parent > child`)
  - sibling selector (`sibling ~ sibling`)
  - adjacent sibling selector (`sibling + sibling`)
  - pseudo-class (`:pseudo`): parsed, but ignored
  - pseudo-element (`::pseudo`): parsed, but ignored
  - functions (`:has()` etc.): not supported
  - attributes (`[attrib=value]` etc.): not supported (yet)
- media queries: not supported yet
- variables: not supported
- calculated properties: not supported

- `border-width`, `border-color`: supported
- `border-style`: recognized, but ignored; support planned in the future
- `border-radius`: support planned in the future
- `padding`, `margin`: supported
- `text-align`: supported
- `vertical-align`: supported
- `background-color`: supported
- `text-decoration`: currently only `underline` supported
- `font-family`: supported, but only one family may be listed (fix planned)
- `font-weight`: mostly supported
- `font-style`: recognized, but ignored; support planned in the near future
- `display`:
    - supported: `block`, `inline`, `list-item`
    - partial support: `inline-block`
    - unsupported: `table-...`, `flex-...`, `grid-...`
- `float`: support planned in the future
- `position`: support planned in the future
- `z-index`: not supported yet, may add support in the need future

### JavaScript

Unfortunately, supporting JavaScript would require implementing a JavaScript
interpreter in Nasal, which would be a project of Quixotian proportions; I am
old enough to refrain from embarking on it, but if anyone feels like they
should, by all means drop me a line.

## Installation

Copy the contents of the included `Nasal` subdirectory into the `Nasal`
subdirectory of your aircraft.

## Usage

Of the included .nas files, only `Nasal/html/main.nas` should be loaded
directly; it automatically takes care of loading in the rest of the code.
`main.nas` must be loaded into the `html` namespace; you can achieve this in
the aircraft XML like so:

```xml
  <nasal>
    <html>
      <file>path/to/the/aircraft/Nasal/html/main.nas
    </html>
  </nasal>
```

...or from within some other Nasal code like so:

```nasal
  io.load_nasal(getprop('/sim/aircraft-dir') ~ '/Nasal/html/main.nas');
```

The code, then, is subdivided into 4 namespaces:

- `html` contains the other namespaces, and exposes the rendering API.
- `html.DOM` contains a DOM API.
- `html.H` offers a hyperscript-like API for constructing HTML DOMs more
  easily.
- `html.CSS` deals with CSS.

To create and render a basic HTML document, the following code sample should
get you started:

```nasal
io.load_nasal(getprop('/sim/aircraft-dir') ~ '/Nasal/html/main.nas');

# alias sub-namespaces
var H = html.H;
var CSS = html.CSS;

# We need a font mapper to resolve HTML font names to things that are available
# in FlightGear.
var fontMapper = func (fontFace, fontStyle=normal) {
  if (family == 'mono') {
      return "LiberationFonts/LiberationMono-Regular.ttf";
  }
  else {
      if (weight == 'normal') {
          return "LiberationFonts/LiberationSans-Regular.ttf";
      }
      else {
          return "LiberationFonts/LiberationSans-Bold.ttf";
      }
  }
}

# A RenderContext determines the canvas group to draw to, the viewport, and
# various other parameters for the render engine.
var rc = makeDefaultRenderContext(canvasGroup, fontMapper, 0, 0, 512, 384);

var dom =
      H.html(
        H.body(
          H.h1("Hello"),
          H.p(
            "Hello, world! Welcome to the wonderful world of rendering HTML",
            "in FlightGear."
          )));
var stylesheet = CSS.loadStylesheet('path/to/style.css');
stylesheet.apply(dom);
html.showDOM(dom, rc);
```
