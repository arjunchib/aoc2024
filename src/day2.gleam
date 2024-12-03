import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import simplifile.{read}

const example = "
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"

pub fn main() {
  let assert 2 = part1(example)
  let assert 4 = part2(example)
  let assert Ok(input) = read(from: "./input/day2.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  total_safe_reports(input, False)
}

pub fn part2(input) {
  total_safe_reports(input, True)
}

fn total_safe_reports(input, do_over) {
  let reports =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(level) {
      level |> string.split(" ") |> list.filter_map(int.parse)
    })

  reports
  |> list.count(fn(levels) {
    levels
    |> safe_report(None, None, do_over)
    // |> io.debug
  })
}

fn safe_report(list, prev1, prev2, do_over) {
  // io.debug(#(list, prev1, prev2, do_over))
  safe_report_pick(list, prev1, prev2, do_over)
  || safe_report_skip(list, prev1, prev2, do_over)
}

fn safe_report_pick(list, prev1, prev2, do_over) {
  case list {
    [a, ..rest] ->
      safe_check(Some(a), prev1, prev2)
      && safe_report(rest, Some(a), prev1, do_over)
    [] -> True
  }
}

fn safe_report_skip(list, prev1, prev2, do_over) {
  case list, do_over {
    [_a, ..rest], True -> safe_report(rest, prev1, prev2, False)
    _, _ -> False
  }
}

fn safe_check(a, prev1, prev2) {
  case a, prev1, prev2 {
    Some(a), Some(prev1), Some(prev2) -> {
      let diff = int.absolute_value(a - prev1)
      let increasing = prev2 < prev1 && prev1 < a
      let decreasing = prev2 > prev1 && prev1 > a
      diff >= 1 && diff <= 3 && bool.or(increasing, decreasing)
    }
    Some(a), Some(prev1), None -> {
      let diff = int.absolute_value(a - prev1)
      diff >= 1 && diff <= 3
    }
    _, None, None -> True
    _, _, _ -> panic
  }
}
