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
      |> list.index_map(fn(c, j) { #(j + 1, list.length(rows) - i, c) })
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
  |> list.reverse
  |> list.unique
  |> list.length
  |> io.debug

  coords
  |> list.filter(fn(coord) { coord.2 == "." })
  |> list.filter(fn(start) {
    let mutated =
      coords
      |> list.map(fn(coord) {
        case coord == start {
          True -> #(start.0, start.1, "#")
          False -> coord
        }
      })
    walk(mutated, [start], start, "up")
    |> list.reverse
    |> list.unique
    |> list.is_empty
  })
  |> list.length
  |> io.debug
}

fn walk(
  coords,
  route,
  curr: #(Int, Int, String),
  direction,
) -> List(#(Int, Int, String)) {
  let at = fn(x, y) {
    list.find(coords, fn(coord: #(Int, Int, String)) {
      x == coord.0 && y == coord.1
    })
    |> result.unwrap(#(0, 0, ""))
  }

  let next = case direction {
    "up" -> at(curr.0, curr.1 + 1)
    "down" -> at(curr.0, curr.1 - 1)
    "left" -> at(curr.0 - 1, curr.1)
    "right" -> at(curr.0 + 1, curr.1)
    _ -> panic as "should never hit"
  }

  let next_direction = case direction {
    "up" -> "right"
    "right" -> "down"
    "down" -> "left"
    "left" -> "up"
    _ -> panic as "should never hit"
  }

  let is_loop =
    route
    |> list.window_by_2
    |> list.contains(#(next, curr))

  case is_loop {
    True -> []
    // make this cleaner
    False -> {
      case
        // oob
        next == #(0, 0, "")
      {
        True -> route
        False ->
          case next.2 == "#" {
            True -> walk(coords, [curr, ..route], curr, next_direction)
            False -> walk(coords, [next, ..route], next, direction)
          }
      }
    }
  }
}
