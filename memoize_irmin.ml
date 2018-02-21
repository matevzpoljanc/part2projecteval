let new_function_id = Memoize.new_function_id

module IrminHashTbl = Memo_result.MemoResult

let (>>=) = Lwt.bind


let m = Lwt_main.run (IrminHashTbl.create ())

let memoize_irmin (type a) (type b) (f:a->b): a->b =
  let f_id = new_function_id () in
  let g x =
    Lwt_main.run @@ IrminHashTbl.find_or_add m (f_id,x) ~default:(fun () -> (f x)) in
  g
  ;;
let double = memoize_irmin (fun x -> x*2);;
let int_of_bool b = if b then 1 else 0;;

let m_int = memoize_irmin int_of_bool;;
let m_string_of_int = memoize_irmin string_of_int;; 

assert (double 1 = 2);
assert (m_int true = 1);
assert (double 4 = 8);
assert (m_string_of_int 1 = "1")