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
  let assert 9 = part2(example)
  let assert Ok(input) = read(from: "./input/day4.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let #(matrix, pivots) = input |> string.trim |> make_matrix(pivot: "X")

  let check_fns = [
    // right
    check1(#(0, 1), #(0, 2), #(0, 3)),
    // left
    check1(#(0, -1), #(0, -2), #(0, -3)),
    // up
    check1(#(-1, 0), #(-2, 0), #(-3, 0)),
    // down
    check1(#(1, 0), #(2, 0), #(3, 0)),
    // down right
    check1(#(1, 1), #(2, 2), #(3, 3)),
    // down left
    check1(#(1, -1), #(2, -2), #(3, -3)),
    // up right
    check1(#(-1, 1), #(-2, 2), #(-3, 3)),
    // up left
    check1(#(-1, -1), #(-2, -2), #(-3, -3)),
  ]

  set.fold(pivots, 0, fn(acc, coord) {
    acc + list.count(check_fns, passes_check(_, matrix, coord))
  })
}

pub fn part2(input) {
  let #(matrix, pivots) = input |> string.trim |> make_matrix(pivot: "A")

  let check_fns = [
    // down right
    check2(#(-1, -1), #(1, 1)),
    // down left
    check2(#(-1, 1), #(1, -1)),
    // up right
    check2(#(1, -1), #(-1, 1)),
    // up left
    check2(#(1, 1), #(-1, -1)),
  ]

  set.fold(pivots, 0, fn(acc, coord) {
    case check_fns |> list.count(passes_check(_, matrix, coord)) {
      2 -> acc + 1
      _ -> acc
    }
  })
}

fn make_matrix(str, pivot pivot) {
  make_matrix_loop(str, 0, 0, dict.new(), set.new(), pivot)
}

fn make_matrix_loop(str, row, col, matrix, pivots, pivot) {
  case str |> string.pop_grapheme {
    Ok(#(hd, rest)) ->
      case hd {
        "\n" -> make_matrix_loop(rest, row + 1, 0, matrix, pivots, pivot)
        hd if hd == pivot ->
          make_matrix_loop(
            rest,
            row,
            col + 1,
            matrix |> dict.insert(#(row, col), hd),
            pivots |> set.insert(#(row, col)),
            pivot,
          )
        _ ->
          make_matrix_loop(
            rest,
            row,
            col + 1,
            matrix |> dict.insert(#(row, col), hd),
            pivots,
            pivot,
          )
      }
    Error(Nil) -> #(matrix, pivots)
  }
}

fn passes_check(check_fn, matrix, coord) {
  let #(row, col) = coord
  check_fn(matrix, row, col)
}

fn check1(m_offset: #(Int, Int), a_offset: #(Int, Int), s_offset: #(Int, Int)) {
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

fn check2(m_offset: #(Int, Int), s_offset: #(Int, Int)) {
  fn(matrix, row, col) {
    let m1 = matrix |> dict.get(#(row + m_offset.0, col + m_offset.1))
    let m2 = matrix |> dict.get(#(row + s_offset.0, col + s_offset.1))
    case m1, m2 {
      Ok(m1), Ok(m2) -> m1 == "M" && m2 == "S"
      _, _ -> False
    }
  }
}
