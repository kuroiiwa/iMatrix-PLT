/* Ocamlyacc parser for MicroC */

%{
open Ast

let bind_arr_dcl_noexpr t id dim = match t,dim with
  | _,(0,0,0) -> raise(Failure("array declartion without initialization should have specific dimension"))
  | t,(0,0,a) when a > 0 -> (Array(t,a), id, Noexpr)
  | t,(0,a,b) when a > 0 && b > 0 -> (Array(Array(t,b),a), id, Noexpr)
  | t,(a,b,c) when a > 0 && b > 0 && c > 0 -> (Array(Array(Array(t,c),b),a), id, Noexpr)
  | _ -> raise(Failure("dimension error"))

let bind_arr_dcl_expr t id dim e = match t,dim with
  | Mat,_ | Img,_ -> raise(Failure("matrix and image should have initialization"))
  | _,(0,0,0) -> (Array(t, 0), id, e) (* canary value here *)
  | _,(0,0,a) when a > 0 -> (Array(t,a), id, e)
  | _,(0,a,b) when a > 0 && b > 0 -> (Array(Array(t,b),a), id, e)
  | _,(a,b,c) when a > 0 && b > 0 && c > 0 -> (Array(Array(Array(t,c),b),a), id, e)
  | _ -> raise(Failure("dimension error"))

let bind_dcl ty id e = (ty, id, e)

let bind_arr_mat_img typ id (e1, e2) dim =
  let rec gen_list l name (e1,e2) n =
    if n = 0 then l
    else gen_list (Call(name, [e1 ; e2]) :: l) name (e1,e2) (n-1)
  in match typ,dim with
  | Mat,(0,0,a) -> (Array(Mat, a), id, let lst = gen_list [] "malloc_mat" (e1,e2) a in Arr1Val(lst))
  | Img,(0,0,a) -> (Array(Img, a), id, let lst = gen_list [] "malloc_img" (e1,e2) a in Arr1Val(lst))
  | _ -> raise(Failure("struct does not have initialization"))

let bind_mat_img typ id (e1, e2) = match typ with
  | Mat -> (Mat, id, Call("malloc_mat", [e1 ; e2]))
  | Img -> (Img, id, Call("malloc_img", [e1 ; e2]))
  | _ -> raise(Failure("struct does not have initialization"))

let bind_list typ id_l = List.map (fun id -> Dcl(typ, id, Noexpr)) id_l

let bind_glb_list typ id_l = List.map (fun id -> Globaldcl(typ, id, Noexpr)) id_l

%}


%token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE INCLUDE
%token SEMI COMMA DOT COLON
%token PLUS MINUS TIMES DIVIDE MODULO POWER SELFPLUS SELFMINUS MATMUL QUOTE
%token ASSIGN
%token EQ NEQ LT LEQ GT GEQ AND OR NOT
%token IF ELSE FOR WHILE RETURN
%token INT BOOL FLOAT CHAR STRING MAT IMG VOID STRUCT
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
%left QUOTE
%right NOT                        /* precedence level: 14 */
%left DOT
%nonassoc SELFPLUS SELFMINUS      /* precedence level: 15 */

%%

program:
  program_opt EOF { $1 }

program_opt:
  | /* nothing */ { ([],[]) }
  | includes decls{ (List.rev $1, List.rev $2) }
  | decls         { ([], List.rev $1)}

includes:
 | INCLUDE STRLIT       { [$2] }
 | includes INCLUDE STRLIT { $3 :: $1 }

decls:
 | vdecl {[Globaldcl($1)]}
 | fdecl {[Func($1)]}
 | fdecl_bodyless {[Func_dcl($1)]}
 | struct_dcl {[Struct_dcl($1)]}
 | typ id_list SEMI { bind_glb_list $1 $2 }
 | decls vdecl { Globaldcl($2) :: $1 }
 | decls fdecl { Func($2) :: $1 }
 | decls fdecl_bodyless { Func_dcl($2) :: $1 }
 | decls struct_dcl {Struct_dcl($2) :: $1 }


struct_dcl:
  STRUCT ID LBRACE struct_list RBRACE SEMI
  {{
    name = $2;
    member_list = List.rev $4;
  }}

struct_list:
  | struct_mem    { [$1] }
  | struct_list struct_mem { $2 :: $1 }

struct_mem:
  | typ ID SEMI { let (t,id,_) = bind_dcl $1 $2 Noexpr in (t, id)}
  | typ ID LBRACK dim_opt RBRACK SEMI { let (t,id,_) =  bind_arr_dcl_noexpr $1 $2 $4 in (t,id)}


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
  | typ ID LBRACK dimension RBRACK { [bind_arr_dcl_noexpr $1 $2 $4] }
  | formal_list COMMA typ ID { (bind_dcl $3 $4 Noexpr) :: $1 }
  | formal_list COMMA typ ID LBRACK dimension RBRACK { (bind_arr_dcl_noexpr $3 $4 $6) :: $1 }

