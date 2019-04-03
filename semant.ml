(* Semantic checking for the MicroC compiler *)

open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.
   Check each global variable, then check each function *)

let check program =


(* Raise an exception if the given rvalue type cannot be assigned to
     the given lvalue type *)
  let rec get_type_arr = function
    | Array(t, _) -> get_type_arr t
    | _ as t -> t
  in

  let check_assign lvaluet rvaluet err = match lvaluet,rvaluet with
    | Mat(0,0),Array(Array(Float,a),b) when a > 0 && b > 0 -> Mat(b,a)
    | Mat(a,b),Array(Array(Float,c),d) when a = d && b = c -> Mat(a,b)
    | Img(0,0,0),Array(Array(Array(Int,a),b),c) when a > 0 && b > 0 && c > 0 -> Img(c,b,a)
    | Img(d,e,f),Array(Array(Array(Int,a),b),c) when a = f && b = e && c = d -> Img(d,e,f)
    | Array(t, 0),Array(_) -> let actual_ty = get_type_arr rvaluet in 
      if actual_ty = t then rvaluet else raise (Failure err)
    | _,_ -> if lvaluet = rvaluet then lvaluet else raise (Failure err)
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

  let check_list_type sarr = match sarr with
    | [] -> raise(Failure ("internal error: array should not be empty"))
    | (hd :: _) ->
      let ty = fst hd in
      let check_type t lst = if t <> (fst lst) then
      raise(Failure ("type in array is not unique")) else ()
      in
      ignore( List.iter (check_type ty) sarr);
      (Array(ty, List.length sarr), SArrVal(sarr))
  in

  let rec array_dim n = function
    | Array(t, _) -> array_dim (n+1) t
    | _ -> n
  in

  let expand_slice slice n = (* n <= 3 *)
      match (n, List.length slice) with
      | (3,1) -> slice @ [(-1,-1)] @ [(-1,-1)]
      | (3,2) | (2,1) -> slice @ [(-1,-1)]
      | _ -> slice
  in

  let slice_helper2 (var: ((int * (int * int)) list)) typ name = 
  (* given input arr/mat/img and input slice, output the range (how many number we will get 
     after slicing and new slice (deal with -1)) *)
    let get_fst var = List.hd var in
    let get_snd var = List.hd (List.tl var) in
    let get_trd var = List.hd (List.tl (List.tl var)) in

    let rec catch_typ = function
      | Array(content, _) -> catch_typ content
      | _ as t -> t
    in
    
    match typ with
    (* the input is a legal slice *)
    | Mat(_) -> (Mat(fst (get_fst var), fst (get_snd var)), 
              SSlice(name, [snd (get_fst var); snd (get_snd var)]))
    | Img(_) -> (Img(fst (get_fst var), fst (get_snd var), fst (get_trd var)),
              SSlice(name, [snd (get_fst var); snd (get_snd var); snd (get_trd var)]))
    | Array(cont,_) -> 
      (match cont with
        | Array(cont2,_) -> (match cont2 with
          |Array(_) -> (Array(Array(Array(catch_typ typ, fst (get_trd var)), fst (get_snd var)), fst (get_fst var)),
            SSlice(name, [snd (get_fst var); snd (get_snd var); snd (get_trd var)]))
          | _ -> (Array(Array(catch_typ typ, fst (get_snd var)), fst (get_fst var)), SSlice(name, [snd (get_fst var); snd (get_snd var)])))
        | _ -> (Array(catch_typ typ, fst (get_fst var)), SSlice(name, [snd (get_fst var)])))
    | _ -> raise(Failure("internal error: slice type match failed"))
  in

  let slice_helper1 n range slicing = match slicing with
    | (-1,-1) -> (range, (0, range-1))
    | (-1,a) when a < range && a > -1 -> (a + 1, (0, a)) 
    | (a,-1) when a < range && a > -1 -> (range - a, (a, range-1))
    | (a,b) when a < range && a > -1 && a < range && a > -1 && a <= b -> (b - a + 1, (a,b))
    | _ -> raise(Failure("illegal slicing at " ^ n))
  in

  let rec slice_helper3 l = function
    (* get array dimension *)
    | Array(t, d) -> slice_helper3 (d :: l) t
    | _ -> List.rev l 
  in

  let rec downgrade_dim = function
    | Array(t,d) when d=1 -> downgrade_dim t
    | _ as t -> t
  in
  
  let check_slice vars n l =
    let ty = type_of_identifier vars n in
    match ty,(List.length l) with

      | Mat(a,b),_ -> 
        let l' = expand_slice l 2 in
        let l_adjusted = [a; b] in
        let legal_slice = List.map2 (slice_helper1 n) l_adjusted l' in
        slice_helper2 legal_slice ty n
      | Img(a,b,c),_ ->
        let l' = expand_slice l 3 in
        let l_adjusted = [a;b;c] in
        let legal_slice = List.map2 (slice_helper1 n) l_adjusted l' in
        slice_helper2 legal_slice ty n
      | Array(_),sn when (array_dim 0 ty) >= sn ->
        let actual_n = array_dim 0 ty in
        let l' = expand_slice l actual_n in
        let l_adjusted = slice_helper3 [] ty in
        let legal_slice = List.map2 (slice_helper1 n) l_adjusted l' in
        let (new_ty, e) = slice_helper2 legal_slice ty n in
        let ty' = downgrade_dim new_ty in
        (ty', e)
      | _,_ -> raise(Failure("illegal slicing"))
  in

  let rec check_arr3 (v,f) arr3 =
    let sarr3 = List.map (check_arr2 (v,f)) arr3 in
    check_list_type sarr3

  and check_arr2 (v,f) arr2 = 
    let sarr2 = List.map (check_arr1 (v,f)) arr2 in
    check_list_type sarr2

  and check_arr1 (v,f) arr1 =
    let sarr1 = List.map (check_expr (v,f)) arr1 in
    check_list_type sarr1

  (**** Check expr including type and function call correctness ****)
  and check_expr (var_symbols, func_symbols) = function
      Literal  l -> (Int, SLiteral l)
    | Fliteral l -> (Float, SFliteral l)
    | StrLit str -> (String, SStrLit str)
    | CharLit ch -> (Char, SCharLit ch)
    | Arr1Val arr -> check_arr1 (var_symbols, func_symbols) arr
    | Arr2Val arr -> check_arr2 (var_symbols, func_symbols) arr
    | Arr3Val arr -> check_arr3 (var_symbols, func_symbols) arr
    | BoolLit l  -> (Bool, SBoolLit l)
    | Noexpr     -> (Void, SNoexpr)
    | Id s       -> (type_of_identifier var_symbols s, SId s)
    | Slice(n, l) -> check_slice var_symbols n l
    | Assign(var, e) as ex -> 
        let lt = type_of_identifier var_symbols var
        and (rt, e') = check_expr (var_symbols, func_symbols) e in
        let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
          string_of_typ rt ^ " in " ^ string_of_expr ex
        in (check_assign lt rt err, SAssign(var, (rt, e')))
    | Unop(op, e) as ex -> 
        let (t, e') = check_expr (var_symbols, func_symbols) e in
        let ty = match op with
          Neg when t = Int || t = Float -> t
        | Not when t = Bool -> Bool
        | _ -> raise (Failure ("illegal unary operator " ^ 
                               string_of_uop op ^ string_of_typ t ^
                               " in " ^ string_of_expr ex))
        in (ty, SUnop(op, (t, e')))
    | Binop(e1, op, e2) as e -> 
        let (t1, e1') = check_expr (var_symbols, func_symbols) e1 
        and (t2, e2') = check_expr (var_symbols, func_symbols) e2 in
        (* All binary operators require operands of the same type *)
        let same = t1 = t2 in
        (* Determine expression type based on operator and operand types *)
        let ty = match op with
          Add | Sub | Mult | Div | Mod | Pow when same && t1 = Int   -> Int
        | Add | Sub | Mult | Div | Pow when same && t1 = Float -> Float
        | Equal | Neq            when same               -> Bool
        | Less | Leq | Greater | Geq
                   when same && (t1 = Int || t1 = Float) -> Bool
        | And | Or when same && t1 = Bool -> Bool
        | _ -> raise (
      Failure ("illegal binary operator " ^
                     string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                     string_of_typ t2 ^ " in " ^ string_of_expr e))
        in (ty, SBinop((t1, e1'), op, (t2, e2')))
    | Call("print", [e]) -> (Void, SCall("print", [check_expr (var_symbols, func_symbols) e]))
    | Call(fname, args) as call -> 
        let fd = find_func func_symbols fname in
        let param_length = List.length fd.formals in
        if List.length args != param_length then
          raise (Failure ("expecting " ^ string_of_int param_length ^ 
                          " arguments in " ^ string_of_expr call))
        else let check_call (ft, _, _) e =
          let (et, e') = check_expr (var_symbols, func_symbols) e in 
          let err = "illegal argument found " ^ string_of_typ et ^
            " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
          in (check_assign ft et err, e')
        in
        let args' = List.map2 check_call fd.formals args
        in (fd.typ, SCall(fname, args'))
  in

  (**** check dups in bind list auxiliary function ****)
  let check_binds_dup (kind: string) (binds : bind list) =
    let extName = fun (_, id, _) -> id in
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
  let check_dcl (var_symbols, func_symbols) (ty, n, e) isGlobal =
    match ty,e with
      | Void,_ -> raise(Failure ("illegal void " ^ n))
      | _,Assign _ -> raise(Failure ("assign in init not allowed"))
      | _,Call _ when isGlobal -> raise(Failure ("calling funciton initializer in global not allowed"))
      | _,Slice _ when isGlobal -> raise(Failure ("slicing initializer in global not allowed"))
      | _ -> ();
    match e with
      | Noexpr -> (ty, n, (Void, SNoexpr))
      | _ ->
    let (rt, e') = check_expr (var_symbols, func_symbols) e in
    let err = "illegal assignment " ^ string_of_typ ty ^ " = " ^ 
          string_of_typ rt ^ " in " ^ n ^ " = " ^ string_of_expr e
      in (check_assign ty rt err, n, (rt, e'))
  in


  (**** Collect all built-in functions at first ****)
  let built_in_decls = 
    let add_bind map (name, ty) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty, "x", Noexpr)];
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
      in if t' != Bool then raise (Failure err) else (t', e') 
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
        if t = funct.typ then SReturn (t, e') 
        else raise (
    Failure ("return gives " ^ string_of_typ t ^ " expected " ^
       string_of_typ funct.typ ^ " in " ^ string_of_expr e))
      | Block sl -> ignore(check_normal_dup sl); let (_, _, lst) = List.fold_left check_body_ele (var_symbols, func_symbols, []) sl in
        SBlock(List.rev lst)
    (* go through func_body line by line here*)
    and check_body_ele (var_symbols, func_symbols, body_sast) = function
      | Dcl((_, id, _) as d) -> let dcl = check_dcl (var_symbols, func_symbols) d false in
      let (t,_,_) = dcl in
      ((StringMap.add id t var_symbols), func_symbols, SDcl(dcl) :: body_sast)
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
      List.fold_left (fun m (ty, id, _) -> StringMap.add id ty m) var_symbols funct.formals in

   (* Check function body line by line while maintaining var and func symbol tables*)
    let (_, _, lst) = List.fold_left check_body_ele (self_var_symbols, func_symbols, []) funct.body in

    (* Return SFunc required in SAST *)
    SFunc{
      styp = funct.typ;
      sfname = funct.fname;
      sformals = List.rev (List.fold_left (fun l d -> let dcl = check_dcl (var_symbols, func_symbols) d false in dcl :: l) [] funct.formals);
      sbody = List.rev lst }
  in

(*   make funtion visible to itself : recursion  *)
  let check_prog_ele (var_symbols, func_symbols, prog_sast) = function
    | Globaldcl((_, id, _) as d) -> let dcl = check_dcl (var_symbols, func_symbols) d true in
      let (t,_,_) = dcl in
    ((StringMap.add id t var_symbols), func_symbols, SGlobaldcl(dcl) :: prog_sast)
    | Func(f) -> let new_func_symbols = add_func func_symbols f in
    (var_symbols, new_func_symbols, (check_function (var_symbols, new_func_symbols) f) :: prog_sast)
    | Func_dcl(f) -> let new_func_symbols = add_func func_symbols f in
    (var_symbols, new_func_symbols, prog_sast)

  in

  (* Check program line by line while maintaining var and func symbol tables*)
  let (_, f, lst) = List.fold_left check_prog_ele (StringMap.empty, built_in_decls, []) program in

  let _ = find_func f "main" in (* Ensure "main" is defined *)

  List.rev lst