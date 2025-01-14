//source: less/tree/js-eval-node.dart 3.0.0 20160714

part of tree.less;

///
abstract class JsEvalNodeMixin implements Node {
  ///
  /// JavaScript evaluation - not supported
  ///
  String evaluateJavaScript(String expression, Contexts context) {
    // String result;
    final JsEvalNodeMixin that = this;
    // Map evalContext = {};

    if (!(context.javascriptEnabled ?? false)) {
      throw LessExceptionError(LessError(
          message: 'Inline JavaScript is not enabled.',
          index: index,
          filename: currentFileInfo.filename));
    }
    final String _expression = expression.replaceAllMapped(
        RegExp(r'@\{([\w-]+)\}'),
        (Match m) => that.jsify(
            Variable('@${m[1]}', that.index, that.currentFileInfo)
                .eval(context)));

    try {
      // expression = new Function('return (' + expression + ')');
    } catch (e) {
      // throw { message: "JavaScript evaluation error: " + e.message + " from `" + expression + "`" ,
      //filename: this.currentFileInfo.filename,
      //index:
    }
//      var variables = context.frames[0].variables();
//      for (var k in variables) {
//          if (variables.hasOwnProperty(k)) {
//              /*jshint loopfunc:true */
//              evalContext[k.slice(1)] = {
//                  value: variables[k].value,
//                  toJS: function () {
//                      return this.value.eval(context).toCSS();
//                  }
//              };
//          }
//      }
//
//      try {
//          result = expression.call(evalContext);
//      } catch (e) {
//          throw { message: "JavaScript evaluation error: '" + e.name + ': ' + e.message.replace(/["]/g, "'") + "'" ,
//              filename: this.currentFileInfo.filename,
//              index: this.index };
//      }

    return _expression;

//3.0.0 20160714
// JsEvalNode.prototype.evaluateJavaScript = function (expression, context) {
//     var result,
//         that = this,
//         evalContext = {};
//
//     if (!context.javascriptEnabled) {
//         throw { message: "Inline JavaScript is not enabled. Is it set in your options?",
//             filename: this.fileInfo().filename,
//             index: this.getIndex() };
//     }
//
//     expression = expression.replace(/@\{([\w-]+)\}/g, function (_, name) {
//         return that.jsify(new Variable('@' + name, that.getIndex(), that.fileInfo()).eval(context));
//     });
//
//     try {
//         expression = new Function('return (' + expression + ')');
//     } catch (e) {
//         throw { message: "JavaScript evaluation error: " + e.message + " from `" + expression + "`" ,
//             filename: this.fileInfo().filename,
//             index: this.getIndex() };
//     }
//
//     var variables = context.frames[0].variables();
//     for (var k in variables) {
//         if (variables.hasOwnProperty(k)) {
//             /*jshint loopfunc:true */
//             evalContext[k.slice(1)] = {
//                 value: variables[k].value,
//                 toJS: function () {
//                     return this.value.eval(context).toCSS();
//                 }
//             };
//         }
//     }
//
//     try {
//         result = expression.call(evalContext);
//     } catch (e) {
//         throw { message: "JavaScript evaluation error: '" + e.name + ': ' + e.message.replace(/["]/g, "'") + "'" ,
//             filename: this.fileInfo().filename,
//             index: this.getIndex() };
//     }
//     return result;
// };
  }

  ///
  String jsify(Node obj) {
    if (obj.value is List && obj.value.length > 1) {
      final List<String> result =
          (obj.value as List<Node>).map((Node v) => v.toCSS(null)).toList();
      return "[${result.join(', ')}]";
    } else {
      return obj.toCSS(null);
    }

//2.3.1
//  JsEvalNode.prototype.jsify = function (obj) {
//      if (Array.isArray(obj.value) && (obj.value.length > 1)) {
//          return '[' + obj.value.map(function (v) { return v.toCSS(); }).join(', ') + ']';
//      } else {
//          return obj.toCSS();
//      }
//  };
  }
}
