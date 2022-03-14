package;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

function BuildITuple(count: Int) {
	const null_pos = Context.currentPos();

	const fields = Context.getBuildFields();
	const toString = [];
	const newArgs = [];
	const newExprs = [];

	for(i in 0...count) {
		const i1 = i + 1;
		toString.push("${this.i" + i1 + "}");

		const indexType = TPath({
			sub: null,
			params: null,
			pack: [],
			name: String.fromCharCode(65 + i)
		});

		fields.push({
			name: "i" + i1,
			pos: null_pos,
			meta: null,
			doc: null,
			access: [APublic],
			kind: FVar(indexType, null)
		});

		fields.push({
			name: "component" + i1,
			pos: null_pos,
			meta: null,
			doc: null,
			access: [APublic, AInline],
			kind: FFun({
				ret: indexType,
				params: null,
				expr: {
					pos: null_pos,
					expr: EReturn({
						pos: null_pos,
						expr: EConst(CIdent("i" + i1))
					})
				},
				args: []
			})
		});

		newArgs.push({
			name: "_i" + i1,
			type: indexType
		});

		newExprs.push({
			pos: null_pos,
			expr: EBinop(OpAssign, {
				pos: null_pos,
				expr: EConst(CIdent("i" + i1))
			}, {
				pos: null_pos, 
				expr: EConst(CIdent("_i" + i1))
			})
		});
	}

	fields.push({
		name: "new",
		pos: null_pos,
		meta: null,
		doc: null,
		access: [APublic, AInline],
		kind: FFun({
			ret: null,
			params: null,
			expr: {
				pos: null_pos,
				expr: EBlock(newExprs)
			},
			args: newArgs
		})
	});

	fields.push({
		name: "toString",
		pos: null_pos,
		meta: null,
		doc: null,
		access: [APublic, AInline],
		kind: FFun({
			ret: null,
			params: null,
			expr: {
				pos: null_pos,
				expr: EReturn({
					pos: null_pos,
					expr: EConst(CString("(" + toString.join(", ") + ")", SingleQuotes))
				})
			},
			args: []
		})
	});

	return fields;
}

function BuildTuple(count: Int) {
	const null_pos = Context.currentPos();

	const fields = Context.getBuildFields();

	const newArgs = [];
	const newExprs = [];

	const typeParams = [];

	var andExprChain = null;
	var orExprChain = null;

	for(i in 0...count) {
		const i1 = i + 1;

		typeParams.push(TPType(TPath({
			pack: [],
			name: String.fromCharCode(65 + i)
		})));

		const eqExpr = {
			pos: null_pos,
			expr: EBinop(OpEq, {
				pos: null_pos,
				expr: EField({
					pos: null_pos,
					expr: EConst(CIdent("this"))
				}, "i" + i1)
			},
			{
				pos: null_pos,
				expr: EField({
					pos: null_pos,
					expr: EConst(CIdent("other"))
				}, "i" + i1)
			})
		};

		const notEqExpr = {
			pos: null_pos,
			expr: EBinop(OpNotEq, {
				pos: null_pos,
				expr: EField({
					pos: null_pos,
					expr: EConst(CIdent("this"))
				}, "i" + i1)
			},
			{
				pos: null_pos,
				expr: EField({
					pos: null_pos,
					expr: EConst(CIdent("other"))
				}, "i" + i1)
			})
		};

		if(andExprChain == null) {
			andExprChain = eqExpr;
		} else {
			andExprChain = {
				pos: null_pos,
				expr: EBinop(OpBoolAnd, andExprChain, eqExpr)
			};
		}

		if(orExprChain == null) {
			orExprChain = notEqExpr;
		} else {
			orExprChain = {
				pos: null_pos,
				expr: EBinop(OpBoolOr, orExprChain, notEqExpr)
			};
		}

		const indexType = TPath({
			sub: null,
			params: null,
			pack: [],
			name: String.fromCharCode(65 + i)
		});

		newArgs.push({
			name: "_i" + i1,
			type: indexType
		});

		newExprs.push({
			pos: null_pos, 
			expr: EConst(CIdent("_i" + i1))
		});
	}

	fields.push({
		name: "new",
		pos: null_pos,
		meta: null,
		doc: null,
		access: [APublic, AInline],
		kind: FFun({
			ret: null,
			params: null,
			expr: {
				pos: null_pos,
				expr: EBinop(OpAssign, {
					pos: null_pos,
					expr: EConst(CIdent("this"))
				}, {
					pos: null_pos,
					expr: ENew({
						sub: null,
						params: null,
						pack: [],
						name: "ITuple" + count
					}, newExprs)
				})
			},
			args: newArgs
		})
	});

	fields.push({
		name: "equals",
		pos: null_pos,
		meta: [
			{ pos: null_pos, params: [{
				pos: null_pos,
				expr: EBinop(OpEq, {
					pos: null_pos,
					expr: EConst(CIdent("A"))
				}, {
					pos: null_pos,
					expr: EConst(CIdent("B"))
				})
			}], name: ":op" }
		],
		doc: null,
		access: [APublic, AInline],
		kind: FFun({
			ret: null,
			params: null,
			expr: { pos: null_pos, expr: EReturn(andExprChain) },
			args: [{
				name: "other",
				type: TPath({
					params: typeParams,
					pack: [],
					name: "Tuple",
					sub: "Tuple" + count
				})
			}]
		})
	});

	fields.push({
		name: "notEquals",
		pos: null_pos,
		meta: [
			{ pos: null_pos, params: [{
				pos: null_pos,
				expr: EBinop(OpNotEq, {
					pos: null_pos,
					expr: EConst(CIdent("A"))
				}, {
					pos: null_pos,
					expr: EConst(CIdent("B"))
				})
			}], name: ":op" }
		],
		doc: null,
		access: [APublic, AInline],
		kind: FFun({
			ret: null,
			params: null,
			expr: { pos: null_pos, expr: EReturn(orExprChain) },
			args: [{
				name: "other",
				type: TPath({
					params: typeParams,
					pack: [],
					name: "Tuple",
					sub: "Tuple" + count
				})
			}]
		})
	});

	return fields;
}

