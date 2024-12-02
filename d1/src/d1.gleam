import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")
  let lists =
    in
    |> string.split("\n")
    |> list.map(fn(a) { string.split(a, "   ") })

  let assert Ok(left) = list.map(lists, list.first) |> result.all
  let assert Ok(right) = list.map(lists, list.last) |> result.all

  let assert Ok(ordered_left) = left |> list.map(int.parse) |> result.all
  let assert Ok(ordered_right) = right |> list.map(int.parse) |> result.all

  // part 1
  list.map2(
    ordered_left |> list.sort(int.compare),
    ordered_right |> list.sort(int.compare),
    fn(l, r) { int.absolute_value(l - r) },
  )
  |> list.fold(0, int.add)
  |> io.debug

  // part 2
  ordered_left
  |> list.map(fn(l) { list.count(ordered_right, fn(r) { l == r }) * l })
  |> list.fold(0, int.add)
  |> io.debug
}
