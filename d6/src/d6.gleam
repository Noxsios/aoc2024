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

  // will cause division by 0 error if given an empty list
  let middle = fn(l) {
    l
    |> list.drop(l |> list.length |> int.divide(2) |> result.unwrap(0))
    |> list.first
    |> result.unwrap(0)
  }

  sets
  |> list.filter(validate_all)
  |> list.fold(0, fn(acc, l) { acc + middle(l) })
  |> io.debug

  // modified from https://dev.to/sethcalebweeks/advent-of-code-5-in-gleam-5h2f
  // because for the life of me i could not figure out how to write the correct fold sort algo in gleam
  // really interesting way to determine rules
  let ordering = fn(a, b) {
    let lt = list.contains(rules, #(a, b))
    let gt = list.contains(rules, #(b, a))
    // matrix cases? TIL
    case lt, gt {
      True, _ -> order.Lt
      _, True -> order.Gt
      _, _ -> order.Eq
    }
  }

  list.fold(sets, 0, fn(sum, update) {
    let sorted = list.sort(update, ordering)
    case sorted != update {
      True -> sum + middle(sorted)
      False -> sum
    }
  })
  |> io.debug
}

fn validate_rule(l, r) {
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
