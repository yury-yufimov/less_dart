//source: less/tree/color.js 2.5.0

part of tree.less;

///
/// RGB Colors - #ff0014, #eee
///
class Color extends Node implements CompareNode, OperateNode<Color> {
  @override final String      name = null;
  @override final String      type = 'Color';
  @override covariant String  value; //TODO used?

  ///
  num           alpha;
  ///
  List<num>     rgb;
  ///
  static String transparentKeyword = 'transparent';


  ///
  /// The end goal here, is to parse the arguments
  /// into an integer triplet, such as `128, 255, 0`
  ///
  /// This facilitates operations and conversions.
  ///
  /// [rgb] could be a List<int> [128, 255, 0]
  /// or String length=6 # 'deb887' or length=3 # 'f01'.
  /// [alpha] 0 < alpha < 1. Default = 1.
  ///
  Color(dynamic rgb, [num this.alpha = 1]){
    if (alpha == 0)
        alpha = 0; // convert to int
    if (alpha == 1)
        alpha = 1;

    final RegExp hex6 = new RegExp('.{2}');

    if (rgb is List<num>) {           // [0, 0 , 0]
      this.rgb = rgb;
    } else if (rgb.length == 6 ) {    // # 'deb887'
      this.rgb = hex6
          .allMatches(rgb)
          .map((Match c) => int.parse(c[0], radix: 16))
          .toList();
    } else {                          // # 'f01'
      this.rgb = rgb
          .split('')
          .map((String c) => int.parse('$c$c', radix: 16))
          .toList();
    }

//2.2.0
//  var Color = function (rgb, a) {
//      //
//      // The end goal here, is to parse the arguments
//      // into an integer triplet, such as `128, 255, 0`
//      //
//      // This facilitates operations and conversions.
//      //
//      if (Array.isArray(rgb)) {
//          this.rgb = rgb;
//      } else if (rgb.length == 6) {
//          this.rgb = rgb.match(/.{2}/g).map(function (c) {
//              return parseInt(c, 16);
//          });
//      } else {
//          this.rgb = rgb.split('').map(function (c) {
//              return parseInt(c + c, 16);
//          });
//      }
//      this.alpha = typeof(a) === 'number' ? a : 1;
//  };
  }

  ///
  factory Color.fromKeyword(String keyword){
    Color         c;
    final String  key = keyword.toLowerCase();

    // detect named color
    String colorValue;
    if ((colorValue = colors[key]) != null) {
      c = new Color(colorValue.substring(1));
    } else if (key == transparentKeyword) {
      c = new Color(<int>[0, 0, 0], 0);
    }

    if (c != null) {
      c.value = keyword;
      return c;
    }

    return null;

//2.3.1
//  Color.fromKeyword = function(keyword) {
//      var c, key = keyword.toLowerCase();
//      if (colors.hasOwnProperty(key)) {
//          c = new Color(colors[key].slice(1));
//      }
//      else if (key === "transparent") {
//          c = new Color([0, 0, 0], 0);
//      }
//
//      if (c) {
//          c.value = keyword;
//          return c;
//      }
//  };
  }

  ///
  num get r => rgb[0];
  ///
  num get g => rgb[1];
  ///
  num get b => rgb[2];

  /// Fields to show with genTree
  @override Map<String, dynamic> get treeField => <String, dynamic>{
    'rgb': rgb,
    'alpha': alpha
  };

  /// Don't use spaces to css
  bool isCompress(Contexts context) =>
      (cleanCss != null) || (context?.compress ?? false);

  ///
  @override
  Node eval(Contexts env) => this;