typ:
    INT   { Int   }
  | BOOL  { Bool  }
  | FLOAT { Float }
  | CHAR  { Char }
  | STRING { String }
  | VOID  { Void  }
  | MAT   { Mat }
  | IMG   { Img }
  | STRUCT ID { Struct($2, []) }

id_list:
  | ID { [$1] }
  | id_list COMMA ID { $3 :: $1 }

func_body_list:
    /* nothing */ { [] }
  | func_body_list stmt  { Stmt($2) :: $1 }
  | func_body_list vdecl { Dcl($2) :: $1 }
  | func_body_list typ id_list SEMI { (bind_list $2 $3) @ $1 }

stmt_list:
  | /* nothing */ { [] }
  | stmt_list stmt { Stmt($2) :: $1 }

vdecl:
  | typ ID ASSIGN expr SEMI  { bind_dcl $1 $2 $4 }
  | typ ID LBRACK dim_opt RBRACK SEMI { bind_arr_dcl_noexpr $1 $2 $4 }
  | typ ID LBRACK dim_opt RBRACK ASSIGN expr SEMI { bind_arr_dcl_expr $1 $2 $4 $7}
  | typ ID LPAREN expr COMMA expr RPAREN LBRACK dimension RBRACK SEMI { bind_arr_mat_img $1 $2 ($4, $6) $9}
  | typ ID LPAREN expr COMMA expr RPAREN SEMI { bind_mat_img $1 $2 ($4, $6) }


dim_opt:
  |             { (0, 0, 0)}
  | dimension   { $1}

dimension:
  | LITERAL                          { (0, 0, $1) }
  | LITERAL COMMA LITERAL               { (0, $1, $3) }
  | LITERAL COMMA LITERAL COMMA LITERAL    { ($1, $3, $5) }

stmt:
    expr SEMI                               { Expr $1               }
  | RETURN expr_opt SEMI                    { Return $2             }
  | LBRACE stmt_list RBRACE                 { Block(List.rev $2)    }
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
  | arr_1d           { Arr1Val($1)           }
  | arr_2d           { Arr2Val($1)           }
  | arr_3d           { Arr3Val($1)           }
  | ID               { Id($1)                 }
  | ID slice_opt        { Slice($1, $2)    }
  | struct_member_opt    { $1      }
  | struct_member_opt ASSIGN expr { StructAssign($1, $3)}
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr MODULO expr { Binop($1, Mod,   $3)   }
  | expr POWER  expr { Binop($1, Pow,   $3)   }
  | SELFPLUS ID      { Assign($2, Binop(Id($2), Add, Literal(1))) }
  | SELFMINUS ID     { Assign($2, Binop(Id($2), Sub, Literal(1))) }
  | expr MATMUL expr { Binop($1, Matmul,   $3)}
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
  | expr QUOTE       { Unop(Transpose, $1)    }
  | ID ASSIGN expr   { Assign($1, $3)         }
  | ID slice_opt ASSIGN expr { SliceAssign($1, $2, $4) }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN expr RPAREN { $2                   }

/*
lamb_expr:
  | LPAREN lamb_ret_typ LPAREN formals_opt RPAREN LBRACE func_body_list RBRACE RPAREN {  }

lamb_ret_typ:
    LITERAL          { Literal($1)            }
  | FLIT             { Fliteral($1)           }
  | BLIT             { BoolLit($1)            }
  | STRLIT           { StrLit($1)             }
  | CHARLIT          { CharLit($1)            } */


struct_member_opt:
  | struct_member DOT struct_member     { GetMember($1, $3)      }
  | struct_member_opt DOT struct_member { GetMember($1, $3)      }

struct_member:
  | ID             { Id($1)           }
  | ID slice_opt   { Slice($1, $2)    }

args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr { $3 :: $1 }

slice_opt:
  | slice   { [$1] }
  | slice slice  { $1 :: [$2] }
  | slice slice slice {$1 :: $2 :: [$3] }

slice:
  | LBRACK ID RBRACK                    { (Id($2), Id($2)) }
  | LBRACK LITERAL RBRACK               { (Literal($2), Literal($2)) }
  | LBRACK LITERAL COLON LITERAL RBRACK { (Literal($2), Literal($4)) }
  | LBRACK COLON LITERAL RBRACK         { (Literal(-1), Literal($3)) }
  | LBRACK LITERAL COLON RBRACK         { (Literal($2), Literal(-1)) }
  | LBRACK COLON RBRACK                 { (Literal(-1), Literal(-1)) }

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
  | ID slice_opt        { Slice($1, $2)    }
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
  | ID LPAREN args_opt RPAREN { Call($1, $3)  } /* might need to be forbidden */
  | LPAREN arr_ele RPAREN { $2                   }


