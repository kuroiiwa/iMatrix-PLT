(* Top-level of the MicroC compiler: scan & parse the input,
   check the resulting AST and generate an SAST from it, generate LLVM IR,
   and dump the module *)
open Printf
open Lexing

type action = Ast | Sast | LLVM_IR | Compile

let print_position outx (lexbuf, fn) =
  let pos = lexbuf.lex_curr_p in
  let str = lexeme lexbuf in
    fprintf outx "%s:character \"%s\" at line %d" fn str pos.pos_lnum

let () =
  let action = ref Compile in
  let set_action a () = action := a in
  let speclist = [
    ("-a", Arg.Unit (set_action Ast), "Print the AST");
    ("-s", Arg.Unit (set_action Sast), "Print the SAST");
    ("-l", Arg.Unit (set_action LLVM_IR), "Print the generated LLVM IR");
    ("-c", Arg.Unit (set_action Compile),
      "Check and print the generated LLVM IR (default)");
  ] in
  let usage_msg = "usage: ./microc.native [-a|-s|-l|-c] [file.mc]" in
  let channel = ref stdin in
  Arg.parse speclist (fun filename -> channel := open_in filename) usage_msg;

  let rec parse_ast file fn =
    let lexbuf = Lexing.from_channel file in
    let (files, ast_main) =
      try
        Microcparse.program Scanner.token lexbuf
      with
        | Parsing.Parse_error ->
          fprintf stderr "%a: syntax error\n" print_position (lexbuf, fn);
          exit (-1)
        | exn -> raise exn
    in
      let parse_file l fn =
         let buf = open_in fn in
         l @ parse_ast buf fn in
      let include_asts = List.fold_left parse_file [] files in
    include_asts @ ast_main
  in
  let ast = parse_ast !channel "main" in
  match !action with
    Ast -> print_string (Ast.string_of_program ast)
  | _ -> let sast = Semant.check ast in
    match !action with
      Ast     -> ()
    | Sast    -> print_string (Sast.string_of_sprogram sast)
    | LLVM_IR -> print_string (Llvm.string_of_llmodule (Codegen.translate sast))
    | Compile -> let m = Codegen.translate sast in
  Llvm_analysis.assert_valid_module m;
  print_string (Llvm.string_of_llmodule m)
