
let rec print_1d_list = function 
[] -> ()
| e::l -> print_int e ; print_string " " ; print_1d_list l;;

let rec print_2d_list = function 
[] -> ()
| e::l -> print_1d_list e ; print_string " " ; print_2d_list l;;

let bind_mat_val idname matval = 
  let get_len mat_nd = if (List.length mat_nd) <> 1 then List.length mat_nd else -1  in
  (* check if dimensions are same *)
  let rec get_child_elements mat_nd ele_list = 
    List.fold_left (fun x y -> x @ y) [] mat_nd in

  let rec check_equal array fst_dim = 
    if List.length array > 1 then 
      if List.length (List.hd array) = fst_dim then check_equal (List.tl array) fst_dim
      else raise(Failure("dimension check failure"))
    else 
      if List.length (List.hd array) = fst_dim then ()
      else raise(Failure("dimension check failure")) in

  let get_dim mat_3d = 
    check_equal mat_3d (List.length (List.hd mat_3d));
    let dim3 = get_len mat_3d in  
    let array_2d = mat_3d in
    (* print_2d_list array_2d; *)
    check_equal array_2d (List.length (List.hd array_2d));
    let dim2 = get_len (List.hd array_2d) in
    let array_1d = get_child_elements array_2d [] in
    (* print_1d_list (List.hd array_1d); *)
    check_equal array_1d (List.length (List.hd array_1d));
    let dim1 = get_len (List.hd array_1d) in
    (dim3, dim2, dim1) in

  (idname, get_dim matval, matval) ;;


  let t1 = [[[1;2]]] ;;
  let t2 = [[[1;2;3]; [4;5;6]]] ;;
  let t3 = [[[1;2]; [3;4]]; [[5;6];[7;8]]] ;;

  let f1 =  [[[1;2];[3;4;5;6]]];; 
  let f2 = [ [[1;2];[3;4;5;6]]; [[1]] ];;
  (* let f2 = [[[1]];[[3];[4]];[[2]] in *)
  let print_dim1 dim = print_int ((fun (fst, _, _) -> fst) dim);;
  let print_dim2 dim = print_int ((fun (_, snd, _) -> snd) dim);;
  let print_dim3 dim = print_int ((fun (_, _, trd) -> trd) dim);;

  let (_, dim, _) = bind_mat_val "valname" t2;;
  print_dim1 dim;;
  print_dim2 dim;;
  print_dim3 dim;;
  (* bind_mat_val "valname" t2;; *)
  (* bind_mat_val "valname" t3;; *)
  (* bind_mat_val "valname" f1;; *)
  bind_mat_val "valname" f2;;
  print_string "finished check"