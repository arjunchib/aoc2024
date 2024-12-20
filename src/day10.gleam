import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

const example = "
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"

pub fn main() {
  let assert 36 = part1(example)
  let assert 81 = part2(example)
  let assert Ok(input) = read(from: "./input/day10.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let #(map, trailheads) = input |> parse_input
  trailheads |> list.map(fn(loc) { hike(0, loc, map) |> set.size }) |> int.sum
}

pub fn part2(input) {
  let #(map, trailheads) = input |> parse_input
  trailheads |> list.map(fn(loc) { hike2(0, loc, map) }) |> int.sum
}

fn parse_input(input) {
  let #(map, trailheads, _, _) =
    input
    |> string.trim
    |> string.to_graphemes
    |> list.fold(#(dict.new(), [], 0, 0), fn(acc, x) {
      let #(map, trailheads, r, c) = acc
      let map = case x {
        "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ->
          map |> dict.insert(#(r, c), x |> int.parse |> result.unwrap(-1))
        _ -> map
      }
      let trailheads = case x {
        "0" -> [#(r, c), ..trailheads]
        _ -> trailheads
      }
      case x {
        "\n" -> #(map, trailheads, r + 1, 0)
        _ -> #(map, trailheads, r, c + 1)
      }
    })
  #(map, trailheads)
}

fn hike(height, location: #(Int, Int), map) {
  case map |> dict.get(location) {
    Ok(h) if height == h && h == 9 -> {
      set.new() |> set.insert(location)
    }
    Ok(h) if height == h -> {
      let #(r, c) = location
      set.new()
      |> set.union(hike(height + 1, #(r, c + 1), map))
      |> set.union(hike(height + 1, #(r, c - 1), map))
      |> set.union(hike(height + 1, #(r + 1, c), map))
      |> set.union(hike(height + 1, #(r - 1, c), map))
    }
    _ -> set.new()
  }
}

fn hike2(height, location: #(Int, Int), map) {
  case map |> dict.get(location) {
    Ok(h) if height == h && h == 9 -> 1
    Ok(h) if height == h -> {
      let #(r, c) = location
      hike2(height + 1, #(r, c + 1), map)
      + hike2(height + 1, #(r, c - 1), map)
      + hike2(height + 1, #(r + 1, c), map)
      + hike2(height + 1, #(r - 1, c), map)
    }
    _ -> 0
  }
}
