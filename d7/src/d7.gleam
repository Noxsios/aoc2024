import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")
  let lines = in |> string.split("\n")

  let equations =
    lines
    |> list.map(fn(l) {
      l
      |> string.split_once(":")
      |> result.unwrap(#("", ""))
      |> pair.map_first(string.trim)
      |> pair.map_first(fn(s) {
        let assert Ok(want) = int.parse(s)
        want
      })
      |> pair.map_second(string.trim)
      |> pair.map_second(fn(s) {
        string.replace(s, " ", "//") |> string.split("/")
      })
      |> pair.map_second(fn(args) { fill_blanks(args) })
    })

  list.map(equations, fn(equation) {
    let #(want, arg_combos) = equation

    let is_satisfied =
      list.any(arg_combos, fn(args) {
        let assert Ok(start) =
          args |> list.first |> result.unwrap("") |> int.parse
        let got = eval(list.drop(args, 1), start)
        got == want
      })

    case is_satisfied {
      True -> want
      False -> 0
    }
  })
  |> list.fold(0, int.add)
  |> io.debug
}

fn eval(args, acc) {
  let next = list.take(args, 2)

  case next {
    [] -> acc
    _ -> {
      let assert Ok(op) = list.first(next)
      let assert Ok(n2) = list.last(next) |> result.unwrap("") |> int.parse

      let result = case op {
        "*" -> int.multiply(acc, n2)
        "+" -> int.add(acc, n2)
        "||" -> {
          let assert Ok(s) =
            { int.to_string(acc) <> int.to_string(n2) } |> int.parse
          s
        }
        _ -> panic as "never should happen"
      }

      eval(list.drop(args, 2), result)
    }
  }
}

fn fill_blanks(args) {
  let empty_positions =
    list.index_map(args, fn(x, i) { #(x, i) })
    |> list.filter(fn(xi) {
      case xi {
        #("", _) -> True
        _ -> False
      }
    })
  case list.is_empty(empty_positions) {
    True -> [args]
    False -> {
      let assert Ok(i) = list.first(empty_positions)
      let i = i |> pair.second

      let with_plus =
        list.index_map(args, fn(c, k) {
          case k == i {
            True -> "+"
            False -> c
          }
        })

      let with_star =
        list.index_map(args, fn(c, k) {
          case k == i {
            True -> "*"
            False -> c
          }
        })

      let with_concat =
        list.index_map(args, fn(c, k) {
          case k == i {
            True -> "||"
            False -> c
          }
        })

      list.flat_map([with_plus, with_star, with_concat], fn(a) {
        fill_blanks(a)
      })
    }
  }
}