#else

// 1

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(1))
class ITuple1<A> {}

@:forward
@:build(Tuple.BuildTuple(1))
abstract Tuple1<A>(ITuple1<A>) {}

// 2

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(2))
class ITuple2<A,B> {}

@:forward
@:build(Tuple.BuildTuple(2))
abstract Tuple2<A,B>(ITuple2<A,B>) {}

// 3

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(3))
class ITuple3<A,B,C> {}

@:forward
@:build(Tuple.BuildTuple(3))
abstract Tuple3<A,B,C>(ITuple3<A,B,C>) {}

// 4

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(4))
class ITuple4<A,B,C,D> {}

@:forward
@:build(Tuple.BuildTuple(4))
abstract Tuple4<A,B,C,D>(ITuple4<A,B,C,D>) {}

// 5

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(5))
class ITuple5<A,B,C,D,E> {}

@:forward
@:build(Tuple.BuildTuple(5))
abstract Tuple5<A,B,C,D,E>(ITuple5<A,B,C,D,E>) {}

// 6

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(6))
class ITuple6<A,B,C,D,E,F> {}

@:forward
@:build(Tuple.BuildTuple(6))
abstract Tuple6<A,B,C,D,E,F>(ITuple6<A,B,C,D,E,F>) {}

// 7

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(7))
class ITuple7<A,B,C,D,E,F,G> {}

@:forward
@:build(Tuple.BuildTuple(7))
abstract Tuple7<A,B,C,D,E,F,G>(ITuple7<A,B,C,D,E,F,G>) {}

// 8

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(8))
class ITuple8<A,B,C,D,E,F,G,H> {}

@:forward
@:build(Tuple.BuildTuple(8))
abstract Tuple8<A,B,C,D,E,F,G,H>(ITuple8<A,B,C,D,E,F,G,H>) {}

// 9

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(9))
class ITuple9<A,B,C,D,E,F,G,H,I> {}

@:forward
@:build(Tuple.BuildTuple(9))
abstract Tuple9<A,B,C,D,E,F,G,H,I>(ITuple9<A,B,C,D,E,F,G,H,I>) {}

// 10

@:struct
@:nativeGen
@:build(Tuple.BuildITuple(10))
class ITuple10<A,B,C,D,E,F,G,H,I,J> {}

@:forward
@:build(Tuple.BuildTuple(10))
abstract Tuple10<A,B,C,D,E,F,G,H,I,J>(ITuple10<A,B,C,D,E,F,G,H,I,J>) {}

#end
