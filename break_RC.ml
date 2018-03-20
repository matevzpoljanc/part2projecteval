open ReactiveCaml


let x = make_variable 10
let y = map x (fun x -> 100 / x)
let b = map x ~f:(fun x -> x=0)
let n0 = if_then_else b ~if_true:(make_variable 0) ~if_false:y
