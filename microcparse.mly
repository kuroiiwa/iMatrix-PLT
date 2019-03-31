/* Ocamlyacc parser for MicroC */

%{
open Ast


let bind_dcl data_type variable_name expr =
    (* let check_list expr = 
      try let _ = (List.hd expr) in raise(Failure("Failure: assign array to common variable"))
      with Not_found -> () in *)
    match data_type with
    | Mat -> (data_type, variable_name, (-1,-1,-1), expr)
    | Img -> (data_type, variable_name, (-1,-1,-1), expr)
    | _ -> (* let _ = check_list expr in *) (data_type, variable_name, (-1,-1,-1), expr)


let fst3tuple = function (fst, _, _) -> fst 
let snd3tuple = function (_, snd, _) -> snd  
let trd3tuple = function (_, _, trd) -> trd 

let get_dimension mat dim_num = 
  let get_child_elements mat_nd = 
    List.fold_left (fun x y -> x @ y) [] mat_nd in

  let mat_3d = mat in
  let dim3 = List.length mat_3d in  
  let array_2d = mat_3d in
  let dim2 = List.length (List.hd array_2d) in
  let array_1d = get_child_elements array_2d in
  let dim1 = List.length (List.hd array_1d) in
  
  if dim_num = 3 then (dim3, dim2, dim1) 
  else begin
    if dim_num = 2 then
      (-1, dim2, dim1)
    else 
      (-1, -1, dim1)
  end

let create_zero_array dim = 
  let get_dim dim = if dim = -1 then 1 else dim in
  let dim1 = get_dim (fst3tuple dim) in
  let dim2 = get_dim (snd3tuple dim) in
  let dim3 = get_dim (trd3tuple dim) in

  let rec copy_arr arr ele_arr count = 
    if count = 1 then arr
    else copy_arr (arr @ ele_arr) ele_arr (count - 1) in

  let zero1d = copy_arr [Literal(0)] [Literal(0)] dim3 in
  let zero2d = copy_arr [zero1d] [zero1d] dim2 in
  let zero3d = copy_arr [zero2d] [zero2d] dim1 in zero3d

(* return the length of a ND array *)
let get_len mat_nd = List.length mat_nd 

(* given a dim tuple, return it's dimension number, e.g. (-1,1,2) -> 2 *)
let get_dim_num dim = if fst3tuple dim <> -1 then 3 else begin
                      if snd3tuple dim <> -1 then 2 else 1 end 

let bind_arr_dcl t id dim = 
  (t, id, dim, ArrVal(dim, create_zero_array dim))


let type_dim_check_match ty dim_num = 
  (* given image, only allow 3 dimension ;
     given matrix, only allow 1 or 2 dimension;
     other type, allow all dimensions *)
     match ty with
      | Img -> if dim_num <> 3 then raise(Failure("Image type can only be 3-dimensional"))
              else ()
      | Mat -> if dim_num = 3 then raise(Failure
                      ("Matrix type can only be 1-dimensional or 2-dimensional"))
              else ()
      | _ -> ()

let bind_arr_with_dim ty id dim arr_val dim_num = 
  let check_dim_num dim_num1 dim_num2 = if dim_num1 <> dim_num2 then
    raise(Failure("dimension check failure")) in
  (* check if dimensions are same *)
  let get_child_elements mat_nd = 
    List.fold_left (fun x y -> x @ y) [] mat_nd in

  let rec check_equal array fst_dim = 
    if List.length array > 1 then 
      if List.length (List.hd array) = fst_dim then check_equal (List.tl array) fst_dim
      else raise(Failure("dimension check failure"))
    else 
      if List.length (List.hd array) = fst_dim then ()
      else raise(Failure("dimension check failure")) in

  let check_dim mat mat_dim_num org_dim =
    let check_dim_corresp dim1  dim2 = 
    if get_dim_num dim1 <> get_dim_num dim2 then raise(Failure("dimension check failure"))
    else begin
      if fst3tuple dim1 <> fst3tuple dim2 then 
        raise(Failure("dimension check failure"))
      else begin
        if snd3tuple dim1 <> snd3tuple dim2 then
          raise(Failure("dimension check failure"))
        else begin
          if trd3tuple dim1 <> trd3tuple dim2 then
            raise(Failure("dimension check failure"))
          else () end
      end 
    end in

    let _ = check_dim_num mat_dim_num (get_dim_num org_dim) in
    let dim_num_inf = get_dim_num org_dim in
    let mat_3d = mat in
    let _ = check_equal mat_3d (List.length (List.hd mat_3d)) in
    let dim3 = get_len mat_3d in  
    let array_2d = mat_3d in
    let _ = check_equal array_2d (List.length (List.hd array_2d)) in
    let dim2 = get_len (List.hd array_2d) in
    let array_1d = get_child_elements array_2d in
    let _ = check_equal array_1d (List.length (List.hd array_1d)) in
    let dim1 = get_len (List.hd array_1d) in
    
    if dim_num_inf < 3 then let dim3 = -1 in
    if dim_num_inf < 2 then let dim2 = -1 in 
    let dim_inf = (dim3, dim2, dim1) in
    (* print_int dim1;
    print_int dim2;
    print_int dim3; *)
    check_dim_corresp dim_inf org_dim 
    in
  
  let _ = check_dim arr_val dim_num dim in
  type_dim_check_match ty dim_num;
  (ty, id, dim, ArrVal(dim, arr_val))

let rec check_equal array fst_dim = 
  (* check if every subarray has the same dimension, e.g.[[1],[1,2]] is not legal *)
  if List.length array > 1 then 
    if List.length (List.hd array) = fst_dim then check_equal (List.tl array) fst_dim
    else raise(Failure("dimension check failure"))
  else 
    if List.length (List.hd array) = fst_dim then ()
    else raise(Failure("dimension check failure")) 

let get_child_elements mat_nd = 
  (* given a higher order array, extract its children, 
     e.g. [[1,2,3],[4,5,6]] -> [1,2,3,4,5,6] *)
  List.fold_left (fun x y -> x @ y) [] mat_nd 

let infer_dim_3darr arr = 
  (* given a 3d array, infer it's dimension (include dimension check) *)
  let dim3 = get_len arr in  
  let array_2d = arr in
  check_equal array_2d (List.length (List.hd array_2d));
  let dim2 = get_len (List.hd array_2d) in
  let array_1d = get_child_elements array_2d in
  check_equal array_1d (List.length (List.hd array_1d));
  let dim1 = get_len (List.hd array_1d) in
  let dim = (dim3, dim2, dim1) in dim 

let infer_dim_2darr arr = 
  (* given a 2d array, infer it's dimension (include dimension check) *)
  let array_2d = arr in
  check_equal array_2d (List.length (List.hd array_2d));
  let dim2 = get_len array_2d in
  let array_1d = get_child_elements array_2d in
  let dim1 = get_len (List.hd array_2d) in
  let dim = (-1, dim2, dim1) in dim

let infer_dim_1darr arr = 
  (* given a 1d array, infer it's dimension (include dimension check) *)
  let array_1d = arr in
  let dim1 = get_len array_1d in
  let dim = (-1, -1, dim1) in dim

let bind_arr_without_dim ty id arr_val dim_inf = 
  (* given type, id, array value expression and infered dimension,
     return the corresponding 'bind' type (see 'bind' in 'ast.ml') *)
  type_dim_check_match ty (get_dim_num dim_inf);
  (ty, id, dim_inf , ArrVal(dim_inf, arr_val))  

%}


%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
%token SEMI COMMA DOT
%token PLUS MINUS TIMES DIVIDE MODULO POWER SELFPLUS SELFMINUS /* MATMUL  */
%token ASSIGN
%token EQ NEQ LT LEQ GT GEQ AND OR NOT
%token IF ELSE FOR WHILE /* BREAK CONTINUE */ RETURN
%token INT BOOL FLOAT CHAR STRING MAT IMG VOID /*STRUCT*/
%token TRUE FALSE

%token <int> LITERAL
%token <bool> BLIT
%token <string> ID FLIT STRLIT
%token <char> CHARLIT
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc ELSE
%right ASSIGN                     /* precedence level: 1 */
%left OR                          /* precedence level: 3 */
%left AND                         /* precedence level: 4 */
%left EQ NEQ                      /* precedence level: 8 */
%left LT GT LEQ GEQ               /* precedence level: 9 */
%left PLUS MINUS                  /* precedence level: 11 */
%left TIMES DIVIDE MODULO MATMUL POWER /* precedence level: 12 */
%right NOT                        /* precedence level: 14 */
%nonassoc SELFPLUS SELFMINUS      /* precedence level: 15 */

%%

program:
  decls EOF { List.rev $1 }

decls:
   /* nothing */ { []              }
 | decls vdecl { Globaldcl($2) :: $1 }
 | decls fdecl { Func($2) :: $1 }
 | decls fdecl_bodyless { Func_dcl($2) :: $1 }

fdecl_bodyless:
  typ ID LPAREN formals_opt RPAREN SEMI
     { { typ = $1;
   fname = $2;
   formals = List.rev $4;
   body = [] }}

fdecl:
   typ ID LPAREN formals_opt RPAREN LBRACE func_body_list RBRACE
     { { typ = $1;
	 fname = $2;
	 formals = List.rev $4;
	 body = List.rev $7 }}

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    typ ID                   { [bind_dcl $1 $2 Noexpr]     }
  | formal_list COMMA typ ID { (bind_dcl $3 $4 Noexpr) :: $1 }

typ:
    INT   { Int   }
  | BOOL  { Bool  }
  | FLOAT { Float }
  | CHAR  { Char }
  | STRING { String }
  | VOID  { Void  }
  | MAT   { Mat }
  | IMG   { Img }

func_body_list:
    /* nothing */ { [] }
  | func_body_list stmt  { Stmt($2) :: $1 }
  | func_body_list vdecl { Dcl($2) :: $1 }

vdecl:
    typ ID SEMI { bind_dcl $1 $2 Noexpr }
  | typ ID LBRACK dimension RBRACK SEMI { bind_arr_dcl $1 $2 $4 }
  | typ ID LBRACK RBRACK ASSIGN arr_1d SEMI { bind_arr_without_dim $1 $2 [[$6]] (infer_dim_1darr $6)  }
  | typ ID LBRACK RBRACK ASSIGN arr_2d SEMI { bind_arr_without_dim $1 $2 [$6] (infer_dim_2darr $6) }
  | typ ID LBRACK RBRACK ASSIGN arr_3d SEMI { bind_arr_without_dim $1 $2 $6 (infer_dim_3darr $6) }
  | typ ID LBRACK dimension RBRACK ASSIGN arr_1d SEMI { bind_arr_with_dim $1 $2 $4 [[$7]] 1 }
  | typ ID LBRACK dimension RBRACK ASSIGN arr_2d SEMI { bind_arr_with_dim $1 $2 $4 [$7] 2 }
  | typ ID LBRACK dimension RBRACK ASSIGN arr_3d SEMI { bind_arr_with_dim $1 $2 $4 $7 3 }
  /* | INT ID ASSIGN arr_opt SEMI  { raise(Failure("Assigning array to variables without dimension")) } */
  | typ ID ASSIGN expr SEMI  { bind_dcl $1 $2 $4 }

dim_opt:
  |             { (-1, -1, -1)}
  | dimension   { $1}

dimension:
  | LITERAL                          { (-1, -1, $1) }
  | LITERAL COMMA LITERAL               { (-1, $1, $3) }
  | LITERAL COMMA LITERAL COMMA LITERAL    { ($1, $3, $5) }

stmt:
    expr SEMI                               { Expr $1               }
  | RETURN expr_opt SEMI                    { Return $2             }
  | LBRACE func_body_list RBRACE                 { Block(List.rev $2)    }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7)        }
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
                                            { For($3, $5, $7, $9)   }
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5)         }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    LITERAL          { Literal($1)            }
  | FLIT	           { Fliteral($1)           }
  | BLIT             { BoolLit($1)            }
  | STRLIT           { StrLit($1)             }
  | CHARLIT          { CharLit($1)            }
  | arr_1d           { ArrVal((get_dimension [[$1]] 1), [[$1]])           }
  | arr_2d           { ArrVal(get_dimension [$1] 2, [$1])           }
  | arr_3d           { ArrVal(get_dimension $1 3, $1)           }
  | ID               { Id($1)                 }
 /* | ID DOT ID        { Getattr ($1, $3)}    */    /* get attribute */
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr MODULO expr { Binop($1, Mod,   $3)   }
  | expr POWER  expr { Binop($1, Pow,   $3)   }
  | SELFPLUS ID      { Assign($2, Binop(Id($2), Add, Literal(1))) }
  | SELFMINUS ID     { Assign($2, Binop(Id($2), Sub, Literal(1))) }
  /* | expr MATMUL expr { Binop($1, Matmul,   $3)   } */
  | expr EQ     expr { Binop($1, Equal, $3)   }
  | expr NEQ    expr { Binop($1, Neq,   $3)   }
  | expr LT     expr { Binop($1, Less,  $3)   }
  | expr LEQ    expr { Binop($1, Leq,   $3)   }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | TRUE             { BoolLit(true) }
  | FALSE            { BoolLit(false) }
  | MINUS expr %prec NOT { Unop(Neg, $2)      }
  | NOT expr         { Unop(Not, $2)          }
  | ID ASSIGN expr   { Assign($1, $3)         }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN expr RPAREN { $2                   }

