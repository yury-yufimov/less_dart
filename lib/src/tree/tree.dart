// source: tree.js

library tree.less;

import 'dart:math' as math;
import 'package:path/path.dart' as path;

import '../file_info.dart';
import '../contexts.dart';
import '../functions/functions.dart';
import '../less_error.dart';
import '../less_options.dart';
import '../logger.dart';
import '../output.dart';
import '../data/colors.dart';
import '../data/unit_conversions.dart';
import '../environment/environment.dart';
import '../visitor/visitor_base.dart';

part 'alpha.dart';
part 'anonymous.dart';
part 'assignment.dart';
part 'attribute.dart';
part 'call.dart';
part 'color.dart';
part 'condition.dart';
part 'combinator.dart';
part 'comment.dart';
part 'debug_info.dart';
part 'detached_ruleset.dart';
part 'dimension.dart';
part 'directive.dart';
part 'element.dart';
part 'extend.dart';
part 'expression.dart';
part 'javascript.dart';
part 'js_eval_node_mixin.dart';
part 'import.dart';
part 'keyword.dart';
part 'media.dart';
part 'mixin_call.dart';
part 'mixin_definition.dart';
part 'negative.dart';
part 'node.dart';
part 'operation.dart';
part 'paren.dart';
part 'options.dart';
part 'output_ruleset_mixin.dart';
part 'rule.dart';
part 'ruleset.dart';
part 'quoted.dart';
part 'ruleset_call.dart';
part 'selector.dart';
part 'unicode_descriptor.dart';
part 'unit.dart';
part 'url.dart';
part 'value.dart';
part 'variable.dart';