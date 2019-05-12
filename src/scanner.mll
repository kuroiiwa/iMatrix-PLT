(* Ocamllex scanner for MicroC *)

{ open Microcparse
  open Lexing

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
 }

let digit = ['0' - '9']
let digits = digit+

rule token = parse
  [' ' '\t'] { token lexbuf } (* Whitespace *)
| [ '\r' '\n'] {next_line lexbuf; token lexbuf}
| "/*"     { comment lexbuf }           (* Comments *)
| "//"     { inlinecom lexbuf }
| "include" { INCLUDE }
| '('      { LPAREN }                   (* () [] {} *)
| ')'      { RPAREN }
| '['      { LBRACK }
| ']'      { RBRACK }
| '{'      { LBRACE }
| '}'      { RBRACE }
| ';'      { SEMI }                     (* split *)
| ','      { COMMA }
| ':'      { COLON }
| '.'      { DOT }
| '+'      { PLUS }                     (* arithmatic *)
| '-'      { MINUS }
| '*'      { TIMES }
| '/'      { DIVIDE }
| '%'      { MODULO }
| '^'      { POWER }
| "++" (['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm)  { SELFPLUS(lxm) }
| "--" (['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm)  { SELFMINUS(lxm) }
| (['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm) "++"  { SELFPLUS(lxm) }
| (['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm) "--"  { SELFMINUS(lxm) }
| ".*"     { MATMUL }
| '='      { ASSIGN }                   (* assign *)
| "=="     { EQ }                       (* logical *)
| "!="     { NEQ }
| '<'      { LT }
| '''      { QUOTE }
| "<="     { LEQ }
| ">"      { GT }
| ">="     { GEQ }
| "&&"     { AND }
| "||"     { OR }
| "!"      { NOT }
| "if"     { IF }                        (* conditional & loops *)
| "else"   { ELSE }
| "for"    { FOR }
| "while"  { WHILE }
| "return" { RETURN }
| "int"    { INT }                       (* data type *)
| "bool"   { BOOL }
| "float"  { FLOAT }
| "char"   { CHAR }
| "string" { STRING }
| "mat"    { MAT }
| "img"    { IMG }
| "void"   { VOID }
| "struct" { STRUCT }
| "true"   { BLIT(true)  }               (* bool *)
| "false"  { BLIT(false) }
| digits as lxm { LITERAL(int_of_string lxm) }  (* int *)
| digits '.'  digit* ( ['e' 'E'] ['+' '-']? digits )? as lxm { FLIT(lxm) }  (* float *)
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*     as lxm { ID(lxm) }    (* ID *)
| ''' (_ as ch) '''         { CHARLIT(ch)}
| '"' ([^ '"']* as str) '"'         { STRLIT(str) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }

and inlinecom = parse
    ['\r' '\n']           { token lexbuf }
  | _                     { inlinecom lexbuf}