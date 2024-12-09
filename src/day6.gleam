import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

const example = "
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"

pub type Direction {
  North
  East
  South
  West
}

pub type State {
  WalkState(
    occupied: set.Set(#(Int, Int)),
    guard: #(Int, Int),
    dir: Direction,
    visited: set.Set(#(Int, Int)),
    max_row: Int,
    max_col: Int,
  )
}

pub fn main() {
  let assert 41 = part1(example)
  // let assert 9 = part2(example)
  let assert Ok(input) = read(from: "./input/day6.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  // part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let #(occupied, guard, r, c) =
    input
    |> string.trim
    |> string.to_graphemes
    |> list.fold(#(set.new(), #(0, 0), 0, 0), fn(acc, letter) {
      let #(occupied, guard, row, col) = acc
      case letter {
        "#" -> #(occupied |> set.insert(#(row, col)), guard, row, col + 1)
        "\n" -> #(occupied, guard, row + 1, 0)
        "^" -> #(occupied, #(row, col), row, col + 1)
        _ -> #(occupied, guard, row, col + 1)
      }
    })
  let max_row = r
  let max_col = c - 1

  let state =
    walk(WalkState(occupied, guard, North, set.new(), max_row, max_col))
  state.visited |> set.size
}

pub fn part2(input) {
  todo
}

fn walk(state: State) {
  case state.guard {
    #(r, c) if r <= state.max_row && c <= state.max_col && r >= 0 && c >= 0 -> {
      walk(move(
        WalkState(..state, visited: state.visited |> set.insert(state.guard)),
      ))
    }
    _ -> state
  }
}

fn turn(dir) {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn move(state: State) {
  let #(r, c) = state.guard
  let new_loc = case state.dir {
    North -> #(r - 1, c)
    East -> #(r, c + 1)
    South -> #(r + 1, c)
    West -> #(r, c - 1)
  }
  case state.occupied |> set.contains(new_loc) {
    True -> WalkState(..state, dir: turn(state.dir))
    False -> WalkState(..state, guard: new_loc)
  }
}
