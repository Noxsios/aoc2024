import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/pair
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
  let safe =
    lists
    |> list.map(is_safe)
    |> list.count(fn(a) { a == True })
    |> io.debug

  // part 2
  let known_unsafe = lists |> list.filter(fn(l) { !is_safe(l) })

  known_unsafe
  |> list.map(fn(u) {
    let len = list.length(u)
    let could =
      list.range(1, len)
      |> list.any(fn(i) {
        let before = list.take(u, i - 1)
        let after = list.drop(u, i)
        is_safe(list.append(before, after))
      })
    case could {
      True -> 1
      False -> 0
    }
  })
  |> list.fold(safe, int.add)
  |> io.debug
}

fn is_safe(in: List(Int)) -> Bool {
  // levels are either ALL increasing/decreasing
  // any 2 adjacent levels differ by at least 1 and at most 3

  in
  |> list.window_by_2
  |> list.all(fn(p) {
    let left = p |> pair.first
    let right = p |> pair.second

    let diff = right - left

    let gd = good_direction(in)

    case diff {
      -3 -> True && gd
      -2 -> True && gd
      -1 -> True && gd
      0 -> False
      1 -> True && gd
      2 -> True && gd
      3 -> True && gd
      _ -> False
    }
  })
}

fn good_direction(l: List(Int)) -> Bool {
  let cmp =
    list.window_by_2(l)
    |> list.map(fn(p) {
      let left = p |> pair.first
      let right = p |> pair.second

      int.compare(right, left)
    })

  let assert Ok(first) = list.first(cmp)

  first != order.Eq && cmp |> list.all(fn(o) { o == first })
}
