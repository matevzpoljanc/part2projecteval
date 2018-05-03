(* let graph = [0;9;2;1;8;4;7];
6;0;1;5;2;8;7];
6;1;0;6;8;4;4];
2;3;3;0;4;3;8];
2;4;6;5;0;4;2];
8;1;1;9;8;0;6];
1;1;7;9;2;1;0];]
             *)
let generate_graph ~range n = 
        let open Core_kernel in
        List.to_array @@ List.init n (fun i -> List.to_array @@ List.init n (fun j -> if j = i then 0 else 1 + (Random.int range)))

let graph = generate_graph ~range:10 8

let add_traffic l amount =
    (* Leave distance to itself unchanged and add random amount to other connections *)
    List.map (fun x -> if x = 0 then x else x + Random.int amount) l

let ins_all_positions x l =
  let rec aux prev acc = function
    | [] -> (prev @ [x]) :: acc |> List.rev
    | hd::tl as l -> aux (prev @ [hd]) ((prev @ [x] @ l) :: acc) tl
  in
  aux [] [] l
  
let rec permutations = function
  | [] -> []
  | x::[] -> [[x]] (* we must specify this edge case *)
  | x::xs -> List.fold_left (fun acc p -> acc @ ins_all_positions x p ) [] (permutations xs)

    
let generate_paths permutations g =
    let open Core_kernel in
    permutations @@ List.range 0 @@ Array.length g

let rec path_length graph = function
    | [] -> 0
    | [x] -> 0
    | x0::x1::xs -> Array.get (Array.get graph x0) x1 + path_length graph (x1::xs)

let travelling_salesman g perm =
    let paths = generate_paths perm g in
    let (_, shortest_path) = 
        List.fold_left 
            (fun (x,sp) p -> 
                let p_length = path_length g p in
                if p_length < x then (p_length,p) else (x,sp))
            ((Int32.to_int Int32.max_int), []) 
            paths in
    shortest_path

let string_of_int_list l = 
    String.concat ";" @@ List.map (string_of_int) l;;

let test1 config ~n = 
    let perm = RememberMe.memoize (RememberMe.IrminFs config) permutations in
    ignore @@ travelling_salesman (generate_graph ~range:4 n) perm