args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr { $3 :: $1 }


arr_opt:
  | arr_1d        { [[$1]] }
  | arr_2d        { [$1] }
  | arr_3d        { $1 }

arr_3d:
  arr_3d_start RBRACK { List.rev $1 }

arr_3d_start:
    LBRACK arr_2d       { [$2] }
  | arr_3d_start COMMA arr_2d { $3 :: $1 }

arr_2d:
  arr_2d_start RBRACK { List.rev $1 }

arr_2d_start:
    LBRACK arr_1d       { [$2] }
  | arr_2d_start COMMA arr_1d { $3 :: $1 }

arr_1d:
  arr_1d_start RBRACK { List.rev $1}

arr_1d_start:
  | LBRACK arr_ele       { [$2] }
  | arr_1d_start COMMA arr_ele { $3::$1 }

arr_ele:
    LITERAL          { Literal($1)            }
  | FLIT             { Fliteral($1)           }
  | BLIT             { BoolLit($1)            }
  | STRLIT           { StrLit($1)             }
  | CHARLIT          { CharLit($1)            }
  | ID               { Id($1)                 }
  | arr_ele PLUS   arr_ele { Binop($1, Add,   $3)   }
  | arr_ele MINUS  arr_ele { Binop($1, Sub,   $3)   }
  | arr_ele TIMES  arr_ele { Binop($1, Mult,  $3)   }
  | arr_ele DIVIDE arr_ele { Binop($1, Div,   $3)   }
  | arr_ele MODULO arr_ele { Binop($1, Mod,   $3)   }
  | arr_ele POWER  arr_ele { Binop($1, Pow,   $3)   }
  | arr_ele EQ     arr_ele { Binop($1, Equal, $3)   }
  | arr_ele NEQ    arr_ele { Binop($1, Neq,   $3)   }
  | arr_ele LT     arr_ele { Binop($1, Less,  $3)   }
  | arr_ele LEQ    arr_ele { Binop($1, Leq,   $3)   }
  | arr_ele GT     arr_ele { Binop($1, Greater, $3) }
  | arr_ele GEQ    arr_ele { Binop($1, Geq,   $3)   }
  | arr_ele AND    arr_ele { Binop($1, And,   $3)   }
  | arr_ele OR     arr_ele { Binop($1, Or,    $3)   }
  | TRUE             { BoolLit(true) }
  | FALSE            { BoolLit(false) }
  | MINUS arr_ele %prec NOT { Unop(Neg, $2)      }
  | NOT arr_ele         { Unop(Not, $2)          }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN arr_ele RPAREN { $2                   }  