(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Pow | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | Matmul

type uop = Neg | Not


type typ = Int | Bool | Float | Char | String | Void | Mat | Img | Array of arr_type | Struct of struct_type

and struct_type = string * ((typ * string) list)
and arr_type = typ * int


and arr3_val = expr list list list
and arr2_val = expr list list
and arr1_val = expr list
and expr =
    Literal of int
  | Fliteral of string
  | BoolLit of bool
  | StrLit of string
  | CharLit of char
  | Arr1Val of arr1_val
  | Arr2Val of arr2_val
  | Arr3Val of arr3_val
  | Slice of string * ((expr * expr) list)
  | Id of string
  | GetMember of expr * expr
  | StructAssign of expr * expr
  | Binop of expr * op * expr
 (* | Getattr of string * string *)
  | Unop of uop * expr
  | Assign of string * expr
  | SliceAssign of string * ((expr * expr) list) * expr
  | Call of string * expr list
  | Noexpr


and bind =  typ * string * expr

    (* Matrix -> failwith("should assign the size for matrix type") *)

type struct_decl = {
   name: string;
   member_list: (typ * string) list;
 }

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
                  | Struct_dcl of struct_decl

type program = prog_element list




(* Pretty-printing functions *)
let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Pow -> "^"
  | Matmul -> ".*"
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
  | Arr1Val(arr) -> string_of_1dmat arr
  | Arr2Val(arr) -> string_of_2dmat arr
  | Arr3Val(arr) -> string_of_arr arr
  | Slice(n, lst) -> n ^ String.concat "" (List.map (fun (a,b) -> "[" ^ string_of_expr a ^ ":" ^ string_of_expr b ^ "]") lst)
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | Id(s) -> s
  | GetMember(e1, e2) -> string_of_expr e1 ^ "." ^ string_of_expr e2
  | StructAssign(e1, e2) -> string_of_expr e1 ^ " = " ^ string_of_expr e2
  | Binop(e1, o, e2) -> 
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | SliceAssign(v, lst, e) -> v ^ String.concat "" (List.map (fun (a,b) -> "[" ^ string_of_expr a ^ ":" ^ string_of_expr b ^ "]") lst)
    ^ " = " ^ string_of_expr e
  | Call(f, el) -> 
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""
and
 string_of_1dmat = function mat1d -> "[" ^ String.concat ", " (List.map string_of_expr mat1d) ^ "]" and
 string_of_2dmat = function mat2d -> "[" ^ String.concat ", " (List.map string_of_1dmat mat2d) ^ "]" and
 string_of_arr = function mat3d -> "[" ^ String.concat ", " (List.map string_of_2dmat mat3d) ^ "]" 


let rec string_of_dim str  = function
  | Array(t,a) -> let new_str = str ^ "[" ^ string_of_int a ^ "]" in string_of_dim new_str t
  | _ as t -> string_of_typ t ^ str

and string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  | Char -> "char"
  | String -> "string"
  | Void -> "void"
  | Mat -> "mat"
  | Img -> "img"
  | Array(_, _) as arr -> string_of_dim "" arr 
  | Struct(n,_) -> "struct " ^ n

and string_of_typ_debug = function
    Int -> "int"
  | Bool -> "bool"
  | Float -> "float"
  | Char -> "char"
  | String -> "string"
  | Void -> "void"
  | Mat -> "mat"
  | Img -> "img"
  | Array(_, _) as arr -> string_of_dim "" arr 
  | Struct(n,l) -> "struct " ^ n ^ "\n" ^ String.concat " " (List.map (fun (ty, str) -> string_of_typ_debug ty ^ " " ^ str) l) ^ "\n"

let string_of_combind (t, id, expr) = match expr with
  | Noexpr -> string_of_typ t ^ " " ^ id ^ ";\n"
  | _ -> string_of_typ t ^ " " ^ id ^ " = "^ string_of_expr expr ^";\n"


let string_of_vdecl (ty, id, e) = match e with
  | Noexpr -> string_of_typ ty ^ " " ^ id ^ ";\n"
  | _ -> string_of_typ ty ^ " " ^ id ^ " = " ^ string_of_expr e ^ ";\n"

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

let string_of_formals (ty, id, e) = match e with
  | Noexpr -> string_of_typ ty ^ " " ^ id  ^ ", "
  | _ -> string_of_typ ty ^ " " ^ id ^ " = " ^ string_of_expr e ^ " "


let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map string_of_formals fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_func_body fdecl.body) ^
  "}\n" 

let string_of_struct sdecl =
   "struct " ^ sdecl.name ^ "{\n  " ^ String.concat "\n  " (List.map (fun (t,id) -> string_of_typ t ^ " " ^ id) sdecl.member_list) ^
   "\n}\n"

let string_of_program lst = 
  let helper str = function
  | Globaldcl(dcl) -> str ^ string_of_vdecl dcl
  | Func(f) -> str ^ string_of_fdecl f
  | Func_dcl(f) -> str ^ string_of_fdecl f
  | Struct_dcl(d) -> str ^ string_of_struct d
  in
  List.fold_left helper "" lst 