  ///
  /// Calculates the luma (perceptual brightness) of a color object
  ///
  double luma() {
    double r = this.r / 255;
    double g = this.g / 255;
    double b = this.b / 255;

    r = (r <= 0.03928) ? r / 12.92 : math.pow(((r + 0.055) / 1.055), 2.4);
    g = (g <= 0.03928) ? g / 12.92 : math.pow(((g + 0.055) / 1.055), 2.4);
    b = (b <= 0.03928) ? b / 12.92 : math.pow(((b + 0.055) / 1.055), 2.4);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;

//2.2.0
//  Color.prototype.luma = function () {
//      var r = this.rgb[0] / 255,
//          g = this.rgb[1] / 255,
//          b = this.rgb[2] / 255;
//
//      r = (r <= 0.03928) ? r / 12.92 : Math.pow(((r + 0.055) / 1.055), 2.4);
//      g = (g <= 0.03928) ? g / 12.92 : Math.pow(((g + 0.055) / 1.055), 2.4);
//      b = (b <= 0.03928) ? b / 12.92 : Math.pow(((b + 0.055) / 1.055), 2.4);
//
//      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
//  };
  }

  ///
  @override
  void genCSS(Contexts context, Output output) {
    output.add(toCSS(context));
  }

  ///
  /// Returns this color as string. Transparent, #rrggbb, #rgb.
  ///
  @override
  String toCSS(Contexts context) {
    if (cleanCss?.compatibility?.properties?.colors ?? false)
        return toCleanCSS(context);

    num         alpha;
    String      color;
    final bool  compress = context?.compress ?? false;

    // `value` is set if this color was originally
    // converted from a named color string so we need
    // to respect this and try to output named color too.
    if (value != null)
        return value;


    // If we have some transparency, the only way to represent it
    // is via `rgba`. Otherwise, we use the hex representation,
    // which has better compatibility with older browsers.
    // Values are capped between `0` and `255`, rounded and zero-padded.
    alpha = fround(context, this.alpha);
    if (alpha < 1)
        return toRGBFunction(context);

    color = toRGB();
    if (compress)
        color = tryHex3(color);
    return color;

//2.3.1
//  Color.prototype.toCSS = function (context, doNotCompress) {
//      var compress = context && context.compress && !doNotCompress, color, alpha;
//
//      // `value` is set if this color was originally
//      // converted from a named color string so we need
//      // to respect this and try to output named color too.
//      if (this.value) {
//          return this.value;
//      }
//
//      // If we have some transparency, the only way to represent it
//      // is via `rgba`. Otherwise, we use the hex representation,
//      // which has better compatibility with older browsers.
//      // Values are capped between `0` and `255`, rounded and zero-padded.
//      alpha = this.fround(context, this.alpha);
//      if (alpha < 1) {
//          return "rgba(" + this.rgb.map(function (c) {
//              return clamp(Math.round(c), 255);
//          }).concat(clamp(alpha, 1))
//              .join(',' + (compress ? '' : ' ')) + ")";
//      }
//
//      color = this.toRGB();
//
//      if (compress) {
//          var splitcolor = color.split('');
//
//          // Convert color to short format
//          if (splitcolor[1] === splitcolor[2] && splitcolor[3] === splitcolor[4] && splitcolor[5] === splitcolor[6]) {
//              color = '#' + splitcolor[1] + splitcolor[3] + splitcolor[5];
//          }
//      }
//
//      return color;
//  };
  }

  /// clean-css output
  String toCleanCSS(Contexts context) {
    final num alpha = fround(context, this.alpha);
    String    color = toRGB();

    if (cleanCss.compatibility.colors.opacity && alpha == 0 && color == '#000000')
          return transparentKeyword;
    if (alpha == 1) {
      final String key = getColorKey(color);
      color = tryHex3(color);
      if (key != null) {
        if (key.length < color.length)
          return key;
        if (key.length == color.length && value != null && key == value)
          return key;
      }
    }
    if (alpha < 1)
        return toRGBFunction(context);

    return color;
  }

//--- OperateNode

  ///
  /// Operations have to be done per-channel, if not,
  /// channels will spill onto each other. Once we have
  /// our result, in the form of an integer triplet,
  /// we create a new Color node to hold the result.
  ///
  @override
  Color operate(Contexts context, String op, Color other) {
    final List<num> rgb = <num>[0, 0, 0];
    final num       alpha = this.alpha * (1 - other.alpha) + other.alpha;

    for (int c = 0; c < 3; c++) {
      rgb[c] = _operate(context, op, this.rgb[c], other.rgb[c]);
    }
    return new Color(rgb, alpha);

//2.3.1
//  Color.prototype.operate = function (context, op, other) {
//      var rgb = [];
//      var alpha = this.alpha * (1 - other.alpha) + other.alpha;
//      for (var c = 0; c < 3; c++) {
//          rgb[c] = this._operate(context, op, this.rgb[c], other.rgb[c]);
//      }
//      return new Color(rgb, alpha);
//  };
  }

