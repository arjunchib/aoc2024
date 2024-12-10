import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

const example1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const example2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn main() {
  let assert 161 = part1(example1)
  let assert 48 = part2(example2)
  let assert Ok(input) = read(from: "./input/day3.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(with: re, content: input)
  |> list.map(mul)
  |> int.sum
}

fn part2(input) {
  let assert Ok(re) =
    regexp.from_string("mul\\((\\d+),(\\d+)\\)|don't\\(\\)|do\\(\\)")
  regexp.scan(with: re, content: input) |> part2_sum(True, 0)
}

fn part2_sum(matches: List(regexp.Match), enabled, sum) {
  case matches {
    [hd, ..rest] ->
      case hd.content {
        "do()" -> part2_sum(rest, True, sum)
        "don't()" -> part2_sum(rest, False, sum)
        _ if enabled -> part2_sum(rest, enabled, mul(hd) + sum)
        _ -> part2_sum(rest, enabled, sum)
      }
    [] -> sum
  }
}

fn mul(match: regexp.Match) {
  case match.submatches {
    [Some(x), Some(y)] -> {
      let x = result.unwrap(int.parse(x), 1)
      let y = result.unwrap(int.parse(y), 1)
      x * y
    }
    _ -> panic
  }
}
