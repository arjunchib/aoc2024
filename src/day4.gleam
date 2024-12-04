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
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"

pub fn main() {
  let assert 18 = part1(example)
  // let assert 48 = part2(example2)
  let assert Ok(input) = read(from: "./input/day4.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  // part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let #(num_rows, num_cols, matrix, x_set) =
    input |> string.trim |> make_matrix(0, 0, dict.new(), set.new())

  let check_fns = [
    // right
    check(#(0, 1), #(0, 2), #(0, 3)),
    // left
    check(#(0, -1), #(0, -2), #(0, -3)),
    // up
    check(#(-1, 0), #(-2, 0), #(-3, 0)),
    // down
    check(#(1, 0), #(2, 0), #(3, 0)),
    // down right
    check(#(1, 1), #(2, 2), #(3, 3)),
    // down left
    check(#(1, -1), #(2, -2), #(3, -3)),
    // up right
    check(#(-1, 1), #(-2, 2), #(-3, 3)),
    // up left
    check(#(-1, -1), #(-2, -2), #(-3, -3)),
  ]

  set.fold(x_set, 0, fn(acc, coord) {
    let #(row, col) = coord
    acc + list.count(check_fns, fn(check_fn) { check_fn(matrix, row, col) })
  })
}

fn make_matrix(str, row, col, matrix, x_set) {
  case str |> string.pop_grapheme {
    Ok(#(hd, rest)) ->
      case hd {
        "\n" -> make_matrix(rest, row + 1, 0, matrix, x_set)
        "X" ->
          make_matrix(
            rest,
            row,
            col + 1,
            matrix |> dict.insert(#(row, col), hd),
            x_set |> set.insert(#(row, col)),
          )
        _ ->
          make_matrix(
            rest,
            row,
            col + 1,
            matrix |> dict.insert(#(row, col), hd),
            x_set,
          )
      }
    // undo last col increment
    Error(Nil) -> #(row, col - 1, matrix, x_set)
  }
}

fn check(m_offset: #(Int, Int), a_offset: #(Int, Int), s_offset: #(Int, Int)) {
  fn(matrix, row, col) {
    let m1 = matrix |> dict.get(#(row + m_offset.0, col + m_offset.1))
    let m2 = matrix |> dict.get(#(row + a_offset.0, col + a_offset.1))
    let m3 = matrix |> dict.get(#(row + s_offset.0, col + s_offset.1))
    case m1, m2, m3 {
      Ok(m1), Ok(m2), Ok(m3) -> m1 == "M" && m2 == "A" && m3 == "S"
      _, _, _ -> False
    }
  }
}
