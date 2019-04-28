(* Semantic checking for the MicroC compiler *)

open Ast
open Sast

module StringMap = Map.Make(String)

(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.
   Check each global variable, then check each function *)
exception NotImplemented

let check program =


  (* Raise an exception if the given rvalue type cannot be assigned to
       the given lvalue type *)
  let rec get_type_arr = function
    | Array(t, _) -> get_type_arr t
    | _ as t -> t
  in

(*   check any assign type equality, allow mat-Float array and img-Int array assignment *)
  let check_assign lvaluet rvaluet err = match lvaluet,rvaluet with
    | Mat,Array(Array(Float,a),b) when a > 0 && b > 0 -> Mat
    | Mat,Mat -> Mat
    | Img,Array(Array(Array(Int,a),b),c) when a > 0 && b > 0 && c > 0 -> Img
    | Img,Img -> Img
    | Array(t, 0),Array(_) -> let actual_ty = get_type_arr rvaluet in
      if actual_ty = t then rvaluet else raise (Failure err)
    | _,_ -> if lvaluet = rvaluet then lvaluet else raise (Failure err)
  in


  (* Return a variable from our current symbol table *)
  let type_of_identifier map s =
    try StringMap.find s map
    with Not_found -> raise (Failure ("undeclared identifier " ^ s))
  in

  (* return struct member list  *)
  let check_struct_scope var_symbols n =
    let ty = type_of_identifier var_symbols n in
    (match ty with
     | Struct(_) -> ()
     | _ -> raise(Failure("struct not defined " ^ n))
    )
  in

  (* Return a function from our symbol table *)
  let find_func map s =
    try StringMap.find s map
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in

(*   check if array have same element type *)
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

(*   return array depth 1 or 2 or 3 *)
  let rec array_dim n = function
    | Array(t, _) -> array_dim (n+1) t
    | _ -> n
  in

