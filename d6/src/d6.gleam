import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")
  let rows = in |> string.split("\n")
  let coords =
    rows
    |> list.index_map(fn(row, i) {
      row
      |> string.split("")
      |> list.index_map(fn(c, j) { #(j + 1, string.length(row) - i, c) })
    })
    |> list.flatten

  let start =
    coords
    |> list.find(fn(coord) {
      let #(_, _, d) = coord

      d == "^"
    })
    |> result.unwrap(#(0, 0, ""))

  walk(coords, [start], start, "up")
  |> list.unique
  |> io.debug
  |> list.length
  |> io.debug
}

fn walk(
  coords,
  route,
  start: #(Int, Int, String),
  direction,
) -> List(#(Int, Int, String)) {
  let at = fn(x, y) {
    list.find(coords, fn(coord: #(Int, Int, String)) {
      x == coord.0 && y == coord.1
    })
    |> result.unwrap(#(0, 0, ""))
  }

  let next = case direction {
    "up" -> at(start.0, start.1 + 1)
    "down" -> at(start.0, start.1 - 1)
    "left" -> at(start.0 - 1, start.1)
    "right" -> at(start.0 + 1, start.1)
    _ -> panic as "should never hit"
  }

  let next_direction = case direction {
    "up" -> "right"
    "right" -> "down"
    "down" -> "left"
    "left" -> "up"
    _ -> panic as "should never hit"
  }

  case
    // oob
    next == #(0, 0, "")
  {
    True -> route
    False ->
      case next.2 == "#" {
        True ->
          walk(coords, [start, ..route] |> list.reverse, start, next_direction)
        False -> walk(coords, [next, ..route] |> list.reverse, next, direction)
      }
  }
}
