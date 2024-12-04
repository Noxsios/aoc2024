import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(in) = simplifile.read(from: "./input.txt")
  let lines = in |> string.split("\n")

  let equals_xmas = fn(l) {
    l == ["X", "M", "A", "S"] || l == ["S", "A", "M", "X"]
  }

  let count_xmas_in_matrix = fn(m) {
    m
    |> list.map(list.window(_, 4))
    |> list.map(list.count(_, equals_xmas))
    |> list.fold(0, int.add)
  }

  let rows = list.length(lines)
  let cols = lines |> list.first |> result.unwrap("") |> string.length

  let get_coord = fn(grid, x, y) {
    grid
    |> list.index_map(fn(row, idx) {
      case idx == y {
        True -> string.slice(row, x, 1)
        False -> ""
      }
    })
    |> string.join("")
  }

  let extract_sequence = fn(grid, r, c, direction) {
    case direction {
      "horizontal" -> {
        case c + 3 < cols {
          True -> [
            get_coord(grid, c, r),
            get_coord(grid, c + 1, r),
            get_coord(grid, c + 2, r),
            get_coord(grid, c + 3, r),
          ]
          False -> []
        }
      }
      "vertical" -> {
        case r + 3 < rows {
          True -> [
            get_coord(grid, c, r),
            get_coord(grid, c, r + 1),
            get_coord(grid, c, r + 2),
            get_coord(grid, c, r + 3),
          ]
          False -> []
        }
      }
      "diag_right" -> {
        case { r + 3 < rows } && { c + 3 < cols } {
          True -> [
            get_coord(grid, c, r),
            get_coord(grid, c + 1, r + 1),
            get_coord(grid, c + 2, r + 2),
            get_coord(grid, c + 3, r + 3),
          ]
          False -> []
        }
      }
      "diag_left" -> {
        case { r + 3 < rows } && { c - 3 >= 0 } {
          True -> [
            get_coord(grid, c, r),
            get_coord(grid, c - 1, r + 1),
            get_coord(grid, c - 2, r + 2),
            get_coord(grid, c - 3, r + 3),
          ]
          False -> []
        }
      }
      _ -> []
    }
  }

  let directions = ["horizontal", "vertical", "diag_right", "diag_left"]

  list.flat_map(directions, fn(direction) {
    list.flat_map(list.range(0, rows - 1), fn(r) {
      list.map(list.range(0, cols - 1), fn(c) {
        extract_sequence(lines, r, c, direction)
      })
    })
  })
  |> count_xmas_in_matrix
  |> io.debug

  // part 2
  let extract_sequence = fn(grid, r, c) {
    case
      { { r + 2 < rows } && { c + 2 < cols } }
      || { { r + 2 < rows } && { c - 2 >= 0 } }
    {
      True -> [
        // TL
        get_coord(grid, c, r),
        // TR
        get_coord(grid, c + 2, r),
        // M
        get_coord(grid, c + 1, r + 1),
        // BR
        get_coord(grid, c, r + 2),
        // BL
        get_coord(grid, c + 2, r + 2),
      ]
      False -> []
    }
  }

  let count_xmas_in_matrix = fn(m) {
    m
    |> list.count(fn(l) {
      l == ["M", "S", "A", "M", "S"]
      || l == ["S", "S", "A", "M", "M"]
      || l == ["S", "M", "A", "S", "M"]
      || l == ["M", "M", "A", "S", "S"]
    })
  }

  list.flat_map(list.range(0, rows - 1), fn(r) {
    list.map(list.range(0, cols - 1), fn(c) { extract_sequence(lines, r, c) })
  })
  |> count_xmas_in_matrix
  |> io.debug
}
