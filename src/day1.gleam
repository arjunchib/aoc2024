import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{read}

const example = "
3   4
4   3
2   5
1   3
3   9
3   3
"

pub fn main() {
  let assert Ok(input) = read(from: "./input/day1.txt")
  let assert 31 = part2(example)
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part2(input: String) {
  let coords =
    input
    |> string.split("\n")
    |> list.filter_map(fn(line) { line |> string.split_once("   ") })
    |> list.map(fn(coord) {
      let #(x, y) = coord
      let assert Ok(x) = int.parse(x)
      let assert Ok(y) = int.parse(y)
      #(x, y)
    })

  let left_list = coords |> list.map(fn(coord) { coord.0 })
  let right_list = coords |> list.map(fn(coord) { coord.1 })

  let lookup_table =
    right_list
    |> list.fold(dict.new(), fn(d, a) { dict.upsert(d, a, increment) })

  left_list
  |> list.map(fn(a) {
    let count = result.unwrap(lookup_table |> dict.get(a), 0)
    count * a
  })
  |> int.sum
}

fn increment(x) {
  case x {
    Some(i) -> i + 1
    None -> 1
  }
}
