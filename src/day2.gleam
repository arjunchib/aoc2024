import gleam/int
import gleam/io
import gleam/list
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

type Direction {
  Increasing
  Decreasing
  Neutral
}

pub fn main() {
  let assert 2 = part1(example)
  let assert Ok(input) = read(from: "./input/day2.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
}

pub fn part1(input: String) {
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
    |> list.window_by_2
    |> safe_report(Neutral)
  })
}

fn safe_report(list, dir) {
  case list {
    [#(a, b), ..rest] ->
      case dir {
        Increasing | Neutral if a < b ->
          safe_dist(b - a) && safe_report(rest, Increasing)
        Decreasing | Neutral if a > b ->
          safe_dist(a - b) && safe_report(rest, Decreasing)
        _ -> False
      }
    [] -> True
  }
}

fn safe_dist(diff) {
  diff >= 1 && diff <= 3
}
