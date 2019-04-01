/* Ocamlyacc parser for MicroC */

%{
open Ast

let bind_arr_dcl_noexpr t id dim = match t,dim with
  | _,(0,0,0) -> raise(Failure("array declartion without initialization should have specific dimension"))
  | Mat(_,_),(0,a,b) when a > 0 && b > 0 -> (Mat(a,b), id, Noexpr)
  | Img(_,_,_),(a,b,c) when a > 0 && b > 0 && c > 0 -> (Img(a,b,c), id, Noexpr)
  | Mat(_,_),_ | Img(_,_,_),_ -> raise(Failure("illegal matrix/image dimension"))
  | _,(0,0,a) when a > 0 -> (Array(t,a), id, Noexpr)
  | _,(0,a,b) when a > 0 && b > 0 -> (Array(Array(t,b),a), id, Noexpr)
  | _,(a,b,c) when a > 0 && b > 0 && c > 0 -> (Array(Array(Array(t,c),b),a), id, Noexpr)
  | _ -> raise(Failure("dimension error"))

let bind_arr_dcl_expr t id dim e = match t,dim with
  | Mat(_,_),(0,0,0) -> (t, id, e)
  | Img(_,_,_),(0,0,0) -> (t, id, e)
  | Mat(_,_),(0,a,b) when a > 0 && b > 0 -> (Mat(a,b), id, e)
  | Img(_,_,_),(a,b,c) when a > 0 && b > 0 && c > 0 -> (Img(a,b,c), id, e)
  | Mat(_,_),_ | Img(_,_,_),_ -> raise(Failure("illegal matrix/image dimension"))
  | _,(0,0,0) -> (Array(t, 0), id, e) (* canary value here *)
  | _,(0,0,a) when a > 0 -> (Array(t,a), id, e)
  | _,(0,a,b) when a > 0 && b > 0 -> (Array(Array(t,b),a), id, e)
  | _,(a,b,c) when a > 0 && b > 0 && c > 0 -> (Array(Array(Array(t,c),b),a), id, e)
  | _ -> raise(Failure("dimension error"))

let bind_dcl ty id e = match ty with
  | Mat(_) | Img(_) -> raise(Failure("array declartion without initialization should have specific dimension"))
  | _ -> (ty, id, e)

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
  | MAT   { Mat(0,0) }
  | IMG   { Img(0,0,0) }

func_body_list:
    /* nothing */ { [] }
  | func_body_list stmt  { Stmt($2) :: $1 }
  | func_body_list vdecl { Dcl($2) :: $1 }

vdecl:
    typ ID SEMI { bind_dcl $1 $2 Noexpr }
  | typ ID ASSIGN expr SEMI  { bind_dcl $1 $2 $4 }
  | typ ID LBRACK dim_opt RBRACK SEMI { bind_arr_dcl_noexpr $1 $2 $4 }
  | typ ID LBRACK dim_opt RBRACK ASSIGN expr SEMI { bind_arr_dcl_expr $1 $2 $4 $7}

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
  | arr_1d           { Arr1Val($1)           }
  | arr_2d           { Arr2Val($1)           }
  | arr_3d           { Arr3Val($1)           }
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
  | ID LPAREN args_opt RPAREN { Call($1, $3)  } /* might need to be forbidden */
  | LPAREN arr_ele RPAREN { $2                   }  


