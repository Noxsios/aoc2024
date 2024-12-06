import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import gleam/yielder
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")
  let assert Ok(parts) = in |> string.split_once("\n\n")
  let rules =
    parts
    |> pair.first
    |> string.split("\n")
    |> list.map(fn(r) {
      let assert Ok(declaration) = string.split_once(r, "|")
      let assert Ok(before) = int.parse(declaration |> pair.first)
      let assert Ok(after) = int.parse(declaration |> pair.second)
      #(before, after)
    })
  let sets =
    parts
    |> pair.second
    |> string.split("\n")
    |> list.map(string.split(_, ","))
    |> list.map(fn(nums) {
      let assert Ok(int_arr) = nums |> list.map(int.parse) |> result.all
      int_arr
    })

  let validate_all = fn(page_set) {
    rules
    |> list.all(validate_rule(page_set, _))
  }

  sets
  |> list.filter(validate_all)
  |> list.fold(0, fn(acc, l) {
    let len = l |> list.length
    let assert Ok(middle) = yielder.from_list(l) |> yielder.at(len / 2)

    acc + middle
  }) |> io.debug
}

fn validate_rule(l, r) {
  // io.debug(l)
  // io.debug(r)

  let indexed = list.index_map(l, fn(v, i) { #(i, v) })

  let first_indices =
    indexed
    |> list.filter(fn(p) { pair.second(p) == pair.first(r) })

  let second_indices =
    indexed
    |> list.filter(fn(p) { pair.second(p) == pair.second(r) })

  list.is_empty(first_indices)
  || list.is_empty(second_indices)
  || first_indices
  |> list.all(fn(f) {
    list.all(second_indices, fn(s) { pair.first(f) < pair.first(s) })
  })
}
