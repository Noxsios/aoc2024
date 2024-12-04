import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/queue
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")
  let lines = in |> string.split("\n")

  // io.debug(lines)

  let equals_xmas = fn(l) {
    l == ["X", "M", "A", "S"] || l == ["S", "A", "M", "X"]
  }

  let count_xmas_in_matrix = fn(m) {
    m
    |> list.map(list.window(_, 4))
    |> list.map(list.count(_, equals_xmas))
    |> list.fold(0, int.add)
  }

  // horizontal + backwards
  lines
  |> list.map(string.split(_, ""))
  |> count_xmas_in_matrix
  |> io.debug
  
  // vertical + backwards
  let cols = lines |> list.first |> result.unwrap("") |> string.length
  list.range(0, cols - 1)
  |> list.map(fn(idx) { list.map(lines, fn(l) { string.slice(l, idx, 1) }) })
  |> count_xmas_in_matrix
  |> io.debug

  // diagonal + backwards
}
