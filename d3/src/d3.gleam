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

  // let got =
  // "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
  // want mul(2,4) mul(5,5) mul(11,8)mul(8,5)

  // let assert Ok(re) = regexp.from_string("(mul\\(\\d*,\\d*\\))")
  let assert Ok(re) = regexp.from_string("(mul\\((\\d*,\\d*)\\))")

  regexp.scan(re, in)
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
