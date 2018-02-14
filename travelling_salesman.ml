(* let graph = [[0;3;5;3;4];
             [2;0;4;1;1];
             [4;6;0;2;2];
             [2;3;7;0;3];
             [8;2;4;1;0]]
             *)
let generate_graph ~range n = 
        let open Core_kernel in
        List.to_list @@ List.init n (fun i -> List.to_list @@ List.init n (fun j -> if j = i then 0 else Random.int range))
let graph = generate_graph 8 10
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

    
let generate_paths g =
    let open Core_kernel in
    permutations @@ List.range 0 @@ List.length g

let rec path_length = function
    | [] -> 0
    | [x] -> 0
    | x0::x1::xs -> List.nth (List.nth graph x0) x1 + path_length (x1::xs)

let travelling_salesman g =
    let paths = generate_paths g in
    let (_, shortest_path) = 
        List.fold_left 
            (fun (x,sp) p -> 
                let p_length = path_length p in
                if p_length < x then (p_length,p) else (x,sp))
            ((Int32.to_int Int32.max_int), []) 
            paths in
    shortest_path
let string_of_int_list l = 
    String.concat ";" @@ List.map (string_of_int) l;;


