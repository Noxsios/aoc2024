import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")
  let lists =
    in
    |> string.split("\n")
    |> list.map(fn(a) {
      let row = string.split(a, " ")
      let assert Ok(to_int) = row |> list.map(int.parse) |> result.all
      to_int
    })

  // part 1
  lists
  |> list.map(is_safe)
  |> list.count(fn(a) { a == True })
  |> io.debug
}

fn is_safe(l: List(Int)) -> Bool {
  // levels are either ALL increasing/decreasing
  // any 2 adjacent levels differ by at least 1 and at most 3

  l
  |> list.window(2)
  |> list.all(fn(w) {
    let assert Ok(left) = list.first(w)
    let assert Ok(right) = list.last(w)

    let diff = right - left

    case diff {
      -3 -> True && good_direction(l)
      -2 -> True && good_direction(l)
      -1 -> True && good_direction(l)
      0 -> False
      1 -> True && good_direction(l)
      2 -> True && good_direction(l)
      3 -> True && good_direction(l)
      _ -> False
    }
  })
}

fn good_direction(l: List(Int)) -> Bool {
  let pairs = l |> list.window(2)
  let cmp =
    pairs
    |> list.map(fn(m) {
      let assert Ok(left) = list.first(m)
      let assert Ok(right) = list.last(m)

      int.compare(right, left)
    })

  let assert Ok(first) = list.first(cmp)

  first != order.Eq && cmp |> list.all(fn(o) { o == first })
}
