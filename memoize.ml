open Core_kernel

let table1 = Hashtbl.Poly.create ()
let table2 = Hashtbl.Poly.create ()
let table3 = Hashtbl.Poly.create ()
let table4 = Hashtbl.Poly.create ()
let counter = ref 0
let new_function_id () = 
  let count= !counter in 
      counter := count + 1; count
let memoize (type a) (type b) (f : a -> b) : a -> b =
  let f_id = new_function_id () in
  let g x =
    let result = Hashtbl.find_or_add table1 (f_id, Obj.repr x) ~default:(fun () -> Obj.repr (f x)) in
    Obj.obj result
    in
  g
  ;;

let memoize2 (type a) (type b) (type c) (f : a -> b -> c) : a -> b -> c=
  let f_id = new_function_id () in
  let g x y=
    let result = Hashtbl.find_or_add table2 (f_id, Obj.repr x, Obj.repr y) ~default:(fun () -> Obj.repr (f x y)) in
    Obj.obj result
    in
  g
  ;;

let memoize3 (type a) (type b) (type c) (type d) (f : a -> b -> c -> d) : a -> b -> c -> d =
  let f_id = new_function_id () in
  let g x0 x1 x2 =
    let result = Hashtbl.find_or_add table3 (f_id, Obj.repr x0, Obj.repr x1, Obj.repr x2) ~default:(fun () -> Obj.repr (f x0 x1 x2)) in
    Obj.obj result
    in
  g
  ;;

let memoize4 (type a) (type b) (type c) (type d) (type e) (f : a -> b -> c -> d -> e) : a -> b -> c -> d -> e =
  let f_id = new_function_id () in
  let g x0 x1 x2 x3 =
    let result = Hashtbl.find_or_add table4 (f_id, Obj.repr x0, Obj.repr x1, Obj.repr x2, Obj.repr x3) ~default:(fun () -> Obj.repr (f x0 x1 x2 x3)) in
    Obj.obj result
    in
  g
  ;;