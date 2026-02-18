(*
  Print.ml
  Printing helpers
*)

(* -------- generic helpers -------- *)

let print_list (print_elem : 'a -> unit) (xs : 'a list) : unit =
  print_char '[';
  let rec loop = function
    | [] -> ()
    | [x] -> print_elem x
    | x :: tl ->
        print_elem x;
        print_string "; ";
        loop tl
  in
  loop xs;
  print_char ']'
;;

let println_list (print_elem : 'a -> unit) (xs : 'a list) : unit =
  print_list print_elem xs;
  print_char '\n'
;;

(* -------- element printers -------- *)

let printi  = print_int;;
let printf  = print_float;;
let prints  = print_string;;
let printc  = print_char;;

let printb (b : bool) : unit =
  print_string (string_of_bool b)
;;

(* -------- println element printers -------- *)

let printlni (x : int) : unit =
  printi x;
  print_char '\n'
;;

let printlnf (x : float) : unit =
  printf x;
  print_char '\n'
;;

let printlns (x : string) : unit =
  prints x;
  print_char '\n'
;;

let printlnc (x : char) : unit =
  printc x;
  print_char '\n'
;;

let printlnb (x : bool) : unit =
  printb x;
  print_char '\n'
;;

(* -------- list printers -------- *)

let print_ints xs = print_list printi xs;;
let println_ints xs = println_list printi xs;;

let print_floats xs = print_list printf xs;;
let println_floats xs = println_list printf xs;;

let print_strings xs = print_list prints xs;;
let println_strings xs = println_list prints xs;;

let print_bools xs = print_list printb xs;;
let println_bools xs = println_list printb xs;;

let print_chars xs = print_list printc xs;;
let println_chars xs = println_list printc xs;;
