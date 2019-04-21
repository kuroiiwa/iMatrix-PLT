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

exception NotImplemented
exception InternalError of string

(* translate : Sast.program -> Llvm.module *)
let translate program =
  let context    = L.global_context () in

  (* Create the LLVM compilation module into which
     we will generate code *)
  let the_module = L.create_module context "iMatrix" in

  (* Get types from the context *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and float_t    = L.double_type context
  and void_t     = L.void_type   context in

  let mat_t      = L.pointer_type (L.named_struct_type context "mat")
  and img_t      = L.pointer_type (L.named_struct_type context "img") in

  let string_t   = L.pointer_type i8_t
  and array1_i8_t   = L.pointer_type i8_t
  and array1_i32_t   = L.pointer_type i32_t
  and array1_float_t = L.pointer_type float_t in

  let array2_i8_t   = L.pointer_type array1_i8_t
  and array2_i32_t   = L.pointer_type array1_i32_t 
  and array2_float_t = L.pointer_type array1_float_t in

  let array3_i8_t   = L.pointer_type array2_i8_t 
  and array3_i32_t   = L.pointer_type array2_i32_t 
  and array3_float_t = L.pointer_type array2_float_t in


  (* array type and dimension helper function *)
  let rec get_dim n = function
    | A.Array(t, _) -> get_dim (n+1) t
    | _ -> n
  in
  let rec get_type_arr = function
    | A.Array(t, _) -> get_type_arr t
    | _ as t -> t
  in
  let arr_type_helper t = (get_type_arr t, get_dim 0 t) in


  let pick_struct lst = function
    | SStruct_dcl(stru) -> stru :: lst
    | _ -> lst
  in
  let structs = List.rev (List.fold_left pick_struct [] program) in


  (* generate struct type in struct map *)
  let struct_decls : (L.lltype * (A.typ * string) list) StringMap.t =
    let struct_decl m sdecl =
      let name = sdecl.sname in
      let ltype_of_typ_opt (ty, _) = match ty with
        | A.Struct(n, _) -> let (lty, _) = StringMap.find n m in lty
        | A.Array(_) as t -> let (ty, dim) = arr_type_helper t in
          (match ty,dim with
           | A.Struct(n,_),1 -> let (lty,_) = StringMap.find n m in L.pointer_type lty
           | A.Char,1 ->  array1_i8_t
           | A.Char,2 ->  array2_i8_t
           | A.Char,3 ->  array3_i8_t
           | A.Int,1 ->  array1_i32_t
           | A.Int,2 ->  array2_i32_t
           | A.Int,3 ->  array3_i32_t
           | A.Float,1 -> array1_float_t
           | A.Float,2 -> array2_float_t
           | A.Float,3 -> array3_float_t
           | A.Mat,1 -> L.pointer_type mat_t
           | A.Img,1 -> L.pointer_type img_t
           | _ -> raise(InternalError("array dimension in struct generation")))
        | A.Int   -> i32_t
        | A.Bool  -> i1_t
        | A.Float -> float_t
        | A.Void  -> void_t
        | A.Char  -> i8_t
        | A.String -> string_t
        | A.Mat -> mat_t
        | A.Img -> img_t
      in
      let members = Array.of_list (List.map ltype_of_typ_opt sdecl.smember_list) in
      let struct_typ = L.named_struct_type context name in
      ignore(L.struct_set_body struct_typ members false);
      StringMap.add name (struct_typ, sdecl.smember_list) m
    in 
    List.fold_left struct_decl StringMap.empty structs
  in


  (* Return the LLVM type for a MicroC type *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Float -> float_t
    | A.Void  -> void_t
    | A.Char  -> i8_t
    | A.String -> string_t
    | A.Array(_) as t -> let (ty, dim) = arr_type_helper t in
      (match ty,dim with
       | A.Struct(n,_),1 -> let (lty,_) = StringMap.find n struct_decls in L.pointer_type lty
       | A.Char,1 ->  array1_i8_t
       | A.Char,2 ->  array2_i8_t
       | A.Char,3 ->  array3_i8_t
       | A.Int,1 ->  array1_i32_t
       | A.Int,2 ->  array2_i32_t
       | A.Int,3 ->  array3_i32_t
       | A.Float,1 -> array1_float_t
       | A.Float,2 -> array2_float_t
       | A.Float,3 -> array3_float_t
       | A.Mat,1 -> L.pointer_type mat_t
       | A.Img,1 -> L.pointer_type img_t
       | _ -> raise(InternalError("dimension in type translation"))) 
    | A.Mat -> mat_t
    | A.Img -> img_t
    | A.Struct(n,_) -> let (lty,_) = StringMap.find n struct_decls in lty
  in

  let pick_func lst = function
    | SFunc(func) -> func :: lst
    | _ -> lst
  in
  let functions = List.fold_left pick_func [] program in

  (* functions that are only used internally *)
  let __printf_t : L.lltype = 
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let __printf_func : L.llvalue = 
    L.declare_function "printf" __printf_t the_module in

  let __printIntArr_t : L.lltype =
    L.function_type i32_t [| array3_i32_t ; i32_t ; i32_t ; i32_t |] in
  let __printIntArr_func : L.llvalue =
    L.declare_function "__printIntArr" __printIntArr_t the_module in

  let __printFloatArr_t : L.lltype =
    L.function_type i32_t [| array3_float_t ; i32_t ; i32_t ; i32_t |] in
  let __printFloatArr_func : L.llvalue =
    L.declare_function "__printFloatArr" __printFloatArr_t the_module in

  let __printCharArr_t : L.lltype =
    L.function_type i32_t [| array3_i8_t ; i32_t ; i32_t ; i32_t |] in
  let __printCharArr_func : L.llvalue =
    L.declare_function "__printCharArr" __printCharArr_t the_module in

  let __printMat_t : L.lltype =
    L.function_type i32_t [| mat_t |] in
  let __printMat_func : L.llvalue =
    L.declare_function "printMat" __printMat_t the_module in

  let __printImg_t : L.lltype =
    L.function_type i32_t [| img_t |] in
  let __printImg_func : L.llvalue =
    L.declare_function "printImg" __printImg_t the_module in

  let __setIntArray_t : L.lltype =
    L.function_type i32_t [|i32_t; array3_i32_t ; array3_i32_t ; i32_t ; array1_i32_t |] in
  let __setIntArray_func : L.llvalue =
    L.declare_function "__setIntArray" __setIntArray_t the_module in

  let __setFloArray_t : L.lltype =
    L.function_type i32_t [|i32_t; array3_float_t ; array3_float_t ; i32_t ; array1_i32_t |] in
  let __setFloArray_func : L.llvalue =
    L.declare_function "__setFloArray" __setFloArray_t the_module in

  let __setMat_t : L.lltype =
    L.function_type i32_t [|mat_t; array2_float_t; i32_t; i32_t|] in
  let __setMat_func : L.llvalue =
    L.declare_function "__setMat" __setMat_t the_module in

  let __returnMatVal_t : L.lltype =
    L.function_type float_t [| mat_t; i32_t ; i32_t |] in
  let __returnMatVal_func : L.llvalue =
    L.declare_function "__returnMatVal" __returnMatVal_t the_module in

  let __returnImgVal_t : L.lltype =
    L.function_type i32_t [| img_t; i32_t ; i32_t; i32_t |] in
  let __returnImgVal_func : L.llvalue =
    L.declare_function "__returnImgVal" __returnImgVal_t the_module in

  let __setMatVal_t : L.lltype =
    L.function_type i32_t [| float_t; mat_t; i32_t ; i32_t |] in
  let __setMatVal_func : L.llvalue =
    L.declare_function "__setMatVal" __setMatVal_t the_module in

  let __setImgVal_t : L.lltype =
    L.function_type i32_t [| i32_t; img_t; i32_t ; i32_t; i32_t |] in
  let __setImgVal_func : L.llvalue =
    L.declare_function "__setImgVal" __setImgVal_t the_module in

  let matMul_t : L.lltype = 
    L.function_type mat_t [| mat_t; mat_t|] in
  let matMul_func : L.llvalue = 
    L.declare_function "matMul" matMul_t the_module in

  let aveFilter_t : L.lltype = 
    L.function_type img_t [| img_t; i32_t|] in
  let aveFilter_func : L.llvalue = 
    L.declare_function "aveFilter" aveFilter_t the_module in

  let edgeDetection_t : L.lltype = 
    L.function_type img_t [| img_t ; i32_t|] in
  let edgeDetection_func : L.llvalue = 
    L.declare_function "edgeDetection" edgeDetection_t the_module in 

  (* buult-in functions for users *)
  let builtin_funcs =
    let builtin = [
      ("malloc_mat", A.Mat, L.function_type mat_t [| i32_t; i32_t|]);
      ("malloc_img", A.Img, L.function_type img_t [| i32_t; i32_t|]);
      ("free_mat", A.Void, L.function_type i32_t [| mat_t |]);
      ("free_img", A.Void, L.function_type i32_t [| img_t |])
    ]
    in
    let add_builtit m (n, ty, llty) =
      let func = L.declare_function n llty the_module in
      let decl = { styp = ty; sfname = n; sformals = []; sbody = []; } in
      StringMap.add n (func, decl) m
    in
    List.fold_left add_builtit StringMap.empty builtin
  in

  (* Define each function (arguments and return type) so we can 
     call it even before we've created its body *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types = 
        Array.of_list (List.map (fun (t, _, _) -> ltype_of_typ t) fdecl.sformals)
      in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl builtin_funcs functions in

  (* this lookup function is only for global declarations*)
  let lookup_global m n = try StringMap.find n m
    with Not_found -> raise(InternalError("global var/func should have been defined"))
  in

  (* return llvalue for a expr for inline init (function call and assign not supported)*)
  let rec expr_val g_vars ((_, e) : sexpr) = match e with
      SLiteral i  -> L.const_int i32_t i
    | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
    | SFliteral l -> L.const_float_of_string float_t l
    | SCharLit ch -> L.const_int i8_t (Char.code ch)
    | SStrLit str -> L.define_global str (L.const_stringz context str) the_module 
    | SArrVal arr ->
      let (ty_ele, _) = List.hd arr in
      let arrval = List.map (expr_val g_vars) arr in
      L.define_global "tmp" (L.const_array (ltype_of_typ ty_ele) (Array.of_list arrval)) the_module
    | SSlice(_) -> raise (InternalError("semant should have rejected slicing in init"))
    | SNoexpr     -> L.const_int i32_t 0
    | SId s       -> L.global_initializer (lookup_global g_vars s)
    | SGetMember _ -> raise (InternalError("semant should have rejected get members in init"))
    | SStructAssign(_) -> raise (InternalError("semant should have rejected assign in init"))
    | SAssign (_, _) -> raise (InternalError("semant should have rejected assign in init"))
    | SSliceAssign (_) -> raise (InternalError("semant should have rejected slicing assign in init"))
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
         raise (InternalError("semant should have rejected and/or on float"))
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
       | A.Pow     ->  raise (InternalError("Power for int not supported yet"))
      ) e1' e2'
    | SUnop(op, ((t, _) as e)) ->
      let e' = expr_val g_vars e in
      (match op with
         A.Neg when t = A.Float -> L.const_fneg 
       | A.Neg                  -> L.const_neg
       | A.Not                  -> L.const_not) e'
    | SCall (_, _) -> raise(InternalError("function call init should be rejected by semantic check"))
  in


  let pick_global_dcl lst = function
    | SGlobaldcl(dcl) -> dcl :: lst
    | _ -> lst
  in
  let globals = List.rev (List.fold_left pick_global_dcl [] program) in


  (* zeroinitializer for globals *)
  let rec type_zeroinitializer t = match t with
    | A.Int | A.Bool -> L.const_int (ltype_of_typ t) 0
    | A.Float -> L.const_float (ltype_of_typ t) 0.0
    | A.Char-> L.const_int (ltype_of_typ t) 0
    | A.String -> L.const_pointer_null string_t
    | A.Array(arr_ty, num) -> 
      let arrval = L.const_array (ltype_of_typ arr_ty) (Array.of_list (generate_type_list [] arr_ty num)) in
      let spc = L.define_global "data" arrval the_module in
      L.const_bitcast spc (ltype_of_typ t)
    | A.Struct(_, l) ->
      let lst_sexpr = List.map (fun (ty, id) -> ty) l in
      L.const_named_struct (ltype_of_typ t) (Array.of_list (List.map type_zeroinitializer lst_sexpr))
    | A.Mat | A.Img -> raise(InternalError("mat and img should have malloc init"))
    | _ -> raise(InternalError("type can not be initialized: " ^ A.string_of_typ t))

  and generate_type_list l t n =
    if n = 0 then l
    else generate_type_list ((type_zeroinitializer t) :: l) t (n-1)
  in


  (* Create a map of global variables after creating each *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (t, n, e) =
      let (_, tmp) = e in
      let e' = expr_val m e in
      let init = match tmp,t with
        | SNoexpr,_ -> type_zeroinitializer t
        | _,A.String -> L.const_bitcast e' (ltype_of_typ t)
        | SArrVal(_),_ -> L.const_bitcast e' (ltype_of_typ t)
        | _,A.Mat | _,A.Img -> raise(InternalError("mat and img should have malloc init"))
        | _,_ -> e'
      in 
      StringMap.add n (L.define_global n init the_module) m 
    in
    List.fold_left global_var StringMap.empty globals in


    (* print format for printf linked function *)
  let int_format_str = L.const_bitcast 
      (L.define_global "fmt" (L.const_stringz context "%d\n") the_module) string_t
  and float_format_str = L.const_bitcast 
      (L.define_global "fmt" (L.const_stringz context "%g\n") the_module) string_t
  and char_format_str = L.const_bitcast 
      (L.define_global "fmt" (L.const_stringz context "%c\n") the_module) string_t
  and string_format_str = L.const_bitcast 
      (L.define_global "fmt" (L.const_stringz context "%s\n") the_module) string_t
  in

  let ty_to_format (ty, _) = match ty with
    | A.Int | A.Bool -> int_format_str
    | A.Float -> float_format_str
    | A.Char -> char_format_str
    | A.String -> string_format_str
    | _ -> int_format_str (* Should be rejected before *)
  in

  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.sfname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    (* construct formals *)
    let formal_vars : L.llvalue StringMap.t =
      let add_formal m (t, n, _) p =
        L.set_value_name n p;
        let local = L.build_alloca (ltype_of_typ t) n builder in
        ignore (L.build_store p local builder);
        StringMap.add n local m
      in
      List.fold_left2 add_formal StringMap.empty fdecl.sformals
        (Array.to_list (L.params the_function))
    in

    let rec extDim_helper l = function
      | A.Array(t, d) -> extDim_helper (d :: l) t
      | _ -> l
    in

    (* extract dimension of array as ocaml array*)
    let extDim = function
      | A.Array(_) as ty ->
        let l = List.rev (extDim_helper [] ty) in
        (match List.length l with
         | 1 -> [|List.hd l ; 0 ; 0|]
         | 2 -> [|List.nth l 0 ;  List.nth l 1 ; 0 |]
         | 3 -> [|List.nth l 0 ;  List.nth l 1 ; List.nth l 2 |]
         | _ -> raise(InternalError("extract dimension for zero dimension")))
      | _ -> raise(InternalError("extract dimension for non array type"))
    in

    let lookup m n = try StringMap.find n m
      with Not_found -> StringMap.find n global_vars
    in

    (* copy elements element by element *)
    let rec copy_eles res des n (vars, builder) =
      if n = 0 then ()
      else (
        let new_res = if n <> 1 then L.build_in_bounds_gep res [|L.const_int i32_t 1|] "copytmp" builder else res
        and new_des = if n <> 1 then L.build_in_bounds_gep des [|L.const_int i32_t 1|] "copytmp" builder else des in
        let ele = L.build_load res "tmp" builder in
        ignore(L.build_store ele des builder);
        copy_eles new_res new_des (n-1) (vars, builder)) 
    in

    (* dereference pointer function *)
    let deref builder (des,prev) (a,b) =
      if a = b && prev then (L.build_load des "tmp" builder, true)
      else (des, false)
    in

    (* copy elements element by element *)
    let rec copy_slice_helper2 res des n index_l (vars, builder) =
      if n = 0 then ()
      else (
        let new_res = if n <> 1 then L.build_in_bounds_gep res [|L.const_int i32_t 1|] "copytmp" builder else res
        and new_des = if n <> 1 then L.build_in_bounds_gep des [|L.const_int i32_t 1|] "copytmp" builder else des in
        let tmp_orig = L.build_load res "tmp" builder in
        let slice = copy_slice tmp_orig ([List.nth index_l 1]) (vars, builder) false in
        ignore(L.build_store slice des builder);
        copy_slice_helper2 new_res new_des (n-1) index_l (vars, builder)
      )

    (* copy elements element by element *)
    and copy_slice_helper3 res des n index_l (vars, builder) =
      if n = 0 then ()
      else (
        let new_res = if n <> 1 then L.build_in_bounds_gep res [|L.const_int i32_t 1|] "copytmp" builder else res
        and new_des = if n <> 1 then L.build_in_bounds_gep des [|L.const_int i32_t 1|] "copytmp" builder else des in
        let tmp_orig = L.build_load res "tmp" builder in
        let slice = copy_slice tmp_orig (List.tl index_l) (vars, builder) false in
        ignore(L.build_store slice des builder);
        copy_slice_helper3 new_res new_des (n-1) index_l (vars, builder)
      )

    (* copy slicing for rvalue compatible with mat/img *)
    and copy_slice_opt orig index_l (vars, builder) down = 
      let ltyp = L.type_of orig in
      if ltyp = mat_t then
        let (a,_) = List.hd index_l
        and (b,_) = List.nth index_l 1 in
        let a' = expr (vars, builder) a
        and b' = expr (vars, builder) b in
        L.build_call __returnMatVal_func [| orig; a'; b'|] "" builder
      else if ltyp = img_t then
        let (a,_) = List.hd index_l
        and (b,_) = List.nth index_l 1
        and (c,_) = List.nth index_l 2 in
        let a' = expr (vars, builder) a
        and b' = expr (vars, builder) b 
        and c' = expr (vars, builder) c in
        L.build_call __returnImgVal_func [| orig; a'; b'; c'|] "" builder
      else copy_slice orig index_l (vars, builder) true

      (* copy slicing for array *)
    and copy_slice orig index_l (vars, builder) down =
      let (a,b) = List.hd index_l in
      let len = match a,b with
        | (_,SId(_)),(_,SId(_)) -> 1
        | (_,SLiteral(a')),(_,SLiteral(b')) -> b' - a' + 1 
        | _ -> raise(InternalError("slicing has wrong type")) in
      let res = L.build_in_bounds_gep orig [|expr (vars, builder) a|] "tmp" builder in

      let tmp = L.build_alloca (L.array_type (L.element_type (L.type_of orig)) len) "tmp" builder in  
      let des_tmp = L.build_in_bounds_gep tmp [|L.const_int i32_t 0|] "tmp" builder in
      let des = L.build_bitcast des_tmp (L.type_of res) "tmp" builder in
      ignore(match (List.length index_l) with
          | 1 -> copy_eles res des len (vars, builder)
          | 2 -> copy_slice_helper2 res des len index_l (vars, builder)
          | 3 -> copy_slice_helper3 res des len index_l (vars, builder)
          | _ -> raise(InternalError("slcing should not be empty")));
      if down then let (ret, _) = List.fold_left (deref builder) (des,true) index_l in ret
      else des

    (* accessing struct member function *)
    and getmember (ptr,local_vars,builder) (se1, se2) =
      let (ty,exp) = se1 in
      (* The left part should be the type of struct with 1 dimension at most *)
      let (des, n) = (match exp with
          | SId(s) -> (lookup local_vars s, s)
          | SSlice(s, l) ->
            let (a,_) = List.hd l in
            let pos = expr (local_vars, builder) a in
            let src = L.build_load (lookup local_vars s) "tmp" builder in
            (L.build_in_bounds_gep src [| pos |] "tmp" builder,s)
          | SGetMember(e1, e2) -> getmember (true, local_vars, builder) (e1, e2)
          | _ -> raise(InternalError("accessing non struct member")))
      in
      let bind_l = match ty with
        | A.Struct(_, lst) -> lst
        | _ -> raise(InternalError("accessing non struct member"))
      in
      let list_pos s lst =
        let meet = ref 0 in
        let count (n,s) (_,s') = match s = s' with
          | true -> meet := 1; (n,s)
          | false when !meet = 0 -> (n+1,s)
          | _ ->(n,s)
        in
        let (n, _) = List.fold_left count (0,s) lst
        in n
      in
      let pos = match se2 with
        | (_,SId(s)) -> list_pos s bind_l
        | (_,SSlice(s,_)) -> list_pos s bind_l
        | _ -> raise(InternalError("accessing wrong struct member"))
      in
      let p = L.build_in_bounds_gep des [|L.const_int i32_t 0 ; L.const_int i32_t pos|] "tmp" builder in
      let deref_ptr ptr (a,_) =
        let offset = expr (local_vars, builder) a in
        let des = L.build_load ptr "tmp" builder in
        L.build_in_bounds_gep des [| offset |] "derefptr" builder
      in
      let isPtr = ref ptr in
      let final = match se2 with
        | (_,SId(s)) -> p
        | (slice_type ,SSlice(s,l)) -> (match slice_type with
            | A.Array(_) -> if !isPtr = true then p else
                let orig = L.build_load p "tmp" builder in
                ignore(isPtr := true);
                copy_slice_opt orig l (local_vars, builder) true
            | _ -> List.fold_left deref_ptr p l)
        | _ -> raise(InternalError("getmember error"))
      in

      if !isPtr = true then (final, n)
      else (L.build_load final "tmp" builder, n)

      (* set slicing value compatible with mat/img *)
    and set_slice_opt (local_vars, builder) (dst, index_l, re) ty = 
      let ltyp = L.type_of dst in
      if ltyp = mat_t then
        let e' = expr (local_vars, builder) re in
        let (a,_) = List.hd index_l
        and (b,_) = List.nth index_l 1 in
        let a' = expr (local_vars, builder) a
        and b' = expr (local_vars, builder) b in
        L.build_call __setMatVal_func [| e'; dst; a'; b'|] "" builder
      else if ltyp = img_t then
        let e' = expr (local_vars, builder) re in
        let (a,_) = List.hd index_l
        and (b,_) = List.nth index_l 1
        and (c,_) = List.nth index_l 2 in
        let a' = expr (local_vars, builder) a
        and b' = expr (local_vars, builder) b 
        and c' = expr (local_vars, builder) c in
        L.build_call __setImgVal_func [| e'; dst; a'; b'; c'|] "" builder
      else set_slice (local_vars, builder) (dst, index_l, re) ty 

    and set_slice (local_vars, builder) (dst, lst, re) ty = 
      let create_ptr c builder =
        let tmp = L.build_alloca (L.type_of c) "tmpptr" builder in
        ignore(L.build_store c tmp builder);
        tmp
      in

      let extDim1 = function
        | A.Array(_) as arr -> let (_, n) = arr_type_helper arr in n
        | _ -> 1
      in

      let (t, _) = re in
      let dimdiff = L.const_int i32_t ((List.length lst) - (extDim1 t)) in
      let isComType = function
        | A.Int | A.Float -> true
        | _ -> false in
      let res_tmp = expr (local_vars, builder) re in
      let res = if isComType t then create_ptr res_tmp builder
        else res_tmp in
      let depth = List.length lst in

      let flatten_l = List.rev (List.fold_left (fun l (a,b) -> b :: a :: l) [] lst) in
      let tmp = expr (local_vars, builder) (A.Array(A.Int, List.length flatten_l), SArrVal(flatten_l)) in
      let slice_info = L.build_bitcast tmp array1_i32_t "tmp" builder in
      let (ty, _) = arr_type_helper ty in
      (match ty with
       | A.Int ->
         let res' = L.build_bitcast res array3_i32_t "res" builder
         and des' = L.build_bitcast dst array3_i32_t "des" builder in
         L.build_call __setIntArray_func [| dimdiff; des' ; res' ; L.const_int i32_t depth ; slice_info |] "__setIntArray" builder
       | A.Float -> 
         let res' = L.build_bitcast res array3_float_t "res" builder
         and des' = L.build_bitcast dst array3_float_t "des" builder in
         L.build_call __setFloArray_func [| dimdiff; des' ; res' ; L.const_int i32_t depth ; slice_info |] "__setFloArray" builder
       | _ as t -> raise(InternalError(A.string_of_typ t ^ " type does not support slicing copy")))


      (* group all print function into one *)
    and call_print (local_vars, builder) e =
      let e' = expr(local_vars, builder) e
      and (t, _) = e in
      match t with
      | A.Mat -> L.build_call __printMat_func [| e' |] "" builder
      | A.Img -> L.build_call __printImg_func [| e' |] "" builder
      | A.Array(_) when get_type_arr t = A.Int ->
        let (t,_) = e in
        let ar = extDim t in
        let des = L.build_bitcast e' array3_i32_t "tmp" builder in
        L.build_call __printIntArr_func [| des; L.const_int i32_t ar.(0) ; L.const_int i32_t ar.(1) ; L.const_int i32_t ar.(2) |]
          "" builder
      | A.Array(_) when get_type_arr t = A.Float ->
        let (t,_) = e in
        let ar = extDim t in
        let des = L.build_bitcast e' array3_float_t "tmp" builder in
        L.build_call __printFloatArr_func [| des; L.const_int i32_t ar.(0) ; L.const_int i32_t ar.(1) ; L.const_int i32_t ar.(2) |]
          "" builder
      | A.Array(_) when get_type_arr t = A.Char ->
        let (t,_) = e in
        let ar = extDim t in
        let des = L.build_bitcast e' array3_i8_t "tmp" builder in
        L.build_call __printCharArr_func [| des; L.const_int i32_t ar.(0) ; L.const_int i32_t ar.(1) ; L.const_int i32_t ar.(2) |]
          "" builder
      | _ -> L.build_call __printf_func [| ty_to_format e ; e' |] "" builder


    (* Construct code for an expression; return its value *)
    and expr (local_vars, builder) ((ty, e) : sexpr) = match e with
        SLiteral i  -> L.const_int i32_t i
      | SBoolLit b  -> L.const_int i1_t (if b then 1 else 0)
      | SFliteral l -> L.const_float_of_string float_t l
      | SCharLit ch -> L.const_int i8_t (Char.code ch)
      | SStrLit str -> L.build_global_stringptr str "str" builder
      | SArrVal arr ->
        (* build the array element by element, might be optimized *)
        let arr_helper builder ptr lvalue =
          ignore(L.build_store lvalue ptr builder);
          L.build_in_bounds_gep ptr [|L.const_int i32_t 1|] "tmp" builder
        in
        let (ty_ele, _) = List.hd arr in
        let arrval = List.map (expr (local_vars,builder)) arr in
        let ptr_tmp = L.build_alloca (L.array_type (ltype_of_typ ty_ele) (List.length arrval)) "tmp" builder in
        let ptr = L.build_bitcast ptr_tmp (ltype_of_typ ty) "tmp" builder in
        ignore(List.fold_left (arr_helper builder) ptr arrval);
        ptr
      | SSlice(d, index_l) ->
        let orig = L.build_load (lookup local_vars d) d builder in
        copy_slice_opt orig index_l (local_vars, builder) true
      | SNoexpr     -> L.const_int i32_t 0
      | SId s       -> L.build_load (lookup local_vars s) s builder
      | SGetMember (se1, se2) ->
        let (res, _) = getmember (false, local_vars, builder) (se1, se2) in
        res
      | SStructAssign(se1, se2) -> 
        let (se1', se2') = (match se1 with
            | (_,SGetMember(a,b)) -> (a,b)
            | _ -> raise (InternalError("internal error: struct assign"))) in
        let (des, _) = getmember (true, local_vars, builder) (se1', se2') in
        let (t,_) = se2 in
        (match ty,t,se2' with
         | A.Array(_),_,(_, SSlice(_, slice_l)) -> 
           let dst = L.build_load des "tmp" builder in
           set_slice (local_vars, builder) (dst, slice_l, se2) ty
         | A.Mat,A.Array(_),_ ->
          let e' = expr (local_vars, builder) se2 in
          let dst = L.build_load des "tmp" builder in
          let ar = extDim t in
          L.build_call __setMat_func [| dst; e'; L.const_int i32_t ar.(0);  L.const_int i32_t ar.(1)|] "__setMat" builder
         | A.Img,_,_ -> raise NotImplemented
         | _ -> let e' = expr (local_vars, builder) se2 in
           ignore(L.build_store e' des builder); e')

      | SAssign (s, e) -> 
        let e' = expr (local_vars, builder) e in
        let (t,_) = e in
        let des = L.build_load (lookup local_vars s) s builder in
        if L.type_of des = mat_t then
          (match t with
            | A.Mat -> L.build_store e' (lookup local_vars s) builder
            | A.Array(_) ->
          let ar = extDim t in
          L.build_call __setMat_func [| des; e'; L.const_int i32_t ar.(0);  L.const_int i32_t ar.(1)|] "__setMat" builder
            | _ -> raise(InternalError("Assign type failure"))
          )
        else if L.type_of des = img_t then
          raise NotImplemented
        else
          L.build_store e' (lookup local_vars s) builder
      | SSliceAssign (v, lst, e) ->
        let des = L.build_load (lookup local_vars v) v builder in
        set_slice_opt (local_vars, builder) (des, lst, e) ty 

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
           raise (InternalError "internal error: semant should have rejected and/or on float")
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
         | A.Pow     ->  raise (InternalError "internal error: Power for int not supported yet")
        ) e1' e2' "tmp" builder
      | SUnop(op, ((t, _) as e)) ->
        let e' = expr (local_vars, builder) e in
        (match op with
           A.Neg when t = A.Float -> L.build_fneg 
         | A.Neg                  -> L.build_neg
         | A.Not                  -> L.build_not) e' "tmp" builder
      | SCall ("print", [e]) ->
        call_print (local_vars, builder) e
      | SCall ("matMul", [e1;e2]) ->
        let e1' = expr (local_vars, builder) e1 in
        let e2' = expr (local_vars, builder) e2 in
        let des1 = L.build_bitcast e1' mat_t "tmp" builder in
        let des2 = L.build_bitcast e2' mat_t "tmp" builder in
        L.build_call matMul_func [| des1; des2 |] "matMul" builder
      | (SCall ("aveFilter", [e1;e2]) | SCall("edgeDetection", [e1;e2])) as f->
        let e1' = expr (local_vars, builder) e1 in
        let e2' = expr (local_vars, builder) e2 in
        let des1 = L.build_bitcast e1' img_t "tmp" builder in
        let des2 = L.build_bitcast e2' i32_t "tmp" builder in
        (match f with
         | SCall ("aveFilter",_) -> L.build_call aveFilter_func [| des1; des2 |] "aveFilter" builder
         | SCall ("edgeDetection",_) -> L.build_call edgeDetection_func [| des1; des2 |] "edgeDetection" builder
         | _ -> raise(InternalError("internel error: unsupported function detected")))
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


    (* zeroinitializer for local vars *)
    and local_type_zeroinitializer des builder t = match t with
      | A.Int | A.Bool -> L.build_store (L.const_int (ltype_of_typ t) 0) des builder
      | A.Float -> L.build_store (L.const_float (ltype_of_typ t) 0.0) des builder
      | A.Char-> L.build_store (L.const_int (ltype_of_typ t) 0) des builder
      | A.String -> L.build_store (L.const_pointer_null string_t) des builder
      | A.Array(arr_ty, num) ->
        let store_helper builder ptr t =
          ignore(local_type_zeroinitializer ptr builder t);
          L.build_in_bounds_gep ptr [|L.const_int i32_t 1|] "tmp" builder
        in

        let ty_l = gen_type_list [] arr_ty num in
        let spc = L.build_alloca (L.array_type (ltype_of_typ arr_ty) num) "data" builder in
        let ptr = L.build_bitcast spc (ltype_of_typ t) "tmp" builder in

        ignore(List.fold_left (store_helper builder) ptr ty_l);
        L.build_store ptr des builder

      | A.Struct(_, l) -> 
        let store_helper builder des (t,n) =
          let ptr = L.build_in_bounds_gep des [| L.const_int i32_t 0 ; L.const_int i32_t n|] "tmp" builder in
          local_type_zeroinitializer ptr builder t
        in
        let (_, tmp) = List.fold_left (fun (n,l) (ty, _) -> (n+1, (ty,n) :: l)) (0,[]) l in
        let lst_ty = List.rev tmp in
        ignore(List.map (store_helper builder des) lst_ty);
        des
      | A.Mat -> L.build_store (L.const_pointer_null mat_t) des builder
      | A.Img -> raise NotImplemented
      | _ -> raise(InternalError("type can not be initialized: " ^ A.string_of_typ t))

    and gen_type_list l t n =
      if n = 0 then l
      else gen_type_list (t :: l) t (n-1)

      (* local declarations generation *)
    and add_local (local_vars , builder) (t, n, e) =
      let local_var = L.build_alloca (ltype_of_typ t) n builder in
      let (_, tmp) = e in
      let () = match tmp,t with
        | SNoexpr,_ -> ignore(local_type_zeroinitializer local_var builder t);()
        | SStrLit str,_ -> ignore(L.build_store (L.build_global_stringptr str "str" builder) local_var builder); ()
        | _ -> let e' = expr (local_vars, builder) e in ignore(L.build_store e' local_var builder); ()
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
  ignore(L.dump_module the_module);
  the_module
