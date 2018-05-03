open Core

(*let graph = [
    [2;5;6];
    [1;3;8];
    [2;4];
    [3;5];
    [1;4];
    [1;7];
    [6;8];
    [7;2]
    (*
    [8;10;18]; [9;11;3]; [10;12;19]; [11;13;4]; [12;14;20]; [13;15;5]; [14;6;16]; [20;17;15]; [16;18;7]; [17;19;9]; 
    [18;20;11]; [19;16;13]
    *)
]
*)
let graph n = Travelling_salesman.generate_graph ~range:2 n

let array_of_list graph = List.to_array @@ List.map ~f:(List.to_array) graph

let ins_all_positions x l =
  let rec aux prev acc = function
    | [] -> (prev @ [x]) :: acc |> List.rev
    | hd::tl as l -> aux (prev @ [hd]) ((prev @ [x] @ l) :: acc) tl
  in
  aux [] [] l
  
let rec permutations = function
  | [] -> []
  | x::[] -> [[x]] (* we must specify this edge case *)
  | x::xs -> List.fold_left ~f:(fun acc p -> acc @ ins_all_positions x p ) ~init:[] (permutations xs)

let memoized_permutations backend = RememberMe.memoize backend permutations

let path_possible_between_nodes (graph: int Core.Array.t Core.Array.t) i j =
     not (graph.(i).(j) = 0)

let path_possible_in_graph graph path = 
    let intermediate = List.mapi path ~f:(fun i el -> 
        if i+1 < List.length path then 
            path_possible_between_nodes graph el (List.nth_exn path (i+1)) 
        else 
            true) in
    List.fold ~init:true ~f:(fun acc el -> acc && el) intermediate

let number_of_hamiltonian_paths graph perm = 
    let possible_paths = perm @@ List.range 0 @@ Array.length graph in
    List.fold ~init:0 ~f:(fun acc el -> if el then acc+1 else acc) @@ 
        List.map possible_paths ~f:(fun path -> path_possible_in_graph graph path)

let test1 config ~n = 
    let perm = memoized_permutations (RememberMe.IrminFs config) in
    ignore @@ number_of_hamiltonian_paths (graph n) perm

