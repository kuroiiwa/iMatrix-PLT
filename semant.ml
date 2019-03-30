(* Semantic checking for the MicroC compiler *)

open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.
   Check each global variable, then check each function *)

let check program =


  let comStype ty = (ty, (-1,-1,-1)) in
(* Raise an exception if the given rvalue type cannot be assigned to
     the given lvalue type *)
  let check_assign lvaluet rvaluet err =
     if lvaluet = rvaluet then lvaluet else raise (Failure err)
  in 


  (* Return a variable from our current symbol table *)
  let type_of_identifier map s =
    try StringMap.find s map
    with Not_found -> raise (Failure ("undeclared identifier " ^ s))
  in

  (* Return a function from our symbol table *)
  let find_func map s = 
    try StringMap.find s map
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in


  let check_ty_list = function
    | [] -> raise(Failure ("internal error: array should not be empty"))
    | (hd :: tl) as orig_lst ->
      let ty = fst hd in 
      let check_type t lst = if t <> (fst lst) then
        raise(Failure ("type in array is not unique")) else ()
      in
      ignore( List.iter (check_type ty) tl);
      (ty, orig_lst)
  in

  let check_ty_list_list = function
    | [] -> raise(Failure ("internal error: array should not be empty"))
    | (hd :: tl) as orig_lst ->
      let ty = fst hd in 
      let check_type t lst = if t <> (fst lst) then
        raise(Failure ("type in array is not unique")) else ()
      in
      ignore(List.iter (check_type ty) tl);
      (ty, List.map (fun (_, l) -> l) orig_lst)
  in

  let check_ty_list_list_list dim = function
    | [] -> raise(Failure ("internal error: array should not be empty"))
    | (hd :: tl) as orig_lst ->
      let ty = fst hd in 
      let check_type t lst = if t <> (fst lst) then
        raise(Failure ("type in array is not unique")) else ()
      in
      ignore(List.iter (check_type ty) tl);
      ((fst ty,dim), SArrVal(List.map (fun (_, l) -> l) orig_lst))
  in

  let rec check_arr3 (v,f) arr3_tmp =
    let (dim, arr3) = arr3_tmp in 
    let (_,_,tmp) = List.fold_left check_arr2 (v,f,[]) arr3 in
    let sarr3 = List.rev tmp in
    check_ty_list_list_list dim sarr3

  and check_arr2 (v,f,lst) arr2 = 
    let (_,_,tmp) = List.fold_left check_arr1 (v,f,[]) arr2 in
    let sarr2 = List.rev tmp in
    (v,f,(check_ty_list_list sarr2) :: lst)

  and check_arr1 (v,f,lst) arr1 =
    let (_,_,tmp) = List.fold_left (fun (v,f,l) e -> (v,f,(check_expr (v,f) e) :: l)) (v,f,[]) arr1 in
    let sarr1 = List.rev tmp in
    (v,f,(check_ty_list sarr1) :: lst)

  (**** Check expr including type and function call correctness ****)
  and check_expr (var_symbols, func_symbols) = function
      Literal  l -> (comStype Int, SLiteral l)
    | Fliteral l -> (comStype Float, SFliteral l)
    | StrLit str -> (comStype String, SStrLit str)
    | CharLit ch -> (comStype Char, SCharLit ch)
    | ArrVal arr -> check_arr3 (var_symbols, func_symbols) arr
    | BoolLit l  -> (comStype Bool, SBoolLit l)
    | Noexpr     -> (comStype Void, SNoexpr)
    | Id s       -> (type_of_identifier var_symbols s, SId s)
    | Assign(var, e) as ex -> 
        let lt = type_of_identifier var_symbols var
        and (rt, e') = check_expr (var_symbols, func_symbols) e in
        let err = "illegal assignment " ^ string_of_styp lt ^ " = " ^ 
          string_of_styp rt ^ " in " ^ string_of_expr ex
        in (check_assign lt rt err, SAssign(var, (rt, e')))
    | Unop(op, e) as ex -> 
        let (t, e') = check_expr (var_symbols, func_symbols) e in
        let ty = match op with
          Neg when t = (comStype Int) || t = (comStype Float) -> t
        | Not when t = (comStype Bool) -> comStype Bool
        | _ -> raise (Failure ("illegal unary operator " ^ 
                               string_of_uop op ^ string_of_styp t ^
                               " in " ^ string_of_expr ex))
        in (ty, SUnop(op, (t, e')))
    | Binop(e1, op, e2) as e -> 
        let (t1, e1') = check_expr (var_symbols, func_symbols) e1 
        and (t2, e2') = check_expr (var_symbols, func_symbols) e2 in
        (* All binary operators require operands of the same type *)
        let same = t1 = t2 in
        (* Determine expression type based on operator and operand types *)
        let ty = match op with
          Add | Sub | Mult | Div | Mod | Pow when same && t1 = (comStype Int)   -> comStype Int
        | Add | Sub | Mult | Div | Pow when same && t1 = (comStype Float) -> comStype Float
        | Equal | Neq            when same               -> comStype Bool
        | Less | Leq | Greater | Geq
                   when same && (t1 = comStype Int || t1 = comStype Float) -> comStype Bool
        | And | Or when same && t1 = comStype Bool -> comStype Bool
        | _ -> raise (
      Failure ("illegal binary operator " ^
                     string_of_styp t1 ^ " " ^ string_of_op op ^ " " ^
                     string_of_styp t2 ^ " in " ^ string_of_expr e))
        in (ty, SBinop((t1, e1'), op, (t2, e2')))
    | Call("print", [e]) -> (comStype Void, SCall("print", [check_expr (var_symbols, func_symbols) e]))
    | Call(fname, args) as call -> 
        let fd = find_func func_symbols fname in
        let param_length = List.length fd.formals in
        if List.length args != param_length then
          raise (Failure ("expecting " ^ string_of_int param_length ^ 
                          " arguments in " ^ string_of_expr call))
        else let check_call (ft, _, d, _) e =
          let (et, e') = check_expr (var_symbols, func_symbols) e in 
          let err = "illegal argument found " ^ string_of_styp et ^
            " expected " ^ string_of_styp (ft,d) ^ " in " ^ string_of_expr e
          in (check_assign (ft, d) et err, e')
        in
        let args' = List.map2 check_call fd.formals args
        in (comStype fd.typ, SCall(fname, args'))
  in

  (**** check dups in bind list auxiliary function ****)
  let check_binds_dup (kind: string) (binds : bind list) =
    let extName = fun (_, id, _, _) -> id in
    let rec dups = function
        [] -> ()
      |  (b1 :: b2 :: _) when (extName b1) = (extName b2) ->
    raise (Failure ("duplicate " ^ kind ^ " " ^ (extName b1)))
      | _ :: t -> dups t
    in dups (List.sort (fun b1 b2 -> compare (extName b1) (extName b2)) binds)
  in

  (**** check dups in global scope ****)
  let check_global_dup (prog : prog_element list) =
    let pick_binds lst = function
      | Globaldcl(dcl) -> dcl :: lst
      | _ -> lst
    in
    let binds_list = List.fold_left pick_binds [] prog in
  check_binds_dup "global" binds_list
  in

  (**** check dups in one local scope ****)
  let pick_binds l = function
      | Dcl(dcl) -> dcl :: l
      | _ -> l
  in
  let check_normal_dup (lst : func_body list) =
    let binds_list = List.fold_left pick_binds [] lst in
  check_binds_dup "local" binds_list
  in
  check_global_dup program;

  (**** check if declaration is void type and if expr is legal ****)
  let check_dcl (var_symbols, func_symbols) (ty, n, d, e) =
    match ty,e with
      | Void,_ -> raise(Failure ("illegal void " ^ n))
      | _,Assign _ -> raise(Failure ("assign in init not supported"))
      | _,Call _ -> raise(Failure ("calling funciton in init not supported"))
      | _ -> ();
    match e with
      | Noexpr -> ((ty, d), n, d, ((Void, (-1,-1,-1)), SNoexpr))
      | _ ->
    let (rt, e') = check_expr (var_symbols, func_symbols) e in
    let err = "illegal assignment " ^ string_of_typ ty ^ " = " ^ 
          string_of_styp rt ^ " in " ^ n ^ " = " ^ string_of_expr e
      in (check_assign (ty, d) rt err, n, d, (rt, e'))
  in


  (**** Collect all built-in functions at first ****)
  let built_in_decls = 
    let add_bind map (name, ty) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty, "x", (-1,-1,-1), Noexpr)];
      body = [] } map
    in List.fold_left add_bind StringMap.empty [
                               ("printbig", Int);
                               ("print", Int) ]
  in

  (**** Add func to func_symbols with error handler ****)
  let add_func map fd = 
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname
    in
    let res = StringMap.mem n map
    in match fd with
         _ when StringMap.mem n built_in_decls -> make_err built_in_err
       | _ when res && (let f = StringMap.find n map in f.body = []) -> StringMap.add n fd map 
       | _ when res && (let f = StringMap.find n map in (f.body <> [] && fd.body <> [])) -> make_err dup_err
(*        | _ when StringMap.mem n map -> make_err dup_err   *)
       | _ ->  StringMap.add n fd map 
  in

  (* Check each function *)
  let check_function (var_symbols, func_symbols) funct =

    let body_dcl = List.fold_left pick_binds [] funct.body in
    check_binds_dup "local" (funct.formals @ body_dcl);

    (**** Check if a expr is bool type ****)
    let check_bool_expr (var_symbols, func_symbols) e = 
      let (t', e') = check_expr (var_symbols, func_symbols) e
      and err = "expected Boolean expression in " ^ string_of_expr e
      in if t' != comStype Bool then raise (Failure err) else (t', e') 
    in


    (* Return a semantically-checked statement i.e. containing sexprs *)
    let rec check_stmt (var_symbols, func_symbols) = function
        Expr e -> SExpr (check_expr (var_symbols, func_symbols) e)
      | If(p, b1, b2) -> SIf(check_bool_expr (var_symbols, func_symbols) p,
                            check_stmt (var_symbols, func_symbols) b1, check_stmt (var_symbols, func_symbols) b2)
      | For(e1, e2, e3, st) ->
    SFor(check_expr (var_symbols, func_symbols) e1, check_bool_expr (var_symbols, func_symbols) e2,
        check_expr (var_symbols, func_symbols) e3, check_stmt (var_symbols, func_symbols) st)
      | While(p, s) -> SWhile(check_bool_expr (var_symbols, func_symbols) p, check_stmt (var_symbols, func_symbols) s)
      | Return e -> let (t, e') = check_expr (var_symbols, func_symbols) e in
        if t = comStype funct.typ then SReturn (t, e') 
        else raise (
    Failure ("return gives " ^ string_of_styp t ^ " expected " ^
       string_of_typ funct.typ ^ " in " ^ string_of_expr e))
      | Block sl -> ignore(check_normal_dup sl); let (_, _, lst) = List.fold_left check_body_ele (var_symbols, func_symbols, []) sl in
        SBlock(List.rev lst)
    (* go through func_body line by line here*)
    and check_body_ele (var_symbols, func_symbols, body_sast) = function
      | Dcl((ty, id, dim, _) as d) -> let dcl = check_dcl (var_symbols, func_symbols) d in
      ((StringMap.add id (ty, dim) var_symbols), func_symbols, SDcl(dcl) :: body_sast)
      | Stmt(st) -> let temp = check_stmt (var_symbols, func_symbols) st in (var_symbols, func_symbols, SStmt(temp) :: body_sast)
    in

    (****      There could be multiple returns in different blocks ****)
    (**** Check all return in all statements ****)
    (**** Return could only be absent in void function ****)
    (**** nothing should follow return ****)
    let ret_absent = ref 1 in
    let followReturn = function
      | (h :: _) -> (function
                      | Return _ -> 1
                      | _ -> 0) h
      | _ -> 0
    in
    let rec check_ret_in_func_body l = function
      | _ when followReturn l = 1 -> raise(Failure ("nothing may follow a return in function " ^ funct.fname))
      | Stmt(Return _ as s) -> ret_absent := 0; s :: l
      | Stmt(Block sl ) -> List.fold_left check_ret_in_func_body [] sl
      | Stmt(If(_, b1, b2))  -> check_ret_in_stmt b1; check_ret_in_stmt b2; l
      | Stmt(While(_, st))  -> check_ret_in_stmt st; l
      | Stmt(For(_, _, _, st))  -> check_ret_in_stmt st; l
      | _ -> l
    and check_ret_in_stmt = function
      | Return _ -> ret_absent := 0; ()
      | Block(stmts) -> ignore(List.fold_left check_ret_in_func_body [] stmts); ()
      | _ -> ()
    in

    let _ = List.fold_left check_ret_in_func_body [] funct.body in

    let isReturnInFunc a = match !a with
      | 1 when funct.typ <> Void -> raise(Failure ("no return in function " ^ funct.fname))
      | _ -> ()
    in
    let () = isReturnInFunc ret_absent in

    let self_var_symbols =
      List.fold_left (fun m (ty, id, dim, _) -> StringMap.add id (ty, dim) m) var_symbols funct.formals in

   (* Check function body line by line while maintaining var and func symbol tables*)
    let (_, _, lst) = List.fold_left check_body_ele (self_var_symbols, func_symbols, []) funct.body in

    (* Return SFunc required in SAST *)
    SFunc{
      styp = comStype funct.typ;
      sfname = funct.fname;
      sformals = List.rev (List.fold_left (fun l d -> let dcl = check_dcl (var_symbols, func_symbols) d in dcl :: l) [] funct.formals);
      sbody = List.rev lst }
  in

(*   make funtion visible to itself : recursion  *)
  let check_prog_ele (var_symbols, func_symbols, prog_sast) = function
    | Globaldcl((ty, id, dim, _) as d) -> let dcl = check_dcl (var_symbols, func_symbols) d in
    ((StringMap.add id (ty,dim) var_symbols), func_symbols, SGlobaldcl(dcl) :: prog_sast)
    | Func(f) -> let new_func_symbols = add_func func_symbols f in
    (var_symbols, new_func_symbols, (check_function (var_symbols, new_func_symbols) f) :: prog_sast)
    | Func_dcl(f) -> let new_func_symbols = add_func func_symbols f in
    (var_symbols, new_func_symbols, prog_sast)

  in

  (* Check program line by line while maintaining var and func symbol tables*)
  let (_, f, lst) = List.fold_left check_prog_ele (StringMap.empty, built_in_decls, []) program in

  let _ = find_func f "main" in (* Ensure "main" is defined *)

  List.rev lst