(*   helper function to expand slicing list *)
  let expand_slice slice n = (* n <= 3 *)
    match (n, List.length slice) with
    | (3,1) -> slice @ [(Literal(-1),Literal(-1))] @ [(Literal(-1),Literal(-1))]
    | (3,2) | (2,1) -> slice @ [(Literal(-1),Literal(-1))]
    | _ -> slice
  in

  (* return to the original AST type based on checked slicing list *)
  let slice_helper2 (var: ((int * (sexpr * sexpr)) list)) typ name =
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
    | Mat -> (Mat,
              SSlice(name, List.map (fun (a,b) -> b) var))
    | Img -> (Img,
              SSlice(name, List.map (fun (a,b) -> b) var))
    | Array(cont,_) ->
      (match cont with
       | Array(cont2,_) -> (match cont2 with
           |Array(_) -> (Array(Array(Array(catch_typ typ, fst (get_trd var)), fst (get_snd var)), fst (get_fst var)),
                         SSlice(name, List.map (fun (a,b) -> b) var))
           | _ -> (Array(Array(catch_typ typ, fst (get_snd var)), fst (get_fst var)), SSlice(name, List.map (fun (a,b) -> b) var)))
       | _ -> (Array(catch_typ typ, fst (get_fst var)), SSlice(name, List.map (fun (a,b) -> b) var)))
    | _ -> raise(Failure("internal error: slice type match failed"))
  in

  (*   generate Int * (sexpr * sexpr) list *)
  let slice_helper1 n range (a',b') =
    let (_, e1) = a' and (_, e2) = b' in
    match e1,e2 with
    | SId(_),SId(_) -> (1, (a', b'))
    | SLiteral(-1),SLiteral(-1) -> (range, ((Int, SLiteral(0)), (Int, SLiteral(range - 1))))
    | SLiteral(-1),SLiteral(a) when a < range && a > -1 -> (a + 1, ((Int, SLiteral(0)), b'))
    | SLiteral(a),SLiteral(-1) when a < range && a > -1 -> (range - a, (a', (Int, SLiteral(range - 1))))
    | SLiteral(a),SLiteral(b) when a < range && a > -1 && a < range && a > -1 && a <= b -> (b - a + 1, (a', b'))
    | _ -> raise(Failure("illegal slicing at " ^ n))
  in

  let rec slice_helper3 l = function
    (* get array dimension *)
    | Array(t, d) -> slice_helper3 (d :: l) t
    | _ -> List.rev l
  in

  (* dereference array depth if possible *)
  let rec downgrade_dim = function
    | Array(t,d) when d=1 -> downgrade_dim t
    | _ as t -> t
  in

  (* mat and img only support single element slicing *)
  let check_equal (((_,a),(_,b)) as tuple) = match a,b with
    | SId(_),SId(_) -> tuple
    | SLiteral(a), SLiteral(b) when a = b -> tuple
    | _ -> raise(Failure("illegal slicing for mat/img"))
  in

  (* check slicing semantic *)
  let rec check_slice (vars, funcs) n l =
    let ty = type_of_identifier vars n in
    let check_slice_expr (a,b) =
      let (t_a, e_a) as ex_a = check_expr (vars, funcs) a
      and (t_b, e_b) as ex_b = check_expr (vars, funcs) b in
      if t_a = Int && t_b = Int then (ex_a, ex_b)
      else raise(Failure("illegal slicing"))
    in
    match ty,(List.length l) with
    | Mat,2 ->
      let l' = List.map check_slice_expr l in
      ignore(List.map check_equal l');
      (Float, SSlice(n, l'))
    | Img,3 ->
      let l' = List.map check_slice_expr l in
      ignore(List.map check_equal l');
      (Int, SSlice(n, l'))
    | Array(_),sn when (array_dim 0 ty) >= sn ->
      let actual_n = array_dim 0 ty in
      let l' = List.map check_slice_expr (expand_slice l actual_n) in
      let l_adjusted = slice_helper3 [] ty in
      let legal_slice = List.map2 (slice_helper1 n) l_adjusted l' in
      let (new_ty, e) = slice_helper2 legal_slice ty n in
      let ty' = downgrade_dim new_ty in
      (ty', e)
    | _,_ -> raise(Failure("illegal slicing"))

  (* check expr in array of depth 3 *)
  and check_arr3 (v,f) arr3 =
    let sarr3 = List.map (check_arr2 (v,f)) arr3 in
    check_list_type sarr3

  and check_arr2 (v,f) arr2 =
    let sarr2 = List.map (check_arr1 (v,f)) arr2 in
    check_list_type sarr2

  and check_arr1 (v,f) arr1 =
    let sarr1 = List.map (check_expr (v,f)) arr1 in
    check_list_type sarr1

  (*  check struct access expresion recursively*)
  and check_struct_access (vars, funcs) e1 e2 =
    let (lt, e1') = check_expr (vars, funcs) e1 in
    let mem_list = match lt with
      | Struct(n, l) -> l
      | _ -> raise(Failure("accessing non struct type"))
    in
    let validTuple (a,b) = a = b in
    match e2 with
    | Id(s) when List.exists (fun (_,n) -> n = s) mem_list ->
      let (ty, _) = List.find (fun (_,n) -> n = s) mem_list in
      (ty, SGetMember((lt,e1'), (ty,SId(s))) )
    | Slice(s,l) when List.exists (fun (_,n) -> n = s) mem_list ->
      let (ty, name) = List.find (fun (_,n) -> n = s) mem_list in
      (match ty with
       | Struct(sn, sl) when List.length l = 1 && validTuple (List.hd l) ->
         let (rt, re) = check_expr (StringMap.add name ty vars, funcs) e2 in
         (ty, SGetMember((lt,e1'), (rt, re)))
       | _ -> let (rt, re) = check_expr (StringMap.add name ty vars, funcs) e2 in
         (rt, SGetMember((lt, e1') ,(rt, re))))
    | Id(s) when List.exists (fun (_,n) -> n = s) mem_list = false -> raise(Failure(string_of_expr e1 ^ " does not have member " ^ s))
    | Slice(s,_) when List.exists (fun (_,n) -> n = s) mem_list = false -> raise(Failure(string_of_expr e1 ^ " does not have member " ^ s))
    | _ -> raise(Failure("illegal expression in struct access at " ^ string_of_expr e1 ^ " " ^ string_of_expr e2))



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
    | GetMember(e1, e2) -> check_struct_access (var_symbols, func_symbols) e1 e2
    | Slice(n, l) -> check_slice (var_symbols,func_symbols) n l
    | StructAssign(e1, e2) as ex ->
      let (lt, le) = check_expr (var_symbols, func_symbols) e1
      and (rt, e') = check_expr (var_symbols, func_symbols) e2 in
      let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^
                string_of_typ rt ^ " in " ^ string_of_expr ex
      in (check_assign lt rt err, SStructAssign((lt, le), (rt, e')))
    | Assign(var, e) as ex ->
      let lt = type_of_identifier var_symbols var
      and (rt, e') = check_expr (var_symbols, func_symbols) e in
      let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^
                string_of_typ rt ^ " in " ^ string_of_expr ex
      in (check_assign lt rt err, SAssign(var, (rt, e')))
    | SliceAssign(var, lst, e) as ex ->
      let (lt, le) = check_expr (var_symbols, func_symbols) (Slice(var, lst))
      and (rt, re) = check_expr (var_symbols, func_symbols) e in
      let slice_list = (match le with
          | SSlice(_, l) -> l
          | _ -> raise(Failure("internal error: slicing assign should be a valid slicing")))
      in
      let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^
                string_of_typ rt ^ " in " ^ string_of_expr ex
      in (check_assign lt rt err, SSliceAssign(var, slice_list, (rt, re)))
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
          Add | Sub | Mult | Div | Mod | Pow
          when same && t1 = Int -> Int
        | Add | Sub | Mult | Div | Pow
          when same && t1 = Float -> Float
        | Equal | Neq
          when same -> Bool
        | Less | Leq | Greater | Geq
          when same && (t1 = Int || t1 = Float) -> Bool
        | And | Or
          when same && t1 = Bool -> Bool
        | Add | Sub | Mult | Div | Matmul
          when same && t1 = Mat -> Mat
        | Add | Sub | Mult | Div
          when same && t1 = Img -> Img
        | _ -> raise (
            Failure ("illegal binary operator " ^
                     string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                     string_of_typ t2 ^ " in " ^ string_of_expr e))
      in (ty, SBinop((t1, e1'), op, (t2, e2')))
    | Call("print", [e]) ->
      (Void, SCall("print", [check_expr (var_symbols, func_symbols) e]))
    | Call("row", [e]) ->
      let e' = check_expr (var_symbols, func_symbols) e in
      let (t, _) = e' in
      (match t with
        | Mat | Img -> (Int, SCall("row", [e']))
        | _ -> raise(Failure("row should have mat/img type")))
    | Call("col", [e]) ->
      let e' = check_expr (var_symbols, func_symbols) e in
      let (t, _) = e' in
      (match t with
        | Mat | Img -> (Int, SCall("col", [e']))
        | _ -> raise(Failure("col should have mat/img type")))
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
      | Struct_dcl(dcl) -> let n = dcl.name in (Int, n, Noexpr) :: lst
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
    ignore(match ty,e with
        | Void,_ -> raise(Failure ("illegal void " ^ n))
        | _,Assign _ -> raise(Failure ("assign in init not allowed"))
        | _,Call _ when isGlobal -> raise(Failure ("calling funciton initializer in global not allowed"))
        | _,Slice _ when isGlobal -> raise(Failure ("slicing initializer in global not allowed"))
        | Array(_) as arr,_ -> let t = get_type_arr arr in
          (match t with
           | Void -> raise(Failure ("illegal void " ^ n))
           | Struct(n,_) -> ignore(check_struct_scope var_symbols n);
             let dim = array_dim 0 arr in
             if dim = 1 && e = Noexpr then () else raise(Failure (n ^ " struct array has initializer or has dimension more than 1"))
           | _ -> ())
        | Struct(n, _),_ -> ignore(check_struct_scope var_symbols n);
          if e <> Noexpr then raise(Failure (n ^ " struct does not support initializer ")) else ()
        | _ -> ());
    match ty,e with
    | Struct(name,_),Noexpr -> let t = type_of_identifier var_symbols name in (t, n, (Void, SNoexpr))
    | Array(Struct(name, _), d), Noexpr -> let t = type_of_identifier var_symbols name in (Array(t, d), n, (Void, SNoexpr))
    | _,Noexpr -> (ty, n, (Void, SNoexpr))
    | _ ->
      let (rt, e') = check_expr (var_symbols, func_symbols) e in
      let err = "illegal assignment " ^ string_of_typ ty ^ " = " ^
                string_of_typ rt ^ " in " ^ n ^ " = " ^ string_of_expr e
      in (check_assign ty rt err, n, (rt, e'))
  in


  (**** Collect all built-in functions at first ****)
  let built_in_decls =
    let collect_formals l =
      let helper (n, lst) ty =
        (n+1, (ty, "x" ^ string_of_int n, Noexpr) :: lst)
      in let (_, res) = (List.fold_left helper (0, []) l)
      in List.rev res
    in
    let add_bind map (fty, name, l) = StringMap.add name {
        typ = fty;
        fname = name;
        formals = collect_formals l;
        body = [] } map
    in List.fold_left add_bind StringMap.empty [
      (Mat,   "malloc_mat",   [Int; Int]);
      (Img,   "malloc_img",   [Int; Int]);
      (Void,  "free_mat",     [Mat]);
      (Void,  "free_img",     [Img]);
      (Mat,   "matAssign",    [Mat; Float]);
      (Img,   "imgAssign",    [Img; Int]);
      (Img,   "aveFilter",    [Img; Int]);
      (Img,   "edgeDetection",[Img; Int]);
      (Img,   "readimg",      [String]);
      ]
  in

  (**** Add func to func_symbols with error handler ****)
  let add_func (var_symbols, map) fd =
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname
    in
    let fixed_typ = (match fd.typ with
      | Struct(name,_) -> type_of_identifier var_symbols name
      | Array(t,_) -> (match get_type_arr t with
        | Struct(name,_) -> raise NotImplemented
        | _ -> fd.typ)
      | _ -> fd.typ)
    in
    let fixed_formals =
      let fix_formal (ty, tmp1, tmp2) = (match ty with
        | Struct(name,_) ->
          let new_ty = type_of_identifier var_symbols name in
          (new_ty, tmp1, tmp2)
        | Array(t,_) -> (match get_type_arr t with
          | Struct(name,_) -> raise NotImplemented
          | _ -> (ty, tmp1, tmp2))
        | _ -> (ty, tmp1, tmp2))
      in List.map fix_formal fd.formals
    in
    let fd_new = {
      typ = fixed_typ;
      fname = fd.fname;
      formals = fixed_formals;
      body = fd.body;
    }
    in
    let res = StringMap.mem n map
    in match fd_new with
      _ when StringMap.mem n built_in_decls -> make_err built_in_err
    | _ when res && (let f = StringMap.find n map in f.body = []) -> StringMap.add n fd_new map
    | _ when res && (let f = StringMap.find n map in (f.body <> [] && fd_new.body <> [])) -> make_err dup_err
    (*        | _ when StringMap.mem n map -> make_err dup_err   *)
    | _ ->  StringMap.add n fd_new map
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

    (**** There could be multiple returns in different blocks ****)
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
      sformals = List.rev (List.fold_left (fun l d -> let dcl = check_dcl (var_symbols, func_symbols) d true in dcl :: l) [] funct.formals);
      sbody = List.rev lst }
  in

  (*   check struct members including scope and fix struct type members *)
  let check_struct (var_symbols, _) struct_dcl =
    check_binds_dup "struct_local" (List.map (fun (t,id) -> (t,id,Noexpr)) struct_dcl.member_list);

    let check_struct_local = (function
        | (Void, _) -> raise(Failure("void struct member in " ^ struct_dcl.name))
        | (Struct(n,_) , nn) -> ignore(check_struct_scope var_symbols n);
          let ty = type_of_identifier var_symbols n in (ty,nn)
        | (Array(orig,d) as arr, n) -> let ty = get_type_arr arr in
          let arr_ty = (match ty with
              | Void -> raise(Failure("void struct member in " ^ struct_dcl.name))
              | Struct(name,_) -> ignore(check_struct_scope var_symbols name);
                let dim = array_dim 0 arr in
                if dim = 1 then type_of_identifier var_symbols name else raise(Failure (n ^ " struct array has dimension more than 1"))
              | _ -> orig
            ) in (Array(arr_ty,d), n)
        | (t, n) -> (t, n)
        (*        | (_, n) -> raise(Failure("illegal struct member definition at " ^ n ^ " in " ^ struct_dcl.name)) *))
    in
    let lst = List.map check_struct_local struct_dcl.member_list in
    ((struct_dcl.name, lst),SStruct_dcl{
        sname = struct_dcl.name;
        smember_list = lst;
      })
  in

  (*   make funtion visible to itself : recursion  *)
  let check_prog_ele (var_symbols, func_symbols, prog_sast) = function
    | Globaldcl((_, id, _) as d) -> let dcl = check_dcl (var_symbols, func_symbols) d true in
      let (t,_,_) = dcl in
      ((StringMap.add id t var_symbols), func_symbols, SGlobaldcl(dcl) :: prog_sast)
    | Func(f) -> let new_func_symbols = add_func (var_symbols, func_symbols) f in
      (var_symbols, new_func_symbols,
        (check_function (var_symbols, new_func_symbols) (find_func new_func_symbols f.fname)) :: prog_sast)
    | Func_dcl(f) -> let new_func_symbols = add_func (var_symbols, func_symbols) f in
      (var_symbols, new_func_symbols, prog_sast)
    | Struct_dcl(dcl) -> let (ty, sdcl) = check_struct (var_symbols, func_symbols) dcl in
      ((StringMap.add (fst ty) (Struct(ty)) var_symbols), func_symbols, sdcl :: prog_sast)

  in

  (* Check program line by line while maintaining var and func symbol tables*)
  let (_, f, lst) = List.fold_left check_prog_ele (StringMap.empty, built_in_decls, []) program in

  let _ = find_func f "main" in (* Ensure "main" is defined *)

  List.rev lst