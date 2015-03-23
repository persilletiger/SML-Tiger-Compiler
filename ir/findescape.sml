signature FINDESCAPE = 
sig
	val findEscape : Absyn.exp -> unit
end

structure FindEscape : FINDESCAPE = 
struct
  type depth = int
  type escEnv = (depth * bool ref) Symbol.table
 
  fun traverseVar(env:escEnv, d:depth, s:Absyn.var) : unit =
      let
        fun trvar(A.SimpleVar(sym,pos)) = () (* TODO *)
          | trvar(A.FieldVar(var, sym,pos)) = () (* TODO *)
          | trvar(A.SubscriptVar(var, exp, pos)) = () (* TODO *)
      in
        trvar s
      end
  and traverseExp(env:escEnv, d:depth, s:Absyn.exp) : unit =
      let
        fun trexp(A.VarExp(var)) = traverseVar(env, d, var)
          | trexp(A.NilExp) = ()
          | trexp(A.IntExp(_)) = ()
          | trexp(A.StringExp(_)) = ()
          | trexp(A.CallExp(_)) = ()
          | trexp(A.OpExp {left, oper, right, pos}) = (trexp left; trexp right)
          | trexp(A.RecordExp {fields, typ, pos}) = 
              let
                fun evalField((sym, exp, pos)) = trexp exp
              in
                app evalField fields
              end
          | trexp(A.SeqExp expList) = 
              let
                fun evalExp((exp, pos)) = trexp exp
              in
                app evalExp expList
              end
          | trexp(A.AssignExp {var, exp, pos}) = 
              (
                traverseVar(env, d, var);
                trexp exp
              )
          | trexp(A.IfExp {test, then', else', pos}) =
              (
                trexp test;
                trexp then';
                case else' of
                     SOME(exp') => trexp exp'
                   | _ => ()
              )
          | trexp(A.WhileExp {test, body, pos}) = (trexp test; trexp body)
          | trexp(A.ForExp {var, escape, lo, hi, body, pos}) =
              ( (* TODO how does escape mean here *)
                (* TODO fix: traverseVar(env, d, var); *)
                trexp lo;
                trexp hi;
                trexp body
              )
          | trexp(A.BreakExp pos) = ()
          | trexp(A.LetExp {decs, body, pos}) = 
              let
                val env' = traverseDecs(env, d, decs);
              in
                traverseExp(env', d, body)
              end
          | trexp(A.ArrayExp {typ, size, init, pos}) = trexp init
      in
        trexp s
      end
  and traverseDecs(env:escEnv, d:depth, s:Absyn.dec list): escEnv = 
      let
        fun trdec(A.FunctionDec(fundec)) = S.empty (* TODO *)
          | trdec(A.VarDec {name, escape, typ, init, pos}) = S.empty (* TODO *)
          | trdec(A.TypeDec(typedec)) = S.empty (* TODO *)
        and foldDecs (dec, env') = trdec dec
      in
        foldl foldDecs env s
      end
  fun findEscape(prog: Absyn.exp): unit = () (* TODO *)
end
