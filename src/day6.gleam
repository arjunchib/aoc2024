import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
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
    visited: dict.Dict(#(Int, Int), set.Set(Direction)),
    max_row: Int,
    max_col: Int,
    paradox: set.Set(#(Int, Int)),
  )
}

pub fn main() {
  let assert 41 = part1(example)
  let assert 6 = part2(example)
  let assert Ok(input) = read(from: "./input/day6.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let state = input |> init_state |> walk
  state.visited |> dict.size
}

pub fn part2(input) {
  let state = input |> init_state |> walk
  state.paradox |> set.size
}

fn init_state(input) {
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
  WalkState(occupied, guard, North, dict.new(), max_row, max_col, set.new())
}

fn walk(state: State) {
  case state.guard {
    #(r, c) if r <= state.max_row && c <= state.max_col && r >= 0 && c >= 0 -> {
      let next_loc = state |> straight1
      let visited =
        state.visited
        |> dict.upsert(state.guard, add_set(state.dir))
      let state = case state.occupied |> set.contains(next_loc) {
        True -> WalkState(..state, dir: turn(state.dir))
        False -> {
          let occupied = state.occupied |> set.insert(next_loc)
          case
            next_loc.0 <= state.max_row
            && next_loc.1 <= state.max_col
            && next_loc.0 >= 0
            && next_loc.1 >= 0
            && visited |> dict.has_key(next_loc) |> bool.negate
          {
            True ->
              case in_a_loop(WalkState(..state, occupied: occupied)) {
                True ->
                  WalkState(
                    ..state,
                    guard: next_loc,
                    paradox: state.paradox |> set.insert(next_loc),
                  )
                False -> WalkState(..state, guard: next_loc)
              }
            False -> WalkState(..state, guard: next_loc)
          }
        }
      }
      let state = WalkState(..state, visited: visited)
      walk(state)
    }
    _ -> state
  }
}

fn in_a_loop(state: State) {
  case state.guard {
    #(r, c) if r <= state.max_row && c <= state.max_col && r >= 0 && c >= 0 -> {
      let dir_set = result.unwrap(state.visited |> dict.get(#(r, c)), set.new())
      case dir_set |> set.contains(state.dir) {
        True -> True
        False -> {
          let visited =
            state.visited
            |> dict.upsert(state.guard, add_set(state.dir))
          let state = WalkState(..state, visited: visited)
          let next_loc = state |> straight1
          let state = case state.occupied |> set.contains(next_loc) {
            True -> WalkState(..state, dir: turn(state.dir))
            False -> WalkState(..state, guard: next_loc)
          }
          in_a_loop(state)
        }
      }
    }
    _ -> False
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

fn straight1(state: State) {
  let #(r, c) = state.guard
  case state.dir {
    North -> #(r - 1, c)
    East -> #(r, c + 1)
    South -> #(r + 1, c)
    West -> #(r, c - 1)
  }
}

fn add_set(dir) {
  fn(x) { x |> option.unwrap(set.new()) |> set.insert(dir) }
}
