(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast
open Sast 

module StringMap = Map.Make(String)

(* translate : Sast.program -> Llvm.module *)
let translate program =
  let context    = L.global_context () in
  
  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "MicroC" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context in

  let string_t   = L.pointer_type i8_t  in

  (* Return the LLVM type for a MicroC type *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | A.Char  -> i8_t
    | A.String -> string_t
  in

  let pick_func lst = function
    | SFunc(func) -> func :: lst
    | _ -> lst
  in
  let functions = List.fold_left pick_func [] program in

  (* Define each function (arguments and return type) so we can 
     call it even before we've created its body *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types = 
  Array.of_list (List.map (fun (t, _, _, _) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in

  (* this lookup function is only for global declarations*)
  let lookup_global m n = try StringMap.find n m
                 with Not_found -> raise(Failure ("internal error: global var/func should have been defined"))
  in

  (* return llvalue for a expr for inline init (function call and assign not supported)*)
  let rec expr_val g_vars ((_, e) : sexpr) = match e with
        SLiteral i  -> L.const_int i32_t i
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      | SCharLit ch -> L.const_int i8_t (Char.code ch)
      | SStrLit str -> L.define_global str (L.const_stringz context str) the_module 
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       -> lookup_global g_vars s
      | SAssign (_, _) -> raise (Failure "internal error: semant should have rejected assign in init")
      | SBinop ((A.Float,_ ) as e1, op, e2) ->
    let e1' = expr_val g_vars e1
    and e2' = expr_val g_vars e2 in
    (match op with 
      A.Add     -> L.const_fadd 
    | A.Sub     -> L.const_fsub
    | A.Mult    -> L.const_fmul
    | A.Div     -> L.const_fdiv 
    | A.Equal   -> L.const_fcmp L.Fcmp.Oeq
    | A.Neq     -> L.const_fcmp L.Fcmp.One
    | A.Less    -> L.const_fcmp L.Fcmp.Olt
    | A.Leq     -> L.const_fcmp L.Fcmp.Ole
    | A.Greater -> L.const_fcmp L.Fcmp.Ogt
    | A.Geq     -> L.const_fcmp L.Fcmp.Oge
    | A.And | A.Or | A.Mod | A.Pow ->
        raise (Failure "internal error: semant should have rejected and/or on float")
    ) e1' e2'
      | SBinop (e1, op, e2) ->
    let e1' = expr_val g_vars e1
    and e2' = expr_val g_vars e2 in
    (match op with
      A.Add     -> L.const_add
    | A.Sub     -> L.const_sub
    | A.Mult    -> L.const_mul
    | A.Div     -> L.const_sdiv
    | A.Mod     -> L.const_srem
    | A.And     -> L.const_and
    | A.Or      -> L.const_or
    | A.Equal   -> L.const_icmp L.Icmp.Eq
    | A.Neq     -> L.const_icmp L.Icmp.Ne
    | A.Less    -> L.const_icmp L.Icmp.Slt
    | A.Leq     -> L.const_icmp L.Icmp.Sle
    | A.Greater -> L.const_icmp L.Icmp.Sgt
    | A.Geq     -> L.const_icmp L.Icmp.Sge
    | A.Pow     ->  raise (Failure "internal error: Power for int not supported yet")
    ) e1' e2'
      | SUnop(op, ((t, _) as e)) ->
          let e' = expr_val g_vars e in
    (match op with
      A.Neg when t = A.Float -> L.const_fneg 
    | A.Neg                  -> L.const_neg
    | A.Not                  -> L.const_not) e'
      | SCall (_, _) -> raise(Failure ("internal error:function call should be rejected by semantic check"))
  in


  let pick_global_dcl lst = function
    | SGlobaldcl(dcl) -> dcl :: lst
    | _ -> lst
  in
  let globals = List.rev (List.fold_left pick_global_dcl [] program) in

  let null_t = L.define_global "__null" (L.const_stringz context "") the_module in 

  (* Create a map of global variables after creating each *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n, _, e) =
      let (_, tmp) = e in
      let e' = expr_val m e in
      let init = match tmp,t with
          SNoexpr,A.Float -> L.const_float (ltype_of_typ t) 0.0
        | SNoexpr,A.Int | SNoexpr,A.Bool -> L.const_int (ltype_of_typ t) 0
        | SNoexpr,A.Char -> L.const_int (ltype_of_typ t) 0
        | SNoexpr,A.String -> L.const_bitcast null_t string_t
        | SNoexpr,_ -> L.const_int (ltype_of_typ t) 0
        | _,A.String -> L.const_bitcast e' string_t
        | _,_ -> e'
      in 
      StringMap.add n (L.define_global n init the_module) m 
    in
    List.fold_left global_var StringMap.empty globals in

  let printf_t : L.lltype = 
      L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue = 
      L.declare_function "printf" printf_t the_module in

  let printbig_t : L.lltype =
      L.function_type i32_t [| i32_t |] in
  let printbig_func : L.llvalue =
      L.declare_function "printbig" printbig_t the_module in

  
 (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
    and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder 
    and char_format_str = L.build_global_stringptr "%c\n" "fmt" builder 
    and string_format_str = L.build_global_stringptr "%s\n" "fmt" builder in

    let ty_to_format (ty, _) = match ty with
      | A.Int | A.Bool -> int_format_str
      | A.Float -> float_format_str
      | A.Char -> char_format_str
      | A.String -> string_format_str
      | _ -> int_format_str (* Should be rejected before *)
    in

    let formal_vars : L.llvalue StringMap.t =
      let add_formal m (t, n, _, _) p =
        L.set_value_name n p;
        let local = L.build_alloca (ltype_of_typ t) n builder in
          ignore (L.build_store p local builder);
        StringMap.add n local m
      in
    List.fold_left2 add_formal StringMap.empty fdecl.sformals
          (Array.to_list (L.params the_function))
    in


    let lookup m n = try StringMap.find n m
                   with Not_found -> StringMap.find n global_vars
    in

    (* Construct code for an expression; return its value *)
    let rec expr (local_vars, builder) ((_, e) : sexpr) = match e with
        SLiteral i  -> L.const_int i32_t i
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      | SCharLit ch -> L.const_int i8_t (Char.code ch)
      | SStrLit str -> L.build_global_stringptr str "str" builder
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       -> L.build_load (lookup local_vars s) s builder
      | SAssign (s, e) -> let e' = expr (local_vars, builder) e in
                          ignore(L.build_store e' (lookup local_vars s) builder); e'
      | SBinop ((A.Float,_ ) as e1, op, e2) ->
    let e1' = expr (local_vars, builder) e1
    and e2' = expr (local_vars, builder) e2 in
    (match op with 
      A.Add     -> L.build_fadd
    | A.Sub     -> L.build_fsub
    | A.Mult    -> L.build_fmul
    | A.Div     -> L.build_fdiv 
    | A.Equal   -> L.build_fcmp L.Fcmp.Oeq
    | A.Neq     -> L.build_fcmp L.Fcmp.One
    | A.Less    -> L.build_fcmp L.Fcmp.Olt
    | A.Leq     -> L.build_fcmp L.Fcmp.Ole
    | A.Greater -> L.build_fcmp L.Fcmp.Ogt
    | A.Geq     -> L.build_fcmp L.Fcmp.Oge
    | A.And | A.Or | A.Mod | A.Pow->
        raise (Failure "internal error: semant should have rejected and/or on float")
    ) e1' e2' "tmp" builder
      | SBinop (e1, op, e2) ->
    let e1' = expr (local_vars, builder) e1
    and e2' = expr (local_vars, builder) e2 in
    (match op with
      A.Add     -> L.build_add
    | A.Sub     -> L.build_sub
    | A.Mult    -> L.build_mul
    | A.Div     -> L.build_sdiv
    | A.Mod     -> L.build_srem
    | A.And     -> L.build_and
    | A.Or      -> L.build_or
    | A.Equal   -> L.build_icmp L.Icmp.Eq
    | A.Neq     -> L.build_icmp L.Icmp.Ne
    | A.Less    -> L.build_icmp L.Icmp.Slt
    | A.Leq     -> L.build_icmp L.Icmp.Sle
    | A.Greater -> L.build_icmp L.Icmp.Sgt
    | A.Geq     -> L.build_icmp L.Icmp.Sge
    | A.Pow     ->  raise (Failure "internal error: Power for int not supported yet")
    ) e1' e2' "tmp" builder
      | SUnop(op, ((t, _) as e)) ->
          let e' = expr (local_vars, builder) e in
    (match op with
      A.Neg when t = A.Float -> L.build_fneg 
    | A.Neg                  -> L.build_neg
    | A.Not                  -> L.build_not) e' "tmp" builder
      | SCall ("print", [e]) ->
        L.build_call printf_func [| ty_to_format e ; (expr (local_vars, builder) e) |]
        "printf" builder
      | SCall ("printbig", [e]) ->
    L.build_call printbig_func [| (expr (local_vars, builder) e) |] "printbig" builder
      | SCall (f, args) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
   let llargs = List.rev (List.map (expr (local_vars, builder)) (List.rev args)) in
   let result = (match fdecl.styp with 
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder
    in


    (* LLVM insists each basic block end with exactly one "terminator" 
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
    let add_terminal (_, builder) instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in

    (* Build the code for the given statement; return the builder for
       the statement's successor (i.e., the next instruction will be built
       after the one generated by this call) *)

    let rec stmt (local_vars, builder) = function
        SBlock sl -> List.fold_left build_stmt (local_vars, builder) sl
      | SExpr e -> ignore(expr (local_vars, builder) e); (local_vars, builder)
      | SReturn e -> ignore(match fdecl.styp with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder 
                              (* Build return statement *)
                            | _ -> L.build_ret (expr (local_vars, builder) e) builder );
                     (local_vars, builder)
      | SIf (predicate, then_stmt, else_stmt) ->
        let bool_val = expr (local_vars, builder) predicate in
        let merge_bb = L.append_block context "merge" the_function in
        let build_br_merge = L.build_br merge_bb in (* partial function *)

   let then_bb = L.append_block context "then" the_function in
   add_terminal (stmt (local_vars, L.builder_at_end context then_bb) then_stmt)
     build_br_merge;

   let else_bb = L.append_block context "else" the_function in
   add_terminal (stmt (local_vars, L.builder_at_end context else_bb) else_stmt)
     build_br_merge;

   ignore(L.build_cond_br bool_val then_bb else_bb builder);
   (local_vars, L.builder_at_end context merge_bb)

      | SWhile (predicate, body) ->
    let pred_bb = L.append_block context "while" the_function in
    ignore(L.build_br pred_bb builder);

    let body_bb = L.append_block context "while_body" the_function in
    add_terminal (stmt (local_vars, L.builder_at_end context body_bb) body)
      (L.build_br pred_bb);

    let pred_builder = L.builder_at_end context pred_bb in
    let bool_val = expr (local_vars, pred_builder) predicate in

    let merge_bb = L.append_block context "merge" the_function in
    ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
    (local_vars, L.builder_at_end context merge_bb)

      (* Implement for loops as while loops *)
      | SFor (e1, e2, e3, body) -> stmt (local_vars, builder)
      ( SBlock [SStmt(SExpr e1) ; SStmt(SWhile (e2, SBlock [SStmt(body) ; SStmt(SExpr e3)])) ] )


    and add_local (local_vars , builder) (t, n, _, e) =
      let local_var = L.build_alloca (ltype_of_typ t) n builder in
      let (_, tmp) = e in
      let () = match tmp with
        | SNoexpr -> ()
        | SStrLit str -> ignore(L.build_store (L.build_global_stringptr str "str" builder) local_var builder); ()
        | _ -> let e' = expr_val local_vars e in ignore(L.build_store e' local_var builder); ()
      in
      (StringMap.add n local_var local_vars, builder)

    and build_stmt (local_vars, builder) = function
      | SDcl(dcl) -> add_local (local_vars, builder) dcl
      | SStmt(st) -> let (_, b) = stmt (local_vars, builder) st in (local_vars, b)
    in

    let (_, builder) = List.fold_left build_stmt (formal_vars, builder) fdecl.sbody in

    (* Add a return if the last block falls off the end *)
    add_terminal (formal_vars, builder) (match fdecl.styp with
        A.Void -> L.build_ret_void
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

  List.iter build_function_body functions;
  the_module
