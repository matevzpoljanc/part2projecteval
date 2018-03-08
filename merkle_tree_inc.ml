open Core_kernel
open Incremental_lib

module Inc = Incremental.Make ()

module Var = Inc.Var

let node_count = ref 0
let hash = Hashtbl.hash
    (* let rec hashn n i h = if i = n then Hashtbl.hash h else hashn n (i+1) (Hashtbl.hash h) in
    hashn 100 1 (Hashtbl.hash a) *)

type 'a merkleTree = 
    | Leaf of 'a * int
    | Node of int * 'a merkleTree * 'a merkleTree


let create_leaf data = Var.create @@ Leaf(data, hash data)
let create_leaf_rc data = ReactiveCaml.make_variable @@ Leaf(data, hash data)
let connect_two_trees t1 t2 = Inc.map2 t1 t2 ~f:(fun x y -> match x with
                                                    | Node (x_hash, _, _) -> (match y with
                                                        | Leaf (_, y_hash) -> Node(hash (x_hash + y_hash) , x, y)
                                                        | Node (y_hash, _, _) -> Node(hash (x_hash + y_hash) , x, y))
                                                    | Leaf (_,x_hash) -> (match y with
                                                        | Leaf (_, y_hash) -> Node(hash (x_hash + y_hash) , x, y)
                                                        | Node (y_hash, _, _) -> Node(hash (x_hash + y_hash) , x, y))
                                                    )
let connect_two_trees_rc t1 t2 = ReactiveCaml.map2 t1 t2 ~f:(fun x y -> match x with
                                                    | Node (x_hash, _, _) -> (match y with
                                                        | Leaf (_, y_hash) -> Node(hash (x_hash + y_hash) , x, y)
                                                        | Node (y_hash, _, _) -> Node(hash (x_hash + y_hash) , x, y))
                                                    | Leaf (_,x_hash) -> (match y with
                                                        | Leaf (_, y_hash) -> Node(hash (x_hash + y_hash) , x, y)
                                                        | Node (y_hash, _, _) -> Node(hash (x_hash + y_hash) , x, y))
                                                    )

let used = ref false
let used_rc = ref false
let leaf0_value = Var.create (100)
let leaf0 = Inc.map (Var.watch leaf0_value) ~f:(fun x -> Leaf(x, hash x))
let leaf0_rc_value = ReactiveCaml.make_variable (100) 
let leaf0_rc = ReactiveCaml.map leaf0_rc_value ~f:(fun x -> Leaf(x, hash x))
let base_of_tree () = 
    if not !used then (
        used := true;
        connect_two_trees leaf0 (Var.watch (create_leaf @@ Random.int 10)) 
    )
    else
        connect_two_trees (Var.watch (create_leaf @@ Random.int 10)) (Var.watch (create_leaf @@ Random.int 10))

let base_of_tree_rc () =
    if not !used_rc then (
        used_rc := true;
        connect_two_trees_rc leaf0_rc (create_leaf_rc @@ Random.int 10) 
    )
    else
        connect_two_trees_rc (create_leaf_rc @@ Random.int 10) (create_leaf_rc @@ Random.int 10)

exception InvalidTreeHeight
let rec tree depth =
    if depth < 1 then
        raise InvalidTreeHeight
    else if depth = 1 then (incr node_count; base_of_tree ()) else connect_two_trees (tree (depth-1)) (tree (depth-1))
let rec tree_rc depth = 
    if depth < 1 then
        raise InvalidTreeHeight
    else if depth = 1 then (incr node_count; base_of_tree_rc ()) else connect_two_trees_rc (tree_rc (depth-1)) (tree_rc (depth-1))
let rec apply2 ~f l = 
    match l with
    | [] -> []
    | [x] -> raise @@ Invalid_argument "List is not of even length"
    | x::y::xs -> f x y :: apply2 ~f:f xs

let rec tree_of_var_list l =
    if List.length l = 1 then
        List.hd_exn l
    else
        tree_of_var_list @@ apply2 ~f:connect_two_trees l
let var_list l = List.map l ~f:(create_leaf)
let merkle_tree_from_list l =
    tree_of_var_list @@ List.map ~f:Var.watch l

let merkle_tree tree () = 
    let tree_obs = Inc.observe @@ tree in
    Inc.stabilize ();
    Inc.Observer.value_exn tree_obs

let print_top tree = 
    match tree with
    | Leaf (_, h) -> print_endline @@ string_of_int h
    | Node (h,_,_) -> print_endline @@ string_of_int h
let rec print_merkle_tree tree depth to_string =
    match tree with 
    | Leaf (data, h) -> print_endline @@ String.make depth '-' ^ (to_string data)
    | Node (h,lc, rc) -> print_endline @@ String.make depth '-' ^ (string_of_int h); 
                         print_merkle_tree lc (depth+1) to_string;
                         print_merkle_tree rc (depth+1) to_string

let eval merkle_tree () = print_merkle_tree (merkle_tree ()) 0 (string_of_int)