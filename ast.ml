(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Pow | Selfplus | Selfminus| Equal | Neq | Less | Leq | Greater | Geq |
          And | Or

type uop = Neg | Not

type typ = Int | Bool | Float | Char | String | Void | Mat | Img

type arr_val = expr list list list

and expr =
    Literal of int
  | Fliteral of string
  | BoolLit of bool
  | StrLit of string
  | CharLit of char
  | ArrVal of arr_val
  | Id of string
  | Binop of expr * op * expr
 (* | Getattr of string * string *)
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list
  | Noexpr

type dim = int * int * int

type bind = typ * string * dim * expr


    (* Matrix -> failwith("should assign the size for matrix type") *)

type stmt =
    Block of func_body list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt
and func_body = Dcl of bind | Stmt of stmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    body : func_body list;
  }

type prog_element = Globaldcl of bind
                  | Func of func_decl
                  | Func_dcl of func_decl

type program = prog_element list




(* Pretty-printing functions *)

let fst3tuple = function (fst, _, _) -> fst 
let snd3tuple = function (_, snd, _) -> snd  
let trd3tuple = function (_, _, trd) -> trd 

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Pow -> "^"
  | Selfplus -> "++"
  | Selfminus -> "--"
 (* | Matmul -> "*." *)
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"


let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | Fliteral(l) -> l
  | StrLit(l) -> l
  | CharLit(c) -> String.make 1 c
  | ArrVal(arr)  -> string_of_arr arr
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
(*  | Getattr(e1, e2) ->
      e1 ^ "." ^ e2 *)
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""
and
 string_of_1dmat = function mat1d -> "[" ^ (String.concat ", " (List.map string_of_expr mat1d)) ^ "]" and
 string_of_2dmat = function mat2d -> "[" ^ String.concat ", " (List.map string_of_1dmat mat2d) ^ "]" and
 string_of_arr = function mat3d -> "[" ^ String.concat ", " (List.map string_of_2dmat mat3d) ^ "]" 

let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  | Char -> "char"
  | String -> "string"
  | Void -> "void"
  | Mat -> "mat"
  | Img -> "img"

let notMinusOne a = if a <> -1 then " " ^ string_of_int a else ""
let string_of_dim (a, b, c) = "[" ^ notMinusOne a ^ notMinusOne b ^ notMinusOne c ^ " ]"

let string_of_combind (t, id, expr) = match expr with
  | Noexpr -> string_of_typ t ^ " " ^ id ^ ";\n"
  | _ -> string_of_typ t ^ " " ^ id ^ " = "^ string_of_expr expr ^";\n"

let string_of_arrbind (ty, id, dim, arrv) = string_of_typ ty ^ " " ^ id ^
  string_of_dim dim ^ " = \n" ^ string_of_expr arrv ^ "\n"


let isCommon dim = if (fst3tuple dim) = -1 then begin
    if (snd3tuple dim) = -1 then begin
      if (trd3tuple dim) = -1 then true else false end
    else false end
  else false

let string_of_vdecl (t, id, dim, expr) = 
  if (isCommon dim) then string_of_combind (t, id, expr)
  else string_of_arrbind(t, id, dim, expr)

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_func_body stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s
and
 string_of_func_body = function
  | Dcl(d) -> string_of_vdecl d
  | Stmt(st) -> string_of_stmt st

let string_of_fcombind (t, id, _) = string_of_typ t ^ " " ^ id

let string_of_farrbind (ty, id, dim, _) = string_of_typ ty ^ " " ^ id ^
  string_of_dim dim


let string_of_formals (t, id, dim, expr) = 
  if (isCommon dim) then string_of_fcombind (t, id, expr)
  else string_of_farrbind (t, id, dim, expr)

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map string_of_formals fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_func_body fdecl.body) ^
  "}\n" 


let string_of_program lst = 
  let helper str = function
  | Globaldcl(dcl) -> str ^ string_of_vdecl dcl
  | Func(f) -> str ^ string_of_fdecl f
  | Func_dcl(f) -> str ^ string_of_fdecl f
  in
  List.fold_left helper "" lst 