  ///
  /// Returns this color as String #rrggbb.
  ///
  String toRGB() => toHex(rgb);

  ///
  /// Returns this Color as HSLA
  ///
  HSLType toHSL() {
    final double r = this.r / 255;
    final double g = this.g / 255;
    final double b = this.b / 255;
    final double a = alpha.toDouble();

    //List maxList = [['r', r], ['g', g], ['b', b]]..sort((x, y) => y[1] - x[1]); // big to little
    final List<List<dynamic>> maxList = <List<dynamic>>[
      <dynamic>['r', r],
      <dynamic>['g', g],
      <dynamic>['b', b]
    ]..sort((dynamic x, dynamic y) => y[1] - x[1]); // big to little

    final double  max = maxList.first[1];
    final double  min = maxList[2][1];
    double        h;
    double        s;
    final double  l = (max + min) / 2;
    final double  d = max - min;

    if (max == min) {
      h = s = 0.0;
    } else {
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      switch (maxList.first[0]) {
        case 'r':
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case 'g':
          h = (b - r) / d + 2;
          break;
        case 'b':
          h = (r - g) / d + 4;
          break;
      }
      h /= 6;
    }

    return new HSLType(h: h * 360, s: s, l: l, a: a);

//2.2.0
//  Color.prototype.toHSL = function () {
//      var r = this.rgb[0] / 255,
//          g = this.rgb[1] / 255,
//          b = this.rgb[2] / 255,
//          a = this.alpha;
//
//      var max = Math.max(r, g, b), min = Math.min(r, g, b);
//      var h, s, l = (max + min) / 2, d = max - min;
//
//      if (max === min) {
//          h = s = 0;
//      } else {
//          s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
//
//          switch (max) {
//              case r: h = (g - b) / d + (g < b ? 6 : 0); break;
//              case g: h = (b - r) / d + 2;               break;
//              case b: h = (r - g) / d + 4;               break;
//          }
//          h /= 6;
//      }
//      return { h: h * 360, s: s, l: l, a: a };
//  };
  }

  ///
  /*
   * Adapted from
   * http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
   */
  HSVType toHSV() {
    final double r = this.r / 255;
    final double g = this.g / 255;
    final double b = this.b / 255;
    final double a = alpha.toDouble();

    final List<List<dynamic>> maxList = <List<dynamic>>[
      <dynamic>['r', r],
      <dynamic>['g', g],
      <dynamic>['b', b]
    ]..sort((dynamic x, dynamic y) => y[1] - x[1]); // big to little

    final double  max = maxList.first[1];
    final double  min = maxList[2][1];
    double        h;
    double        s;
    final double  v = max;
    final double  d = max - min;

    if (max == 0.0) {
      s = 0.0;
    } else {
      s = d / max;
    }

    if (max == min) {
      h = 0.0;
    } else {
      switch (maxList.first[0]) {
        case 'r':
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case 'g':
          h = (b - r) / d + 2;
          break;
        case 'b':
          h = (r - g) / d + 4;
          break;
      }
      h /= 6;
    }

    return new HSVType(h: h * 360, s: s, v: v, a: a);

//2.2.0
//  Color.prototype.toHSV = function () {
//      var r = this.rgb[0] / 255,
//          g = this.rgb[1] / 255,
//          b = this.rgb[2] / 255,
//          a = this.alpha;
//
//      var max = Math.max(r, g, b), min = Math.min(r, g, b);
//      var h, s, v = max;
//
//      var d = max - min;
//      if (max === 0) {
//          s = 0;
//      } else {
//          s = d / max;
//      }
//
//      if (max === min) {
//          h = 0;
//      } else {
//          switch(max){
//              case r: h = (g - b) / d + (g < b ? 6 : 0); break;
//              case g: h = (b - r) / d + 2; break;
//              case b: h = (r - g) / d + 4; break;
//          }
//          h /= 6;
//      }
//      return { h: h * 360, s: s, v: v, a: a };
//  };
  }

