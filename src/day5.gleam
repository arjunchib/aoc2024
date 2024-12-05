import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import simplifile.{read}

const example = "
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"

pub fn main() {
  let assert 143 = part1(example)
  // let assert 9 = part2(example)
  let assert Ok(input) = read(from: "./input/day5.txt")
  part1(input) |> int.to_string |> string.append(to: "PART I - ") |> io.println
  // part2(input) |> int.to_string |> string.append(to: "PART II - ") |> io.println
}

pub fn part1(input) {
  let #(str1, str2) =
    input |> string.trim |> string.split_once("\n\n") |> force_unwrap

  let rules =
    str1
    |> string.split("\n")
    |> list.map(fn(rule) { rule |> string.split_once("|") |> force_unwrap })
    |> list.fold(dict.new(), fn(acc, rule) {
      let b1 = int.parse(rule.0) |> force_unwrap
      let b2 = int.parse(rule.1) |> force_unwrap
      let upsert_value = fn(x) {
        case x {
          Some(set) -> set |> set.insert(b2)
          None -> set.new() |> set.insert(b2)
        }
      }
      acc
      |> dict.upsert(b1, upsert_value)
    })

  let updates =
    str2
    |> string.split("\n")
    |> list.map(fn(update) {
      update |> string.split(",") |> list.filter_map(int.parse)
    })

  let valid_updates = updates |> list.filter(valid_update(_, rules))

  valid_updates
  |> list.map(fn(update) {
    let len = update |> list.length
    update |> list.drop(len / 2) |> list.first |> force_unwrap
  })
  |> int.sum
}

pub fn part2(input) {
  todo
}

fn valid_update(update, rules) {
  case update {
    [x, ..rest] ->
      rest
      |> list.all(fn(y) {
        case rules |> dict.get(y) {
          Ok(set) -> set |> set.contains(x) |> bool.negate
          _ -> True
        }
      })
      && valid_update(rest, rules)
    [] -> True
  }
}

fn force_unwrap(result) {
  case result {
    Ok(result) -> result
    _ -> panic
  }
}
