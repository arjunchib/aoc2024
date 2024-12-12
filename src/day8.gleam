import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import simplifile.{read}

const example = "
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"

pub fn main() {
  let assert 14 = part1(example)
  let assert 34 = part2(example)
  let assert Ok(input) = read(from: "./input/day8.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let #(antennas, rows, cols) = input |> parse_input

  antennas
  |> dict.fold(set.new(), fn(acc, _k, v) {
    let antinodes =
      set.from_list(
        v |> permutations2 |> list.filter_map(find_antinode(_, rows, cols)),
      )
    acc |> set.union(antinodes)
  })
  |> set.size
}

pub fn part2(input) {
  let #(antennas, rows, cols) = input |> parse_input

  antennas
  |> dict.fold(set.new(), fn(acc, _k, v) {
    let antinodes =
      v
      |> permutations2
      |> list.fold(acc, fn(acc, a) {
        find_antinodes(a, rows, cols) |> set.union(acc)
      })
    acc |> set.union(antinodes)
  })
  |> set.size
}

fn parse_input(input) {
  let #(antennas, rows, cols) =
    input
    |> string.trim
    |> string.to_graphemes
    |> list.fold(#(dict.new(), 0, 0), fn(acc, a) {
      let #(antennas, r, c) = acc
      case a {
        "\n" -> #(antennas, r + 1, 0)
        "." -> #(antennas, r, c + 1)
        _ -> {
          let antennas =
            antennas
            |> dict.upsert(a, fn(x) {
              case x {
                Some(rest) -> [#(r, c), ..rest]
                None -> [#(r, c)]
              }
            })
          #(antennas, r, c + 1)
        }
      }
    })
  #(antennas, rows, cols - 1)
}

fn permutations2(a) {
  a
  |> list.flat_map(fn(x) {
    a
    |> set.from_list
    |> set.delete(x)
    |> set.to_list
    |> list.map(fn(y) { #(x, y) })
  })
}

fn find_antinode(a: #(#(Int, Int), #(Int, Int)), rows, cols) {
  let #(n1, n2) = a
  let #(r1, c1) = n1
  let #(r2, c2) = n2
  let dr = r2 - r1
  let dc = c2 - c1
  let r = r1 - dr
  let c = c1 - dc
  case r >= 0 && c >= 0 && r <= rows && c <= cols {
    True -> Ok(#(r, c))
    False -> Error(Nil)
  }
}

fn find_antinodes(a: #(#(Int, Int), #(Int, Int)), rows, cols) {
  let #(n1, n2) = a
  let #(r1, c1) = n1
  let #(r2, c2) = n2
  let dr = r2 - r1
  let dc = c2 - c1
  find_antinodes_loop(r2, c2, dr, dc, rows, cols)
}

fn find_antinodes_loop(r, c, dr, dc, rows, cols) {
  let r = r - dr
  let c = c - dc
  case r >= 0 && c >= 0 && r <= rows && c <= cols {
    True -> find_antinodes_loop(r, c, dr, dc, rows, cols) |> set.insert(#(r, c))
    False -> set.new()
  }
}