  ///
  /// Returns a String such as #aarrggbb
  ///
  String toARGB() => toHex(<num>[alpha * 255]..addAll(rgb));

//--- CompareNode

  ///
  /// Returns -1, 0 for different, equal
  ///
  @override
  int compare(Node x) {
    if (x is! Color)
        return -1;

    final Color xx = x;
    return (xx.r == r && xx.g == g && xx.b == b && xx.alpha == alpha)
        ? 0
        : null;

//2.2.0
//  Color.prototype.compare = function (x) {
//      return (x.rgb &&
//          x.rgb[0] === this.rgb[0] &&
//          x.rgb[1] === this.rgb[1] &&
//          x.rgb[2] === this.rgb[2] &&
//          x.alpha  === this.alpha) ? 0 : undefined;
//  };
  }

  ///
  /// Returns a String #rrggbb.
  /// [v] is a List<num> = [r, g, b] or [r, b, b, a].
  ///
  // static?
  String toHex(List<num> v) {
    final String result = v.map((num c) {
      final int r = c.round().clamp(0, 255);
      // ignore: prefer_interpolation_to_compose_strings
      return (r < 16 ? '0' : '') + r.toRadixString(16);
    }).toList().join('');

    return '#$result';

//2.2.0
//  function toHex(v) {
//      return '#' + v.map(function (c) {
//          c = clamp(Math.round(c), 255);
//          return (c < 16 ? '0' : '') + c.toString(16);
//      }).join('');
//  }
  }

  ///
  /// [hex] == '#rrggbb' => '#rgb'
  /// else return unchanged
  ///
  String tryHex3(String hex) {
    if (hex.length != 7)
        return hex;

    if (hex[1] == hex[2] && hex[3] == hex[4] && hex[5] == hex[6]) {
      return '#${hex[1]}${hex[3]}${hex[5]}';
    } else {
      return hex;
    }

//  List splitcolor = color.split('');
//
//  // Convert color to short format
//  if (splitcolor[1] == splitcolor[2]
//      && splitcolor[3] == splitcolor[4]
//      && splitcolor[5] == splitcolor[6]) {
//    color = '#' + splitcolor[1] + splitcolor[3] + splitcolor[5];
//  }
  }

  ///
  /// => 'rgba(r, g, b, a)'
  ///
  String toRGBFunction(Contexts context) {
    final num alpha = fround(context, this.alpha);

    final List<String> resultList = rgb
        .map((num c) => clamp(c.round(), 255).toString())
        .toList();

    final String alphaStr = numToString(clamp(alpha, 1));
    resultList.add(cleanCss != null ? alphaStr.replaceFirst('0.', '.') : alphaStr); //0.1 -> .1

    final String separator = isCompress(context) ? ',' : ', ';
    final String result = resultList.join(separator);
    return 'rgba($result)';

//      alpha = this.fround(context, this.alpha);
//      if (alpha < 1) {
//          return "rgba(" + this.rgb.map(function (c) {
//              return clamp(Math.round(c), 255);
//          }).concat(clamp(alpha, 1))
//              .join(',' + (compress ? '' : ' ')) + ")";
//      }
  }

  ///
  /// [value] == '#rrggbb' returns the color key
  ///
  String getColorKey(String value) => colors.getKey(value);
  /*
    for (String key in colors.keys) {
      if (colors[key] == value) return key;
    }
    return null;
  */

  ///
  /// Returns num v in the range [0 v max].
  ///
  // static?
  num clamp(num v, num max) => v.clamp(0, max);

//2.2.0
//  function clamp(v, max) {
//      return Math.min(Math.max(v, 0), max);
//  }

  @override
  String toString() => toCSS(null);
}

///
class HSLType {
  ///
  double h;
  ///
  double s;
  ///
  double l;
  ///
  double a;

  ///
  HSLType({this.h, this.s, this.l, this.a});
}

///
class HSVType {
  ///
  double h;
  ///
  double s;
  ///
  double v;
  ///
  double a;

  ///
  HSVType({this.h, this.s, this.v, this.a});
}
