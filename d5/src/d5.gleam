import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")

  parse_memory(in)

  cleanup_memory(in)
}

fn cleanup_memory(mem) {
  let assert Ok(to_remove) = regexp.from_string("don't\\(\\)[\\s\\S]*?do\\(\\)")

  let assert Ok(ending_to_remove) = regexp.from_string("don't\\(\\)[\\s\\S]*?$")

  to_remove
  |> regexp.replace(mem, "")
  |> regexp.replace(ending_to_remove, _, "")
  |> parse_memory
}

fn parse_memory(mem) {
  let assert Ok(re) = regexp.from_string("(mul\\((\\d*,\\d*)\\))")

  regexp.scan(re, mem)
  |> list.map(fn(m) { m.submatches })
  |> list.map(fn(s) {
    let assert Ok(last) = s |> list.last
    last
  })
  |> list.map(fn(o) {
    option.lazy_unwrap(o, fn() {
      io.print_error("error parsing")
      ""
    })
  })
  |> list.map(fn(s) {
    let assert Ok(args) =
      string.split(s, ",") |> list.map(int.parse) |> result.all
    args |> list.fold(1, int.multiply)
  })
  |> list.fold(0, int.add)
  |> io.debug
}

fn get_coord(grid, x, y) {
  grid
  |> list.index_map(fn(row, idx) {
    case idx == y - 1 {
      True -> {
        string.slice(row, x - 1, 1)
      }
      False -> ""
    }
  })
  |> string.join("")
}