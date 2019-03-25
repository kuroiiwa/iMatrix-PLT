/* Ocamlyacc parser for MicroC */

%{
open Ast

let bind_dcl = fun data_type variable_name expr -> CommonBind(data_type, variable_name, (-1, -1, -1), expr)
let bind_mat_img = let fst3tuple = function (fst, _, _) -> fst in
                   let snd3tuple = function (_, snd, _) -> snd in 
                   let trd3tuple = function (_, _, trd) -> trd in
                   fun data_type variable_name dimension -> 
                    match data_type with 
                    | Mat -> MatBind(data_type, variable_name, (fst3tuple dimension, snd3tuple dimension, trd3tuple dimension))
                    | Img -> ImgBind(data_type, variable_name, (fst3tuple dimension, snd3tuple dimension, trd3tuple dimension))
                    | _ -> raise (Failure("Given type does not match MAT / IMG"))
%}

%token LPAREN RPAREN /* LBRACK RBRACK */ LBRACE RBRACE
%token SEMI COMMA DOT
%token PLUS MINUS TIMES DIVIDE MODULO POWER /*SELFPLUS SELFMINUS*/ /* MATMUL  */
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
  | typ ID ASSIGN expr       { [bind_dcl $1 $2 $4] }
  | typ ID LPAREN dimension RPAREN { [bind_mat_img $1 $2 $4] }
  | formal_list COMMA typ ID { (bind_dcl $3 $4 Noexpr) :: $1 }
  | formal_list COMMA typ ID ASSIGN expr { (bind_dcl $3 $4 $6) :: $1 }
  | formal_list COMMA typ ID LPAREN dimension RPAREN { (bind_mat_img $3 $4 $6) :: $1 }

typ:
    INT   { Int   }
  | BOOL  { Bool  }
  | FLOAT { Float }
  | CHAR  { Char }
  | STRING { String }
  | MAT   { Mat }
  | IMG   { Img }
  | VOID  { Void  }

func_body_list:
    /* nothing */ { [] }
  | func_body_list stmt  { Stmt($2) :: $1 }
  | func_body_list vdecl { Dcl($2) :: $1 }

vdecl:
    typ ID SEMI { bind_dcl $1 $2 Noexpr }
  | typ ID ASSIGN expr SEMI  { bind_dcl $1 $2 $4 }
  | typ ID LPAREN dimension RPAREN SEMI {bind_mat_img $1 $2 $4}

dimension:
    expr                          { (Literal(-1), Literal(-1), $1) }
  | expr COMMA expr               { (Literal(-1), $1, $3) }
  | expr COMMA expr COMMA expr    { ($1, $3, $5) }

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
  | ID               { Id($1)                 }
 /* | ID DOT ID        { Getattr ($1, $3)}    */    /* get attribute */
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr MODULO expr { Binop($1, Mod,   $3)   }
  | expr POWER  expr { Binop($1, Pow,   $3)   }
  /* | SELFPLUS expr     { Binop($2, Selfplus)} */
  /* | SELFMINUS expr    { Binop($2, Selfminus)} */
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
