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
	var assignmentIndexToName = [];
	var declaredVariables = [];
	var namePositions: Map<String, Position> = [];
	var nameMeta: Map<String, Array<MetadataEntry>> = [];
	var nameOptional: Map<String, Bool> = [];
	var requiredFieldCount = 0;

	var addAssignmentName = function(name, index, meta, optional) {
		if(name == "_") {
			assignmentIndexToName.push(null);
			return;
		} else {
			assignmentIndexToName.push(assignmentNames.length);
		}
		var exists = false;
		for(n in assignmentNames) {
			if(n.name == name) {
				exists = true;
			}
		}
		if(!exists) {
			assignmentNames.push({ name: name, index: index });
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
					addAssignmentName(v.name, index - 1, meta, optional);
					namePositions[v.name] = expr.pos;
				}
			}
			case EConst(c): {
				switch(c) {
					case CIdent(s): {
						addAssignmentName(s, index - 1, meta, optional);
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
							var index = 0;
							for(param in args) {
								if(assignmentIndexToName[index] != null) {
									var i = assignmentIndexToName[index];
									var name = assignmentNames[i].name;
									paramList.push("_" + name);
									if(!nameOptional.exists(name)) {
										matchCount++;
									}
								} else {
									paramList.push("_");
								}
								index++;
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

	var isArray = switch(typeExpr.t) {
		case TInst(classTypeRef, _): classTypeRef.get().name == "Array";
		case _: false;
	}

	var assignExpr = [];
	for(namePos in assignmentNames) {
		// do not explicitly check for field's existance since Haxe will print robust error.
		var name = namePos.name;
		var exprPos = namePositions[name];
		if(enumName != null) {
			assignExpr.push(macro @:pos(exprPos) $i{name} = $i{ "_" + name });
		} else if(isArray) {
			assignExpr.push(macro @:pos(exprPos) $i{name} = temp[$v{namePos.index}]);
		} else {
			var n = "component" + (namePos.index + 1);
			assignExpr.push(macro @:pos(exprPos) $i{name} = temp.$n());
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
