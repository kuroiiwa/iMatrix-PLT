(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sarr_val = sexpr list
and sexpr = typ * sx
and sx =
    SLiteral of int
  | SFliteral of string
  | SBoolLit of bool
  | SStrLit of string
  | SCharLit of char
  | SArrVal of sarr_val
  | SId of string
  | SSlice of string * ((int * int) list)
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SAssign of string * sexpr
  | SSliceAssign of string * ((int * int) list) * sexpr
  | SCall of string * sexpr list
  | SNoexpr

type sbind =  typ * string * sexpr

type sstmt =
    SBlock of sbody list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SFor of sexpr * sexpr * sexpr * sstmt
  | SWhile of sexpr * sstmt
and sbody = SStmt of sstmt
           | SDcl of sbind

type sfunc_decl = {
    styp : typ;
    sfname : string;
    sformals : sbind list;
    sbody : sbody list;
  }

type sprog_element = SGlobaldcl of sbind
                  | SFunc of sfunc_decl

type sprogram = sprog_element list

(* Pretty-printing functions *)

let rec string_of_sexpr (t, e) =
  "(" ^ string_of_typ t ^ " : " ^ (match e with
    SLiteral(l) -> string_of_int l
  | SBoolLit(true) -> "true"
  | SBoolLit(false) -> "false"
  | SFliteral(l) -> l
  | SStrLit(l) -> l
  | SArrVal(arr) -> "[" ^ String.concat ", " (List.map string_of_sexpr arr) ^ "]"
  | SCharLit(c) -> String.make 1 c
  | SId(s) -> s
  | SSlice(n, lst) -> n ^ String.concat "" (List.map (fun (a,b) -> "[" ^ string_of_int a ^ ":" ^ string_of_int b ^ "]") lst)
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
  | SSliceAssign(v, lst, e) -> v ^ String.concat "" (List.map (fun (a,b) -> "[" ^ string_of_int a ^ ":" ^ string_of_int b ^ "]") lst)
    ^ " = " ^ string_of_sexpr e
  | SCall(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SNoexpr -> ""
          ) ^ ")"
and
 string_of_s1dmat = function mat1d -> "[" ^ (String.concat ", " (List.map string_of_sexpr mat1d)) ^ "]" and
 string_of_s2dmat = function mat2d -> "[" ^ String.concat ", " (List.map string_of_s1dmat mat2d) ^ "]" and
 string_of_sarr = function mat3d -> "[" ^ String.concat ", " (List.map string_of_s2dmat mat3d) ^ "]"   


let string_of_svdecl (ty, id, e) = match e with
  | (_,SNoexpr) -> string_of_typ ty ^ " " ^ id ^ ";\n"
  | _ -> string_of_typ ty ^ " " ^ id ^ " = " ^ string_of_sexpr e ^ "\n"

let rec string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sbody stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  | SIf(e, s, SBlock([])) ->
      "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SFor(e1, e2, e3, s) ->
      "for (" ^ string_of_sexpr e1  ^ " ; " ^ string_of_sexpr e2 ^ " ; " ^
      string_of_sexpr e3  ^ ") " ^ string_of_sstmt s
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s
and
 string_of_sbody = function
  | SDcl(d) -> string_of_svdecl d
  | SStmt(st) -> string_of_sstmt st

let string_of_sformals (ty, id, e) = match e with
  | (_,SNoexpr) -> string_of_typ ty ^ " " ^ id ^ ", "
  | _ -> string_of_typ ty ^ " " ^ id ^ " = " ^ string_of_sexpr e ^ " "

let string_of_sfdecl fdecl =
  string_of_typ fdecl.styp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map string_of_sformals fdecl.sformals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_sbody fdecl.sbody) ^
  "}\n"

let string_of_sprogram lst =
  let helper str = function
    | SGlobaldcl(dcl) -> str ^ string_of_svdecl dcl
    | SFunc(f) -> str ^ string_of_sfdecl f
  in
  List.fold_left helper "" lst