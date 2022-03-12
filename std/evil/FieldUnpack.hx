package evil;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.ExprTools;
using haxe.macro.PositionTools;
using haxe.macro.TypeTools;

macro function unpack(input: Expr, exprs: Array<Expr>) {
	var pos = Context.currentPos();

	var assignmentNames = [];
	var declaredVariables = [];
	var namePositions: Map<String, Position> = [];
	var nameMeta: Map<String, Array<MetadataEntry>> = [];
	var nameOptional: Map<String, Bool> = [];
	var requiredFieldCount = 0;

	var addAssignmentName = function(name, meta, optional) {
		if(!assignmentNames.contains(name)) {
			assignmentNames.push(name);
			if(meta != null) nameMeta[name] = meta;
			if(optional) {
				nameOptional[name] = true;
			} else {
				requiredFieldCount++;
			}
		} else {
			Context.error('Multiple instances of \'${name}\' are attemping to be unpacked', pos);
		}
	};

	var index = 1;
	for(expr in exprs) {
		var internalExpr = expr;

		var meta: Null<Array<MetadataEntry>> = null;
		var optional = false;

		while(switch(internalExpr.expr) {
			case EMeta(s, e): {
				if(meta == null) {
					meta = [];
				}
				meta.push(s);
				if(!optional && s.name == ":optional") {
					optional = true;
				}
				internalExpr = e;
				true;
			}
			case _: false;
		}) {}

		switch(internalExpr.expr) {
			case EVars(vars): {
				declaredVariables.push({
					expr: EVars(vars.map(v -> {
						v.expr = optional ? { expr: EConst(CIdent("null")), pos: pos } : null;
						v;
					})),
					pos: expr.pos
				});
				for(v in vars) {
					addAssignmentName(v.name, meta, optional);
					namePositions[v.name] = expr.pos;
				}
			}
			case EConst(c): {
				switch(c) {
					case CIdent(s): {
						addAssignmentName(s, meta, optional);
						namePositions[s] = expr.pos;
					}
					case _: {
						Context.error('Unpack parameter #$index \'${expr.toString()}\' is not a valid identifier', expr.pos);
					}
				}
			}
			case _: {
				Context.error('Unpack parameter #$index \'${expr.toString()}\' is neither an EVars or EConst(CIdent)', expr.pos);
			}
		}
		index++;
	}

	var typeExpr = Context.typeExpr(input);
	var resultExprs = [];

	for(declared in declaredVariables) {
		resultExprs.push(macro @:pos(pos) $declared);
	}

	var enumSwitchCases: Null<Array<Case>> = null;
	var enumName = switch(typeExpr.t) {
		case TEnum(enumTypeRef, _): {
			var enumType = enumTypeRef.get();
			for(enumChoiceName in enumType.names) {
				var enumChoice = enumType.constructs[enumChoiceName];
				var paramList = [];
				var matchCount = 0;
				if(enumChoice != null) {
					switch(enumChoice.type) {
						case TFun(args, _): {
							for(param in args) {
								if(assignmentNames.contains(param.name)) {
									paramList.push("_" + param.name);
									if(!nameOptional.exists(param.name)) {
										matchCount++;
									}
								} else {
									paramList.push("_");
								}
							}
							if(matchCount == requiredFieldCount) {
								if(enumSwitchCases == null) enumSwitchCases = [];
								enumSwitchCases.push({
									values:  [ macro $i{ enumChoice.name }($a{ paramList.map(p -> macro $i{p}) }) ]
								});
							}
						}
						case _:
					}
					
				}
			}
			enumType.name;
		}
		case _: null;
	}

	var assignExpr = [];
	for(name in assignmentNames) {
		// do not explicitly check for field's existance since Haxe will print robust error.
		var exprPos = namePositions[name];
		if(enumName != null) {
			assignExpr.push(macro @:pos(exprPos) $i{name} = $i{ "_" + name });
		} else {
			assignExpr.push(macro @:pos(exprPos) $i{name} = temp.$name);
		}
	}

	if(enumName != null) {
		if(enumSwitchCases == null) {
			Context.error('Unpack of instance of $enumName failed as no option matches every desired field.', pos);
		}

		var cases = enumSwitchCases.map(c -> {
			{ values: c.values, expr: macro $b{assignExpr}, guard: null }
		});

		if(requiredFieldCount > 0) {
			var errorText = 'Provided enum instance of $enumName does not contain option with all desired fields.';
			cases.push({ values: [ macro _ ], expr: macro @:pos(pos) {
				throw $v{errorText};
			}, guard: null });
		} else {
			cases.push({ values: [ macro _ ], expr: macro @:pos(pos) {}, guard: null });
		}

		var switchExpr = {
			expr: ESwitch(macro temp, cases, null),
			pos: pos
		};

		resultExprs.push(macro @:pos(pos) @:finalAccess {
			var temp = $input;
			$switchExpr;
			temp;
		});
	} else {
		resultExprs.push(macro @:pos(pos) @:finalAccess {
			var temp = $input;
			$b{assignExpr};
			temp;
		});
	}

	return macro @:mergeBlock $b{resultExprs};
}
